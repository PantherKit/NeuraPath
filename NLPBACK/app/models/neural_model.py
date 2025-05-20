import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Conv1D, MaxPooling1D, Flatten
from tensorflow.keras.utils import to_categorical
from sklearn.preprocessing import LabelEncoder
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt
import joblib
from typing import Dict, List, Tuple, Union
import os
from pathlib import Path
import json

class NeuralCareerModel:
    def __init__(self):
        """Inicializa el modelo de red neuronal para recomendación de carreras."""
        self.fnn_model = None
        self.cnn_model = None
        self.label_encoder = LabelEncoder()
        self.model_path = Path(os.path.dirname(os.path.abspath(__file__))) / ".." / "data" / "neural_models"
        os.makedirs(self.model_path, exist_ok=True)
        
        # Cargar el modelo si ya existe
        self.load_models()
        
    def prepare_input_features(self, mbti_vector: List[int], mbti_weights: Dict[str, float], 
                              mi_scores: Dict[str, float]) -> np.ndarray:
        """
        Prepara las características de entrada combinando el vector MBTI y los scores MI.
        
        Args:
            mbti_vector: Vector binario de MBTI (ej. [0, 1, 0, 1])
            mbti_weights: Pesos de las dimensiones MBTI (ej. {"E/I": 0.8, "S/N": 0.6, ...})
            mi_scores: Puntuaciones de inteligencias múltiples (ej. {"Lin": 0.7, "LogMath": 0.9, ...})
            
        Returns:
            Vector numpy de 12 dimensiones (4 MBTI + 8 MI)
        """
        # Convertir mbti_weights a vector (mismas dimensiones que mbti_vector pero con intensidades)
        mbti_dimensions = ["E/I", "S/N", "T/F", "J/P"]
        mbti_weight_vector = [mbti_weights[dim] for dim in mbti_dimensions]
        
        # Convertir mi_scores a vector (asegurando orden consistente)
        mi_types = ["Lin", "LogMath", "Spa", "BodKin", "Mus", "Inter", "Intra", "Nat"]
        mi_vector = [mi_scores.get(mi_type, 0.0) for mi_type in mi_types]
        
        # Combinar ambos vectores
        combined_vector = np.array(mbti_vector + mbti_weight_vector + mi_vector)
        
        return combined_vector.reshape(1, -1)  # Formato para predicción (batch_size=1)
    
    def train_fnn_model(self, X: np.ndarray, y: np.ndarray, epochs: int = 50, batch_size: int = 32):
        """
        Entrena un modelo de red neuronal feedforward para predecir carreras.
        
        Args:
            X: Matriz de características (N x 12) - MBTI + MI
            y: Etiquetas de carreras (codificadas con one-hot)
            epochs: Número de epochs para entrenamiento
            batch_size: Tamaño del batch
        """
        num_classes = y.shape[1]
        
        # Definir arquitectura de red FNN
        self.fnn_model = Sequential([
            Dense(128, activation='relu', input_shape=(X.shape[1],)),
            Dropout(0.3),
            Dense(64, activation='relu'),
            Dropout(0.3),
            Dense(num_classes, activation='softmax')
        ])
        
        # Compilar el modelo
        self.fnn_model.compile(
            optimizer='adam',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        # Entrenar el modelo
        self.fnn_model.fit(X, y, epochs=epochs, batch_size=batch_size, verbose=1)
        
        # Guardar el modelo entrenado
        self.save_models()
    
    def train_cnn_model(self, X: np.ndarray, y: np.ndarray, epochs: int = 50, batch_size: int = 32):
        """
        Entrena un modelo CNN para capturar patrones en la secuencia MBTI+MI.
        
        Args:
            X: Matriz de características (N x 12) - MBTI + MI
            y: Etiquetas de carreras (codificadas con one-hot)
            epochs: Número de epochs para entrenamiento
            batch_size: Tamaño del batch
        """
        num_classes = y.shape[1]
        
        # Reestructurar datos para CNN (samples, timesteps, features)
        X_reshaped = X.reshape(X.shape[0], X.shape[1], 1)
        
        # Definir arquitectura CNN
        self.cnn_model = Sequential([
            Conv1D(32, 3, activation='relu', input_shape=(X.shape[1], 1)),
            MaxPooling1D(2),
            Conv1D(64, 3, activation='relu'),
            MaxPooling1D(2),
            Flatten(),
            Dense(64, activation='relu'),
            Dropout(0.3),
            Dense(num_classes, activation='softmax')
        ])
        
        # Compilar el modelo
        self.cnn_model.compile(
            optimizer='adam',
            loss='categorical_crossentropy', 
            metrics=['accuracy']
        )
        
        # Entrenar el modelo
        self.cnn_model.fit(X_reshaped, y, epochs=epochs, batch_size=batch_size, verbose=1)
        
        # Guardar el modelo entrenado
        self.save_models()
    
    def predict_career(self, mbti_vector: List[int], mbti_weights: Dict[str, float], 
                      mi_scores: Dict[str, float], career_names: List[str], 
                      use_cnn: bool = False) -> List[Tuple[str, float]]:
        """
        Predice carreras recomendadas basado en el perfil MBTI y MI del usuario.
        
        Args:
            mbti_vector: Vector binario de MBTI (ej. [0, 1, 0, 1])
            mbti_weights: Pesos de las dimensiones MBTI 
            mi_scores: Puntuaciones de inteligencias múltiples
            career_names: Lista de nombres de carreras disponibles
            use_cnn: Si True, usa el modelo CNN; si False, usa el modelo FNN
            
        Returns:
            Lista de tuplas (nombre_carrera, probabilidad) ordenadas por probabilidad
        """
        # Verificar si el modelo está entrenado
        model = self.cnn_model if use_cnn else self.fnn_model
        if model is None:
            raise ValueError("El modelo no está entrenado. Entrena el modelo primero.")
            
        # Preparar datos de entrada
        X = self.prepare_input_features(mbti_vector, mbti_weights, mi_scores)
        
        # Remodelar para CNN si es necesario
        if use_cnn:
            X = X.reshape(X.shape[0], X.shape[1], 1)
        
        # Hacer predicción
        probs = model.predict(X)[0]
        
        # Combinar resultados con nombres de carreras
        results = [(career, float(prob)) for career, prob in zip(career_names, probs)]
        
        # Ordenar por probabilidad de mayor a menor
        results.sort(key=lambda x: x[1], reverse=True)
        
        return results
        
    def visualize_embeddings(self, X: np.ndarray, career_labels: List[str], perplexity: int = 30):
        """
        Visualiza los embeddings de perfil y carreras usando t-SNE.
        
        Args:
            X: Matriz de características (N x 12) - MBTI + MI
            career_labels: Etiquetas correspondientes a cada muestra
            perplexity: Parámetro de perplexity para t-SNE
        """
        # Aplicar t-SNE para reducir dimensionalidad a 2D
        tsne = TSNE(n_components=2, random_state=42, perplexity=perplexity)
        X_2d = tsne.fit_transform(X)
        
        # Visualizar los puntos
        plt.figure(figsize=(10, 8))
        
        # Obtener clases únicas
        unique_careers = list(set(career_labels))
        colors = plt.cm.rainbow(np.linspace(0, 1, len(unique_careers)))
        
        for i, career in enumerate(unique_careers):
            indices = [j for j, label in enumerate(career_labels) if label == career]
            plt.scatter(X_2d[indices, 0], X_2d[indices, 1], label=career, color=colors[i], alpha=0.7)
            
        plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
        plt.title('Visualización t-SNE de Perfiles MBTI+MI por Carrera')
        plt.tight_layout()
        
        # Guardar el gráfico
        plt.savefig(str(self.model_path / "tsne_visualization.png"))
        plt.close()
    
    def save_models(self):
        """Guarda los modelos entrenados y el codificador de etiquetas."""
        if self.fnn_model:
            self.fnn_model.save(str(self.model_path / "fnn_model"))
        
        if self.cnn_model:
            self.cnn_model.save(str(self.model_path / "cnn_model"))
            
        if hasattr(self, 'label_encoder') and self.label_encoder.classes_.size > 0:
            joblib.dump(self.label_encoder, str(self.model_path / "label_encoder.pkl"))
    
    def load_models(self):
        """Carga los modelos entrenados si existen."""
        try:
            fnn_path = self.model_path / "fnn_model"
            if fnn_path.exists():
                self.fnn_model = tf.keras.models.load_model(str(fnn_path))
                
            cnn_path = self.model_path / "cnn_model"
            if cnn_path.exists():
                self.cnn_model = tf.keras.models.load_model(str(cnn_path))
                
            encoder_path = self.model_path / "label_encoder.pkl"
            if encoder_path.exists():
                self.label_encoder = joblib.load(str(encoder_path))
                
        except Exception as e:
            print(f"Error al cargar los modelos: {e}")
            # Si hay error, inicializar modelos nuevos
            self.fnn_model = None
            self.cnn_model = None 