from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from sqlalchemy.exc import ProgrammingError
from app.routes import auth, responses, storage, test_responses
from app.database import engine, Base
from sqlalchemy import text

app = FastAPI()

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global exception handlers
@app.exception_handler(ValidationError)
async def validation_exception_handler(request: Request, exc: ValidationError):
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors()}
    )

@app.exception_handler(ProgrammingError)
async def programming_error_handler(request: Request, exc: ProgrammingError):
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc)}
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc)}
    )

# Incluir los routers
app.include_router(auth.router, prefix="/api", tags=["auth"])
app.include_router(responses.router, prefix="/api", tags=["responses"])
app.include_router(storage.router, prefix="/api", tags=["storage"])
app.include_router(test_responses.router, prefix="/api", tags=["test"])

@app.get("/")
async def root():
    return {"message": "Welcome to PantherKit API"}

# Crear tablas al iniciar
@app.on_event("startup")
async def startup_event():
    try:
        # Read and execute the SQL file
        with open('app/migrations/create_tables.sql', 'r') as file:
            sql_commands = file.read()
            
        # Execute each command separately
        for command in sql_commands.split(';'):
            if command.strip():
                with engine.connect() as conn:
                    conn.execute(text(command))
                    conn.commit()
        print("Tables created successfully")
    except Exception as e:
        print(f"Error creating tables: {str(e)}")
        raise 

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import RespuestasTest
from pydantic import BaseModel

router = APIRouter()

# Pydantic models para las respuestas del test vocacional
class RespuestasCreate(BaseModel):
    user_id: str
    pregunta_1: int
    pregunta_2: int
    pregunta_3: int
    pregunta_4: int
    pregunta_5: int

@router.post("/guardar_respuestas")
def guardar_respuestas(respuestas: RespuestasCreate, db: Session = Depends(get_db)):
    """
    Recibe las respuestas del test vocacional y las guarda en la base de datos.
    """
    try:
        db_respuesta = RespuestasTest(
            user_id=respuestas.user_id,
            pregunta_1=respuestas.pregunta_1,
            pregunta_2=respuestas.pregunta_2,
            pregunta_3=respuestas.pregunta_3,
            pregunta_4=respuestas.pregunta_4,
            pregunta_5=respuestas.pregunta_5,
        )
        db.add(db_respuesta)
        db.commit()
        db.refresh(db_respuesta)
        return {"message": "Respuestas guardadas correctamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al guardar respuestas: {str(e)}")
