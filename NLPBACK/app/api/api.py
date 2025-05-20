from fastapi import APIRouter

from app.api.endpoints import recommendations, questions, neural_recommendations, minimal_recommendations
 
api_router = APIRouter()
api_router.include_router(recommendations.router, prefix="/api/recommendations", tags=["recommendations"])
api_router.include_router(questions.router, prefix="/api/questions", tags=["questions"]) 
api_router.include_router(neural_recommendations.router, prefix="/api/neural", tags=["neural_recommendations"])
api_router.include_router(minimal_recommendations.router, prefix="/api/minimal", tags=["minimal_recommendations"]) 

# Añadir endpoint de health check directamente en el router principal
@api_router.get("/health", tags=["health"])
async def health_check():
    """Endpoint para verificar que la API está funcionando."""
    return {"status": "ok"} 