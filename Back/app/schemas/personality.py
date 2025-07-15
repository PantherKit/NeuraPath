from typing import Dict, List, Optional, Any, Union
from pydantic import BaseModel, Field

# Schemas para el formato de escala Likert (nuevo)
class LikertQuestionResponse(BaseModel):
    id: str  # e.g., "ei_1", "ling_2"
    dimension: Optional[str] = None  # Para MBTI: "E/I", "S/N", etc.
    intelligence: Optional[str] = None  # Para MI: "Linguistic", "Musical", etc.
    likert_score: int = Field(..., ge=1, le=5)  # Escala 1-5

class MBTILikertResponse(BaseModel):
    id: str  # e.g., "ei_1"
    dimension: str  # "E/I", "S/N", "T/F", "J/P"
    likert_score: int = Field(..., ge=1, le=5)

class MILikertResponse(BaseModel):
    id: str  # e.g., "ling_1"
    intelligence: str  # "Linguistic", "Musical", etc.
    likert_score: int = Field(..., ge=1, le=5)

# Schemas para el formato anterior (legacy)
class MBTIQuestion(BaseModel):
    question_id: int
    dimension: str  # E/I, S/N, T/F, J/P
    user_choice: str  # E or I, S or N, etc.
    weight: float = Field(..., ge=0.0, le=1.0)  # between 0 and 1

# Schemas de resultados (actualizados)
class MBTIResult(BaseModel):
    MBTI_code: str  # e.g., "INTP"
    MBTI_vector: List[int]  # binary representation, e.g., [0, 1, 0, 0]
    MBTI_weights: Dict[str, float]  # e.g., {"E/I": 0.85, "S/N": 0.62, ...}

class MIResult(BaseModel):
    MI_scores: Dict[str, float]  # e.g., {"Linguistic": 0.7, "Logical-Mathematical": 0.9, ...}

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

# Schemas para respuestas de usuario (formato texto libre)
class QuestionResponse(BaseModel):
    pregunta: str
    respuesta: str

class UserResponseCreate(BaseModel):
    responses: List[QuestionResponse]
    session_id: Optional[str] = None
    user_id: Optional[int] = None

# Schemas para respuestas combinadas (nuevo formato unificado)
class CombinedQuestionResponse(BaseModel):
    """Schema unificado que puede manejar tanto preguntas MBTI como MI en formato Likert"""
    id: str  # e.g., "ei_1", "ling_2"
    question_type: str  # "mbti" o "mi"
    dimension: Optional[str] = None  # Para MBTI: "E/I", "S/N", etc.
    intelligence: Optional[str] = None  # Para MI: "Linguistic", "Musical", etc.
    likert_score: int = Field(..., ge=1, le=5)

class CombinedUserResponse(BaseModel):
    """Schema para envío combinado de respuestas MBTI y MI"""
    mbti_responses: List[MBTILikertResponse]
    mi_responses: List[MILikertResponse]
    session_id: Optional[str] = None
    user_id: Optional[int] = None

# Schemas de base de datos
class UserResponseDB(BaseModel):
    id: int
    session_id: str
    responses_data: List[Dict[str, str]]
    created_at: str
    user_id: Optional[int] = None
    
    class Config:
        orm_mode = True

class MBTIWeightDetail(BaseModel):
    value: str  # "I fuerte", "N medio", etc.
    score: Optional[float] = None

class LLMResultCreate(BaseModel):
    mbti_result: str  # e.g., "INTP"
    mbti_vector: Optional[List[float]] = None  # e.g., [0.1, 0.8, 0.2, 0.7]
    mbti_weights: Union[Dict[str, str], Dict[str, float]]  # Flexible para ambos formatos
    mi_ranking: List[str]  # e.g., ["Espacial", "Interpersonal", ...]
    full_analysis: Optional[Dict[str, Any]] = None

class LLMResultDB(BaseModel):
    id: int
    user_response_id: int
    mbti_result: str
    mbti_vector: Optional[List[float]] = None
    mbti_weights: Dict[str, Any]
    mi_ranking: List[str]
    full_result: Dict[str, Any]
    prompt_used: str
    created_at: str
    user_id: Optional[int] = None
    
    class Config:
        orm_mode = True

class LLMRequestPrompt(BaseModel):
    responses: List[QuestionResponse]
    
class LLMResponse(BaseModel):
    status: str
    message: str
    prompt: str
    raw_data: List[Dict[str, str]]

# Schemas para self-regulation (nuevo - placeholder para la tercera sección)
class SelfRegulationResponse(BaseModel):
    id: str  # e.g., "sr_1"
    dimension: str  # Dimensión de autorregulación
    likert_score: int = Field(..., ge=1, le=5)

class SelfRegulationResult(BaseModel):
    SR_scores: Dict[str, float]  # Puntuaciones de autorregulación 