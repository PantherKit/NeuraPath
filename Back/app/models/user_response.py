from sqlalchemy import Column, String, DateTime, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.database import Base
import uuid

class UserResponse(Base):
    __tablename__ = "user_responses"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(UUID(as_uuid=True), index=True)
    response = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now()) 