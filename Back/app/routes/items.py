from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.core.deps import get_current_active_user, get_current_active_admin
from app.database import get_db
from app.models.user import User
from app.models.item import Item
from app.schemas.item import Item as ItemSchema, ItemCreate, ItemUpdate

router = APIRouter()

@router.get("/", response_model=List[ItemSchema])
def read_items(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_active_user),
    title: Optional[str] = Query(None, description="Filter by title"),
    min_price: Optional[float] = Query(None, description="Minimum price filter"),
    max_price: Optional[float] = Query(None, description="Maximum price filter"),
) -> Any:
    """
    Retrieve items.
    """
    # Build query
    query = db.query(Item)
    
    # Apply filters if provided
    if title:
        query = query.filter(Item.title.ilike(f"%{title}%"))
    if min_price is not None:
        query = query.filter(Item.price >= min_price)
    if max_price is not None:
        query = query.filter(Item.price <= max_price)
        
    # Admin can see all items, regular users can only see their own items
    if not current_user.is_admin:
        query = query.filter(Item.owner_id == current_user.id)
        
    # Apply pagination
    items = query.offset(skip).limit(limit).all()
    return items

@router.post("/", response_model=ItemSchema)
def create_item(
    *,
    db: Session = Depends(get_db),
    item_in: ItemCreate,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """
    Create new item.
    """
    # Create new item
    item = Item(
        **item_in.dict(),
        owner_id=current_user.id
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@router.get("/{item_id}", response_model=ItemSchema)
def read_item(
    *,
    db: Session = Depends(get_db),
    item_id: int,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """
    Get item by ID.
    """
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )
    
    # Check if the user has permission to access this item
    if not current_user.is_admin and item.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions",
        )
    
    return item

@router.put("/{item_id}", response_model=ItemSchema)
def update_item(
    *,
    db: Session = Depends(get_db),
    item_id: int,
    item_in: ItemUpdate,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """
    Update an item.
    """
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )
    
    # Check if the user has permission to update this item
    if not current_user.is_admin and item.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions",
        )
    
    # Update item
    update_data = item_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(item, field, update_data[field])
    
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

@router.delete("/{item_id}", response_model=ItemSchema)
def delete_item(
    *,
    db: Session = Depends(get_db),
    item_id: int,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """
    Delete an item.
    """
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )
    
    # Check if the user has permission to delete this item
    if not current_user.is_admin and item.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions",
        )
    
    db.delete(item)
    db.commit()
    return item 