import os
from google.cloud import firestore as gc_firestore
from ..config import FIREBASE_PROJECT_ID, USE_EMULATOR, FIRESTORE_EMULATOR_HOST

# Firebase baslatma (singleton)
_firestore_client = None
_initialized = False


def initialize_firebase():
    """Firebase'i baslat"""
    global _firestore_client, _initialized

    if _initialized:
        return _firestore_client

    # Emulator kullanilacaksa environment variable ayarla
    if USE_EMULATOR:
        os.environ["FIRESTORE_EMULATOR_HOST"] = FIRESTORE_EMULATOR_HOST
        print(f"Firestore Emulator kullaniliyor: {FIRESTORE_EMULATOR_HOST}")

    try:
        # google-cloud-firestore dogrudan kullan (emulator icin credentials gerekmez)
        _firestore_client = gc_firestore.Client(project=FIREBASE_PROJECT_ID)
        _initialized = True
        print("Firebase basariyla baslatildi")
    except Exception as e:
        print(f"Firebase baslatilamadi: {e}")
        raise e

    return _firestore_client


def get_firestore():
    """Firestore client'i dondur"""
    global _firestore_client

    if _firestore_client is None:
        initialize_firebase()

    return _firestore_client
