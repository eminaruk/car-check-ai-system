# CarCheck AI - Yapay Zeka Ozellikleri (MVP v1.0)

Bu dokuman, ilk surumde yer alacak AI ozelliklerini, test senaryolarini ve prompt yapilarini detayli sekilde aciklamaktadir.

## Genel Bakis

MVP'de 5 temel AI modulu bulunacaktir:

| # | Modul | Oncelik | Durum |
|---|-------|---------|-------|
| 1 | Arac Hasar Tespiti | Yuksek | Test Edilecek |
| 2 | Lastik Durumu Analizi | Yuksek | Test Edilecek |
| 3 | Hasar Seviyesi Degerlendirme | Yuksek | Test Edilecek |
| 4 | Plaka Tanima | Orta | Test Edilecek |
| 5 | Gorsel Rapor Olusturma | Orta | Test Edilecek |

---

## 1. Arac Hasar Tespiti

### Amac
Kullanicinin yuklediği arac fotograflarindan hasar turlerini tespit etmek.

### Tespit Edilecek Hasar Turleri
- **Cizik (Scratch):** Yuzeysel boya hasarlari
- **Gocuk (Dent):** Metal ezilmeleri, carpisma izleri
- **Pas (Rust):** Korozyon ve pas olusumlari
- **Cam Hasari (Glass Damage):** Kirik, catlak, tas carpmasi
- **Boya Dokulmesi (Paint Chip):** Boya kalkmasi, solmasi
- **Tampon Hasari (Bumper Damage):** Tampon kirilmasi, cakilmasi

### Girdi
```json
{
  "image": "base64_encoded_image veya image_url",
  "image_type": "front | rear | left_side | right_side | detail",
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "color": "Beyaz"
  }
}
```

### Beklenen Cikti
```json
{
  "damages": [
    {
      "type": "scratch",
      "severity": "minor | moderate | severe",
      "location": "sol on camurluk",
      "confidence": 0.92,
      "bounding_box": { "x": 120, "y": 340, "width": 80, "height": 15 },
      "description": "Yaklasik 15cm uzunlugunda yuzeysel cizik"
    }
  ],
  "overall_condition": "good | attention | critical",
  "analysis_timestamp": "2025-12-17T10:30:00Z"
}
```

### Test Prompt Sablonu

```
Sen bir arac hasar tespit uzmanlisin. Sana verilen arac fotografini analiz et.

GOREV:
1. Fotograftaki tum hasarlari tespit et
2. Her hasar icin tur, siddet ve konum belirt
3. Genel arac durumunu degerlendir

HASAR TURLERI:
- scratch: Cizik
- dent: Gocuk
- rust: Pas
- glass_damage: Cam hasari
- paint_chip: Boya dokulmesi
- bumper_damage: Tampon hasari

SIDDET SEVIYELERI:
- minor: Kozmetik, acil mudahale gerektirmez
- moderate: Dikkat gerektirir, yakin zamanda onarilmali
- severe: Kritik, hemen mudahale edilmeli

CIKTI FORMATI:
JSON formatinda yanit ver. Hasar yoksa bos "damages" dizisi dondur.

ARAC BILGISI:
Marka: {brand}
Model: {model}
Yil: {year}
Renk: {color}
Fotograf Acisi: {image_type}
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-1.1 | Temiz, hasarsiz arac | Bos damages dizisi |
| TS-1.2 | Tek cizikli arac | 1 scratch tespit |
| TS-1.3 | Coklu hasar (cizik + gocuk) | Birden fazla hasar |
| TS-1.4 | Pasli arac | rust tespit |
| TS-1.5 | Kirik cam | glass_damage tespit |
| TS-1.6 | Dusuk kalite fotograf | Dusuk confidence veya hata |

---

## 2. Lastik Durumu Analizi

### Amac
Lastik fotograflarindan dis derinligi, asinma durumu ve guvenlik seviyesini tahmin etmek.

### Analiz Edilecek Parametreler
- **Dis Derinligi Tahmini:** mm cinsinden (yeni lastik ~8mm)
- **Asinma Durumu:** Esit/esitsiz asinma
- **Yan Duvar Durumu:** Catlak, sisme, hasar
- **Genel Guvenlik:** Guvenli/dikkat/tehlikeli

### Girdi
```json
{
  "image": "base64_encoded_image",
  "tire_position": "front_left | front_right | rear_left | rear_right",
  "tire_info": {
    "brand": "Michelin",
    "size": "205/55R16",
    "age_months": 24
  }
}
```

### Beklenen Cikti
```json
{
  "tread_depth_mm": 4.5,
  "tread_status": "adequate | low | critical",
  "wear_pattern": "even | center | edge | cupping",
  "sidewall_condition": "good | cracked | bulge | damaged",
  "safety_rating": "safe | caution | danger",
  "recommendation": "Lastikler yaklasik 10.000 km daha kullanilabilir",
  "confidence": 0.85
}
```

### Test Prompt Sablonu

```
Sen bir lastik analiz uzmanlisin. Lastik fotografini inceleyerek detayli analiz yap.

