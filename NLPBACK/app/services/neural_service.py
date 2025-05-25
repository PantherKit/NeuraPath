from typing import Dict, List, Tuple, Any
import numpy as np
from app.models.neural_model import NeuralCareerModel
from app.models.career_model import CareerRecommender
from sklearn.preprocessing import LabelEncoder
from tensorflow.keras.utils import to_categorical

class NeuralCareerService:
    def __init__(self):
        self.neural_model = NeuralCareerModel()
        self.career_recommender = CareerRecommender()
        
    def generate_training_data(self, num_samples: int = 1000) -> Tuple[np.ndarray, np.ndarray, List[str]]:
        """
        Genera datos sintéticos para entrenar los modelos neuronales.
        
        Args:
            num_samples: Número de muestras de entrenamiento a generar
            
        Returns:
            Tupla con (X_train, y_train, career_names)
        """
        # Definir dimensiones MBTI
        mbti_dims = ["E/I", "S/N", "T/F", "J/P"]
        
        # Definir tipos de inteligencia múltiple
        mi_types = ["Lin", "LogMath", "Spa", "BodKin", "Mus", "Inter", "Intra", "Nat"]
        
        # Usar las carreras disponibles en nuestro recomendador
        careers = [career["nombre"] for career in self.career_recommender.careers]
        
        # Inicializar matrices de características y etiquetas
        X = np.zeros((num_samples, 16))  # 4 MBTI + 4 pesos MBTI + 8 MI
        y_labels = []
        
        # Generar datos simulados basados en reglas y probabilidades
        for i in range(num_samples):
            # Generar MBTI aleatorio pero con algunas reglas
            mbti_vector = np.random.randint(0, 2, 4)
            mbti_weights = {dim: np.random.uniform(0.5, 1.0) for dim in mbti_dims}
            
            # Generar scores MI aleatorios pero con algunas correlaciones
            mi_scores = {}
            for mi_type in mi_types:
                if mi_type == "LogMath" and mbti_vector[2] == 0:  # T correlaciona con LogMath
                    mi_scores[mi_type] = np.random.uniform(0.6, 1.0)
                elif mi_type == "Inter" and mbti_vector[0] == 0:  # E correlaciona con Inter
                    mi_scores[mi_type] = np.random.uniform(0.6, 1.0)
                else:
                    mi_scores[mi_type] = np.random.uniform(0.2, 0.8)
            
            # Combinar en un solo vector
            X[i, :4] = mbti_vector
            X[i, 4:8] = [mbti_weights[dim] for dim in mbti_dims]
            X[i, 8:] = [mi_scores[mi_type] for mi_type in mi_types]
            
            # Determinar la carrera basada en el perfil (reglas simplificadas)
            mbti_code = self._vector_to_mbti_code(mbti_vector)
            
            # Usar reglas de afinidad existentes en el recomendador
            if hasattr(self.career_recommender, '_rule_based_recommendations'):
                recommendations = self.career_recommender._rule_based_recommendations(
                    mbti_code, mi_scores, top_n=1
                )
                if recommendations:
                    y_labels.append(recommendations[0]["nombre"])
                    continue
            
            # Si no hay recomendaciones, asignar carrera aleatoriamente con sesgo
            if mbti_vector[2] == 0 and mi_scores["LogMath"] > 0.7:  # T + LogMath alto
                candidates = ["Ciencia de Datos", "Ingeniería Mecatrónica"]
            elif mbti_vector[0] == 1 and mi_scores["Intra"] > 0.7:  # I + Intra alto
                candidates = ["Ciencia de Datos", "Ingeniería en Biotecnología"]
            elif mbti_vector[0] == 0 and mi_scores["Inter"] > 0.7:  # E + Inter alto
                candidates = ["Diseño UX", "Ingeniería Ambiental"]
            else:
                candidates = careers
                
            y_labels.append(np.random.choice(candidates))
        
        # Codificar etiquetas
        self.neural_model.label_encoder = LabelEncoder()
        y_encoded = self.neural_model.label_encoder.fit_transform(y_labels)
        y_categorical = to_categorical(y_encoded)
        
        return X, y_categorical, careers
        
    def train_models(self, num_samples: int = 1000, epochs: int = 50, batch_size: int = 32):
        """
        Entrena los modelos FNN y CNN con datos sintéticos.
        
        Args:
            num_samples: Número de muestras para entrenar
            epochs: Número de epochs para entrenamiento
            batch_size: Tamaño del batch
        """
        # Generar datos de entrenamiento
        X, y, career_names = self.generate_training_data(num_samples)
        
        # Entrenar modelo FNN
        self.neural_model.train_fnn_model(X, y, epochs=epochs, batch_size=batch_size)
        
        # Entrenar modelo CNN
        self.neural_model.train_cnn_model(X, y, epochs=epochs, batch_size=batch_size)
        
        # Visualizar embeddings
        self.neural_model.visualize_embeddings(X, [career_names[i] for i in self.neural_model.label_encoder.transform(career_names)])
        
        return {
            "message": "Modelos entrenados exitosamente",
            "num_samples": num_samples,
            "careers": career_names,
            "epochs": epochs
        }
    
    def predict_careers(self, mbti_code: str, mbti_vector: List[int], 
                       mbti_weights: Dict[str, float], mi_scores: Dict[str, float], 
                       top_n: int = 3, use_cnn: bool = False) -> List[Dict]:
        """
        Predice las carreras STEM más adecuadas para el perfil del usuario.
        
        Args:
            mbti_code: Código MBTI (ej. "INTP")
            mbti_vector: Vector binario MBTI
            mbti_weights: Pesos de las dimensiones MBTI
            mi_scores: Puntuaciones de inteligencias múltiples
            top_n: Número de recomendaciones a devolver
            use_cnn: Si True, usa el modelo CNN; si False, usa el modelo FNN
            
        Returns:
            Lista de recomendaciones de carrera con puntajes de coincidencia
        """
        # Verificar si el modelo está entrenado
        model = self.neural_model.cnn_model if use_cnn else self.neural_model.fnn_model
        if model is None:
            # Si no hay modelo entrenado, entrenar con datos sintéticos
            self.train_models(num_samples=1000, epochs=30, batch_size=32)
            
        # Obtener los nombres de las carreras codificadas
        career_names = list(self.neural_model.label_encoder.classes_)
        
        # Obtener predicciones del modelo
        predictions = self.neural_model.predict_career(
            mbti_vector, mbti_weights, mi_scores, career_names, use_cnn
        )
        
        # Formatear resultados
        results = []
        for career_name, score in predictions[:top_n]:
            # Buscar información adicional sobre la carrera
            career_info = next(
                (career for career in self.career_recommender.careers 
                 if career["nombre"] == career_name),
                None
            )
            
            if career_info:
                results.append({
                    "nombre": career_name,
                    "universidad": career_info["universidad"],
                    "ciudad": career_info["ubicacion"],
                    "match_score": score
                })
            else:
                # Si no se encuentra la información, usar solo el nombre y puntaje
                results.append({
                    "nombre": career_name,
                    "universidad": "Universidad no especificada",
                    "ciudad": "Ciudad no especificada",
                    "match_score": score
                })
        
        return results
    
    def _vector_to_mbti_code(self, mbti_vector: List[int]) -> str:
        """Convierte un vector MBTI binario en su código de letras correspondiente"""
        letter_mapping = [
            ["E", "I"],
            ["S", "N"],
            ["T", "F"],
            ["J", "P"]
        ]
        
        return "".join(letter_mapping[i][v] for i, v in enumerate(mbti_vector)) 