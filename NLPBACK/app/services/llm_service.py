import json
import uuid
import logging
from typing import List, Dict, Any, Optional
from sqlalchemy.orm import Session

from app.db.models import UserResponse, LLMResult
from app.schemas.personality import QuestionResponse, LLMResultCreate

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("llm_service")

class LLMService:
    def __init__(self):
        logger.info("LLMService inicializado")
    
    def generate_career_analysis_prompt(self, mbti_code: str, mi_scores: Dict[str, float], 
                                      career_recommendations: List[Dict[str, Any]]) -> str:
        """
        Genera un prompt para que el LLM analice las recomendaciones de carrera
        
        Args:
            mbti_code: Código MBTI del usuario (ej. "INTJ")
            mi_scores: Puntuaciones de inteligencias múltiples
            career_recommendations: Lista de recomendaciones de carrera con puntuaciones
            
        Returns:
            Prompt para el LLM
        """
        logger.info(f"Generando prompt para análisis de carreras para perfil {mbti_code}")
        
        # Crear una representación ordenada de las puntuaciones MI
        mi_sorted = sorted(mi_scores.items(), key=lambda x: x[1], reverse=True)
        mi_text = "\n".join([f"- {name}: {score:.2f}" for name, score in mi_sorted])
        
        # Crear una representación de las recomendaciones
        rec_text = "\n".join([
            f"- {i+1}. {rec['nombre']} ({rec['universidad']}, {rec['ciudad']}): {rec['match_score']:.2f} match"
            for i, rec in enumerate(career_recommendations[:5])  # Limitar a 5 recomendaciones
        ])
        
        prompt = f"""Actúa como un consejero vocacional experto. Basándote en el perfil de personalidad MBTI, 
las puntuaciones de inteligencias múltiples y las recomendaciones de carrera proporcionadas, 
genera un análisis detallado y personalizado explicando:

1. Por qué estas carreras son adecuadas para este perfil específico
2. Cómo las características del perfil MBTI se alinean con cada carrera recomendada
3. Cómo las inteligencias múltiples del usuario se relacionan con las demandas de cada carrera
4. Qué habilidades específicas podría desarrollar el usuario para tener éxito en estas carreras
5. Oportunidades y desafíos potenciales que podría enfrentar en estos campos

Perfil MBTI: {mbti_code}

Inteligencias Múltiples (ordenadas de mayor a menor):
{mi_text}

Recomendaciones de Carrera:
{rec_text}

Proporciona un análisis detallado, personalizado y práctico que ayude al usuario a entender por qué estas 
carreras son compatibles con su perfil y cómo podría aprovechar sus fortalezas naturales.
"""
        
        logger.info(f"Prompt generado con longitud: {len(prompt)} caracteres")
        return prompt
    
    def process_career_analysis_response(self, llm_response: str) -> Dict[str, Any]:
        """
        Procesa la respuesta del LLM sobre el análisis de carreras
        
        Args:
            llm_response: Respuesta del LLM en formato de texto
            
        Returns:
            Diccionario con el análisis procesado
        """
        logger.info("Procesando respuesta de análisis de carreras del LLM")
        logger.info(f"Longitud de la respuesta: {len(llm_response)} caracteres")
        
        # Simplemente devolvemos la respuesta como texto, no necesitamos procesarla
        return {
            "analysis": llm_response.strip(),
            "raw_response": llm_response
        }
    
    def save_user_responses(self, db: Session, responses: List[QuestionResponse], 
                           user_id: Optional[int] = None, session_id: Optional[str] = None) -> UserResponse:
        """
        Guarda las respuestas del usuario en la base de datos
        
        Args:
            db: Sesión de base de datos
            responses: Lista de respuestas del usuario
            user_id: ID del usuario (opcional)
            session_id: ID de sesión (opcional, se genera uno si no se proporciona)
            
        Returns:
            Objeto UserResponse guardado en la base de datos
        """
        # Si no se proporciona session_id, generar uno
        if not session_id:
            session_id = str(uuid.uuid4())
            logger.info(f"Generando nuevo session_id: {session_id}")
        else:
            logger.info(f"Usando session_id proporcionado: {session_id}")
        
        # Convertir las respuestas a formato JSON para la base de datos
        responses_data = [resp.dict() for resp in responses]
        logger.info(f"Guardando {len(responses_data)} respuestas en la base de datos")
        
        # Crear y guardar el objeto UserResponse
        db_response = UserResponse(
            user_id=user_id,
            session_id=session_id,
            responses_data=responses_data
        )
        
        db.add(db_response)
        db.commit()
        db.refresh(db_response)
        logger.info(f"Respuestas guardadas con ID: {db_response.id}")
        
        return db_response
    
    def generate_llm_prompt(self, responses: List[QuestionResponse]) -> str:
        """
        Genera un prompt para el LLM basado en las respuestas del usuario
        
        Args:
            responses: Lista de respuestas del usuario
            
        Returns:
            Prompt formateado para enviar al LLM
        """
        logger.info(f"Generando prompt para {len(responses)} respuestas")
        
        prompt = """Actúa como un psicólogo vocacional.

Te daré una lista de preguntas y respuestas de un usuario.

Para cada una:
1. Clasifícala como MBTI o MI.
2. Si es MBTI, indica la dimensión (E/I, S/N, T/F, J/P) y qué polo refuerza.
3. Si es MI, indica qué inteligencia múltiple evalúa y si la respuesta del usuario sugiere que es alta, media o baja.

Luego, dame:
- El tipo MBTI más probable
- Un ranking de inteligencias múltiples (de más fuerte a más débil)

Ejemplo de respuesta final:

{
  "MBTI": "INFP",
  "MBTI_weights": {
    "E/I": "I fuerte",
    "S/N": "N medio",
    "T/F": "F fuerte",
    "J/P": "P leve"
  },
  "MI": ["Intrapersonal", "Lingüística", "Naturalista", "Interpersonal", ...]
}

---

Preguntas y respuestas del usuario:
"""
        
        # Añadir cada pregunta y respuesta al prompt
        for i, resp in enumerate(responses, 1):
            prompt += f"\n{i}. {resp.pregunta} → {resp.respuesta}"
        
        logger.info(f"Prompt generado con longitud: {len(prompt)} caracteres")
        return prompt
    
    def save_llm_result(self, db: Session, user_response_id: int, 
                       llm_result: LLMResultCreate, prompt_used: str,
                       user_id: Optional[int] = None) -> LLMResult:
        """
        Guarda el resultado del LLM en la base de datos
        
        Args:
            db: Sesión de base de datos
            user_response_id: ID de las respuestas del usuario
            llm_result: Resultado del LLM
            prompt_used: Prompt utilizado para generar el resultado
            user_id: ID del usuario (opcional)
            
        Returns:
            Objeto LLMResult guardado en la base de datos
        """
        logger.info(f"Guardando resultado LLM para user_response_id: {user_response_id}")
        
        # Crear y guardar el objeto LLMResult
        db_result = LLMResult(
            user_id=user_id,
            user_response_id=user_response_id,
            mbti_result=llm_result.mbti_result,
            mbti_vector=llm_result.mbti_vector,
            mbti_weights=llm_result.mbti_weights,
            mi_ranking=llm_result.mi_ranking,
            full_result=llm_result.full_analysis if llm_result.full_analysis else {},
            prompt_used=prompt_used
        )
        
        db.add(db_result)
        db.commit()
        db.refresh(db_result)
        logger.info(f"Resultado LLM guardado con ID: {db_result.id}")
        
        return db_result
    
    def process_llm_response(self, llm_response: str) -> LLMResultCreate:
        """
        Procesa la respuesta del LLM y la convierte a un formato estructurado
        
        Args:
            llm_response: Respuesta del LLM en formato de texto
            
        Returns:
            Objeto LLMResultCreate con los datos procesados
        """
        logger.info("Procesando respuesta del LLM")
        logger.info(f"Longitud de la respuesta: {len(llm_response)} caracteres")
        
        # Por ahora, asumimos que el LLM devuelve un JSON bien formateado
        # En un entorno real, se necesitaría un procesamiento más robusto
        try:
            # Extraer la parte JSON de la respuesta
            json_start = llm_response.find('{')
            json_end = llm_response.rfind('}') + 1
            
            logger.info(f"JSON encontrado: inicio={json_start}, fin={json_end}")
            
            if json_start >= 0 and json_end > json_start:
                json_str = llm_response[json_start:json_end]
                logger.info(f"Extrayendo JSON. Longitud: {len(json_str)} caracteres")
                logger.info(f"JSON extraído: {json_str}")
                
                result_dict = json.loads(json_str)
                logger.info(f"JSON parseado correctamente. Claves: {', '.join(result_dict.keys())}")
                
                # Extraer los campos necesarios
                mbti_result = result_dict.get("MBTI", "")
                mbti_weights = result_dict.get("MBTI_weights", {})
                mi_ranking = result_dict.get("MI", [])
                
                logger.info(f"MBTI extraído: {mbti_result}")
                logger.info(f"MBTI weights extraídos: {mbti_weights}")
                logger.info(f"MI ranking extraído: {mi_ranking}")
                
                # Opcionalmente, intentar extraer el vector MBTI si está presente
                mbti_vector = result_dict.get("MBTI_vector", None)
                logger.info(f"MBTI vector extraído: {mbti_vector}")
                
                return LLMResultCreate(
                    mbti_result=mbti_result,
                    mbti_vector=mbti_vector,
                    mbti_weights=mbti_weights,
                    mi_ranking=mi_ranking,
                    full_analysis=result_dict
                )
            else:
                logger.error("No se encontró un JSON válido en la respuesta del LLM")
                logger.error(f"Respuesta completa: {llm_response}")
                raise ValueError("No se encontró un JSON válido en la respuesta del LLM")
                
        except Exception as e:
            logger.error(f"Error procesando respuesta del LLM: {str(e)}")
            logger.error(f"Respuesta que causó el error: {llm_response}")
            
            # En caso de error, crear un resultado genérico
            return LLMResultCreate(
                mbti_result="XXXX",
                mbti_weights={"E/I": "Error", "S/N": "Error", "T/F": "Error", "J/P": "Error"},
                mi_ranking=["Error procesando respuesta del LLM"],
                full_analysis={"error": str(e), "raw_response": llm_response}
            ) 