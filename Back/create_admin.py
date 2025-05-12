"""
Script to create an admin user for the FastAPI CRUD Template
Run this script to create an admin user if none exists

Usage:
    python create_admin.py --email admin@example.com --username admin --password securepassword
"""

import argparse
from sqlalchemy.orm import Session

from app.database import SessionLocal, engine, Base
from app.models.user import User
from app.core.security import get_password_hash

def create_admin_user(email: str, username: str, password: str):
    """Create an admin user if none exists"""
    # Create database tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    # Get database session
    db = SessionLocal()
    
    try:
        # Check if admin user already exists
        user = db.query(User).filter(User.is_admin == True).first()
        if user:
            print(f"Admin user already exists with email: {user.email}")
            return
        
        # Check if user with this email already exists
        user = db.query(User).filter(User.email == email).first()
        if user:
            print(f"User with email {email} already exists but is not an admin")
            return
        
        # Check if user with this username already exists
        user = db.query(User).filter(User.username == username).first()
        if user:
            print(f"User with username {username} already exists but is not an admin")
            return
        
        # Create new admin user
        admin_user = User(
            email=email,
            username=username,
            hashed_password=get_password_hash(password),
            is_active=True,
            is_admin=True
        )
        
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        
        print(f"Admin user created successfully with email: {email}")
    
    finally:
        db.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create an admin user for the FastAPI CRUD Template")
    parser.add_argument("--email", required=True, help="Admin email")
    parser.add_argument("--username", required=True, help="Admin username")
    parser.add_argument("--password", required=True, help="Admin password")
    
    args = parser.parse_args()
    
    create_admin_user(args.email, args.username, args.password) 