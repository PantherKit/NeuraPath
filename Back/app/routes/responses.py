from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List

from app.database import get_db
from app.models.response import UserResponse
from app.schemas.response import Response, ResponseCreate

router = APIRouter()

@router.post("/responses", response_model=Response)
async def create_response(
    response: ResponseCreate,
    db: Session = Depends(get_db)
):
    """
    Save a new user response
    """
    try:
        db_response = UserResponse(
            session_id=response.session_id,
            response=response.response
        )
        db.add(db_response)
        db.commit()
        db.refresh(db_response)
        return db_response
    except Exception as e:
        db.rollback()
        print(f"Error creating response: {str(e)}")  # Detalles del error
        raise HTTPException(
            status_code=400,
            detail=f"Error creating response: {str(e)}"
        )

@router.get("/responses/{session_id}", response_model=List[Response])
async def get_session_responses(
    session_id: str,
    db: Session = Depends(get_db)
):
    """
    Get all responses for a specific session
    """
    try:
        # Convert string to UUID
        try:
            session_uuid = UUID(session_id)  # Validate and convert session_id to UUID
        except ValueError:
            raise HTTPException(
                status_code=422,
                detail="Invalid UUID format"
            )

        # Query responses using session_uuid
        responses = db.query(UserResponse).filter(
            UserResponse.session_id == session_uuid  # Directly compare UUID
        ).all()

        if not responses:
            return []  # Return empty list if no responses found

        return responses
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error retrieving responses: {str(e)}")  # Detalles del error
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving responses: {str(e)}"
        )
