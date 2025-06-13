from typing import Any, Dict, List, Optional, Union
from sqlalchemy.orm import Session
import json

from app.db.models import User, MBTIProfile, MIProfile, Career, CareerMatch

# Operaciones CRUD para usuarios

def get_user(db: Session, user_id: int) -> Optional[User]:
    """Obtener un usuario por su ID"""
    return db.query(User).filter(User.id == user_id).first()

def get_user_by_email(db: Session, email: str) -> Optional[User]:
    """Obtener un usuario por su email"""
    return db.query(User).filter(User.email == email).first()

def get_users(db: Session, skip: int = 0, limit: int = 100) -> List[User]:
    """Obtener lista de usuarios con paginación"""
    return db.query(User).offset(skip).limit(limit).all()

def create_user(db: Session, user_data: Dict[str, Any]) -> User:
    """Crear un nuevo usuario"""
    db_user = User(**user_data)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# Operaciones CRUD para perfiles MBTI

def create_mbti_profile(db: Session, user_id: int, mbti_code: str, 
                       mbti_vector: List[int], mbti_weights: Dict[str, float]) -> MBTIProfile:
    """Crear un nuevo perfil MBTI para un usuario"""
    db_profile = MBTIProfile(
        user_id=user_id,
        mbti_code=mbti_code,
        mbti_vector=mbti_vector,
        mbti_weights=mbti_weights
    )
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)
    return db_profile

def get_user_mbti_profiles(db: Session, user_id: int) -> List[MBTIProfile]:
    """Obtener todos los perfiles MBTI de un usuario"""
    return db.query(MBTIProfile).filter(MBTIProfile.user_id == user_id).all()

def get_latest_mbti_profile(db: Session, user_id: int) -> Optional[MBTIProfile]:
    """Obtener el perfil MBTI más reciente de un usuario"""
    return db.query(MBTIProfile).filter(
        MBTIProfile.user_id == user_id
    ).order_by(MBTIProfile.created_at.desc()).first()

# Operaciones CRUD para perfiles de Inteligencias Múltiples

def create_mi_profile(db: Session, user_id: int, mi_scores: Dict[str, float]) -> MIProfile:
    """Crear un nuevo perfil de Inteligencias Múltiples para un usuario"""
    db_profile = MIProfile(
        user_id=user_id,
        mi_scores=mi_scores
    )
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)
    return db_profile

def get_user_mi_profiles(db: Session, user_id: int) -> List[MIProfile]:
    """Obtener todos los perfiles MI de un usuario"""
    return db.query(MIProfile).filter(MIProfile.user_id == user_id).all()

def get_latest_mi_profile(db: Session, user_id: int) -> Optional[MIProfile]:
    """Obtener el perfil MI más reciente de un usuario"""
    return db.query(MIProfile).filter(
        MIProfile.user_id == user_id
    ).order_by(MIProfile.created_at.desc()).first()

# Operaciones CRUD para carreras

def get_career(db: Session, career_id: int) -> Optional[Career]:
    """Obtener una carrera por su ID"""
    return db.query(Career).filter(Career.id == career_id).first()

def get_careers(db: Session, skip: int = 0, limit: int = 100) -> List[Career]:
    """Obtener lista de carreras con paginación"""
    return db.query(Career).offset(skip).limit(limit).all()

def create_career(db: Session, career_data: Dict[str, Any]) -> Career:
    """Crear una nueva carrera"""
    db_career = Career(**career_data)
    db.add(db_career)
    db.commit()
    db.refresh(db_career)
    return db_career

def get_careers_by_location(db: Session, location: str) -> List[Career]:
    """Obtener carreras por ubicación"""
    return db.query(Career).filter(Career.ubicacion.ilike(f"%{location}%")).all()

def import_careers_from_json(db: Session, careers_data: List[Dict[str, Any]]) -> List[Career]:
    """Importar carreras desde datos JSON"""
    db_careers = []
    for career_data in careers_data:
        # Verificar si la carrera ya existe
        existing = db.query(Career).filter(
            Career.nombre == career_data["nombre"],
            Career.universidad == career_data["universidad"]
        ).first()
        
        if not existing:
            db_career = Career(**career_data)
            db.add(db_career)
            db_careers.append(db_career)
    
    db.commit()
    
    # Refrescar las instancias
    for career in db_careers:
        db.refresh(career)
    
    return db_careers

# Operaciones CRUD para coincidencias de carreras

def create_career_match(db: Session, user_id: int, career_id: int, 
                       match_score: float, mbti_profile_id: Optional[int] = None,
                       mi_profile_id: Optional[int] = None) -> CareerMatch:
    """Crear una nueva coincidencia de carrera para un usuario"""
    db_match = CareerMatch(
        user_id=user_id,
        career_id=career_id,
        match_score=match_score,
        mbti_profile_id=mbti_profile_id,
        mi_profile_id=mi_profile_id
    )
    db.add(db_match)
    db.commit()
    db.refresh(db_match)
    return db_match

def get_user_career_matches(db: Session, user_id: int) -> List[CareerMatch]:
    """Obtener todas las coincidencias de carreras de un usuario"""
    return db.query(CareerMatch).filter(
        CareerMatch.user_id == user_id
    ).order_by(CareerMatch.match_score.desc()).all()

def get_latest_user_career_matches(db: Session, user_id: int, limit: int = 5) -> List[CareerMatch]:
    """Obtener las coincidencias de carreras más recientes de un usuario"""
    return db.query(CareerMatch).filter(
        CareerMatch.user_id == user_id
    ).order_by(CareerMatch.timestamp.desc()).limit(limit).all() 