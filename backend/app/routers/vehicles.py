from fastapi import APIRouter, HTTPException
from typing import List

from ..models import Vehicle, VehicleCreate, VehicleUpdate
from ..services import StorageService

router = APIRouter(prefix="/vehicles", tags=["vehicles"])


@router.get("", response_model=List[dict])
async def get_vehicles():
    """Tum araclari listele"""
    return StorageService.get_all_vehicles()


@router.get("/{vehicle_id}")
async def get_vehicle(vehicle_id: str):
    """Belirli bir araci getir"""
    vehicle = StorageService.get_vehicle_by_id(vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Arac bulunamadi")
    return vehicle


@router.post("", status_code=201)
async def create_vehicle(vehicle: VehicleCreate):
    """Yeni arac ekle"""
    vehicle_dict = vehicle.model_dump(by_alias=True)
    return StorageService.create_vehicle(vehicle_dict)


@router.put("/{vehicle_id}")
async def update_vehicle(vehicle_id: str, vehicle: VehicleUpdate):
    """Arac bilgilerini guncelle"""
    vehicle_dict = vehicle.model_dump(by_alias=True, exclude_none=True)
    updated = StorageService.update_vehicle(vehicle_id, vehicle_dict)
    if not updated:
        raise HTTPException(status_code=404, detail="Arac bulunamadi")
    return updated


@router.delete("/{vehicle_id}")
async def delete_vehicle(vehicle_id: str):
    """Araci sil"""
    deleted = StorageService.delete_vehicle(vehicle_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Arac bulunamadi")
    return {"message": "Arac silindi", "id": vehicle_id}
