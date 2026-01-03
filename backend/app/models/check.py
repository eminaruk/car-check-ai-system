from pydantic import BaseModel, Field
from typing import Optional


class CheckBase(BaseModel):
    vehicle_id: str = Field(..., alias="vehicleId")
    status: Optional[str] = "Tamamlandı"
    photo_count: Optional[int] = Field(0, alias="photoCount")

    class Config:
        populate_by_name = True


class CheckCreate(CheckBase):
    pass


class Check(CheckBase):
    id: str
    created_at: str = Field(..., alias="createdAt")

    class Config:
        populate_by_name = True
