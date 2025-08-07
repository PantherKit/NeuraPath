from beanie import Document
from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import List, Dict, Optional, Any
from bson import ObjectId

class User(Document):
    """Modelo de usuario para MongoDB"""
    email: str
    name: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Settings:
        name = "users"

class Career(Document):
    """Modelo de carrera STEM para MongoDB"""
    nombre: str
    descripcion: str
    stem_area: str
    # Removido riasec_profile - ya no usamos RIASEC
    
    class Settings:
        name = "careers"

class GameSession(Document):
    """Sesión completa del juego de 4 niveles"""
    model_config = ConfigDict(arbitrary_types_allowed=True)
    
    user_id: Optional[ObjectId] = None
    session_id: str
    
    # Respuestas de cada nivel (4 niveles sin RIASEC)
    mbti_responses: Optional[List[Dict]] = None
    mi_responses: Optional[List[Dict]] = None
    srlas_responses: Optional[List[Dict]] = None  # Self-Regulation, Learning, Affective Strategies
    
    # Resultados procesados
    mbti_result: Optional[Dict] = None  # {"MBTI_code": "INTP", "MBTI_vector": [1,1,0,1], "MBTI_weights": {...}}
    mi_result: Optional[Dict] = None    # {"MI_scores": {"Lin": 0.7, "LogMath": 0.9, ...}}
    srlas_result: Optional[Dict] = None # {"SRLAS_scores": {"Self_Regulation": 0.8, ...}}
    
    # Recomendaciones finales de carreras
    career_recommendations: Optional[List[Dict]] = None
    
    # Análisis generado por LLM
    career_analysis: Optional[str] = None
    
    # Metadatos de la sesión
    created_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    total_score: Optional[float] = None
    completion_time_seconds: Optional[int] = None
    
    class Settings:
        name = "game_sessions"

class LLMResult(Document):
    """Resultados del análisis del LLM"""
    model_config = ConfigDict(arbitrary_types_allowed=True)
    
    session_id: str
    user_id: Optional[ObjectId] = None
    
    # Resultados del LLM
    mbti_analysis: Optional[Dict] = None
    mi_analysis: Optional[Dict] = None
    srlas_analysis: Optional[Dict] = None
    career_analysis: Optional[str] = None
    
    # Metadatos
    prompt_used: str
    llm_provider: str  # "openai", "anthropic", "mock"
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Settings:
        name = "llm_results"

# Pydantic models para requests/responses
class QuestionResponse(BaseModel):
    """Respuesta a una pregunta individual"""
    id: str
    dimension: str
    likert_score: int = Field(..., ge=1, le=5)

class MBTIResult(BaseModel):
    """Resultado del análisis MBTI"""
    MBTI_code: str  # e.g., "INTP"
    MBTI_vector: List[int]  # e.g., [1, 1, 0, 1]
    MBTI_weights: Dict[str, float]  # e.g., {"E/I": 0.8, "S/N": 0.6, ...}
    ei: str
    sn: str
    tf: str
    jp: str
    ei_score: float
    sn_score: float
    tf_score: float
    jp_score: float

class MIResult(BaseModel):
    """Resultado del análisis de Inteligencias Múltiples"""
    MI_scores: Dict[str, float]  # e.g., {"Lin": 0.7, "LogMath": 0.9, ...}

class SRLASResult(BaseModel):
    """Resultado del análisis SRLAS"""
    SRLAS_scores: Dict[str, float]  # {"Self_Regulation": 0.8, "Learning_Strategies": 0.6, "Affective_Strategies": 0.7}
    profile_description: str
    learning_recommendations: List[str]

class CareerMatch(BaseModel):
    """Recomendación de carrera"""
    nombre: str
    descripcion: str
    stem_area: str
    match_score: float

class CompleteGameRequest(BaseModel):
    """Request para el flujo completo del juego"""
    mbti_responses: List[QuestionResponse]
    mi_responses: List[QuestionResponse]
    srlas_responses: List[QuestionResponse]
    user_id: Optional[str] = None
    session_id: Optional[str] = None

class CompleteGameResult(BaseModel):
    """Resultado completo del juego de 4 niveles"""
    session_id: str
    user_id: Optional[str] = None
    
    # Resultados de cada nivel
    mbti_result: MBTIResult
    mi_result: MIResult
    srlas_result: SRLASResult
    
    # Recomendaciones finales
    career_recommendations: List[CareerMatch]
    
    # Análisis integrado
    career_analysis: Optional[str] = None
    
    # Metadatos
    total_score: float
    completion_time_seconds: Optional[int] = None
    completed_at: datetime