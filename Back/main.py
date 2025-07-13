import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.api import api_router
from app.core.config import settings
from app.db.init_db import init

# Metadatos para los tags de Swagger
tags_metadata = [
    {
        "name": "health",
        "description": "🟢 **Health Check** - Verificar estado de la API",
    },
    {
        "name": "questions",
        "description": "❓ **Cuestionarios** - Obtener preguntas MBTI e Inteligencias Múltiples",
    },
    {
        "name": "recommendations",
        "description": "🎯 **Recomendaciones** - Procesar respuestas y generar recomendaciones de carreras",
    },
    {
        "name": "neural_recommendations",
        "description": "🧠 **Red Neuronal** - Recomendaciones usando modelos CNN entrenados",
    },
    {
        "name": "minimal_recommendations",
        "description": "⚡ **Modelo Minimal** - Recomendaciones rápidas usando Random Forest",
    },
]

# Crear la aplicación FastAPI
app = FastAPI(
    title=settings.API_TITLE,
    description=settings.API_DESCRIPTION,
    version=settings.API_VERSION,
    docs_url="/docs",  # Swagger UI URL
    redoc_url="/redoc",  # ReDoc URL
    openapi_url="/openapi.json",  # OpenAPI schema URL
    openapi_tags=tags_metadata,
    contact={
        "name": "NeuraPath Team",
        "url": "https://github.com/yourusername/neurapath",
        "email": "contact@neurapath.com",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/licenses/MIT",
    },
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=settings.CORS_CREDENTIALS,
    allow_methods=settings.CORS_METHODS,
    allow_headers=settings.CORS_HEADERS,
)

# Incluir los routers
app.include_router(api_router)

# Evento de inicio
@app.on_event("startup")
async def startup_event():
    """Inicializar la base de datos al iniciar la aplicación"""
    init()

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=settings.DEBUG) 