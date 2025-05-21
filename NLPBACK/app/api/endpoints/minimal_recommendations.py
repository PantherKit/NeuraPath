from fastapi import APIRouter, Depends, HTTPException, Query, BackgroundTasks
from typing import Dict, List, Optional, Any
from pydantic import BaseModel

from app.schemas.personality import MBTIResult, MIResult, CareerMatch
from app.services.minimal_service import MinimalNeuralService, MinimalRecommendationService
from app.scripts.train_with_riasec import train_model_with_riasec

router = APIRouter()
minimal_service = MinimalRecommendationService()

class TrainingData(BaseModel):
    training_data: List[Dict[str, Any]]
    career_names: List[str]

class TrainingResponse(BaseModel):
    message: str
    accuracy: float

class RIASECTrainingParams(BaseModel):
    sample_size: Optional[int] = 5000
    save_training_data: Optional[bool] = False

@router.post("/train", response_model=TrainingResponse)
async def train_model(training_data: TrainingData):
    try:
        # Extraer datos de entrenamiento
        result = minimal_service.train_model(training_data.training_data, training_data.career_names)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error entrenando modelo: {str(e)}")

@router.post("/train_with_riasec", response_model=TrainingResponse)
async def train_with_riasec_data(params: RIASECTrainingParams, background_tasks: BackgroundTasks):
    try:
        # Usar muestra más pequeña para respuesta rápida
        result = minimal_service.train_with_riasec(
            sample_size=1000,  # Muestra inicial pequeña para respuesta rápida
            verbose=False
        )
        
        # Continuar entrenamiento en segundo plano con muestra completa si se solicita
        if params.sample_size != 1000:
            background_tasks.add_task(
                minimal_service.train_with_riasec,
                sample_size=params.sample_size,
                save_training_data=params.save_training_data,
                verbose=True
            )
            
            return {
                "message": f"Modelo inicializado con 1000 muestras. Continuando entrenamiento en segundo plano con {params.sample_size if params.sample_size else 'todas las'} muestras.",
                "accuracy": result["accuracy"]
            }
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error entrenando modelo con datos RIASEC: {str(e)}")

@router.post("/predict", response_model=List[CareerMatch])
async def predict_minimal(
    mbti_result: MBTIResult,
    mi_result: MIResult
):
    """
    Predice carreras recomendadas basadas en perfiles MBTI e inteligencias múltiples
    usando el modelo RandomForest.
    """
    try:
        predictions = minimal_service.predict(mbti_result, mi_result)
        return predictions
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en la predicción: {str(e)}")

@router.get("/compare", response_model=Dict[str, Any])
async def compare_with_original(
    mbti_result: MBTIResult,
    mi_result: MIResult,
    top_n: Optional[int] = Query(3, description="Número de recomendaciones a devolver")
):
    """
    Compara las recomendaciones del modelo RandomForest con el modelo basado en similitud coseno
    """
    try:
        # Obtener recomendaciones del modelo RandomForest
        rf_recommendations = minimal_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n
        )
        
        # Obtener recomendaciones del modelo de similitud coseno
        cosine_recommendations = minimal_service.career_recommender.recommend_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n
        )
        
        return {
            "rf_recommendations": rf_recommendations,
            "cosine_recommendations": cosine_recommendations,
            "mbti_profile": mbti_result.MBTI_code
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error comparando modelos: {str(e)}") 