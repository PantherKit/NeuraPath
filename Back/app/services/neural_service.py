from typing import Dict, List, Tuple, Any
import numpy as np
from app.models.neural_model import NeuralCareerModel
from app.models.career_model import CareerRecommender
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
from tensorflow.keras.utils import to_categorical
import logging
import random

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("neural_service")

class NeuralCareerService:
    def __init__(self):
        self.neural_model = NeuralCareerModel()
        self.career_recommender = CareerRecommender()
        logger.info("NeuralCareerService inicializado")
        
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
        
        # Usar todas las carreras disponibles en nuestro recomendador
        careers = [career["nombre"] for career in self.career_recommender.careers]
        num_careers = len(careers)
        logger.info(f"Generando datos para {num_careers} carreras")
        
        # Asegurar una distribución uniforme de carreras
        # Calculamos cuántas muestras por carrera necesitamos
        samples_per_career = num_samples // num_careers
        remainder = num_samples % num_careers
        
        # Inicializar matrices de características y etiquetas
        X = np.zeros((num_samples, 16))  # 4 MBTI + 4 pesos MBTI + 8 MI
        y_labels = []
        
        # Contador para llevar seguimiento de las muestras generadas
        sample_index = 0
        
        # Primera fase: generar muestras equilibradas para cada carrera
        for career_index, career_name in enumerate(careers):
            # Determinar cuántas muestras generar para esta carrera
            # Las primeras carreras obtienen una muestra extra si hay un remainder
            career_samples = samples_per_career + (1 if career_index < remainder else 0)
            
            for _ in range(career_samples):
                # Generar MBTI aleatorio 
                mbti_vector = np.random.randint(0, 2, 4)
                mbti_weights = {dim: np.random.uniform(0.5, 1.0) for dim in mbti_dims}
                
                # Generar scores MI aleatorios con algunas correlaciones
                mi_scores = {}
                for mi_type in mi_types:
                    # Correlaciones más fuertes y específicas
                    if mi_type == "LogMath" and mbti_vector[2] == 0:  # T correlaciona con LogMath
                        mi_scores[mi_type] = np.random.uniform(0.7, 1.0)  # Mayor valor mínimo
                    elif mi_type == "Inter" and mbti_vector[0] == 0:  # E correlaciona con Inter
                        mi_scores[mi_type] = np.random.uniform(0.7, 1.0)
                    elif mi_type == "Lin" and career_name in ["Ciencia de Datos", "Ingeniería en Sistemas Computacionales"]:
                        mi_scores[mi_type] = np.random.uniform(0.7, 1.0)
                    elif mi_type == "Spa" and career_name in ["Ingeniería Aeroespacial", "Física de Materiales"]:
                        mi_scores[mi_type] = np.random.uniform(0.7, 1.0)
                    elif mi_type == "Nat" and career_name in ["Ingeniería Ambiental", "Oceanografía", "Geología"]:
                        # Correlación entre naturalista y carreras ambientales
                        mi_scores[mi_type] = np.random.uniform(0.8, 1.0)
                    elif mi_type == "BodKin" and career_name in ["Ingeniería Mecatrónica", "Ingeniería en Robótica"]:
                        mi_scores[mi_type] = np.random.uniform(0.7, 1.0)
                    elif mi_type == "Intra" and mbti_vector[0] == 1 and career_name in ["Neurociencias", "Bioinformática"]:
                        # I (introvertido) + Intrapersonal correlaciona con carreras de investigación
                        mi_scores[mi_type] = np.random.uniform(0.7, 1.0)
                    else:
                        mi_scores[mi_type] = np.random.uniform(0.2, 0.8)
                
                # Combinar en un solo vector
                X[sample_index, :4] = mbti_vector
                X[sample_index, 4:8] = [mbti_weights[dim] for dim in mbti_dims]
                X[sample_index, 8:] = [mi_scores[mi_type] for mi_type in mi_types]
                
                # Asignar la carrera actual
                y_labels.append(career_name)
                
                # Incrementar el índice de muestra
                sample_index += 1
        
        # Mezclar los datos para evitar patrones secuenciales
        indices = np.arange(num_samples)
        np.random.shuffle(indices)
        X = X[indices]
        y_labels = [y_labels[i] for i in indices]
        
        # Codificar etiquetas
        self.neural_model.label_encoder = LabelEncoder()
        y_encoded = self.neural_model.label_encoder.fit_transform(y_labels)
        y_categorical = to_categorical(y_encoded)
        
        # Verificar distribución de carreras
        unique_careers, career_counts = np.unique(y_labels, return_counts=True)
        logger.info(f"Generados datos de entrenamiento con {len(unique_careers)} carreras únicas")
        logger.info(f"Distribución de carreras: min={career_counts.min()}, max={career_counts.max()}, media={career_counts.mean():.1f}")
        
        return X, y_categorical, careers
        
    def train_models(self, num_samples: int = 1000, epochs: int = 50, batch_size: int = 32, validation: bool = True):
        """
        Entrena el modelo CNN con datos sintéticos.
        """
        try:
            logger.info(f"Comenzando entrenamiento con {num_samples} muestras")
            logger.info(f"Usando todas las carreras disponibles: {len(self.career_recommender.careers)}")
            hard_classes = [
                "Astrofísica", "Bioestadística", "Física de Materiales", 
                "Ingeniería Biomédica", "Neurociencias", "Oceanografía",
                "Química de Materiales", "Ingeniería en Fotónica"
            ]
            extra_samples_per_hard_class = num_samples // 20
            total_extra_samples = extra_samples_per_hard_class * len(hard_classes)
            adjusted_num_samples = num_samples + total_extra_samples
            logger.info(f"Ajustando número de muestras a {adjusted_num_samples} para dar más énfasis a clases difíciles")
            X, y, career_names = self.generate_training_data(adjusted_num_samples)
            logger.info(f"Generando {total_extra_samples} muestras adicionales para {len(hard_classes)} carreras difíciles")
            if validation:
                X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
                logger.info(f"Datos divididos: {X_train.shape[0]} muestras de entrenamiento, {X_test.shape[0]} muestras de prueba")
                logger.info("Entrenando modelo CNN...")
                self.neural_model.train_cnn_model(X_train, y_train, epochs=epochs, batch_size=batch_size)
                X_test_reshaped = X_test.reshape(X_test.shape[0], X_test.shape[1], 1)
                cnn_predictions = self.neural_model.cnn_model.predict(X_test_reshaped)
                cnn_pred_classes = np.argmax(cnn_predictions, axis=1)
                cnn_true_classes = np.argmax(y_test, axis=1)
                cnn_accuracy = accuracy_score(cnn_true_classes, cnn_pred_classes)
                logger.info(f"Precisión del modelo CNN: {cnn_accuracy:.4f}")
                class_names = list(self.neural_model.label_encoder.classes_)
                unique_classes = sorted(list(set(np.concatenate([cnn_pred_classes, cnn_true_classes]))))
                target_names = [class_names[i] for i in unique_classes]
                logger.info(f"El modelo puede predecir {len(class_names)} carreras")
                logger.info(f"Clases únicas en la evaluación: {len(unique_classes)}")
                logger.info("\nInforme de clasificación CNN:")
                classification_rep = classification_report(
                    cnn_true_classes, cnn_pred_classes, 
                    labels=unique_classes,  # Usar solo las clases presentes en los datos
                    target_names=target_names,
                    zero_division=0
                )
                logger.info(f"\n{classification_rep}")
            else:
                logger.info("Entrenando modelo CNN sin validación...")
                self.neural_model.train_cnn_model(X, y, epochs=epochs, batch_size=batch_size)
            self.neural_model.visualize_embeddings(X, [career_names[i] for i in self.neural_model.label_encoder.transform(career_names)])
            results = {
                "message": "Modelo CNN entrenado exitosamente",
                "num_samples": num_samples,
                "careers": list(self.neural_model.label_encoder.classes_),
                "epochs": epochs,
                "validation": validation
            }
            if validation:
                results["cnn_accuracy"] = float(cnn_accuracy)
            return results
        except Exception as e:
            logger.error(f"Error entrenando modelo CNN: {str(e)}", exc_info=True)
            return {"error": f"Error entrenando modelo CNN: {str(e)}"}
    
    def evaluate_models(self, num_samples: int = 500):
        """
        Evalúa el modelo CNN entrenado con un conjunto de datos de prueba.
        """
        logger.info(f"Evaluando modelo CNN con {num_samples} muestras...")
        if self.neural_model.cnn_model is None:
            logger.warning("No hay modelo CNN entrenado para evaluar")
            return {"error": "No hay modelo CNN entrenado para evaluar"}
        try:
            known_careers = list(self.neural_model.label_encoder.classes_)
            logger.info(f"El modelo conoce {len(known_careers)} carreras")
            X_test, y_test, _ = self.generate_training_data(num_samples)
            X_test_reshaped = X_test.reshape(X_test.shape[0], X_test.shape[1], 1)
            cnn_predictions = self.neural_model.cnn_model.predict(X_test_reshaped)
            cnn_pred_classes = np.argmax(cnn_predictions, axis=1)
            cnn_true_classes = np.argmax(y_test, axis=1)
            cnn_accuracy = accuracy_score(cnn_true_classes, cnn_pred_classes)
            logger.info(f"Precisión del modelo CNN: {cnn_accuracy:.4f}")
            unique_classes = sorted(list(set(np.concatenate([cnn_pred_classes, cnn_true_classes]))))
            target_names = [known_careers[i] for i in unique_classes]
            cnn_report = classification_report(
                cnn_true_classes, cnn_pred_classes, 
                labels=unique_classes,
                target_names=target_names, 
                output_dict=True,
                zero_division=0
            )
            return {
                "cnn_accuracy": float(cnn_accuracy),
                "num_samples": num_samples,
                "cnn_report": cnn_report,
                "known_careers": known_careers,
                "num_known_careers": len(known_careers),
                "num_evaluated_careers": len(target_names)
            }
        except Exception as e:
            logger.error(f"Error evaluando modelo CNN: {str(e)}", exc_info=True)
            return {"error": f"Error evaluando modelo CNN: {str(e)}"}
    
    def predict_careers(self, mbti_code: str, mbti_vector: List[int], 
                       mbti_weights: Dict[str, float], mi_scores: Dict[str, float], 
                       top_n: int = 3) -> List[Dict]:
        """
        Predice las carreras STEM más adecuadas para el perfil del usuario usando solo CNN.
        """
        logger.info(f"Iniciando predicción de carreras para perfil MBTI: {mbti_code}")
        if self.neural_model.cnn_model is None:
            logger.info("No hay modelo CNN entrenado. Entrenando un nuevo modelo...")
            self.train_models(num_samples=5000, epochs=50, batch_size=32)
        career_names = list(self.neural_model.label_encoder.classes_)
        logger.info(f"Prediciendo entre {len(career_names)} carreras disponibles")
        logger.info("Ejecutando predicción con red neuronal CNN...")
        predictions = self.neural_model.predict_career(
            mbti_vector, mbti_weights, mi_scores, career_names
        )
        top_predictions = predictions[:5]
        logger.info(f"Top 5 predicciones iniciales: {top_predictions}")
        actual_top_n = min(top_n * 5, len(predictions))
        predictions = predictions[:actual_top_n]
        logger.info(f"Seleccionadas {actual_top_n} predicciones preliminares para filtrado")
        filtered_predictions = []
        logger.info("Iniciando filtrado de predicciones...")
        for i, (career_name, score) in enumerate(predictions):
            if i < 3:
                filtered_predictions.append((career_name, score))
                logger.info(f"Incluida carrera top {i+1}: {career_name} (score: {score:.4f})")
            elif score > 0.03:
                filtered_predictions.append((career_name, score))
                logger.info(f"Incluida carrera adicional: {career_name} (score: {score:.4f})")
            else:
                logger.info(f"Descartada carrera: {career_name} (score: {score:.4f} - muy bajo)")
            if len(filtered_predictions) >= top_n:
                logger.info(f"Alcanzado número objetivo de recomendaciones ({top_n})")
                break
        if len(filtered_predictions) < top_n and hasattr(self.career_recommender, '_rule_based_recommendations'):
            logger.info(f"Insuficientes recomendaciones ({len(filtered_predictions)}). Añadiendo basadas en reglas...")
            rule_recs = self.career_recommender._rule_based_recommendations(
                mbti_code, mi_scores, top_n=top_n
            )
            for rec in rule_recs:
                career_name = rec["nombre"]
                if career_name not in [c for c, _ in filtered_predictions]:
                    filtered_predictions.append((career_name, 0.05))
                    logger.info(f"Añadida carrera por reglas: {career_name} (score asignado: 0.05)")
                if len(filtered_predictions) >= top_n:
                    break
        if len(filtered_predictions) < top_n:
            logger.info(f"Aún faltan recomendaciones. Añadiendo carreras menos comunes...")
            recommended_careers = set(career_name for career_name, _ in filtered_predictions)
            less_common_careers = [
                career for career in self.career_recommender.careers 
                if career["nombre"] not in recommended_careers
            ]
            random.shuffle(less_common_careers)
            for career in less_common_careers[:top_n - len(filtered_predictions)]:
                filtered_predictions.append((career["nombre"], 0.01))
                logger.info(f"Añadida carrera poco común: {career['nombre']} (score asignado: 0.01)")
        logger.info("Iniciando enriquecimiento de resultados con información adicional...")
        results = []
        for career_name, score in filtered_predictions[:top_n]:
            logger.info(f"Procesando carrera: {career_name} (score: {score:.4f})")
            career_info = next(
                (career for career in self.career_recommender.careers 
                 if career["nombre"] == career_name),
                None
            )
            if career_info:
                logger.info(f"Información encontrada para {career_name}: universidad={career_info['universidad']}, ciudad={career_info['ubicacion']}")
                results.append({
                    "nombre": career_name,
                    "universidad": career_info["universidad"],
                    "ciudad": career_info["ubicacion"],
                    "match_score": float(score)
                })
            else:
                logger.warning(f"No se encontró información adicional para la carrera: {career_name}")
                results.append({
                    "nombre": career_name,
                    "universidad": "Universidad no especificada",
                    "ciudad": "Ciudad no especificada",
                    "match_score": float(score)
                })
        logger.info(f"Recomendaciones finales generadas: {[r['nombre'] for r in results]}")
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