from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

# Shared properties
class ItemBase(BaseModel):
    title: str
    description: Optional[str] = None
    price: Optional[float] = 0.0
    is_active: Optional[bool] = True

# Properties to receive on item creation
class ItemCreate(ItemBase):
    pass

# Properties to receive on item update
class ItemUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    is_active: Optional[bool] = None

# Properties shared by models stored in DB
class ItemInDBBase(ItemBase):
    id: int
    owner_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

# Properties to return to client
class Item(ItemInDBBase):
    pass

# Properties stored in DB
class ItemInDB(ItemInDBBase):
    pass
