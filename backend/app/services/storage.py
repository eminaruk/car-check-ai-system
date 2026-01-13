from datetime import datetime
from typing import List, Optional
from .firebase_service import get_firestore


class StorageService:
    """Firestore tabanli depolama servisi"""

    # ============================================
    # VEHICLES
    # ============================================

    @classmethod
    def get_all_vehicles(cls) -> List[dict]:
        """Tum araclari getir"""
        db = get_firestore()
        vehicles_ref = db.collection('vehicles')

        # Sadece aktif araclari getir
        docs = vehicles_ref.where('status', '==', 'active').order_by(
            'createdAt', direction='DESCENDING'
        ).stream()

        vehicles = []
        for doc in docs:
            vehicle = doc.to_dict()
            vehicle['id'] = doc.id
            # currentKm -> km donusumu (frontend uyumu)
            if 'currentKm' in vehicle:
                vehicle['km'] = vehicle.pop('currentKm')
            vehicles.append(vehicle)

        return vehicles

    @classmethod
    def get_vehicle_by_id(cls, vehicle_id: str) -> Optional[dict]:
        """Belirli bir araci getir"""
        db = get_firestore()
        doc = db.collection('vehicles').document(vehicle_id).get()

        if not doc.exists:
            return None

        vehicle = doc.to_dict()
        vehicle['id'] = doc.id
        if 'currentKm' in vehicle:
            vehicle['km'] = vehicle.pop('currentKm')

        return vehicle

    @classmethod
    def create_vehicle(cls, vehicle_data: dict) -> dict:
        """Yeni arac ekle"""
        db = get_firestore()

        # Frontend'den gelen km -> Firestore currentKm
        if 'km' in vehicle_data:
            vehicle_data['currentKm'] = vehicle_data.pop('km')

        # Kategori belirle
        fuel_type = vehicle_data.get('fuelType', '')
        vehicle_data['category'] = cls._get_category_from_fuel_type(fuel_type)

        # Firestore alanlari
        vehicle_data['status'] = 'active'
        vehicle_data['createdAt'] = datetime.now()
        vehicle_data['updatedAt'] = datetime.now()

        # Firestore'a ekle
        doc_ref = db.collection('vehicles').add(vehicle_data)
        vehicle_id = doc_ref[1].id

        # Eklenen aracu dondur
        vehicle_data['id'] = vehicle_id
        if 'currentKm' in vehicle_data:
            vehicle_data['km'] = vehicle_data.pop('currentKm')

        return vehicle_data

    @classmethod
    def update_vehicle(cls, vehicle_id: str, update_data: dict) -> Optional[dict]:
        """Arac guncelle"""
        db = get_firestore()
        doc_ref = db.collection('vehicles').document(vehicle_id)

        # Mevcut dokuman var mi kontrol et
        if not doc_ref.get().exists:
            return None

        # km -> currentKm donusumu
        if 'km' in update_data:
            update_data['currentKm'] = update_data.pop('km')

        # Kategori guncelle
        if 'fuelType' in update_data:
            update_data['category'] = cls._get_category_from_fuel_type(
                update_data['fuelType']
            )

        # updatedAt ekle
        update_data['updatedAt'] = datetime.now()

        # None degerleri cikar
        update_data = {k: v for k, v in update_data.items() if v is not None}

        # Guncelle
        doc_ref.update(update_data)

        # Guncellenmis aracu dondur
        return cls.get_vehicle_by_id(vehicle_id)

    @classmethod
    def delete_vehicle(cls, vehicle_id: str) -> bool:
        """Arac sil (soft delete)"""
        db = get_firestore()
        doc_ref = db.collection('vehicles').document(vehicle_id)

        if not doc_ref.get().exists:
            return False

        # Soft delete - status'u deleted yap
        doc_ref.update({
            'status': 'deleted',
            'updatedAt': datetime.now()
        })

        return True

    # ============================================
    # CHECKS / MAINTENANCE REPORTS
    # ============================================

    @classmethod
    def get_all_checks(cls) -> List[dict]:
        """Tum checkleri getir"""
        db = get_firestore()
        reports_ref = db.collection('maintenance_reports')

        docs = reports_ref.order_by(
            'generatedAt', direction='DESCENDING'
        ).stream()

        checks = []
        for doc in docs:
            check = doc.to_dict()
            check['id'] = doc.id

            # generatedAt -> createdAt donusumu (frontend uyumu)
            if 'generatedAt' in check:
                generated_at = check['generatedAt']
                if hasattr(generated_at, 'isoformat'):
                    check['createdAt'] = generated_at.isoformat()
                else:
                    check['createdAt'] = str(generated_at)

            # photoCount hesapla
            if 'partAnalyses' in check:
                check['photoCount'] = len(check.get('partAnalyses', []))
            elif 'photoCount' not in check:
                check['photoCount'] = 0

            checks.append(check)

        return checks

    @classmethod
    def create_check(cls, check_data: dict) -> dict:
        """Yeni check olustur"""
        db = get_firestore()

        # Firestore alanlari
        check_data['generatedAt'] = datetime.now()
        check_data['status'] = check_data.get('status', 'completed')

        # Firestore'a ekle
        doc_ref = db.collection('maintenance_reports').add(check_data)
        check_id = doc_ref[1].id

        # Eklenen checki dondur
        check_data['id'] = check_id
        check_data['createdAt'] = check_data['generatedAt'].isoformat()

        return check_data

    # ============================================
    # HELPER METHODS
    # ============================================

    @staticmethod
    def _get_category_from_fuel_type(fuel_type: str) -> str:
        """Yakit tipinden kategori belirle"""
        mapping = {
            'elektrik': 'BEV',
            'hibrit': 'HEV',
            'plugin_hibrit': 'PHEV',
        }
        return mapping.get(fuel_type, 'ICE')
