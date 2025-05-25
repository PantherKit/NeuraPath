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
from app.services.llm_profile_interpreter import LLMProfileInterpreter
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
    llm_provider: Optional[str] = Query("openai", description="Proveedor LLM a utilizar: openai, anthropic o mock"),
    include_analysis: Optional[bool] = Query(False, description="Incluir análisis detallado de las recomendaciones")
):
    """
    Procesa el flujo completo:
    1. Recibe las preguntas y respuestas
    2. Las guarda en la base de datos
    3. Usa el LLMProfileInterpreter para obtener el perfil MBTI y MI
    4. Guarda el resultado en la base de datos
    5. Pasa el resultado a la red neuronal para generar recomendaciones
    6. Opcionalmente, solicita un análisis de las recomendaciones al LLM
    7. Devuelve el resultado final con recomendaciones y análisis
    
    Args:
        questions_responses: Lista de preguntas y respuestas
        db: Sesión de base de datos
        user_id: ID del usuario (opcional)
        session_id: ID de sesión (opcional)
        llm_provider: Proveedor de LLM a utilizar (openai, anthropic, mock)
        include_analysis: Si se debe incluir un análisis detallado de las recomendaciones
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
        
        # 2. Usar el intérprete de perfiles para obtener los vectores
        logger.info("Paso 2: Obteniendo perfil MBTI y MI con LLMProfileInterpreter")
        profile_interpreter = LLMProfileInterpreter(llm_provider=llm_provider)
        mbti_vector, mbti_weights, mi_scores = await profile_interpreter.interpret_responses(questions_responses)
        
        # 3. Convertir el código MBTI a partir del vector
        letter_mapping = [
            ["E", "I"],
            ["S", "N"],
            ["T", "F"],
            ["J", "P"]
        ]
        mbti_code = "".join(letter_mapping[i][v] for i, v in enumerate(mbti_vector))
        logger.info(f"Código MBTI generado: {mbti_code}")
        
        # 4. Guardar el resultado en la base de datos (usando el servicio existente)
        # Crear un objeto LLMResultCreate para compatibilidad
        from app.schemas.personality import LLMResultCreate
        llm_result = LLMResultCreate(
            mbti_result=mbti_code,
            mbti_vector=mbti_vector,
            mbti_weights=mbti_weights,
            mi_ranking=list(mi_scores.keys()),  # Usar las claves como ranking
            full_analysis={
                "MBTI": mbti_code,
                "MBTI_vector": mbti_vector,
                "MBTI_weights": mbti_weights,
                "MI_scores": mi_scores
            }
        )
        
        logger.info("Paso 3: Guardando resultado en la base de datos")
        db_result = llm_service.save_llm_result(
            db=db,
            user_response_id=db_response.id,
            llm_result=llm_result,
            prompt_used="Generado con LLMProfileInterpreter",
            user_id=user_id
        )
        
        # 5. Crear objetos para la red neuronal
        logger.info("Paso 4: Preparando datos para la red neuronal")
        mbti_result = MBTIResult(
            MBTI_code=mbti_code,
            MBTI_vector=mbti_vector,
            MBTI_weights=mbti_weights
        )
        
        mi_result = MIResult(MI_scores=mi_scores)
        
        # 6. Usar la red neuronal para obtener recomendaciones de carreras
        logger.info("Paso 5: Obteniendo recomendaciones de carreras con la red neuronal")
        career_recommendations = neural_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=5,  # Obtener 5 recomendaciones
            use_cnn=False  # Usar el modelo FNN por defecto
        )
        
        # 7. Opcionalmente, solicitar un análisis de las recomendaciones al LLM
        career_analysis = None
        if include_analysis:
            logger.info("Paso 6: Solicitando análisis de recomendaciones al LLM")
            # Generar prompt para el análisis
            analysis_prompt = llm_service.generate_career_analysis_prompt(
                mbti_code=mbti_code,
                mi_scores=mi_scores,
                career_recommendations=career_recommendations
            )
            
            # Llamar al LLM para obtener análisis
            llm_api = LLMApiService()
            llm_response = await llm_api.call_llm(
                prompt=analysis_prompt,
                provider=llm_provider,
                max_tokens=1500  # Análisis más largo
            )
            
            # Procesar la respuesta
            analysis_result = llm_service.process_career_analysis_response(llm_response)
            career_analysis = analysis_result["analysis"]
            logger.info(f"Análisis de carreras generado: {len(career_analysis)} caracteres")
        
        # 8. Devolver el resultado completo
        logger.info("Paso final: Preparando respuesta final")
        
        result = {
            "status": "success",
            "message": "Procesamiento y recomendación completados",
            "response_id": db_response.id,
            "llm_result_id": db_result.id,
            "llm_provider": llm_provider,
            "mbti_profile": {
                "code": mbti_code,
                "weights": mbti_weights,
                "vector": mbti_vector
            },
            "mi_scores": mi_scores,
            "mi_ranking": list(mi_scores.keys()),  # Ordenar por valor descendente
            "career_recommendations": career_recommendations
        }
        
        # Incluir el análisis si fue solicitado
        if include_analysis and career_analysis:
            result["career_analysis"] = career_analysis
        
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

@router.post("/train-models")
async def train_neural_models(
    num_samples: int = Query(1000, description="Número de muestras a generar para entrenamiento"),
    epochs: int = Query(50, description="Número de epochs para entrenamiento"),
    batch_size: int = Query(32, description="Tamaño del batch para entrenamiento"),
    validation: bool = Query(True, description="Si se debe realizar validación cruzada")
):
    """
    Entrena los modelos neuronales con datos sintéticos
    
    Args:
        num_samples: Número de muestras para entrenamiento
        epochs: Número de epochs para entrenamiento
        batch_size: Tamaño del batch
        validation: Si se debe realizar validación cruzada
    """
    try:
        logger.info(f"Iniciando entrenamiento de modelos con {num_samples} muestras")
        result = neural_service.train_models(
            num_samples=num_samples,
            epochs=epochs,
            batch_size=batch_size,
            validation=validation
        )
        return result
    except Exception as e:
        logger.error(f"Error entrenando modelos: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error entrenando modelos: {str(e)}"
        )

@router.get("/evaluate-models")
async def evaluate_neural_models(
    num_samples: int = Query(500, description="Número de muestras a generar para evaluación")
):
    """
    Evalúa los modelos neuronales con datos sintéticos
    
    Args:
        num_samples: Número de muestras para evaluación
    """
    try:
        logger.info(f"Iniciando evaluación de modelos con {num_samples} muestras")
        result = neural_service.evaluate_models(num_samples=num_samples)
        
        if "error" in result:
            raise HTTPException(
                status_code=400,
                detail=result["error"]
            )
            
        return result
    except Exception as e:
        logger.error(f"Error evaluando modelos: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error evaluando modelos: {str(e)}"
        ) 