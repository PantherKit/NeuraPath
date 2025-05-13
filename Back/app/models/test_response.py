from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.database import Base

class TestResponse(Base):
    __tablename__ = "respuestas_test"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True)
    user_id = Column(String(100), nullable=False)
    fecha = Column(DateTime(timezone=True), server_default=func.now())
    pregunta_1 = Column(Integer, nullable=False)
    pregunta_2 = Column(Integer, nullable=False)
    pregunta_3 = Column(Integer, nullable=False)
    pregunta_4 = Column(Integer, nullable=False)
    pregunta_5 = Column(Integer, nullable=False) 