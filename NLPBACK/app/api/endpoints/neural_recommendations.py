from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Dict, List, Optional, Any
import asyncio

from app.schemas.personality import MBTIResult, MIResult, CareerMatch
from app.services.neural_service import NeuralCareerService
from app.services.llm_api_service import LLMApiService
from app.services.llm_service import LLMService

router = APIRouter()
neural_service = NeuralCareerService()
llm_api_service = LLMApiService()
llm_service = LLMService()

@router.post("/recommendations-with-analysis", response_model=Dict[str, Any])
async def get_neural_recommendations_with_analysis(
    mbti_result: MBTIResult,
    mi_result: MIResult,
    top_n: Optional[int] = Query(5, description="Número de recomendaciones a devolver"),
    use_cnn: Optional[bool] = Query(False, description="Usar modelo CNN en lugar de FNN"),
    llm_provider: Optional[str] = Query(None, description="Proveedor LLM a utilizar")
):
    """
    Obtiene recomendaciones de carrera usando el modelo neural entrenado
    junto con un análisis detallado generado por un LLM
    """
    try:
        # 1. Obtener recomendaciones del modelo neural
        recommendations = neural_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n,
            use_cnn=use_cnn
        )
        
        # 2. Generar un prompt para el LLM para analizar las recomendaciones
        analysis_prompt = llm_service.generate_career_analysis_prompt(
            mbti_code=mbti_result.MBTI_code,
            mi_scores=mi_result.MI_scores,
            career_recommendations=recommendations
        )
        
        # 3. Llamar al LLM para obtener el análisis
        llm_response = await llm_api_service.call_llm(
            prompt=analysis_prompt,
            provider=llm_provider,
            max_tokens=1500  # Análisis más largo
        )
        
        # 4. Procesar la respuesta del LLM
        analysis_result = llm_service.process_career_analysis_response(llm_response)
        
        # 5. Devolver tanto las recomendaciones como el análisis
        return {
            "recommendations": recommendations,
            "analysis": analysis_result["analysis"],
            "mbti_profile": mbti_result.MBTI_code,
            "model_type": "CNN" if use_cnn else "FNN"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando recomendaciones con análisis: {str(e)}")

@router.post("/reset", response_model=Dict[str, Any])
async def reset_neural_models():
    """
    Reinicia los modelos neurales para un nuevo entrenamiento
    """
    try:
        # Crear una nueva instancia del servicio
        global neural_service
        neural_service = NeuralCareerService()
        
        return {"message": "Modelos neurales reiniciados correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reiniciando modelos: {str(e)}")

@router.post("/train", response_model=Dict[str, Any])
async def train_neural_models(
    num_samples: Optional[int] = Query(1000, description="Número de muestras para entrenamiento"),
    epochs: Optional[int] = Query(50, description="Número de epochs para entrenamiento"),
    batch_size: Optional[int] = Query(32, description="Tamaño del batch")
):
    """
    Entrena los modelos neurales FNN y CNN con datos sintéticos
    """
    try:
        result = neural_service.train_models(
            num_samples=num_samples,
            epochs=epochs,
            batch_size=batch_size
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error entrenando modelos: {str(e)}")

@router.post("/recommendations", response_model=List[CareerMatch])
async def get_neural_recommendations(
    mbti_result: MBTIResult,
    mi_result: MIResult,
    top_n: Optional[int] = Query(3, description="Número de recomendaciones a devolver"),
    use_cnn: Optional[bool] = Query(False, description="Usar modelo CNN en lugar de FNN")
):
    """
    Obtiene recomendaciones de carrera usando el modelo neural entrenado
    """
    try:
        recommendations = neural_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n,
            use_cnn=use_cnn
        )
        return recommendations
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generando recomendaciones: {str(e)}")

@router.get("/compare", response_model=Dict[str, Any])
async def compare_models(
    mbti_result: MBTIResult,
    mi_result: MIResult,
    top_n: Optional[int] = Query(3, description="Número de recomendaciones a devolver")
):
    """
    Compara las recomendaciones del modelo neural (FNN y CNN) con el modelo basado en similitud coseno
    """
    try:
        # Obtener recomendaciones del modelo FNN
        fnn_recommendations = neural_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n,
            use_cnn=False
        )
        
        # Obtener recomendaciones del modelo CNN
        cnn_recommendations = neural_service.predict_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n,
            use_cnn=True
        )
        
        # Obtener recomendaciones del modelo de similitud coseno
        cosine_recommendations = neural_service.career_recommender.recommend_careers(
            mbti_code=mbti_result.MBTI_code,
            mbti_vector=mbti_result.MBTI_vector,
            mbti_weights=mbti_result.MBTI_weights,
            mi_scores=mi_result.MI_scores,
            top_n=top_n
        )
        
        return {
            "fnn_recommendations": fnn_recommendations,
            "cnn_recommendations": cnn_recommendations,
            "cosine_recommendations": cosine_recommendations,
            "mbti_profile": mbti_result.MBTI_code
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error comparando modelos: {str(e)}") 