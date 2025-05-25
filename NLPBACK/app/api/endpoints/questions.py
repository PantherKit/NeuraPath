from fastapi import APIRouter, HTTPException, Depends, Query
import json
from pathlib import Path
import os
import logging
from typing import List, Dict, Optional
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.services.llm_service import LLMService
from app.services.llm_api_service import LLMApiService
from app.services.neural_service import NeuralCareerService
from app.schemas.personality import QuestionResponse, UserResponseCreate, LLMResponse, MBTIResult, MIResult

from app.db.models import UserResponse

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("questions_api")

router = APIRouter()
llm_service = LLMService()
llm_api_service = LLMApiService()
neural_service = NeuralCareerService()

@router.get("/mbti")
async def get_mbti_questions():
    """
    Get all MBTI questions
    """
    try:
        # Path to the questions data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "mbti_questions.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="MBTI questions file not found")
            
        # Read the questions
        with open(data_path, "r", encoding="utf-8") as f:
            questions = json.load(f)
            
        return {"mbti_questions": questions}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading MBTI questions: {str(e)}")

@router.get("/multiple-intelligence")
async def get_mi_questions():
    """
    Get all Multiple Intelligence questions
    """
    try:
        # Path to the questions data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "mi_questions.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="MI questions file not found")
            
        # Read the questions
        with open(data_path, "r", encoding="utf-8") as f:
            questions = json.load(f)
            
        return {"mi_questions": questions}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading MI questions: {str(e)}")

@router.get("/careers")
async def get_careers():
    """
    Get all careers
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
            
        return {"careers": careers}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading careers: {str(e)}")

@router.get("/careers/locations")
async def get_career_locations():
    """
    Get all unique locations from careers
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
        
        # Extract unique locations
        locations = sorted(list(set(career["ubicacion"] for career in careers)))
            
        return {"locations": locations}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading career locations: {str(e)}")

@router.get("/careers/universities")
async def get_career_universities():
    """
    Get all unique universities from careers
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
        
        # Extract unique universities
        universities = sorted(list(set(career["universidad"] for career in careers)))
            
        return {"universities": universities}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading career universities: {str(e)}")

@router.get("/careers/names")
async def get_career_names():
    """
    Get all unique career names
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
        
        # Extract career names
        names = sorted(list(set(career["nombre"] for career in careers)))
            
        return {"career_names": names}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading career names: {str(e)}")

@router.post("/combined-questions")
async def process_combined_questions(questions_responses: List[Dict[str, str]]):
    """
    Recibe y procesa un array de preguntas y respuestas combinadas vía POST
    
    El formato esperado en el cuerpo de la petición es:
    [
      {
        "pregunta": "¿Te recargas de energía estando solo o al convivir con otros?",
        "respuesta": "Solo"
      },
      ...
    ]
    """
    try:
        # Verificamos que el formato sea correcto
        for item in questions_responses:
            if "pregunta" not in item or "respuesta" not in item:
                raise HTTPException(
                    status_code=400, 
                    detail="Formato incorrecto. Cada elemento debe tener 'pregunta' y 'respuesta'"
                )
        
        # Procesamos las preguntas y respuestas
        # Por ahora, simplemente devolvemos lo recibido con un status
        processed_result = {
            "status": "success",
            "message": "Preguntas y respuestas recibidas correctamente",
            "questions_count": len(questions_responses),
            "data": questions_responses
        }
        
        return processed_result
        
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=500, 
            detail=f"Error procesando preguntas y respuestas: {str(e)}"
        )

