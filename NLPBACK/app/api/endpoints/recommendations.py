from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional

from app.schemas.personality import MBTIQuestion, MIResult, MBTIResult, UserProfile, CareerMatch
from app.services.recommendation_service import RecommendationService

router = APIRouter()
recommendation_service = RecommendationService()

@router.post("/mbti", response_model=MBTIResult)
async def process_mbti(mbti_questions: List[MBTIQuestion]):
    """
    Process MBTI questions and return MBTI profile
    """
    try:
        # Convert pydantic models to dictionaries
        questions_data = [q.model_dump() for q in mbti_questions]
        result = recommendation_service.process_mbti_answers(questions_data)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error processing MBTI questions: {str(e)}")

@router.post("/multiple-intelligence", response_model=MIResult)
async def process_mi(mi_responses: List[dict]):
    """
    Process multiple intelligence responses and return MI profile
    """
    try:
        result = recommendation_service.process_mi_answers(mi_responses)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error processing MI responses: {str(e)}")

@router.post("/recommendations", response_model=UserProfile)
async def get_recommendations(
    mbti_questions: List[MBTIQuestion],
    mi_responses: List[dict],
    top_n: Optional[int] = Query(3, description="Number of recommendations to return"),
    location_filter: Optional[str] = Query(None, description="Filter results by location")
):
    """
    Get full user profile with career recommendations based on MBTI and MI profiles
    """
    try:
        # Convert pydantic models to dictionaries
        mbti_data = [q.model_dump() for q in mbti_questions]
        
        # Get full profile
        profile = recommendation_service.get_full_profile(
            mbti_data, mi_responses, top_n, location_filter
        )
        return profile
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error generating recommendations: {str(e)}")

@router.post("/filtered-recommendations", response_model=List[CareerMatch])
async def get_filtered_recommendations(
    mbti_result: MBTIResult,
    mi_result: MIResult,
    top_n: Optional[int] = Query(3, description="Number of recommendations to return"),
    location_filter: Optional[str] = Query(None, description="Filter results by location")
):
    """
    Get career recommendations with optional filtering based on already processed MBTI and MI profiles
    """
    try:
        recommendations = recommendation_service.get_career_recommendations(
            mbti_result.model_dump(), mi_result.model_dump(), top_n, location_filter
        )
        return recommendations["career_recommendations"]
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error generating filtered recommendations: {str(e)}")

@router.get("/profile-description")
async def get_profile_description(
    mbti_code: str,
    mbti_weights: dict,
    mi_scores: dict
):
    """
    Generate a personalized STEM profile description based on MBTI and MI results
    """
    try:
        description = recommendation_service.career_recommender.generate_profile_description(
            mbti_code, mbti_weights, mi_scores["MI_scores"]
        )
        return {"profile_description": description}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error generating profile description: {str(e)}")

@router.get("/health")
async def health_check():
    """
    Simple health check endpoint
    """
    return {"status": "ok"} 