GOREV:
1. Dis derinligini tahmin et (mm)
2. Asinma paternini belirle
3. Yan duvar durumunu kontrol et
4. Guvenlik degerlendirmesi yap

DIS DERINLIGI REFERANS:
- 8mm: Yeni lastik
- 4-6mm: Iyi durumda
- 3-4mm: Dikkat, degisim planlenmali
- 1.6mm alti: Yasal limit, tehlikeli

ASINMA PATERNLERI:
- even: Esit asinma (normal)
- center: Ortadan asinma (fazla hava basinci)
- edge: Kenarlardan asinma (dusuk hava basinci)
- cupping: Dalgali asinma (suspansiyon sorunu)

CIKTI FORMATI:
JSON formatinda detayli analiz dondur.

LASTIK BILGISI:
Konum: {tire_position}
Marka: {brand}
Ebat: {size}
Yas: {age_months} ay
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-2.1 | Yeni lastik | 7-8mm, safe |
| TS-2.2 | Orta asinmis lastik | 4-5mm, safe/caution |
| TS-2.3 | Cok asinmis lastik | <3mm, danger |
| TS-2.4 | Esitsiz asinma | wear_pattern != even |
| TS-2.5 | Yan duvarda catlak | sidewall: cracked |
| TS-2.6 | Sismis lastik | sidewall: bulge, danger |

---

## 3. Hasar Seviyesi Degerlendirme

### Amac
Tespit edilen hasarlari analiz ederek genel arac durumunu ve tahmini onarim maliyetini belirlemek.

### Degerlendirme Kriterleri
- **Kozmetik Hasar:** Aracin islevini etkilemez
- **Fonksiyonel Hasar:** Guvenlik/performans etkiler
- **Yapisal Hasar:** Ciddi, profesyonel mudahale sart

### Girdi
```json
{
  "damages": [...],  // Hasar tespitinden gelen liste
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "market": "TR"
  }
}
```

### Beklenen Cikti
```json
{
  "overall_score": 75,  // 0-100 arasi
  "condition_label": "good | fair | poor | critical",
  "repair_urgency": "none | low | medium | high | immediate",
  "estimated_repair_cost": {
    "min": 2500,
    "max": 4000,
    "currency": "TRY"
  },
  "repair_recommendations": [
    {
      "damage_ref": 0,
      "action": "Boya rotusu yeterli",
      "priority": "low",
      "estimated_cost": { "min": 500, "max": 1000 }
    }
  ],
  "safety_impact": "none | minor | significant | severe"
}
```

### Test Prompt Sablonu

```
Sen bir arac degerleme ve hasar analiz uzmanlisin.

GOREV:
1. Verilen hasar listesini analiz et
2. Genel arac durumu puani ver (0-100)
3. Onarim oncelik sirasini belirle
4. Tahmini maliyet hesapla (Turkiye pazari)

PUANLAMA KRITERLERI:
- 90-100: Mukemmel, hasar yok veya minimal
- 70-89: Iyi, kucuk kozmetik hasarlar
- 50-69: Orta, onarim gerektiren hasarlar
- 30-49: Kotu, ciddi hasarlar
- 0-29: Kritik, yapisal hasar

MALIYET REFERANSI (2025 Turkiye):
- Kucuk cizik rotusu: 500-1500 TL
- Gocuk duzeltme (PDR): 1000-3000 TL
- Panel boyama: 3000-8000 TL
- Tampon degisimi: 5000-15000 TL
- Cam degisimi: 2000-10000 TL

CIKTI FORMATI:
JSON formatinda detayli degerlendirme dondur.

ARAC: {brand} {model} ({year})
PAZAR: {market}
HASAR LISTESI:
{damages_json}
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-3.1 | Hasarsiz arac | score: 95-100 |
| TS-3.2 | Tek minor cizik | score: 85-90, low urgency |
| TS-3.3 | Coklu orta hasar | score: 60-75, medium urgency |
| TS-3.4 | Ciddi hasar | score: <50, high urgency |
| TS-3.5 | Guvenlik etkileyen | safety_impact: significant |

---

## 4. Plaka Tanima

### Amac
Arac fotograflarindan plaka numarasini otomatik okumak.

### Desteklenen Plaka Formatlari
- Turkiye standart plakalari (34 ABC 123)
- Turkiye eski format (34 AB 1234)
- Ozel plakalar (diplomatik, resmi)

### Girdi
```json
{
  "image": "base64_encoded_image",
  "region": "TR"
}
```

### Beklenen Cikti
```json
{
  "plate_detected": true,
  "plate_text": "34 ABC 123",
  "plate_format": "standard",
  "city_code": "34",
  "city_name": "Istanbul",
  "confidence": 0.95,
  "bounding_box": { "x": 200, "y": 450, "width": 150, "height": 40 }
}
```

### Test Prompt Sablonu

```
Sen bir plaka tanima sistemisin.

