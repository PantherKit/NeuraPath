import logging
import json
from pathlib import Path
import os
from sqlalchemy.orm import Session

from app.db.session import Base, engine
from app.db import crud
from app.db.models import User, Career

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def init_db(db: Session) -> None:
    """Inicializar la base de datos con datos iniciales"""
    # Importar carreras desde el archivo JSON
    careers_path = Path(os.path.dirname(os.path.abspath(__file__))) / ".." / "data" / "careers.json"
    
    if careers_path.exists():
        with open(careers_path, "r", encoding="utf-8") as f:
            careers_data = json.load(f)
        
        logger.info(f"Importando {len(careers_data)} carreras desde {careers_path}")
        imported_careers = crud.import_careers_from_json(db, careers_data)
        logger.info(f"Se importaron {len(imported_careers)} carreras nuevas")
    else:
        logger.warning(f"No se encontró el archivo de carreras en: {careers_path}")
    
    # Crear usuario de prueba si no existe
    test_user = crud.get_user_by_email(db, "test@example.com")
    if not test_user:
        logger.info("Creando usuario de prueba")
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "hashed_password": "testpassword",  # En producción, esto debe ser hash
            "is_active": True
        }
        test_user = crud.create_user(db, user_data)

def create_tables() -> None:
    """Crear todas las tablas en la base de datos"""
    logger.info("Creando tablas en la base de datos...")
    Base.metadata.create_all(bind=engine)
    logger.info("¡Tablas creadas!")

def init() -> None:
    """Inicializar la base de datos completa"""
    from app.db.session import SessionLocal
    
    # Crear tablas
    create_tables()
    
    # Inicializar con datos
    db = SessionLocal()
    try:
        init_db(db)
    finally:
        db.close()

if __name__ == "__main__":
    logger.info("Inicializando base de datos...")
    init()
    logger.info("Base de datos inicializada correctamente") 