@router.post("/process-complete")
async def process_complete_flow(
    questions_responses: List[QuestionResponse],
    db: Session = Depends(get_db),
    user_id: Optional[int] = None,
    session_id: Optional[str] = None,
    llm_provider: Optional[str] = Query("openai", description="Proveedor LLM a utilizar: openai, anthropic o mock")
):
    """
    Procesa el flujo completo:
    1. Recibe las preguntas y respuestas
    2. Las guarda en la base de datos
    3. Genera el prompt para el LLM
    4. Llama a la API del LLM seleccionado
    5. Procesa la respuesta
    6. Guarda el resultado
    7. Pasa el resultado a la red neuronal para generar recomendaciones
    8. Devuelve el resultado final con recomendaciones
    
    Args:
        questions_responses: Lista de preguntas y respuestas
        db: Sesión de base de datos
        user_id: ID del usuario (opcional)
        session_id: ID de sesión (opcional)
        llm_provider: Proveedor de LLM a utilizar (openai, anthropic, mock)
    """
    try:
        logger.info(f"Iniciando procesamiento completo con proveedor LLM: {llm_provider}")
        logger.info(f"Recibidas {len(questions_responses)} preguntas y respuestas")
        
        # 1. Guardar las respuestas en la base de datos
        logger.info("Paso 1: Guardando respuestas en la base de datos")
        db_response = llm_service.save_user_responses(
            db=db,
            responses=questions_responses,
            user_id=user_id,
            session_id=session_id
        )
        
        # 2. Generar el prompt para el LLM
        logger.info("Paso 2: Generando prompt para el LLM")
        prompt_text = llm_service.generate_llm_prompt(questions_responses)
        
        # 3. Llamar al LLM con el proveedor seleccionado
        logger.info(f"Paso 3: Llamando al LLM con proveedor: {llm_provider}")
        llm_response = await llm_api_service.call_llm(
            prompt=prompt_text,
            provider=llm_provider,
            max_tokens=1000
        )
        
        # 4. Procesar la respuesta del LLM
        logger.info("Paso 4: Procesando respuesta del LLM")
        llm_result = llm_service.process_llm_response(llm_response)
        logger.info(f"Resultado MBTI: {llm_result.mbti_result}")
        
        # 5. Guardar el resultado en la base de datos
        logger.info("Paso 5: Guardando resultado en la base de datos")
        db_result = llm_service.save_llm_result(
            db=db,
            user_response_id=db_response.id,
            llm_result=llm_result,
            prompt_used=prompt_text,
            user_id=user_id
        )
        
        # 6. Convertir el resultado del LLM a formato para red neuronal
        logger.info("Paso 6: Convirtiendo resultado a formato para red neuronal")
        
        # Convertir el formato de MBTI_vector si está presente, de lo contrario usar [1, 1, 1, 1] como ejemplo
        mbti_vector = llm_result.mbti_vector if llm_result.mbti_vector else [1, 1, 1, 1]
        
        # Asegurarnos de que todos los elementos del vector son enteros
        mbti_vector = [int(v) for v in mbti_vector]
        logger.info(f"Vector MBTI convertido: {mbti_vector}")
        
        # Crear objeto MBTIResult para la red neuronal
        mbti_result = MBTIResult(
            MBTI_code=llm_result.mbti_result,
            MBTI_vector=mbti_vector,
            MBTI_weights={
                "E/I": 0.8,  # Estos valores se podrían inferir del llm_result.mbti_weights
                "S/N": 0.7,  # Por ahora usamos valores de ejemplo
                "T/F": 0.9,
                "J/P": 0.6
            }
        )
        
        # Crear objeto MIResult para la red neuronal basado en el ranking de MI
        # Convertir el ranking de MI a puntuaciones (las primeras tienen mayor puntuación)
        mi_scores = {}
        mi_types = ["Lin", "LogMath", "Spa", "BodKin", "Mus", "Inter", "Intra", "Nat"]
        
        # Asignar puntuaciones basadas en el ranking (si está disponible)
        if llm_result.mi_ranking:
            for i, mi_type in enumerate(llm_result.mi_ranking):
                # Mapear nombres largos a códigos cortos
                mi_code = None
                if "Lingüística" in mi_type:
                    mi_code = "Lin"
                elif "Lógico" in mi_type or "Matemática" in mi_type:
                    mi_code = "LogMath"
                elif "Espacial" in mi_type:
                    mi_code = "Spa"
                elif "Corporal" in mi_type or "Kinestésica" in mi_type:
                    mi_code = "BodKin"
                elif "Musical" in mi_type:
                    mi_code = "Mus"
                elif "Interpersonal" in mi_type:
                    mi_code = "Inter"
                elif "Intrapersonal" in mi_type:
                    mi_code = "Intra"
                elif "Natural" in mi_type:
                    mi_code = "Nat"
                
                if mi_code:
                    # Asignar puntuación inversamente proporcional a la posición en el ranking
                    mi_scores[mi_code] = 1.0 - (i * 0.1)  # De 1.0 a 0.3 aproximadamente
        
        # Si no hay puntuaciones para algún tipo, asignar un valor por defecto
        for mi_type in mi_types:
            if mi_type not in mi_scores:
                mi_scores[mi_type] = 0.5  # Valor neutro
        
        mi_result = MIResult(MI_scores=mi_scores)
        
        # 7. Usar la red neuronal para obtener recomendaciones de carreras
        logger.info("Paso 7: Obteniendo recomendaciones de carreras con la red neuronal")
        career_recommendations = neural_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=5,  # Obtener 5 recomendaciones
            use_cnn=False  # Usar el modelo FNN por defecto
        )
        
        # 8. Devolver el resultado completo
        logger.info("Paso 8: Preparando respuesta final")
        
        result = {
            "status": "success",
            "message": "Procesamiento y recomendación completados",
            "response_id": db_response.id,
            "llm_result_id": db_result.id,
            "llm_provider": llm_provider,
            "mbti_profile": {
                "code": llm_result.mbti_result,
                "weights": llm_result.mbti_weights,
                "vector": mbti_vector
            },
            "mi_ranking": llm_result.mi_ranking,
            "career_recommendations": career_recommendations
        }
        
        logger.info("Procesamiento completo finalizado exitosamente")
        return result
        
    except Exception as e:
        logger.error(f"Error en el procesamiento completo: {str(e)}", exc_info=True)
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=500,
            detail=f"Error en el procesamiento completo: {str(e)}"
        )

@router.get("/health")
async def health_check():
    """
    Simple health check endpoint
    """
    return {"status": "ok"} 