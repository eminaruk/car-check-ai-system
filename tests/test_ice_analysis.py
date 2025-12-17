"""
CarCheck AI - ICE Kategorisi Test Scripti
Benzinli/Dizel/LPG araclar icin Gemini Vision API testi
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime

# Proje root'unu path'e ekle
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.ai.gemini_client import GeminiVisionClient, MaintenancePrompts


def load_vehicles():
    """Arac veritabanindan ICE araclarini yukler"""
    data_path = project_root / "data" / "vehicles.json"
    with open(data_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Sadece ICE kategorisindeki araclar
    ice_vehicles = [v for v in data['vehicles'] if v['category'] == 'ICE']
    return ice_vehicles


def test_tire_analysis(client: GeminiVisionClient, image_path: str, vehicle: dict, position: str):
    """Lastik analizi testi"""
    print(f"\n{'='*60}")
    print(f"LASTIK ANALIZI TESTI - {position}")
    print(f"Arac: {vehicle['brand']} {vehicle['model']} ({vehicle['year']})")
    print(f"Gorsel: {image_path}")
    print('='*60)

    prompt = MaintenancePrompts.tire_analysis(vehicle, position)

    print("\nAnaliz yapiliyor...")
    result = client.analyze_image(image_path, prompt)

    if result['success']:
        print("\n✅ BASARILI")
        print(f"Model: {result['model']}")
        print(f"Zaman: {result['timestamp']}")
        print("\nSONUC:")
        print(json.dumps(result['result'], indent=2, ensure_ascii=False))
    else:
        print("\n❌ HATA")
        print(f"Hata: {result['error']}")

    return result


def test_engine_bay_analysis(client: GeminiVisionClient, image_path: str, vehicle: dict):
    """Motor bolgesi analizi testi"""
    print(f"\n{'='*60}")
    print(f"MOTOR BOLGESI ANALIZI TESTI")
    print(f"Arac: {vehicle['brand']} {vehicle['model']} ({vehicle['year']})")
    print(f"Gorsel: {image_path}")
    print('='*60)

    prompt = MaintenancePrompts.engine_bay_analysis(vehicle)

    print("\nAnaliz yapiliyor...")
    result = client.analyze_image(image_path, prompt)

    if result['success']:
        print("\n✅ BASARILI")
        print(f"Model: {result['model']}")
        print("\nSONUC:")
        print(json.dumps(result['result'], indent=2, ensure_ascii=False))
    else:
        print("\n❌ HATA")
        print(f"Hata: {result['error']}")

    return result


def test_headlight_analysis(client: GeminiVisionClient, image_path: str, vehicle: dict):
    """Far analizi testi"""
    print(f"\n{'='*60}")
    print(f"FAR ANALIZI TESTI")
    print(f"Arac: {vehicle['brand']} {vehicle['model']} ({vehicle['year']})")
    print(f"Gorsel: {image_path}")
    print('='*60)

    prompt = MaintenancePrompts.headlight_analysis(vehicle)

    print("\nAnaliz yapiliyor...")
    result = client.analyze_image(image_path, prompt)

    if result['success']:
        print("\n✅ BASARILI")
        print("\nSONUC:")
        print(json.dumps(result['result'], indent=2, ensure_ascii=False))
    else:
        print("\n❌ HATA")
        print(f"Hata: {result['error']}")

    return result


def test_exhaust_analysis(client: GeminiVisionClient, image_path: str, vehicle: dict):
    """Egzoz analizi testi"""
    print(f"\n{'='*60}")
    print(f"EGZOZ ANALIZI TESTI")
    print(f"Arac: {vehicle['brand']} {vehicle['model']} ({vehicle['year']})")
    print(f"Gorsel: {image_path}")
    print('='*60)

    prompt = MaintenancePrompts.exhaust_analysis(vehicle)

    print("\nAnaliz yapiliyor...")
    result = client.analyze_image(image_path, prompt)

    if result['success']:
        print("\n✅ BASARILI")
        print("\nSONUC:")
        print(json.dumps(result['result'], indent=2, ensure_ascii=False))
    else:
        print("\n❌ HATA")
        print(f"Hata: {result['error']}")

    return result


def test_dashboard_analysis(client: GeminiVisionClient, image_path: str, vehicle: dict):
    """Gosterge paneli analizi testi"""
    print(f"\n{'='*60}")
    print(f"GOSTERGE PANELI ANALIZI TESTI")
    print(f"Arac: {vehicle['brand']} {vehicle['model']} ({vehicle['year']})")
    print(f"Gorsel: {image_path}")
    print('='*60)

    prompt = MaintenancePrompts.dashboard_analysis(vehicle)

    print("\nAnaliz yapiliyor...")
    result = client.analyze_image(image_path, prompt)

    if result['success']:
        print("\n✅ BASARILI")
        print("\nSONUC:")
        print(json.dumps(result['result'], indent=2, ensure_ascii=False))
    else:
        print("\n❌ HATA")
        print(f"Hata: {result['error']}")

    return result


def run_single_image_test(api_key: str, image_path: str, test_type: str = "tire"):
    """Tek gorsel ile test calistir"""
    print("\n" + "="*60)
    print("CARCHECK AI - ICE KATEGORI TESTI")
    print("="*60)

    # Client olustur
    client = GeminiVisionClient(api_key, model="gemini-2.0-flash-exp")

    # Ornek arac bilgisi (ICE - Toyota Corolla)
    sample_vehicle = {
        "id": "VH001",
        "brand": "Toyota",
        "model": "Corolla",
        "year": 2020,
        "fuel_type": "benzin",
        "category": "ICE",
        "current_km": 45000
    }

    # Test tipine gore calistir
    if test_type == "tire":
        result = test_tire_analysis(client, image_path, sample_vehicle, "Sol On Lastik")
    elif test_type == "engine":
        result = test_engine_bay_analysis(client, image_path, sample_vehicle)
    elif test_type == "headlight":
        result = test_headlight_analysis(client, image_path, sample_vehicle)
    elif test_type == "exhaust":
        result = test_exhaust_analysis(client, image_path, sample_vehicle)
    elif test_type == "dashboard":
        result = test_dashboard_analysis(client, image_path, sample_vehicle)
    else:
        print(f"Bilinmeyen test tipi: {test_type}")
        return None

    # Sonucu kaydet
    save_result(result, test_type)
    return result


def save_result(result: dict, test_type: str):
    """Test sonucunu dosyaya kaydet"""
    results_dir = project_root / "tests" / "results"
    results_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{test_type}_{timestamp}.json"

    with open(results_dir / filename, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"\nSonuc kaydedildi: tests/results/{filename}")


def interactive_test(api_key: str):
    """Interaktif test modu"""
    print("\n" + "="*60)
    print("CARCHECK AI - INTERAKTIF TEST MODU")
    print("="*60)

    client = GeminiVisionClient(api_key, model="gemini-2.0-flash-exp")

    # ICE araclari listele
    ice_vehicles = load_vehicles()
    print("\nMevcut ICE Araclar:")
    for i, v in enumerate(ice_vehicles):
        print(f"  {i+1}. {v['plate']} - {v['brand']} {v['model']} ({v['year']}) - {v['fuel_type']}")

    print("\nTest tipleri:")
    print("  1. tire      - Lastik analizi")
    print("  2. engine    - Motor bolgesi analizi")
    print("  3. headlight - Far analizi")
    print("  4. exhaust   - Egzoz analizi")
    print("  5. dashboard - Gosterge paneli analizi")

    while True:
        print("\n" + "-"*40)
        image_path = input("Gorsel yolu (cikis icin 'q'): ").strip()

        if image_path.lower() == 'q':
            print("Test sonlandirildi.")
            break

        if not os.path.exists(image_path):
            print(f"HATA: Dosya bulunamadi: {image_path}")
            continue

        test_type = input("Test tipi (tire/engine/headlight/exhaust/dashboard): ").strip().lower()

        if test_type not in ['tire', 'engine', 'headlight', 'exhaust', 'dashboard']:
            print("Gecersiz test tipi!")
            continue

        vehicle_idx = input("Arac no (1-5, varsayilan 1): ").strip()
        vehicle_idx = int(vehicle_idx) - 1 if vehicle_idx.isdigit() else 0
        vehicle_idx = max(0, min(vehicle_idx, len(ice_vehicles) - 1))

        vehicle = ice_vehicles[vehicle_idx]

        if test_type == "tire":
            position = input("Lastik konumu (Sol On/Sag On/Sol Arka/Sag Arka): ").strip()
            result = test_tire_analysis(client, image_path, vehicle, position or "Sol On Lastik")
        elif test_type == "engine":
            result = test_engine_bay_analysis(client, image_path, vehicle)
        elif test_type == "headlight":
            result = test_headlight_analysis(client, image_path, vehicle)
        elif test_type == "exhaust":
            result = test_exhaust_analysis(client, image_path, vehicle)
        elif test_type == "dashboard":
            result = test_dashboard_analysis(client, image_path, vehicle)

        save_result(result, test_type)


def main():
    """Ana fonksiyon"""
    # API anahtarini environment variable'dan al
    api_key = os.environ.get('GEMINI_API_KEY')

    if not api_key:
        print("HATA: GEMINI_API_KEY environment variable tanimli degil!")
        print("\nKullanim:")
        print("  Windows: set GEMINI_API_KEY=your_api_key")
        print("  Linux/Mac: export GEMINI_API_KEY=your_api_key")
        print("\nYa da dogrudan kod icinde belirtin:")
        print("  api_key = 'your_api_key'")
        return

    # Komut satiri argumanlari
    if len(sys.argv) >= 3:
        # python test_ice_analysis.py <image_path> <test_type>
        image_path = sys.argv[1]
        test_type = sys.argv[2]
        run_single_image_test(api_key, image_path, test_type)
    elif len(sys.argv) == 2 and sys.argv[1] == '--interactive':
        # python test_ice_analysis.py --interactive
        interactive_test(api_key)
    else:
        print("\nKullanim:")
        print("  python test_ice_analysis.py <gorsel_yolu> <test_tipi>")
        print("  python test_ice_analysis.py --interactive")
        print("\nTest tipleri: tire, engine, headlight, exhaust, dashboard")
        print("\nOrnek:")
        print("  python test_ice_analysis.py ./test_images/tire.jpg tire")


if __name__ == "__main__":
    main()
