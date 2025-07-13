import os
from pathlib import Path
from dotenv import load_dotenv

# Cargar variables de entorno desde .env si existe
env_path = Path('.') / '.env'
if env_path.exists():
    load_dotenv(dotenv_path=env_path)

class Settings:
    # Información de la aplicación
    API_TITLE: str = "NeuraPath - STEM Career Recommendation API"
    API_DESCRIPTION: str = """
    🧠 **NeuraPath** - API inteligente para recomendaciones de carreras STEM

    Esta API utiliza análisis de personalidad MBTI, evaluación de Inteligencias Múltiples y Machine Learning 
    para recomendar carreras STEM personalizadas.

    ## Características principales:
    - 🔍 **Cuestionarios MBTI** (Myers-Briggs Type Indicator)
    - 🎯 **Evaluación de Inteligencias Múltiples** (Howard Gardner)
    - 🤖 **Modelos de ML/Neural Networks** para recomendaciones
    - 📊 **Dataset RIASEC** para análisis profesional
    - 💾 **Persistencia en PostgreSQL**

    ## Flujo de uso:
    1. Obtener preguntas (`/api/questions/`)
    2. Procesar respuestas (`/api/recommendations/`)  
    3. Recibir recomendaciones personalizadas de carreras STEM

    **Desarrollado para ayudar a estudiantes a encontrar su vocación STEM ideal.**
    """
    API_VERSION: str = "1.0.0"
    
    # Configuración de la base de datos
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_HOST: str = os.getenv("POSTGRES_HOST", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "stem_careers")
    
    # URL de la base de datos para SQLAlchemy
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"
    )
    
    # Configuración general
    DEBUG: bool = os.getenv("DEBUG", "True").lower() in ('true', '1', 't')
    
    # CORS
    CORS_ORIGINS: list = ["*"]  # Permitir cualquier origen en desarrollo
    CORS_CREDENTIALS: bool = True
    CORS_METHODS: list = ["*"]  # Permitir cualquier método
    CORS_HEADERS: list = ["*"]  # Permitir cualquier header

settings = Settings() 