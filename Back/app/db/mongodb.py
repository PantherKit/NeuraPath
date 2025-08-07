import motor.motor_asyncio
from beanie import init_beanie
import json
import os
from pathlib import Path
from typing import List
from app.core.config import settings
from app.db.models import User, Career, GameSession, LLMResult

# Cliente MongoDB
client = motor.motor_asyncio.AsyncIOMotorClient(settings.MONGODB_URL)
database = client[settings.MONGODB_DB_NAME]

async def init_db():
    """Inicializar MongoDB con Beanie ODM"""
    print("🍃 Inicializando MongoDB...")
    
    # Inicializar Beanie con nuestros modelos
    await init_beanie(
        database=database,
        document_models=[User, Career, GameSession, LLMResult]
    )
    
    print("✅ Beanie ODM inicializado")
    
    # Inicializar carreras si no existen
    career_count = await Career.count()
    if career_count == 0:
        print("📚 Inicializando carreras STEM...")
        await init_careers()
    else:
        print(f"📚 Ya existen {career_count} carreras en la base de datos")

async def init_careers():
    """Inicializar las 17 carreras STEM desde el archivo JSON"""
    try:
        # Ruta al archivo de carreras
        careers_file = Path(__file__).parent.parent / "data" / "careers.json"
        
        if not careers_file.exists():
            print(f"❌ No se encontró el archivo de carreras: {careers_file}")
            return
        
        # Leer carreras desde JSON
        with open(careers_file, "r", encoding="utf-8") as f:
            careers_data = json.load(f)
        
        # Crear documentos Career
        careers = []
        for career_data in careers_data:
            career = Career(
                nombre=career_data["nombre"],
                descripcion=career_data["descripcion"],
                stem_area=career_data["stem_area"]
            )
            careers.append(career)
        
        # Insertar en MongoDB
        await Career.insert_many(careers)
        print(f"✅ Insertadas {len(careers)} carreras STEM en MongoDB")
        
    except Exception as e:
        print(f"❌ Error inicializando carreras: {str(e)}")

async def get_database():
    """Obtener la instancia de la base de datos"""
    return database

async def close_db():
    """Cerrar conexión a MongoDB"""
    client.close()
    print("🍃 Conexión a MongoDB cerrada")

# Funciones CRUD para GameSession
async def create_game_session(session_id: str, user_id: str = None) -> GameSession:
    """Crear nueva sesión de juego"""
    session = GameSession(
        session_id=session_id,
        user_id=user_id
    )
    await session.insert()
    return session

async def get_game_session(session_id: str) -> GameSession:
    """Obtener sesión de juego por ID"""
    return await GameSession.find_one(GameSession.session_id == session_id)

async def update_game_session(session_id: str, update_data: dict) -> GameSession:
    """Actualizar sesión de juego"""
    session = await get_game_session(session_id)
    if session:
        for key, value in update_data.items():
            setattr(session, key, value)
        await session.save()
    return session

async def complete_game_session(session_id: str) -> GameSession:
    """Marcar sesión como completada"""
    from datetime import datetime
    return await update_game_session(session_id, {
        "completed_at": datetime.utcnow()
    })

# Funciones CRUD para Career
async def get_all_careers() -> List[Career]:
    """Obtener todas las carreras"""
    return await Career.find_all().to_list()

async def get_career_by_name(nombre: str) -> Career:
    """Obtener carrera por nombre"""
    return await Career.find_one(Career.nombre == nombre)

# Funciones CRUD para LLMResult
async def create_llm_result(session_id: str, prompt_used: str, 
                           llm_provider: str, **analysis_data) -> LLMResult:
    """Crear resultado de análisis LLM"""
    result = LLMResult(
        session_id=session_id,
        prompt_used=prompt_used,
        llm_provider=llm_provider,
        **analysis_data
    )
    await result.insert()
    return result