from typing import Dict, List, Optional
from pydantic import BaseModel, Field

class MBTIQuestion(BaseModel):
    question_id: int
    dimension: str  # E/I, S/N, T/F, J/P
    user_choice: str  # E or I, S or N, etc.
    weight: float = Field(..., ge=0.0, le=1.0)  # between 0 and 1

class MBTIResult(BaseModel):
    MBTI_code: str  # e.g., "INTP"
    MBTI_vector: List[int]  # binary representation, e.g., [0, 1, 0, 0]
    MBTI_weights: Dict[str, float]  # e.g., {"E/I": 0.85, "S/N": 0.62, ...}

class MIResult(BaseModel):
    MI_scores: Dict[str, float]  # e.g., {"Lin": 0.7, "LogMath": 0.9, ...}

class CareerPrediction(BaseModel):
    top_predictions: List[str]
    confidence: List[float]

class Career(BaseModel):
    nombre: str
    universidad: str
    descripcion: str
    ubicacion: str
    
class CareerMatch(BaseModel):
    nombre: str
    universidad: str
    ciudad: str
    match_score: float

class UserProfile(BaseModel):
    mbti_result: Optional[MBTIResult] = None
    mi_result: Optional[MIResult] = None
    career_recommendations: Optional[List[CareerMatch]] = None
    profile_description: Optional[str] = None 