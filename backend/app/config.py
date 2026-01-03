from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
VEHICLES_FILE = DATA_DIR / "vehicles.json"
CHECKS_FILE = DATA_DIR / "checks.json"

DATA_DIR.mkdir(exist_ok=True)
