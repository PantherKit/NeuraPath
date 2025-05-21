from typing import Dict, List, Tuple, Any
import numpy as np
from app.models.minimal_neural import MinimalNeuralCareerModel
from app.models.career_model import CareerRecommender
from sklearn.preprocessing import LabelEncoder
import random
from app.utils.riasec_processor import RIASECProcessor
from app.scripts.train_with_riasec import train_model_with_riasec

class MinimalNeuralService:
    """Servicio de recomendación de carreras usando el modelo RandomForest como alternativa a TensorFlow"""
    
    def __init__(self):
        self.neural_model = MinimalNeuralCareerModel()
        self.career_recommender = CareerRecommender()
        self.label_encoder = LabelEncoder()
        
    def generate_training_data(self, num_samples: int = 1000) -> Tuple[np.ndarray, np.ndarray, List[str]]:
        """
        Genera datos sintéticos para entrenar el modelo.
        
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
        self.label_encoder.fit(careers)
        y_encoded = self.label_encoder.transform(y_labels)
        
        return X, y_encoded, careers
        
    def train_model(self, num_samples: int = 1000):
        """
        Entrena el modelo RandomForest con datos sintéticos.
        
        Args:
            num_samples: Número de muestras para entrenar
            
        Returns:
            Diccionario con los resultados del entrenamiento
        """
        # Generar datos de entrenamiento
        X, y, career_names = self.generate_training_data(num_samples)
        
        # Entrenar modelo
        result = self.neural_model.train_model(X, y)
        
        return {
            "message": "Modelo entrenado exitosamente",
            "num_samples": num_samples,
            "careers": career_names,
            "accuracy": result["accuracy"]
        }
    
    def predict_careers(self, mbti_code: str, mbti_vector: List[int], 
                       mbti_weights: Dict[str, float], mi_scores: Dict[str, float], 
                       top_n: int = 3) -> List[Dict]:
        """
        Predice las carreras STEM más adecuadas para el perfil del usuario.
        
        Args:
            mbti_code: Código MBTI (ej. "INTP")
            mbti_vector: Vector binario MBTI
            mbti_weights: Pesos de las dimensiones MBTI
            mi_scores: Puntuaciones de inteligencias múltiples
            top_n: Número de recomendaciones a devolver
            
        Returns:
            Lista de recomendaciones de carrera con puntajes de coincidencia
        """
        try:
            # Si el modelo no está entrenado, entrenar con datos sintéticos
            if not self.neural_model.model_trained:
                self.train_model(num_samples=1000)
                
            # Obtener los nombres de las carreras
            careers = [career["nombre"] for career in self.career_recommender.careers]
            self.label_encoder.fit(careers)
                
            # Obtener predicciones del modelo
            predictions = self.neural_model.predict_career(
                mbti_vector, mbti_weights, mi_scores, careers
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
        except Exception as e:
            # Si hay un error, usar el recomendador de similitud de coseno como fallback
            print(f"Error en la predicción con RandomForest: {e}. Usando fallback.")
            return self.career_recommender.recommend_careers(
                mbti_code, mbti_vector, mbti_weights, mi_scores, top_n
            )
    
    def _vector_to_mbti_code(self, mbti_vector: List[int]) -> str:
        """Convierte un vector MBTI binario en su código de letras correspondiente"""
        letter_mapping = [
            ["E", "I"],
            ["S", "N"],
            ["T", "F"],
            ["J", "P"]
        ]
        
        return "".join(letter_mapping[i][v] for i, v in enumerate(mbti_vector)) 

class MinimalRecommendationService:
    """Servicio para generar recomendaciones de carreras usando el modelo minimal_neural"""
    
    def __init__(self):
        """Inicializa el servicio de recomendaciones"""
        self.model = MinimalNeuralCareerModel()
        self.career_names = []
        
    def train_model(self, training_data: List[Dict[str, Any]], career_names: List[str]) -> Dict[str, Any]:
        """
        Entrena el modelo con datos proporcionados externamente.
        
        Args:
            training_data: Lista de diccionarios con mbti_vector, mbti_weights, mi_scores y career_label
            career_names: Lista de nombres de las carreras
            
        Returns:
            Diccionario con mensaje y precisión del modelo
        """
        try:
            # Preparar datos para el formato esperado por el modelo
            X_train = []
            y_train = []
            
            for item in training_data:
                # Crear vector de características
                features = self.model.prepare_input_features(
                    item["mbti_vector"],
                    item["mbti_weights"],
                    item["mi_scores"]
                )
                X_train.append(features)
                y_train.append(item["career_label"])
            
            # Convertir a arrays
            X_train_array = np.vstack(X_train)
            y_train_array = np.array(y_train)
            
            # Entrenar modelo
            result = self.model.train_model(X_train_array, y_train_array)
            
            # Guardar nombres de carreras
            self.career_names = career_names
            
            return result
        except Exception as e:
            raise Exception(f"Error en el entrenamiento: {str(e)}")
        
    def train_with_riasec(self, sample_size: int = 5000, save_training_data: bool = False, verbose: bool = True) -> Dict[str, Any]:
        """
        Entrena el modelo utilizando datos del dataset RIASEC procesados.
        
        Args:
            sample_size: Número de muestras a utilizar (None para usar todas)
            save_training_data: Si se deben guardar los datos de entrenamiento
            verbose: Si se debe mostrar información detallada
            
        Returns:
            Diccionario con mensaje y precisión del modelo
        """
        try:
            # Usar la función del script 
            self.model = train_model_with_riasec(
                sample_size=sample_size, 
                save_training_data=save_training_data, 
                verbose=verbose
            )
            
            # Obtener los nombres de carreras
            processor = RIASECProcessor()
            _, self.career_names = processor.prepare_training_data(sample_size=10)  # Solo necesitamos los nombres
            
            return {
                "message": f"Modelo entrenado exitosamente con {sample_size if sample_size else 'todas las'} muestras de RIASEC",
                "accuracy": self.model.model.score(X=None, y=None)  # Calcular precisión
            }
        except Exception as e:
            raise Exception(f"Error al entrenar con datos RIASEC: {str(e)}")
    
    def generate_training_data(self, num_samples: int = 1000) -> Tuple[np.ndarray, np.ndarray, List[str]]:
        """
        Genera datos sintéticos para entrenar el modelo.
        
        Args:
            num_samples: Número de muestras de entrenamiento a generar
            
        Returns:
            Tupla con (X_train, y_train, career_names)
        """
        # Definir dimensiones MBTI
        mbti_dims = ["E/I", "S/N", "T/F", "J/P"]
        
        # Definir tipos de inteligencia múltiple
        mi_types = ["Lin", "LogMath", "Spa", "BodKin", "Mus", "Inter", "Intra", "Nat"]
        
        # Definir carreras
        careers = [
            "Ingeniería", "Medicina", "Psicología", "Negocios", 
            "Arte", "Educación", "Tecnología", "Derecho", 
            "Ciencias Sociales", "Comunicación"
        ]
        self.career_names = careers
        
        # Perfiles de personalidad típicos para cada carrera
        career_profiles = {
            "Ingeniería": {
                "mbti": [[1, 0, 0, 0], [1, 0, 0, 1], [0, 0, 0, 1]],  # INT*, IST*
                "mi": {
                    "high": ["LogMath", "Spa"],
                    "medium": ["Intra", "Nat"]
                }
            },
            "Medicina": {
                "mbti": [[0, 1, 1, 1], [0, 0, 1, 1], [1, 1, 1, 1]],  # INF*, ISF*
                "mi": {
                    "high": ["LogMath", "Inter", "BodKin"],
                    "medium": ["Intra", "Nat"]
                }
            },
            "Psicología": {
                "mbti": [[0, 1, 1, 0], [0, 1, 1, 1], [1, 1, 1, 0]],  # INF*
                "mi": {
                    "high": ["Inter", "Intra"],
                    "medium": ["Lin", "LogMath"]
                }
            },
            "Negocios": {
                "mbti": [[0, 0, 0, 1], [0, 0, 1, 1], [0, 1, 0, 1]],  # EST*, ESF*
                "mi": {
                    "high": ["LogMath", "Inter"],
                    "medium": ["Lin", "Intra"]
                }
            },
            "Arte": {
                "mbti": [[0, 1, 1, 0], [1, 1, 1, 0], [0, 1, 0, 0]],  # *NF*
                "mi": {
                    "high": ["Mus", "Spa", "Lin"],
                    "medium": ["BodKin", "Intra"]
                }
            },
            "Educación": {
                "mbti": [[0, 0, 1, 1], [0, 1, 1, 1], [0, 1, 1, 0]],  # ESF*, ENF*
                "mi": {
                    "high": ["Inter", "Lin"],
                    "medium": ["Intra", "LogMath"]
                }
            },
            "Tecnología": {
                "mbti": [[1, 1, 0, 0], [1, 1, 0, 1], [1, 0, 0, 1]],  # INT*
                "mi": {
                    "high": ["LogMath", "Spa"],
                    "medium": ["Intra", "Lin"]
                }
            },
            "Derecho": {
                "mbti": [[0, 0, 0, 1], [0, 1, 0, 1], [0, 0, 1, 1]],  # E*TJ
                "mi": {
                    "high": ["Lin", "LogMath"],
                    "medium": ["Inter", "Intra"]
                }
            },
            "Ciencias Sociales": {
                "mbti": [[1, 1, 1, 0], [0, 1, 1, 0], [1, 1, 0, 0]],  # IN**
                "mi": {
                    "high": ["Intra", "Inter"],
                    "medium": ["Lin", "Nat"]
                }
            },
            "Comunicación": {
                "mbti": [[0, 1, 1, 0], [0, 1, 0, 0], [0, 0, 1, 0]],  # E*F*
                "mi": {
                    "high": ["Lin", "Inter"],
                    "medium": ["Mus", "Spa"]
                }
            }
        }
        
        # Generar datos de entrenamiento
        X_train = []
        y_train = []
        
        for i in range(num_samples):
            # Elegir una carrera aleatoria para esta muestra
            career_idx = random.randint(0, len(careers) - 1)
            career = careers[career_idx]
            profile = career_profiles[career]
            
            # Generar vector MBTI
            mbti_vector = random.choice(profile["mbti"])
            
            # Generar pesos MBTI (cuán fuerte es cada preferencia)
            mbti_weights = {}
            for j, dim in enumerate(mbti_dims):
                # Peso más alto para dimensiones relevantes para esta carrera
                mbti_weights[dim] = random.uniform(0.6, 0.9)
            
            # Generar puntuaciones MI
            mi_scores = {}
            for mi in mi_types:
                if mi in profile["mi"]["high"]:
                    # Puntuación alta para inteligencias clave
                    mi_scores[mi] = random.uniform(0.7, 0.95)
                elif mi in profile["mi"]["medium"]:
                    # Puntuación media para inteligencias secundarias
                    mi_scores[mi] = random.uniform(0.5, 0.8)
                else:
                    # Puntuación más baja para el resto
                    mi_scores[mi] = random.uniform(0.3, 0.6)
            
            # Preparar features
            features = self.model.prepare_input_features(mbti_vector, mbti_weights, mi_scores)
            X_train.append(features)
            y_train.append(career_idx)
        
        # Convertir a arrays numpy
        X_train_array = np.vstack(X_train)  # Convertir lista de arrays 2D a un solo array 2D
        y_train_array = np.array(y_train)
        
        return X_train_array, y_train_array, careers
    
    def train(self, num_samples: int = 1000) -> Dict[str, Any]:
        """
        Entrena el modelo con datos sintéticos.
        
        Args:
            num_samples: Número de muestras a generar para entrenamiento
            
        Returns:
            Diccionario con resultado del entrenamiento
        """
        try:
            # Generar datos sintéticos
            X_train, y_train, careers = self.generate_training_data(num_samples)
            
            # Entrenar modelo
            result = self.model.train_model(X_train, y_train)
            
            # Actualizar lista de carreras
            self.career_names = careers
            
            return result
        except Exception as e:
            raise Exception(f"Error entrenando modelo: {str(e)}")
    
    def predict(self, mbti_result, mi_result) -> List[Dict[str, Any]]:
        """
        Realiza predicciones con el modelo entrenado.
        
        Args:
            mbti_result: Resultado del test MBTI
            mi_result: Resultado del test de inteligencias múltiples
            
        Returns:
            Lista de carreras recomendadas con sus puntuaciones
        """
        try:
            # Verificar si hay un modelo entrenado y con carreras
            if not self.model.model_trained:
                # Entrenar con datos sintéticos si no hay modelo
                self.train()
            
            if not self.career_names:
                # Usar nombres de carreras por defecto si no se establecieron
                self.career_names = [
                    "Ingeniería", "Medicina", "Psicología", "Negocios", 
                    "Arte", "Educación", "Tecnología", "Derecho", 
                    "Ciencias Sociales", "Comunicación"
                ]
            
            # Convertir vector MBTI
            mbti_vector = [
                1 if mbti_result.ei == "I" else 0,
                1 if mbti_result.sn == "N" else 0,
                1 if mbti_result.tf == "F" else 0,
                1 if mbti_result.jp == "P" else 0
            ]
            
            # Extraer pesos MBTI
            mbti_weights = {
                "E/I": mbti_result.ei_score,
                "S/N": mbti_result.sn_score,
                "T/F": mbti_result.tf_score,
                "J/P": mbti_result.jp_score
            }
            
            # Transformar resultados MI
            mi_scores = {
                "Lin": mi_result.linguistic,
                "LogMath": mi_result.logical_mathematical,
                "Spa": mi_result.spatial,
                "BodKin": mi_result.bodily_kinesthetic,
                "Mus": mi_result.musical,
                "Inter": mi_result.interpersonal,
                "Intra": mi_result.intrapersonal,
                "Nat": mi_result.naturalistic
            }
            
            # Realizar predicción
            predictions = self.model.predict_career(
                mbti_vector, 
                mbti_weights, 
                mi_scores, 
                self.career_names
            )
            
            # Convertir a formato esperado
            results = []
            for career, score in predictions:
                results.append({
                    "carrera": career,
                    "puntuacion": float(score),
                    "descripcion": f"Basado en tu perfil, {career} parece ser una buena opción para ti."
                })
            
            return results
            
        except Exception as e:
            raise Exception(f"Error realizando predicción: {str(e)}") 