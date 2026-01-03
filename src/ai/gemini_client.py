"""
CarCheck AI - Gemini Vision API Client
Arac bakim analizi icin Gemini 2.5 Flash/Pro API istemcisi
"""

import google.generativeai as genai
import base64
import json
from pathlib import Path
from typing import Optional, Dict, Any
from datetime import datetime

class GeminiVisionClient:
    """Gemini Vision API istemcisi"""

    def __init__(self, api_key: str, model: str = "gemini-2.0-flash"):
        """
        Args:
            api_key: Google AI Studio API anahtari
            model: Kullanilacak model (gemini-2.0-flash, gemini-2.0-pro, vb.)
        """
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel(model)
        self.model_name = model

    def encode_image(self, image_path: str) -> Dict[str, Any]:
        """Gorseli base64 formatina donusturur"""
        path = Path(image_path)

        # MIME type belirleme
        mime_types = {
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.png': 'image/png',
            '.webp': 'image/webp',
            '.gif': 'image/gif'
        }

        mime_type = mime_types.get(path.suffix.lower(), 'image/jpeg')

        with open(path, 'rb') as f:
            image_data = base64.b64encode(f.read()).decode('utf-8')

        return {
            'mime_type': mime_type,
            'data': image_data
        }

    def analyze_image(self, image_path: str, prompt: str) -> Dict[str, Any]:
        """
        Tek bir gorseli analiz eder

        Args:
            image_path: Gorsel dosya yolu
            prompt: Analiz promptu

        Returns:
            Analiz sonucu (JSON formatinda parse edilmis)
        """
        try:
            # Gorseli yukle
            image_data = self.encode_image(image_path)

            # API cagrisi
            response = self.model.generate_content([
                {
                    'mime_type': image_data['mime_type'],
                    'data': image_data['data']
                },
                prompt
            ])

            # Yaniti parse et
            response_text = response.text

            # JSON blogu cikar
            if '```json' in response_text:
                json_str = response_text.split('```json')[1].split('```')[0].strip()
            elif '```' in response_text:
                json_str = response_text.split('```')[1].split('```')[0].strip()
            else:
                json_str = response_text.strip()

            try:
                result = json.loads(json_str)
            except json.JSONDecodeError:
                result = {"raw_response": response_text, "parse_error": True}

            return {
                "success": True,
                "model": self.model_name,
                "timestamp": datetime.now().isoformat(),
                "result": result
            }

        except Exception as e:
            return {
                "success": False,
                "model": self.model_name,
                "timestamp": datetime.now().isoformat(),
                "error": str(e)
            }

    def analyze_multiple_images(self, image_paths: list, prompt: str) -> Dict[str, Any]:
        """
        Birden fazla gorseli tek seferde analiz eder

        Args:
            image_paths: Gorsel dosya yollari listesi
            prompt: Analiz promptu

        Returns:
            Analiz sonucu
        """
        try:
            content = []

            # Tum gorselleri ekle
            for image_path in image_paths:
                image_data = self.encode_image(image_path)
                content.append({
                    'mime_type': image_data['mime_type'],
                    'data': image_data['data']
                })

            # Promptu ekle
            content.append(prompt)

            # API cagrisi
            response = self.model.generate_content(content)
            response_text = response.text

            # JSON parse
            if '```json' in response_text:
                json_str = response_text.split('```json')[1].split('```')[0].strip()
            elif '```' in response_text:
                json_str = response_text.split('```')[1].split('```')[0].strip()
            else:
                json_str = response_text.strip()

            try:
                result = json.loads(json_str)
            except json.JSONDecodeError:
                result = {"raw_response": response_text, "parse_error": True}

            return {
                "success": True,
                "model": self.model_name,
                "timestamp": datetime.now().isoformat(),
                "image_count": len(image_paths),
                "result": result
            }

        except Exception as e:
            return {
                "success": False,
                "model": self.model_name,
                "timestamp": datetime.now().isoformat(),
                "error": str(e)
            }

