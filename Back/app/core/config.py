import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # MongoDB Configuration
    MONGODB_URL: str = "mongodb://localhost:27017"
    MONGODB_DB_NAME: str = "neurapath"
    
    # API Configuration
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_TITLE: str = "NeuraPath API"
    API_DESCRIPTION: str = "API for STEM career recommendations using AI"
    API_VERSION: str = "1.0.0"
    DEBUG: bool = True
    ALLOW_AUTO_TRAIN: bool = True  # Deshabilitar en prod
    LLM_TIMEOUT_SECONDS: int = 30
    
    # LLM Configuration
    OPENAI_API_KEY: str = ""
    ANTHROPIC_API_KEY: str = ""
    APIKEY: str = ""  # Alias para OPENAI_API_KEY
    
    # Security
    SECRET_KEY: str = "your-super-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Environment
    ENVIRONMENT: str = "development"
    
    # CORS Configuration
    CORS_ORIGINS: str = '["*"]'
    CORS_CREDENTIALS: bool = True
    CORS_METHODS: str = '["*"]'
    CORS_HEADERS: str = '["*"]'
    
    # Legacy fields - ignored
    POSTGRES_DB: str = ""
    POSTGRES_HOST: str = ""
    POSTGRES_PORT: str = ""
    DATABASE_URL: str = ""
    
    class Config:
        env_file = ".env"
        extra = "ignore"  # Ignorar campos extras en Pydantic V2

settings = Settings()