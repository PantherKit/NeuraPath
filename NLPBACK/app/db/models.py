from sqlalchemy import Column, Integer, String, Float, ForeignKey, Table, Text, DateTime, Boolean, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.session import Base

# Tabla de asociación para la relación muchos a muchos entre Usuario y Carrera
user_career_association = Table(
    'user_career_association',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id'), primary_key=True),
    Column('career_id', Integer, ForeignKey('careers.id'), primary_key=True)
)

class User(Base):
    """Modelo de usuario"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relaciones
    mbti_profiles = relationship("MBTIProfile", back_populates="user")
    mi_profiles = relationship("MIProfile", back_populates="user")
    career_matches = relationship("Career", secondary=user_career_association, back_populates="matched_users")

class MBTIProfile(Base):
    """Modelo para almacenar perfiles de personalidad MBTI"""
    __tablename__ = "mbti_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    mbti_code = Column(String(4))  # INTP, ESTJ, etc.
    mbti_vector = Column(JSON)  # [0, 1, 0, 1] correspondiente a [E/I, S/N, T/F, J/P]
    mbti_weights = Column(JSON)  # {"E/I": 0.8, "S/N": 0.6, ...}
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relación con el usuario
    user = relationship("User", back_populates="mbti_profiles")

class MIProfile(Base):
    """Modelo para almacenar perfiles de Inteligencias Múltiples"""
    __tablename__ = "mi_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    mi_scores = Column(JSON)  # {"Lin": 0.7, "LogMath": 0.9, ...}
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relación con el usuario
    user = relationship("User", back_populates="mi_profiles")

class Career(Base):
    """Modelo para almacenar carreras STEM"""
    __tablename__ = "careers"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True)
    universidad = Column(String, index=True)
    descripcion = Column(Text)
    ubicacion = Column(String, index=True)
    
    # Campos para búsqueda y filtrado
    area_conocimiento = Column(String, index=True, nullable=True)
    nivel_estudio = Column(String, nullable=True)  # Licenciatura, Posgrado, etc.
    duracion = Column(String, nullable=True)
    
    # Relaciones
    matched_users = relationship("User", secondary=user_career_association, back_populates="career_matches")

class CareerMatch(Base):
    """Modelo para almacenar recomendaciones de carreras a usuarios"""
    __tablename__ = "career_matches"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    career_id = Column(Integer, ForeignKey("careers.id"))
    match_score = Column(Float)  # Puntuación de coincidencia (0.0 a 1.0)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    
    # Parámetros usados en la recomendación
    mbti_profile_id = Column(Integer, ForeignKey("mbti_profiles.id"), nullable=True)
    mi_profile_id = Column(Integer, ForeignKey("mi_profiles.id"), nullable=True)
    
    # Relaciones
    career = relationship("Career")
    user = relationship("User")
    mbti_profile = relationship("MBTIProfile")
    mi_profile = relationship("MIProfile") 