# Analiz Promptlari
class MaintenancePrompts:
    """Bakim analizi icin prompt sablonlari"""

    @staticmethod
    def engine_bay_analysis(vehicle_info: Dict[str, Any]) -> str:
        """Motor bolgesi analizi promptu"""
        return f"""Sen bir arac bakim uzmanlisin. Bu motor bolgesi fotografini inceleyerek BAKIM odakli analiz yap.

ARAC BILGISI:
- Marka: {vehicle_info.get('brand', 'Bilinmiyor')}
- Model: {vehicle_info.get('model', 'Bilinmiyor')}
- Yil: {vehicle_info.get('year', 'Bilinmiyor')}
- Yakit: {vehicle_info.get('fuel_type', 'Bilinmiyor')}
- Kilometre: {vehicle_info.get('current_km', 'Bilinmiyor')} km

GOREV:
1. Genel temizlik durumunu degerlendir
2. Sizinti belirtisi var mi kontrol et
3. Gorunen parcalarin durumunu incele (aku, kayis, hortum)
4. Bakim onerileri sun

KONTROL NOKTALARI:
- Yag sizintisi: Koyu lekeler, islak alanlar
- Antifriz sizintisi: Yesil/turuncu/pembe lekeler
- Aku terminalleri: Beyaz/yesil oksidasyon
- Kayislar: Catlak, asinma
- Hortumlar: Sertlesme, catlak, sisme

ONEMLI:
- Bu bir BAKIM sistemi
- Sadece gorulebilen sorunlari raporla
- Emin olmadigin durumlar icin "serviste kontrol ettirin" oner

CIKTI FORMATI (JSON):
{{
    "overall_cleanliness": "clean | dusty | dirty",
    "leak_detection": {{
        "detected": true | false,
        "type": "oil | coolant | brake_fluid | none",
        "severity": "none | minor | moderate | severe",
        "location": "<konum veya null>"
    }},
    "visible_components": {{
        "battery_terminals": "good | oxidized | corroded | not_visible",
        "belts": "good | worn | cracked | not_visible",
        "hoses": "good | aged | cracked | not_visible",
        "air_filter_housing": "clean | dusty | dirty | not_visible"
    }},
    "fluid_levels": {{
        "coolant": "full | adequate | low | not_visible",
        "washer": "full | adequate | low | not_visible",
        "brake_fluid": "full | adequate | low | not_visible"
    }},
    "maintenance_recommendations": [
        {{
            "component": "<parca adi>",
            "action": "<yapilacak islem>",
            "urgency": "low | medium | high"
        }}
    ],
    "confidence": <0-1 arasi>
}}

Sadece JSON formatinda yanit ver, baska bir sey yazma."""

    @staticmethod
    def headlight_analysis(vehicle_info: Dict[str, Any]) -> str:
        """Far analizi promptu"""
        return f"""Sen bir arac bakim uzmanlisin. Bu far fotografini inceleyerek BAKIM odakli analiz yap.

ARAC BILGISI:
- Marka: {vehicle_info.get('brand', 'Bilinmiyor')}
- Model: {vehicle_info.get('model', 'Bilinmiyor')}
- Yil: {vehicle_info.get('year', 'Bilinmiyor')}

GOREV:
1. Lens durumunu degerlendir (sari, buzlu, temiz)
2. Temizlik durumunu kontrol et
3. Gorunen sorunlari belirle
4. Bakim onerisi sun

LENS DURUMLARI:
- clear: Net, seffaf (ideal)
- cloudy: Hafif buzlanma (polish ile duzelebilir)
- yellowed: Sararmis (polish veya degisim)
- damaged: Kirik veya catlak

CIKTI FORMATI (JSON):
{{
    "lens_condition": "clear | cloudy | yellowed | damaged",
    "cleanliness": "clean | dirty",
    "visible_issues": ["<sorun1>", "<sorun2>"],
    "maintenance_recommendation": {{
        "action": "none | clean | polish | replace",
        "urgency": "none | soon | immediate",
        "description": "<Turkce aciklama>"
    }},
    "confidence": <0-1 arasi>
}}

Sadece JSON formatinda yanit ver, baska bir sey yazma."""

    @staticmethod
    def exhaust_analysis(vehicle_info: Dict[str, Any]) -> str:
        """Egzoz analizi promptu"""
        return f"""Sen bir arac bakim uzmanlisin. Bu egzoz fotografini inceleyerek BAKIM odakli analiz yap.

ARAC BILGISI:
- Marka: {vehicle_info.get('brand', 'Bilinmiyor')}
- Model: {vehicle_info.get('model', 'Bilinmiyor')}
- Yil: {vehicle_info.get('year', 'Bilinmiyor')}
- Yakit: {vehicle_info.get('fuel_type', 'Bilinmiyor')}
- Kilometre: {vehicle_info.get('current_km', 'Bilinmiyor')} km

GOREV:
1. Egzoz ucunun genel durumunu degerlendir
2. Pas/korozyon var mi kontrol et
3. Is birikimi var mi incele
4. Bakim onerisi sun

KONTROL NOKTALARI:
- Pas/Korozyon: Delinme riski gosterir
- Is birikimi: Yakit yakim problemi isareti olabilir
- Fiziksel hasar: Ezik, kirik
- Renk degisimi: Asiri isinma isareti

CIKTI FORMATI (JSON):
{{
    "overall_condition": "good | fair | poor",
    "rust_corrosion": {{
        "detected": true | false,
        "severity": "none | minor | moderate | severe",
        "description": "<aciklama>"
    }},
    "soot_buildup": "none | light | moderate | heavy",
    "physical_damage": {{
        "detected": true | false,
        "description": "<aciklama veya null>"
    }},
    "maintenance_recommendation": {{
        "action": "none | clean | inspect | replace",
        "urgency": "none | soon | immediate",
        "description": "<Turkce aciklama>"
    }},
    "confidence": <0-1 arasi>
}}

Sadece JSON formatinda yanit ver, baska bir sey yazma."""

    @staticmethod
    def dashboard_analysis(vehicle_info: Dict[str, Any]) -> str:
        """Gosterge paneli analizi promptu"""
        return f"""Sen bir arac bakim uzmanlisin. Bu gosterge paneli fotografini inceleyerek analiz yap.

ARAC BILGISI:
- Marka: {vehicle_info.get('brand', 'Bilinmiyor')}
- Model: {vehicle_info.get('model', 'Bilinmiyor')}
- Yil: {vehicle_info.get('year', 'Bilinmiyor')}
- Beklenen Kilometre: {vehicle_info.get('current_km', 'Bilinmiyor')} km

GOREV:
1. Kilometre sayacini oku
2. Yanan uyari isiklari var mi tespit et
3. Yakit/batarya seviyesini oku (gorunuyorsa)
4. Onemli uyarilari raporla

YAYGIN UYARI ISIKLARI:
- Motor uyari (sari): Motor kontrol sistemi
- Yag uyari (kirmizi): Dusuk yag basinci
- Aku uyari: Sarj sistemi sorunu
- ABS uyari: Fren sistemi
- Airbag uyari: Guvenlik sistemi
- El freni: El freni cekilmis

CIKTI FORMATI (JSON):
{{
    "odometer_reading": <kilometre sayisi veya null>,
    "fuel_level": "full | 3/4 | half | 1/4 | low | not_visible",
    "warning_lights": [
        {{
            "type": "<uyari turu>",
            "color": "red | yellow | green | blue",
            "description": "<aciklama>"
        }}
    ],
    "critical_warnings": true | false,
    "notes": "<ek notlar>",
    "confidence": <0-1 arasi>
}}

Sadece JSON formatinda yanit ver, baska bir sey yazma."""

# Test fonksiyonu
def test_connection(api_key: str) -> bool:
    """API baglantisini test eder"""
    try:
        client = GeminiVisionClient(api_key)
        # Basit bir metin testi
        response = client.model.generate_content("Merhaba, 1+1 kac eder?")
        return response.text is not None
    except Exception as e:
        print(f"Baglanti hatasi: {e}")
        return False
