from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Dict, List, Optional, Any

from app.schemas.personality import MBTIResult, MIResult, CareerMatch
from app.services.minimal_service import MinimalNeuralService

router = APIRouter()
minimal_service = MinimalNeuralService()

@router.post("/train", response_model=Dict[str, Any])
async def train_minimal_model(
    num_samples: Optional[int] = Query(1000, description="Número de muestras para entrenamiento")
):
    """
    Entrena el modelo RandomForest con datos sintéticos
    """
    try:
        result = minimal_service.train_model(num_samples=num_samples)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error entrenando modelo: {str(e)}")

@router.post("/recommendations", response_model=List[CareerMatch])
async def get_minimal_recommendations(
    mbti_result: MBTIResult,
    mi_result: MIResult,
    top_n: Optional[int] = Query(3, description="Número de recomendaciones a devolver")
):
    """
    Obtiene recomendaciones de carrera usando el modelo RandomForest
    """
    try:
        recommendations = minimal_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n
        )
        return recommendations
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando recomendaciones: {str(e)}")

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