GOREV:
1. Fotograftaki arac plakasini bul
2. Plaka metnini oku
3. Plaka formatini belirle
4. Il kodunu coz

TURKIYE PLAKA FORMATI:
- Standart: [Il Kodu] [Harfler] [Rakamlar]
- Ornekler: 34 ABC 123, 06 A 1234, 35 AB 12

IL KODLARI:
01-Adana, 06-Ankara, 07-Antalya, 16-Bursa, 34-Istanbul, 35-Izmir...

KURALLAR:
- Plaka bulunamazsa plate_detected: false dondur
- Kismi okunabilen plakalarda confidence dusuk olsun
- Sadece Turkiye plakalari destekleniyor

CIKTI FORMATI:
JSON formatinda dondur.
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-4.1 | Net gorunen plaka | Yuksek confidence |
| TS-4.2 | Uzak/bulanik plaka | Dusuk confidence |
| TS-4.3 | Plaka yok | plate_detected: false |
| TS-4.4 | Farkli sehir kodlari | Dogru city_name |
| TS-4.5 | Eski format plaka | plate_format: legacy |

---

## 5. Gorsel Rapor Olusturma

### Amac
Tum analizleri birlestirerek kullanici dostu gorsel rapor olusturmak.

### Rapor Icerigi
- Genel arac durumu ozeti
- Tespit edilen hasarlar (gorsel isaretli)
- Lastik durumu
- Onarim onerileri
- Tahmini maliyet

### Girdi
```json
{
  "vehicle_info": {...},
  "damage_analysis": {...},
  "tire_analysis": [...],
  "images": [...]
}
```

### Beklenen Cikti
```json
{
  "report_id": "RPT-2025-001234",
  "generated_at": "2025-12-17T10:45:00Z",
  "summary": {
    "overall_condition": "good",
    "score": 82,
    "urgent_issues": 0,
    "attention_needed": 2
  },
  "sections": [
    {
      "title": "Dis Gorunum",
      "status": "attention",
      "findings": ["Sol camurlukta hafif cizik", "Arka tamponda kucuk gocuk"],
      "image_refs": ["img_001", "img_002"]
    },
    {
      "title": "Lastikler",
      "status": "good",
      "findings": ["Tum lastikler yeterli dis derinliginde"],
      "image_refs": ["img_003"]
    }
  ],
  "recommendations": [
    "3 ay icinde boya rotusu onerilir",
    "Lastikler 15.000 km sonra kontrol edilmeli"
  ],
  "next_check_date": "2026-03-17"
}
```

### Test Prompt Sablonu

```
Sen bir arac rapor olusturma sistemisin.

GOREV:
1. Tum analiz sonuclarini birlesitir
2. Kullanici dostu ozet olustur
3. Oncelikli aksiyonlari belirle
4. Sonraki kontrol tarihini oner

RAPOR YAPISI:
- Ozet: Genel durum ve puan
- Bolumler: Her alan icin detay
- Oneriler: Yapilmasi gerekenler
- Sonraki Kontrol: Tarih onerisi

DURUM ETIKETLERI:
- good: Sorun yok (yesil)
- attention: Dikkat gerekli (sari)
- critical: Acil mudahale (kirmizi)

DILI: Turkce, anlasilir, teknik olmayan

CIKTI FORMATI:
JSON formatinda rapor dondur.

ANALIZ VERILERI:
{analysis_data}
```

---

## Test Sureci

### Asama 1: Bireysel Modul Testleri
Her modul icin test senaryolari tek tek calistirilacak.

### Asama 2: Entegrasyon Testleri
Moduller arasi veri akisi test edilecek.

### Asama 3: Prompt Optimizasyonu
Test sonuclarina gore promptlar iyilestirilecek.

### Asama 4: Edge Case Testleri
Sinir durumlar ve hatali girdiler test edilecek.

---

## Basari Metrikleri

| Metrik | Hedef | Olcum Yontemi |
|--------|-------|---------------|
| Hasar Tespit Dogrulugu | >90% | Manuel dogrulama |
| Lastik Analiz Dogrulugu | >85% | Gercek olcum karsilastirma |
| Plaka Tanima Dogrulugu | >95% | Otomatik test seti |
| Yanlis Pozitif Orani | <5% | Manuel dogrulama |
| Ortalama Yanit Suresi | <3sn | Performans olcumu |

---

## Notlar

- Tum promptlar test sirasinda iteratif olarak gelistirilecek
- Her test sonucu dokumante edilecek
- Basarisiz testler icin prompt revizyonu yapilacak
- Nihai promptlar `prompts/` klasorune kaydedilecek

---

*Son Guncelleme: Aralik 2025*
