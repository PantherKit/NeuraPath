from sqlalchemy import Column, Integer, DateTime, JSON
from sqlalchemy.sql import func
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class UserResponse(Base):
    __tablename__ = "user_responses"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True)
    session_id = Column(UUID(as_uuid=True), nullable=False)
    response = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now()) 