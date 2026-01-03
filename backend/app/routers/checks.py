from fastapi import APIRouter
from typing import List

from ..models import CheckCreate
from ..services import StorageService

router = APIRouter(prefix="/checks", tags=["checks"])


@router.get("", response_model=List[dict])
async def get_checks():
    """Tum checkleri listele"""
    return StorageService.get_all_checks()


@router.post("", status_code=201)
async def create_check(check: CheckCreate):
    """Yeni check ekle"""
    check_dict = check.model_dump(by_alias=True)
    return StorageService.create_check(check_dict)
