from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

# Crear el motor de SQLAlchemy
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,  # Verificar las conexiones antes de usarlas
    echo=settings.DEBUG  # Mostrar consultas SQL en modo debug
)

# Crear clase de sesión para el uso con contexto
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Clase base para los modelos de SQLAlchemy
Base = declarative_base()

# Función para obtener la conexión a la base de datos
def get_db():
    """
    Genera una sesión de base de datos para cada solicitud
    y la cierra al finalizar
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close() 