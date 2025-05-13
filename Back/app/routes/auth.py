from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import Session as SessionModel
from app.schemas.token import Token

router = APIRouter()

@router.post("/session", response_model=Token)
def create_session(
    db: Session = Depends(get_db)
) -> Token:
    """
    Create a new session and return a session ID
    """
    # Generate a new session ID
    session_id = SessionModel.generate_session_id()
    
    # Create new session in database
    new_session = SessionModel(id=session_id)
    db.add(new_session)
    db.commit()
    db.refresh(new_session)
    
    return {
        "access_token": session_id,
        "token_type": "bearer"
    }
