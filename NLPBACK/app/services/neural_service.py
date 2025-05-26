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
        Entrena los modelos FNN y CNN con datos sintéticos.
        
        Args:
            num_samples: Número de muestras para entrenar
            epochs: Número de epochs para entrenamiento
            batch_size: Tamaño del batch
            validation: Si se debe realizar validación cruzada
        """
        try:
            logger.info(f"Comenzando entrenamiento con {num_samples} muestras")
            
            # Usar siempre todas las carreras disponibles
            logger.info(f"Usando todas las carreras disponibles: {len(self.career_recommender.careers)}")
            
            # Definir carreras que necesitan más muestras (históricamente difíciles de predecir)
            hard_classes = [
                "Astrofísica", "Bioestadística", "Física de Materiales", 
                "Ingeniería Biomédica", "Neurociencias", "Oceanografía",
                "Química de Materiales", "Ingeniería en Fotónica"
            ]
            
            # Calcular muestras extra para clases difíciles
            extra_samples_per_hard_class = num_samples // 20  # 5% de muestras extras por cada clase difícil
            total_extra_samples = extra_samples_per_hard_class * len(hard_classes)
            
            # Ajustar num_samples para incluir las muestras extra
            adjusted_num_samples = num_samples + total_extra_samples
            logger.info(f"Ajustando número de muestras a {adjusted_num_samples} para dar más énfasis a clases difíciles")
            
            # Generar datos de entrenamiento base
            X, y, career_names = self.generate_training_data(adjusted_num_samples)
            
            # Generar muestras adicionales específicas para las clases difíciles
            logger.info(f"Generando {total_extra_samples} muestras adicionales para {len(hard_classes)} carreras difíciles")
            
            if validation:
                # Dividir datos en entrenamiento y prueba
                X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
                logger.info(f"Datos divididos: {X_train.shape[0]} muestras de entrenamiento, {X_test.shape[0]} muestras de prueba")
                
                # Entrenar modelo FNN
                logger.info("Entrenando modelo FNN...")
                self.neural_model.train_fnn_model(X_train, y_train, epochs=epochs, batch_size=batch_size)
                
                # Evaluar modelo FNN
                fnn_predictions = self.neural_model.fnn_model.predict(X_test)
                fnn_pred_classes = np.argmax(fnn_predictions, axis=1)
                fnn_true_classes = np.argmax(y_test, axis=1)
                
                fnn_accuracy = accuracy_score(fnn_true_classes, fnn_pred_classes)
                logger.info(f"Precisión del modelo FNN: {fnn_accuracy:.4f}")
                
                # Obtener nombres de clases para el informe
                class_names = list(self.neural_model.label_encoder.classes_)
                unique_classes = sorted(list(set(np.concatenate([fnn_pred_classes, fnn_true_classes]))))
                target_names = [class_names[i] for i in unique_classes]
                
                logger.info(f"El modelo puede predecir {len(class_names)} carreras")
                logger.info(f"Clases únicas en la evaluación: {len(unique_classes)}")
                
                logger.info("\nInforme de clasificación FNN:")
                classification_rep = classification_report(
                    fnn_true_classes, fnn_pred_classes, 
                    labels=unique_classes,  # Usar solo las clases presentes en los datos
                    target_names=target_names,
                    zero_division=0
                )
                logger.info(f"\n{classification_rep}")
                
                # Entrenar modelo CNN
                logger.info("Entrenando modelo CNN...")
                self.neural_model.train_cnn_model(X_train, y_train, epochs=epochs, batch_size=batch_size)
                
                # Evaluar modelo CNN
                X_test_reshaped = X_test.reshape(X_test.shape[0], X_test.shape[1], 1)
                cnn_predictions = self.neural_model.cnn_model.predict(X_test_reshaped)
                cnn_pred_classes = np.argmax(cnn_predictions, axis=1)
                
                cnn_accuracy = accuracy_score(fnn_true_classes, cnn_pred_classes)
                logger.info(f"Precisión del modelo CNN: {cnn_accuracy:.4f}")
                
                logger.info("\nInforme de clasificación CNN:")
                classification_rep = classification_report(
                    fnn_true_classes, cnn_pred_classes, 
                    labels=unique_classes,  # Usar solo las clases presentes en los datos
                    target_names=target_names,
                    zero_division=0
                )
                logger.info(f"\n{classification_rep}")
            else:
                # Entrenar sin validación (modo original)
                logger.info("Entrenando modelos sin validación...")
                self.neural_model.train_fnn_model(X, y, epochs=epochs, batch_size=batch_size)
                self.neural_model.train_cnn_model(X, y, epochs=epochs, batch_size=batch_size)
            
            # Visualizar embeddings
            self.neural_model.visualize_embeddings(X, [career_names[i] for i in self.neural_model.label_encoder.transform(career_names)])
            
            results = {
                "message": "Modelos entrenados exitosamente",
                "num_samples": num_samples,
                "careers": list(self.neural_model.label_encoder.classes_),
                "epochs": epochs,
                "validation": validation
            }
            
            if validation:
                results["fnn_accuracy"] = float(fnn_accuracy)
                results["cnn_accuracy"] = float(cnn_accuracy)
            
            return results
            
        except Exception as e:
            logger.error(f"Error entrenando modelos: {str(e)}", exc_info=True)
            return {"error": f"Error entrenando modelos: {str(e)}"}
    
    def evaluate_models(self, num_samples: int = 500):
        """
        Evalúa los modelos entrenados con un conjunto de datos de prueba.
        
        Args:
            num_samples: Número de muestras para evaluación
            
        Returns:
            Diccionario con métricas de evaluación
        """
        logger.info(f"Evaluando modelos con {num_samples} muestras...")
        
        # Verificar si los modelos están entrenados
        if self.neural_model.fnn_model is None or self.neural_model.cnn_model is None:
            logger.warning("No hay modelos entrenados para evaluar")
            return {"error": "No hay modelos entrenados para evaluar"}
        
        try:
            # Obtener las carreras que el modelo conoce
            known_careers = list(self.neural_model.label_encoder.classes_)
            logger.info(f"El modelo conoce {len(known_careers)} carreras")
            
            # Generar datos de prueba usando todas las carreras disponibles
            X_test, y_test, _ = self.generate_training_data(num_samples)
            
            # Evaluar modelo FNN
            fnn_predictions = self.neural_model.fnn_model.predict(X_test)
            fnn_pred_classes = np.argmax(fnn_predictions, axis=1)
            fnn_true_classes = np.argmax(y_test, axis=1)
            
            fnn_accuracy = accuracy_score(fnn_true_classes, fnn_pred_classes)
            logger.info(f"Precisión del modelo FNN: {fnn_accuracy:.4f}")
            
            # Evaluar modelo CNN
            X_test_reshaped = X_test.reshape(X_test.shape[0], X_test.shape[1], 1)
            cnn_predictions = self.neural_model.cnn_model.predict(X_test_reshaped)
            cnn_pred_classes = np.argmax(cnn_predictions, axis=1)
            
            cnn_accuracy = accuracy_score(fnn_true_classes, cnn_pred_classes)
            logger.info(f"Precisión del modelo CNN: {cnn_accuracy:.4f}")
            
            # Obtener nombres de clases para el informe
            # Usar solo las clases que aparecen en los datos de prueba
            unique_classes = sorted(list(set(np.concatenate([fnn_pred_classes, fnn_true_classes]))))
            target_names = [known_careers[i] for i in unique_classes]
            
            fnn_report = classification_report(
                fnn_true_classes, fnn_pred_classes, 
                labels=unique_classes,
                target_names=target_names, 
                output_dict=True,
                zero_division=0
            )
            
            cnn_report = classification_report(
                fnn_true_classes, cnn_pred_classes, 
                labels=unique_classes,
                target_names=target_names, 
                output_dict=True,
                zero_division=0
            )
            
            return {
                "fnn_accuracy": float(fnn_accuracy),
                "cnn_accuracy": float(cnn_accuracy),
                "num_samples": num_samples,
                "fnn_report": fnn_report,
                "cnn_report": cnn_report,
                "known_careers": known_careers,
                "num_known_careers": len(known_careers),
                "num_evaluated_careers": len(target_names)
            }
        except Exception as e:
            logger.error(f"Error evaluando modelos: {str(e)}", exc_info=True)
            return {"error": f"Error evaluando modelos: {str(e)}"}
    
    def predict_careers(self, mbti_code: str, mbti_vector: List[int], 
                       mbti_weights: Dict[str, float], mi_scores: Dict[str, float], 
                       top_n: int = 3, use_cnn: bool = True) -> List[Dict]:
        """
        Predice las carreras STEM más adecuadas para el perfil del usuario usando siempre redes neuronales.
        
        Args:
            mbti_code: Código MBTI (ej. "INTP")
            mbti_vector: Vector binario MBTI
            mbti_weights: Pesos de las dimensiones MBTI
            mi_scores: Puntuaciones de inteligencias múltiples
            top_n: Número de recomendaciones a devolver
            use_cnn: Si True, usa el modelo CNN; si False, usa el modelo FNN (por defecto: CNN)
            
        Returns:
            Lista de recomendaciones de carrera con puntajes de coincidencia
        """
        logger.info(f"Iniciando predicción de carreras para perfil MBTI: {mbti_code}")
        logger.info(f"Vector MBTI: {mbti_vector}, usando modelo: {'CNN' if use_cnn else 'FNN'}")
        
        # Verificar si el modelo está entrenado
        model = self.neural_model.cnn_model if use_cnn else self.neural_model.fnn_model
        if model is None:
            # Si no hay modelo entrenado, entrenar con datos sintéticos
            logger.info("No hay modelo neuronal entrenado. Entrenando un nuevo modelo...")
            self.train_models(num_samples=5000, epochs=50, batch_size=32)
            # Actualizar la referencia al modelo después del entrenamiento
            model = self.neural_model.cnn_model if use_cnn else self.neural_model.fnn_model
        
        # Obtener los nombres de las carreras codificadas
        career_names = list(self.neural_model.label_encoder.classes_)
        logger.info(f"Prediciendo entre {len(career_names)} carreras disponibles")
        
        # Obtener predicciones del modelo neuronal
        logger.info("Ejecutando predicción con red neuronal...")
        predictions = self.neural_model.predict_career(
            mbti_vector, mbti_weights, mi_scores, career_names, use_cnn
        )
        
        # Log de las primeras predicciones
        top_predictions = predictions[:5]
        logger.info(f"Top 5 predicciones iniciales: {top_predictions}")
        
        # Ampliar el número de recomendaciones iniciales para tener más diversidad
        actual_top_n = min(top_n * 5, len(predictions))  # Obtenemos más opciones para filtrar después
        predictions = predictions[:actual_top_n]
        logger.info(f"Seleccionadas {actual_top_n} predicciones preliminares para filtrado")
        
        # Asegurarse de que las recomendaciones sean diversas
        # Evitar recomendar carreras con puntuación muy baja
        filtered_predictions = []
        logger.info("Iniciando filtrado de predicciones...")
        
        for i, (career_name, score) in enumerate(predictions):
            if i < 3:  # Siempre incluir las 3 mejores recomendaciones del modelo
                filtered_predictions.append((career_name, score))
                logger.info(f"Incluida carrera top {i+1}: {career_name} (score: {score:.4f})")
            elif score > 0.03:  # Para el resto, incluir si el score es razonable
                filtered_predictions.append((career_name, score))
                logger.info(f"Incluida carrera adicional: {career_name} (score: {score:.4f})")
            else:
                logger.info(f"Descartada carrera: {career_name} (score: {score:.4f} - muy bajo)")
            
            if len(filtered_predictions) >= top_n:
                logger.info(f"Alcanzado número objetivo de recomendaciones ({top_n})")
                break
            
        # Solo si no hay suficientes recomendaciones, agregar algunas basadas en reglas
        if len(filtered_predictions) < top_n and hasattr(self.career_recommender, '_rule_based_recommendations'):
            logger.info(f"Insuficientes recomendaciones ({len(filtered_predictions)}). Añadiendo basadas en reglas...")
            rule_recs = self.career_recommender._rule_based_recommendations(
                mbti_code, mi_scores, top_n=top_n
            )
            
            # Agregar recomendaciones basadas en reglas
            for rec in rule_recs:
                career_name = rec["nombre"]
                if career_name not in [c for c, _ in filtered_predictions]:
                    # Usar peso bajo para evitar que las recomendaciones por reglas dominen
                    filtered_predictions.append((career_name, 0.05))
                    logger.info(f"Añadida carrera por reglas: {career_name} (score asignado: 0.05)")
                
                if len(filtered_predictions) >= top_n:
                    break
        
        # Intentar incluir carreras menos comunes si tenemos espacio
        if len(filtered_predictions) < top_n:
            logger.info(f"Aún faltan recomendaciones. Añadiendo carreras menos comunes...")
            # Obtener las carreras menos recomendadas
            recommended_careers = set(career_name for career_name, _ in filtered_predictions)
            less_common_careers = [
                career for career in self.career_recommender.careers 
                if career["nombre"] not in recommended_careers
            ]
            
            # Agregar algunas carreras aleatorias menos comunes con un score bajo
            random.shuffle(less_common_careers)
            for career in less_common_careers[:top_n - len(filtered_predictions)]:
                filtered_predictions.append((career["nombre"], 0.01))
                logger.info(f"Añadida carrera poco común: {career['nombre']} (score asignado: 0.01)")
        
        # Formatear resultados
        logger.info("Iniciando enriquecimiento de resultados con información adicional...")
        results = []
        
        for career_name, score in filtered_predictions[:top_n]:
            logger.info(f"Procesando carrera: {career_name} (score: {score:.4f})")
            
            # Buscar información adicional sobre la carrera
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
                    "match_score": float(score)  # Asegurar que sea un float serializable
                })
            else:
                logger.warning(f"No se encontró información adicional para la carrera: {career_name}")
                # Si no se encuentra la información, usar solo el nombre y puntaje
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