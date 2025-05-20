from typing import Dict, List, Tuple, Union
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import joblib
import os
from pathlib import Path

class MinimalNeuralCareerModel:
    """Versión simplificada del modelo neural usando scikit-learn en lugar de TensorFlow.
    Esta clase sirve como fallback en caso de que TensorFlow no funcione correctamente."""
    
    def __init__(self):
        """Inicializa el modelo de recomendación de carreras basado en RandomForest."""
        self.model = RandomForestClassifier(n_estimators=100, random_state=42)
        self.model_trained = False
        self.model_path = Path(os.path.dirname(os.path.abspath(__file__))) / ".." / "data" / "minimal_models"
        os.makedirs(self.model_path, exist_ok=True)
        
        # Intentar cargar el modelo si existe
        self.load_model()
        
    def prepare_input_features(self, mbti_vector: List[int], mbti_weights: Dict[str, float], 
                               mi_scores: Dict[str, float]) -> np.ndarray:
        """
        Prepara las características de entrada combinando el vector MBTI y los scores MI.
        
        Args:
            mbti_vector: Vector binario de MBTI (ej. [0, 1, 0, 1])
            mbti_weights: Pesos de las dimensiones MBTI (ej. {"E/I": 0.8, "S/N": 0.6, ...})
            mi_scores: Puntuaciones de inteligencias múltiples (ej. {"Lin": 0.7, "LogMath": 0.9, ...})
            
        Returns:
            Vector numpy de 16 dimensiones (4 MBTI + 4 pesos MBTI + 8 MI)
        """
        # Convertir mbti_weights a vector (mismas dimensiones que mbti_vector pero con intensidades)
        mbti_dimensions = ["E/I", "S/N", "T/F", "J/P"]
        mbti_weight_vector = [mbti_weights[dim] for dim in mbti_dimensions]
        
        # Convertir mi_scores a vector (asegurando orden consistente)
        mi_types = ["Lin", "LogMath", "Spa", "BodKin", "Mus", "Inter", "Intra", "Nat"]
        mi_vector = [mi_scores.get(mi_type, 0.0) for mi_type in mi_types]
        
        # Combinar todos los vectores en uno solo
        combined_vector = np.array(mbti_vector + mbti_weight_vector + mi_vector)
        
        return combined_vector.reshape(1, -1)  # Formato para predicción (batch_size=1)
    
    def train_model(self, X: np.ndarray, y: np.ndarray):
        """
        Entrena un modelo RandomForest para predecir carreras.
        
        Args:
            X: Matriz de características (N x 12) - MBTI + MI
            y: Etiquetas de carreras (no one-hot, índices enteros)
        """
        # Entrenar el modelo
        self.model.fit(X, y)
        self.model_trained = True
        
        # Guardar el modelo entrenado
        self.save_model()
        
        return {
            "message": "Modelo entrenado exitosamente",
            "accuracy": self.model.score(X, y)
        }
    
    def predict_career(self, mbti_vector: List[int], mbti_weights: Dict[str, float], 
                       mi_scores: Dict[str, float], career_names: List[str]) -> List[Tuple[str, float]]:
        """
        Predice carreras recomendadas basado en el perfil MBTI y MI del usuario.
        
        Args:
            mbti_vector: Vector binario de MBTI (ej. [0, 1, 0, 1])
            mbti_weights: Pesos de las dimensiones MBTI 
            mi_scores: Puntuaciones de inteligencias múltiples
            career_names: Lista de nombres de carreras disponibles
            
        Returns:
            Lista de tuplas (nombre_carrera, probabilidad) ordenadas por probabilidad
        """
        # Verificar si el modelo está entrenado
        if not self.model_trained:
            raise ValueError("El modelo no está entrenado. Entrena el modelo primero.")
            
        # Preparar datos de entrada
        X = self.prepare_input_features(mbti_vector, mbti_weights, mi_scores)
        
        # Hacer predicción
        probas = self.model.predict_proba(X)[0]
        
        # Combinar resultados con nombres de carreras
        results = [(career, float(prob)) for career, prob in zip(career_names, probas)]
        
        # Ordenar por probabilidad de mayor a menor
        results.sort(key=lambda x: x[1], reverse=True)
        
        return results
        
    def save_model(self):
        """Guarda el modelo entrenado y el codificador de etiquetas."""
        if self.model_trained:
            joblib.dump(self.model, str(self.model_path / "rf_model.pkl"))
            
    def load_model(self):
        """Carga el modelo entrenado si existe."""
        try:
            model_file = self.model_path / "rf_model.pkl"
            if model_file.exists():
                self.model = joblib.load(str(model_file))
                self.model_trained = True
                
        except Exception as e:
            print(f"Error al cargar el modelo: {e}")
            self.model_trained = False 