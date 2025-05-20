from fastapi import APIRouter

from app.api.endpoints import recommendations, questions
 
api_router = APIRouter()
api_router.include_router(recommendations.router, prefix="/api/recommendations", tags=["recommendations"])
api_router.include_router(questions.router, prefix="/api/questions", tags=["questions"]) 