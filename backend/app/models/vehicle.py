from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


class FuelType(str, Enum):
    benzin = "benzin"
    dizel = "dizel"
    lpg = "lpg"
    hibrit = "hibrit"
    plugin_hibrit = "plugin_hibrit"
    elektrik = "elektrik"


class Transmission(str, Enum):
    manuel = "manuel"
    otomatik = "otomatik"
    yari_otomatik = "yarı_otomatik"
    cvt = "cvt"


class Modification(str, Enum):
    orijinal = "orijinal"
    hafif_modifiye = "hafif_modifiye"
    orta_modifiye = "orta_modifiye"
    agir_modifiye = "agir_modifiye"


class VehicleBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    brand: str = Field(..., min_length=1, max_length=50)
    model: str = Field(..., min_length=1, max_length=50)
    year: int = Field(..., ge=1900, le=2030)
    fuel_type: FuelType = Field(..., alias="fuelType")
    km: int = Field(..., ge=0)
    transmission: Transmission
    modification: Modification

    class Config:
        populate_by_name = True


class VehicleCreate(VehicleBase):
    pass


class VehicleUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    brand: Optional[str] = Field(None, min_length=1, max_length=50)
    model: Optional[str] = Field(None, min_length=1, max_length=50)
    year: Optional[int] = Field(None, ge=1900, le=2030)
    fuel_type: Optional[FuelType] = Field(None, alias="fuelType")
    km: Optional[int] = Field(None, ge=0)
    transmission: Optional[Transmission] = None
    modification: Optional[Modification] = None

    class Config:
        populate_by_name = True


class Vehicle(VehicleBase):
    id: str
    created_at: str = Field(..., alias="createdAt")
    updated_at: Optional[str] = Field(None, alias="updatedAt")

    class Config:
        populate_by_name = True
