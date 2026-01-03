import json
from datetime import datetime
from typing import List, Optional
from pathlib import Path

from ..config import VEHICLES_FILE, CHECKS_FILE


class StorageService:
    @staticmethod
    def _read_vehicles() -> List[dict]:
        if not VEHICLES_FILE.exists():
            return []

        with open(VEHICLES_FILE, "r", encoding="utf-8") as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                return []

    @staticmethod
    def _write_vehicles(vehicles: List[dict]) -> None:
        with open(VEHICLES_FILE, "w", encoding="utf-8") as f:
            json.dump(vehicles, f, ensure_ascii=False, indent=2)

    @classmethod
    def get_all_vehicles(cls) -> List[dict]:
        return cls._read_vehicles()

    @classmethod
    def get_vehicle_by_id(cls, vehicle_id: str) -> Optional[dict]:
        vehicles = cls._read_vehicles()
        for vehicle in vehicles:
            if vehicle.get("id") == vehicle_id:
                return vehicle
        return None

    @classmethod
    def create_vehicle(cls, vehicle_data: dict) -> dict:
        vehicles = cls._read_vehicles()

        vehicle = {
            "id": str(int(datetime.now().timestamp() * 1000)),
            "createdAt": datetime.now().isoformat(),
            "updatedAt": None,
            **vehicle_data
        }

        vehicles.append(vehicle)
        cls._write_vehicles(vehicles)
        return vehicle

    @classmethod
    def update_vehicle(cls, vehicle_id: str, update_data: dict) -> Optional[dict]:
        vehicles = cls._read_vehicles()

        for i, vehicle in enumerate(vehicles):
            if vehicle.get("id") == vehicle_id:
                update_data = {k: v for k, v in update_data.items() if v is not None}
                vehicles[i] = {
                    **vehicle,
                    **update_data,
                    "updatedAt": datetime.now().isoformat()
                }
                cls._write_vehicles(vehicles)
                return vehicles[i]

        return None

    @classmethod
    def delete_vehicle(cls, vehicle_id: str) -> bool:
        vehicles = cls._read_vehicles()
        initial_count = len(vehicles)

        vehicles = [v for v in vehicles if v.get("id") != vehicle_id]

        if len(vehicles) < initial_count:
            cls._write_vehicles(vehicles)
            return True

        return False

    # Check methods
    @staticmethod
    def _read_checks() -> List[dict]:
        if not CHECKS_FILE.exists():
            return []

        with open(CHECKS_FILE, "r", encoding="utf-8") as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                return []

    @staticmethod
    def _write_checks(checks: List[dict]) -> None:
        with open(CHECKS_FILE, "w", encoding="utf-8") as f:
            json.dump(checks, f, ensure_ascii=False, indent=2)

    @classmethod
    def get_all_checks(cls) -> List[dict]:
        return cls._read_checks()

    @classmethod
    def create_check(cls, check_data: dict) -> dict:
        checks = cls._read_checks()

        check = {
            "id": str(int(datetime.now().timestamp() * 1000)),
            "createdAt": datetime.now().isoformat(),
            **check_data
        }

        checks.append(check)
        cls._write_checks(checks)
        return check
