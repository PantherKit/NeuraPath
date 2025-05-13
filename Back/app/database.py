from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# Cargar la URL de conexión de la base de datos desde las variables de entorno
DB_USER = 'root'
DB_PASSWORD = os.getenv("DB_PASSWORD", "tu_contraseña")  # Usa la contraseña desde las variables de entorno
DB_NAME = 'test_vocacional'
DB_CONNECTION_NAME = 'pantherkit:us-central1:pantherkit-sql-instance'  # Nombre de la instancia de Cloud SQL

# Crear la URL de conexión
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@/cloudsql/{DB_CONNECTION_NAME}/{DB_NAME}"

# Crear motor de conexión
engine = create_engine(DATABASE_URL, pool_recycle=3600)

# Crear la sesión local
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Crear la base
Base = declarative_base()

# Dependencia para obtener la sesión de base de datos
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
