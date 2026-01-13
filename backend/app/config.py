import os
from pathlib import Path

# Proje dizinleri
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
VEHICLES_FILE = DATA_DIR / "vehicles.json"
CHECKS_FILE = DATA_DIR / "checks.json"

DATA_DIR.mkdir(exist_ok=True)

# Firebase ayarlari
FIREBASE_PROJECT_ID = "carcheck-1967f"

# Emulator ayarlari
USE_EMULATOR = os.getenv("USE_FIREBASE_EMULATOR", "true").lower() == "true"
FIRESTORE_EMULATOR_HOST = os.getenv("FIRESTORE_EMULATOR_HOST", "localhost:8080")
AUTH_EMULATOR_HOST = os.getenv("FIREBASE_AUTH_EMULATOR_HOST", "localhost:9099")
