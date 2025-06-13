import logging
from typing import List, Dict, Tuple, Any, Optional
import json
from app.services.llm_api_service import LLMApiService
from app.schemas.personality import QuestionResponse

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("llm_profile_interpreter")

class LLMProfileInterpreter:
    """
    Intérprete de perfiles que utiliza un LLM para convertir respuestas de usuarios
    en vectores MBTI y puntuaciones de inteligencias múltiples estructurados.
    """
    
    def __init__(self, llm_provider: str = "openai"):
        """
        Inicializa el intérprete de perfiles
    
        """
        self.llm_api = LLMApiService()
        self.llm_provider = llm_provider
        logger.info(f"LLMProfileInterpreter inicializado con proveedor: {llm_provider}")
    
    async def interpret_responses(self, responses: List[QuestionResponse]) -> Tuple[List[int], Dict[str, float], Dict[str, float]]:
        """
        Interpreta las respuestas del usuario y devuelve vectores estructurados
        
        Args:
            responses: Lista de objetos QuestionResponse con las respuestas del usuario
            
        Returns:
            Tupla con (mbti_vector, mbti_weights, mi_scores)
        """
        logger.info(f"Interpretando {len(responses)} respuestas de usuario")
        
        # 1. Generar el prompt para el LLM
        prompt = self._generate_prompt(responses)
        
        # 2. Llamar al LLM
        llm_response = await self.llm_api.call_llm(
            prompt=prompt,
            provider=self.llm_provider,
            max_tokens=1000
        )
        logger.info("Respuesta recibida del LLM")
        
        # 3. Procesar la respuesta del LLM
        mbti_vector, mbti_weights, mi_scores = self._process_llm_response(llm_response)
        
        logger.info(f"Interpretación completada: MBTI vector={mbti_vector}, MI scores tiene {len(mi_scores)} elementos")
        return mbti_vector, mbti_weights, mi_scores
    
    def _generate_prompt(self, responses: List[QuestionResponse]) -> str:
        """
        Genera un prompt para el LLM basado en las respuestas del usuario
        
        Args:
            responses: Lista de respuestas del usuario
            
        Returns:
            Prompt formateado para enviar al LLM
        """
        prompt = """Actúa como un psicólogo experto en personalidad MBTI e inteligencias múltiples.

Analiza las siguientes respuestas de un usuario y determina:

1. Su perfil MBTI más probable (4 letras: E/I, S/N, T/F, J/P)
2. Un vector binario MBTI (ejemplo: [1, 0, 1, 0] donde 1=I/N/F/P y 0=E/S/T/J)
3. Pesos/intensidades para cada dimensión MBTI (valores entre 0.0 y 1.0)
4. Puntuaciones para cada tipo de inteligencia múltiple (valores entre 0.0 y 1.0)

Formatea tu respuesta como un JSON con esta estructura exacta:
{
  "MBTI": "XXXX",
  "MBTI_vector": [0, 0, 0, 0],
  "MBTI_weights": {
    "E/I": 0.0,
    "S/N": 0.0,
    "T/F": 0.0,
    "J/P": 0.0
  },
  "MI_scores": {
    "Lin": 0.0,
    "LogMath": 0.0,
    "Spa": 0.0,
    "BodKin": 0.0,
    "Mus": 0.0,
    "Inter": 0.0,
    "Intra": 0.0,
    "Nat": 0.0
  }
}

Donde:
- Lin = Lingüística
- LogMath = Lógico-Matemática
- Spa = Espacial
- BodKin = Corporal-Kinestésica
- Mus = Musical
- Inter = Interpersonal
- Intra = Intrapersonal
- Nat = Naturalista

Respuestas del usuario:
"""
        
        # Añadir cada pregunta y respuesta al prompt
        for i, resp in enumerate(responses, 1):
            prompt += f"\n{i}. {resp.pregunta} → {resp.respuesta}"
        
        logger.info(f"Prompt generado con longitud: {len(prompt)} caracteres")
        return prompt
    
    def _process_llm_response(self, llm_response: str) -> Tuple[List[int], Dict[str, float], Dict[str, float]]:
        """
        Procesa la respuesta del LLM y extrae los vectores y puntuaciones
        
        Args:
            llm_response: Respuesta del LLM en formato de texto
            
        Returns:
            Tupla con (mbti_vector, mbti_weights, mi_scores)
        """
        logger.info("Procesando respuesta del LLM")
        logger.info(f"Respuesta completa del LLM (primeros 200 chars): {llm_response[:200]}...")
        
        try:
            # Extraer la parte JSON de la respuesta
            json_start = llm_response.find('{')
            json_end = llm_response.rfind('}') + 1
            
            logger.info(f"Índices JSON encontrados: inicio={json_start}, fin={json_end}")
            
            if json_start >= 0 and json_end > json_start:
                json_str = llm_response[json_start:json_end]
                logger.info(f"JSON extraído, longitud: {len(json_str)}")
                logger.info(f"JSON extraído (primeros 200 chars): {json_str[:200]}...")
                
                result = json.loads(json_str)
                logger.info(f"JSON parseado correctamente. Claves encontradas: {', '.join(result.keys())}")
                
                # Extraer los datos necesarios
                mbti_vector = result.get("MBTI_vector", [1, 1, 1, 1])  # Valores por defecto si no hay datos
                mbti_weights = result.get("MBTI_weights", {
                    "E/I": 0.5, "S/N": 0.5, "T/F": 0.5, "J/P": 0.5
                })
                mi_scores = result.get("MI_scores", {
                    "Lin": 0.5, "LogMath": 0.5, "Spa": 0.5, "BodKin": 0.5,
                    "Mus": 0.5, "Inter": 0.5, "Intra": 0.5, "Nat": 0.5
                })
                
                logger.info(f"MBTI extraído: {mbti_vector}")
                logger.info(f"MBTI weights extraídos: {mbti_weights}")
                logger.info(f"MI scores extraídos (primeras 3 entradas): {dict(list(mi_scores.items())[:3])}")
                
                # Asegurar que el vector MBTI tiene valores enteros
                mbti_vector = [int(v) for v in mbti_vector]
                logger.info(f"MBTI vector final (después de convertir a enteros): {mbti_vector}")
                
                return mbti_vector, mbti_weights, mi_scores
            else:
                logger.error("No se encontró un JSON válido en la respuesta")
                logger.error(f"Contenido de la respuesta problemática: {llm_response}")
                
        except Exception as e:
            logger.error(f"Error procesando respuesta del LLM: {str(e)}")
            logger.error(f"JSON que causó el error: {json_str if 'json_str' in locals() else 'No se pudo extraer JSON'}")
        
        # Valores por defecto en caso de error
        logger.warning("Usando valores por defecto debido a error en procesamiento")
        default_mbti_vector = [1, 1, 1, 1]
        default_mbti_weights = {"E/I": 0.5, "S/N": 0.5, "T/F": 0.5, "J/P": 0.5}
        default_mi_scores = {
            "Lin": 0.5, "LogMath": 0.5, "Spa": 0.5, "BodKin": 0.5,
            "Mus": 0.5, "Inter": 0.5, "Intra": 0.5, "Nat": 0.5
        }
        
        return default_mbti_vector, default_mbti_weights, default_mi_scores 