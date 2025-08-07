import os
import json
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.api import api_router
from app.core.config import settings
from app.db.mongodb import init_db, close_db

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

# Configurar CORS (permitir lista o string JSON)
def _parse_list(value):
    if isinstance(value, list):
        return value
    try:
        return json.loads(value)
    except Exception:
        return ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_parse_list(settings.CORS_ORIGINS),
    allow_credentials=bool(settings.CORS_CREDENTIALS),
    allow_methods=_parse_list(settings.CORS_METHODS),
    allow_headers=_parse_list(settings.CORS_HEADERS),
)

# Incluir los routers
app.include_router(api_router)

# Eventos de inicio y cierre
@app.on_event("startup")
async def startup_event():
    """Inicializar MongoDB al iniciar la aplicación"""
    print("🚀 Iniciando NeuraPath API...")
    print("🍃 Inicializando MongoDB...")
    await init_db()
    print("✅ MongoDB inicializada")

@app.on_event("shutdown")
async def shutdown_event():
    """Cerrar conexión MongoDB al cerrar la aplicación"""
    print("🔄 Cerrando NeuraPath API...")
    await close_db()
    print("✅ API cerrada correctamente")

if __name__ == "__main__":
    # Cloud Run provee PORT por entorno (default 8080)
    port = int(os.getenv("PORT", "8080"))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=settings.DEBUG)