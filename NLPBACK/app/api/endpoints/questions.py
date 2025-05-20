from fastapi import APIRouter, HTTPException
import json
from pathlib import Path
import os

router = APIRouter()

@router.get("/mbti")
async def get_mbti_questions():
    """
    Get all MBTI questions
    """
    try:
        # Path to the questions data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "mbti_questions.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="MBTI questions file not found")
            
        # Read the questions
        with open(data_path, "r", encoding="utf-8") as f:
            questions = json.load(f)
            
        return {"mbti_questions": questions}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading MBTI questions: {str(e)}")

@router.get("/multiple-intelligence")
async def get_mi_questions():
    """
    Get all Multiple Intelligence questions
    """
    try:
        # Path to the questions data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "mi_questions.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="MI questions file not found")
            
        # Read the questions
        with open(data_path, "r", encoding="utf-8") as f:
            questions = json.load(f)
            
        return {"mi_questions": questions}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading MI questions: {str(e)}")

@router.get("/careers")
async def get_careers():
    """
    Get all careers
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
            
        return {"careers": careers}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading careers: {str(e)}")

@router.get("/careers/locations")
async def get_career_locations():
    """
    Get all unique locations from careers
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
        
        # Extract unique locations
        locations = sorted(list(set(career["ubicacion"] for career in careers)))
            
        return {"locations": locations}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading career locations: {str(e)}")

@router.get("/careers/universities")
async def get_career_universities():
    """
    Get all unique universities from careers
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
        
        # Extract unique universities
        universities = sorted(list(set(career["universidad"] for career in careers)))
            
        return {"universities": universities}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading career universities: {str(e)}")

@router.get("/careers/names")
async def get_career_names():
    """
    Get all unique career names
    """
    try:
        # Path to the career data
        data_path = Path(os.path.dirname(os.path.abspath(__file__))) / "../.." / "data" / "careers.json"
        
        # Check if file exists
        if not data_path.exists():
            raise HTTPException(status_code=404, detail="Careers file not found")
            
        # Read the careers
        with open(data_path, "r", encoding="utf-8") as f:
            careers = json.load(f)
        
        # Extract career names
        names = sorted(list(set(career["nombre"] for career in careers)))
            
        return {"career_names": names}
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error loading career names: {str(e)}")

@router.get("/health")
async def health_check():
    """
    Simple health check endpoint
    """
    return {"status": "ok"} 