# CarCheck AI - Yapay Zeka Ozellikleri (MVP v1.0)

Bu dokuman, ilk surumde yer alacak AI ozelliklerini, test senaryolarini ve prompt yapilarini detayli sekilde aciklamaktadir.

---

## Uygulama Kullanim Senaryosu

```
1. Kullanici uygulamaya giris yapar
2. Arac bilgilerini girer (marka, model, yil, yakit tipi, kilometre)
3. "Araclarim" bolumunden aracini secer
4. "Bakim Analizi Yaptir" butonuna tiklar
5. AI sistemi kullanicidan belirli bolgelerin fotografini ister
6. Kullanici tek tek fotograflari ceker ve yukler
7. AI analiz yapar ve bakim raporu olusturur:
   - Iyi durumda olan parcalar
   - Dikkat gerektiren parcalar
   - Acil bakim gerektiren parcalar
   - Onerilen islemler (yag degisimi, lastik rotasyonu vb.)
8. Bakim kaydi sisteme kaydedilir
9. Sistem duzenliaraliklerla hatirlatma gonderir:
   - "Son bakimdan bu yana X gun gecti"
   - "Kilometre Y'ye ulasti, Z bakimi onerilir"
```

---

## Kapsam Tanimi

### BU UYGULAMA NEDIR
- **Bakim takip ve analiz sistemi**
- Duzenli bakim kontrolu icin gorsel analiz
- Preventif (onleyici) bakim onerileri
- Kilometre ve zaman bazli hatirlatmalar

### BU UYGULAMA NE DEGILDIR
- ❌ Hasar tespit sistemi (cizik, gocuk, kaporta hasari)
- ❌ Kaza sonrasi degerlendirme
- ❌ Sigorta hasar raporu
- ❌ Ikinci el arac ekspertizi

> **ONEMLI:** Buyuk hasarlar (cizik, gocuk, carpisma izleri) bu uygulamanin kapsaminda DEGILDIR. Odak noktasi BAKIM'dir.

---

## Genel Bakis

MVP'de 6 temel AI modulu bulunacaktir:

| # | Modul | Oncelik | Durum |
|---|-------|---------|-------|
| 1 | Lastik Durumu Analizi | Yuksek | Test Edilecek |
| 2 | Motor Bolgesi Kontrolu | Yuksek | Test Edilecek |
| 3 | Aydinlatma Sistemi Kontrolu | Orta | Test Edilecek |
| 4 | Sivi Seviyeleri Kontrolu | Orta | Test Edilecek |
| 5 | EV Sarj Sistemi Kontrolu | Orta | Test Edilecek |
| 6 | Bakim Raporu Olusturma | Yuksek | Test Edilecek |

---

## Fotograf Cekim Akisi

Kullanicidan istenecek fotograflar sirasi ile:

| Sira | Bolge | Aciklama |
|------|-------|----------|
| 1 | Sol On Lastik | Dis yuzey gorunecek sekilde |
| 2 | Sag On Lastik | Dis yuzey gorunecek sekilde |
| 3 | Sol Arka Lastik | Dis yuzey gorunecek sekilde |
| 4 | Sag Arka Lastik | Dis yuzey gorunecek sekilde |
| 5 | Motor Bolgesi | Kaput acik, genel gorunum |
| 6 | On Farlar | Her iki far gorunecek |
| 7 | Arka Stoplar | Her iki stop gorunecek |
| 8 | Gostergeler/Kilometre | Dijital veya analog gosterge |
| 9 | EV Sarj Portu (opsiyonel) | Sadece elektrikli araclar |

---

## 1. Lastik Durumu Analizi

### Amac
Lastik fotograflarindan dis derinligi, asinma durumu ve bakim ihtiyacini belirlemek.

### Analiz Edilecek Parametreler
- **Dis Derinligi Tahmini:** mm cinsinden
- **Asinma Paterni:** Esit mi, esitsiz mi
- **Yan Duvar Durumu:** Catlak, yaslasma belirtileri
- **Hava Basinci Gostergesi:** Asinma paterninden tahmin
- **Sonraki Bakim Onerisi:** Km veya ay cinsinden

### Girdi
```json
{
  "image": "base64_encoded_image",
  "tire_position": "front_left | front_right | rear_left | rear_right",
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "current_km": 45000
  },
  "last_tire_change_km": 30000
}
```

### Beklenen Cikti
```json
{
  "tread_depth_mm": 4.5,
  "tread_status": "good | attention | critical",
  "wear_pattern": {
    "type": "even | center | edge | cupping",
    "description": "Esit asinma, normal kullanim"
  },
  "sidewall_condition": "good | aged | cracked",
  "estimated_remaining_km": 15000,
  "maintenance_recommendation": {
    "action": "none | rotation | replacement | pressure_check",
    "urgency": "none | soon | immediate",
    "description": "Lastikler iyi durumda, 15.000 km sonra kontrol onerilir"
  },
  "confidence": 0.85
}
```

### Test Prompt Sablonu

```
Sen bir arac bakim uzmanlisin. Lastik fotografini inceleyerek BAKIM odakli analiz yap.

GOREV:
1. Dis derinligini tahmin et (mm)
2. Asinma paternini belirle
3. Yan duvar durumunu kontrol et
4. Kalan kullanim omrunu tahmin et
5. Bakim onerisi sun

DIS DERINLIGI REFERANS:
- 8mm: Yeni lastik
- 5-7mm: Cok iyi durumda
- 4-5mm: Iyi durumda, takipte tut
- 3-4mm: Dikkat, degisim planlenmali
- 1.6mm alti: Kritik, hemen degistirilmeli

ASINMA PATERNLERI VE ANLAMI:
- even: Esit asinma → Normal, lastik rotasyonu yeterli
- center: Ortadan asinma → Fazla hava basinci, ayarla
- edge: Kenarlardan asinma → Dusuk hava basinci, ayarla
- cupping: Dalgali asinma → Balans/rot kontrolu gerekli

ONEMLI:
- Bu bir BAKIM sistemi, hasar degerlendirmesi DEGIL
- Kullaniciya anlasilir Turkce aciklamalar yap
- Pratik ve uygulanabilir oneriler sun

CIKTI: JSON formatinda
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-1.1 | Yeni lastik | 7-8mm, status: good |
| TS-1.2 | Orta kullanilmis | 4-5mm, status: good/attention |
| TS-1.3 | Asinmis lastik | <3mm, status: critical |
| TS-1.4 | Ortadan asinmis | center pattern, basinc uyarisi |
| TS-1.5 | Kenardan asinmis | edge pattern, basinc uyarisi |
| TS-1.6 | Yaslanmis lastik | sidewall: aged, dikkat onerisi |

---

## 2. Motor Bolgesi Kontrolu

### Amac
Motor bolumu fotografindan genel bakim durumunu, sizinti belirtilerini ve temizlik ihtiyacini tespit etmek.

### Analiz Edilecek Parametreler
- **Genel Temizlik:** Kir, toz birikimi
- **Sizinti Belirtileri:** Yag, antifriz, fren hidrolik
- **Kayis Durumu:** Gorulebildigi olcude
- **Aku Terminalleri:** Oksidasyon, korozyon
- **Hortum Durumu:** Catlak, yaslasma

### Girdi
```json
{
  "image": "base64_encoded_image",
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "fuel_type": "gasoline | diesel | hybrid | electric",
    "current_km": 45000
  },
  "last_oil_change_km": 40000
}
```

### Beklenen Cikti
```json
{
  "overall_cleanliness": "clean | dusty | dirty",
  "leak_detection": {
    "detected": false,
    "type": null,
    "location": null,
    "severity": null
  },
  "visible_components": {
    "battery_terminals": "good | oxidized | corroded",
    "belts": "good | worn | not_visible",
    "hoses": "good | aged | cracked | not_visible"
  },
  "oil_condition_estimate": "ok | check_needed | change_needed",
  "maintenance_recommendations": [
    {
      "component": "motor bolgesi",
      "action": "Genel temizlik onerilir",
      "urgency": "low"
    }
  ],
  "confidence": 0.80
}
```

### Test Prompt Sablonu

```
Sen bir arac bakim uzmanlisin. Motor bolgesi fotografini inceleyerek BAKIM odakli analiz yap.

GOREV:
1. Genel temizlik durumunu degerlendir
2. Sizinti belirtisi var mi kontrol et
3. Gorunen parcalarin durumunu incele
4. Bakim onerileri sun

KONTROL NOKTALARI:
- Yag sizintisi: Koyu lekeler, islak alanlar
- Antifriz sizintisi: Yesil/turuncu lekeler
- Aku terminalleri: Beyaz/yesil oksidasyon
- Kayislar: Catlak, asinma
- Hortumlar: Sertlesme, catlak

SIZINTI SEVIYELERI:
- none: Sizinti yok
- minor: Hafif nem, takip edilmeli
- moderate: Belirgin sizinti, servise gotur
- severe: Ciddi sizinti, hemen mudahale

ONEMLI:
- Bu bir BAKIM sistemi
- Sadece gorulebilen sorunlari raporla
- Emin olmadigin durumlar icin "serviste kontrol ettirin" one

CIKTI: JSON formatinda
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-2.1 | Temiz motor bolgesi | cleanliness: clean |
| TS-2.2 | Tozlu motor | cleanliness: dusty |
| TS-2.3 | Yag sizintisi belirtisi | leak_detection.detected: true |
| TS-2.4 | Oksitlenmis aku | battery_terminals: oxidized |
| TS-2.5 | Yaslanmis hortumlar | hoses: aged |

---

## 3. Aydinlatma Sistemi Kontrolu

### Amac
Far ve stop fotograflarindan aydinlatma sisteminin calisma durumunu ve bakim ihtiyacini belirlemek.

### Analiz Edilecek Parametreler
- **Far Durumu:** Net/buzlu/sarimis
- **Ampul Durumu:** Gorulebilir yanma/kararma
- **Lens Temizligi:** Kir, cizik
- **Hizalama:** Gorusel tahmin

### Girdi
```json
{
  "image": "base64_encoded_image",
  "light_type": "headlight | taillight | fog | signal",
  "light_position": "left | right | both",
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020
  }
}
```

### Beklenen Cikti
```json
{
  "lens_condition": "clear | cloudy | yellowed | damaged",
  "cleanliness": "clean | dirty",
  "visible_issues": [],
  "maintenance_recommendation": {
    "action": "none | clean | polish | replace",
    "urgency": "none | soon | immediate",
    "description": "Farlar iyi durumda"
  },
  "confidence": 0.85
}
```

### Test Prompt Sablonu

```
Sen bir arac bakim uzmanlisin. Far/stop fotografini inceleyerek BAKIM odakli analiz yap.

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

BAKIM ONERILERI:
- clear + clean: Bakim gerektirmez
- cloudy: Far parlatma seti ile temizlik
- yellowed: Profesyonel parlatma veya degisim
- damaged: Degisim gerekli

CIKTI: JSON formatinda
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-3.1 | Temiz, net far | lens: clear, action: none |
| TS-3.2 | Buzlu far | lens: cloudy, action: polish |
| TS-3.3 | Sarimis far | lens: yellowed, action: polish/replace |
| TS-3.4 | Kirli far | cleanliness: dirty |

---

## 4. Sivi Seviyeleri Kontrolu

### Amac
Motor bolumu fotografindan gorulebilen sivi haznelerinin seviyelerini tahmin etmek.

### Analiz Edilecek Parametreler
- **Cam Suyu:** Seviye tahmini
- **Antifriz:** Seviye ve renk
- **Fren Hidrolik:** Seviye

### Girdi
```json
{
  "image": "base64_encoded_image",
  "fluid_type": "washer | coolant | brake | all",
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020
  }
}
```

### Beklenen Cikti
```json
{
  "fluids_detected": [
    {
      "type": "washer",
      "level": "full | adequate | low | empty | not_visible",
      "condition": "ok | contaminated | not_visible",
      "action_needed": "none | refill | check"
    }
  ],
  "general_recommendation": "Tum sivi seviyeleri normal gorunuyor",
  "confidence": 0.75
}
```

### Test Prompt Sablonu

```
Sen bir arac bakim uzmanlisin. Motor bolgesi fotografinda gorunen sivi haznelerini analiz et.

GOREV:
1. Gorunen sivi haznelerini tespit et
2. Seviyelerini tahmin et
3. Renk/kalite durumunu degerlendir
4. Bakim onerisi sun

SIVI TURLERI:
- washer: Cam suyu (genelde mavi hazne)
- coolant: Antifriz (genelde seffaf hazne, renkli sivi)
- brake: Fren hidrolik (kucuk hazne, sari sivi)

SEVIYE DEGERLENDIRME:
- full: Dolu (%80-100)
- adequate: Yeterli (%50-80)
- low: Dusuk (%20-50)
- empty: Bos (%0-20)

ONEMLI:
- Gorunmeyen hazneler icin "not_visible" kullan
- Tahminlerde dikkatli ol, kesin olma
- Profesyonel kontrol onerisinde bulun

CIKTI: JSON formatinda
```

---

## 5. EV Sarj Sistemi Kontrolu (Elektrikli Araclar)

### Amac
Elektrikli arac sarj portunu inceleyerek temizlik ve bakim durumunu belirlemek.

### Analiz Edilecek Parametreler
- **Port Temizligi:** Kir, toz
- **Pin Durumu:** Oksidasyon, hasar
- **Kapak Durumu:** Tam kapanma
- **Genel Durum:** Kullanima hazir mi

### Girdi
```json
{
  "image": "base64_encoded_image",
  "port_type": "type2 | ccs | chademo",
  "vehicle_info": {
    "brand": "Tesla",
    "model": "Model 3",
    "year": 2023
  }
}
```

### Beklenen Cikti
```json
{
  "port_cleanliness": "clean | dusty | dirty",
  "pin_condition": "good | oxidized | damaged | not_visible",
  "visible_damage": false,
  "maintenance_recommendation": {
    "action": "none | clean | inspect | service",
    "urgency": "none | soon | immediate",
    "description": "Sarj portu temiz ve iyi durumda"
  },
  "confidence": 0.80
}
```

### Test Prompt Sablonu

```
Sen bir elektrikli arac bakim uzmanlisin. Sarj portu fotografini analiz et.

GOREV:
1. Port temizligini degerlendir
2. Pin/konnektor durumunu kontrol et
3. Gorunen hasar var mi belirle
4. Bakim onerisi sun

KONTROL NOKTALARI:
- Toz/kir birikimi
- Pin oksidasyonu (yesil/beyaz lekeler)
- Plastik parcalarda catlak
- Yabanci cisim

BAKIM ONERILERI:
- clean: Temiz, bakim gerektirmez
- dusty: Kuru bezle silin
- dirty: Ozel temizleyici ile temizlik
- oxidized: Servis kontrolu onerilir

CIKTI: JSON formatinda
```

---

## 6. Bakim Raporu Olusturma

### Amac
Tum analizleri birlestirerek kullanici dostu, anlasilir bir bakim raporu olusturmak.

### Rapor Icerigi
- Genel arac bakim durumu
- Iyi durumda olan parcalar
- Dikkat gerektiren parcalar
- Acil bakim gerektiren parcalar
- Onerilen islemler listesi
- Sonraki bakim tarihi/km onerisi

### Girdi
```json
{
  "vehicle_info": {
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "current_km": 45000,
    "fuel_type": "gasoline"
  },
  "analysis_results": {
    "tires": [...],
    "engine_bay": {...},
    "lights": {...},
    "fluids": {...}
  },
  "previous_maintenance": {
    "last_date": "2025-06-15",
    "last_km": 40000
  }
}
```

### Beklenen Cikti
```json
{
  "report_id": "RPT-2025-001234",
  "generated_at": "2025-12-17T10:45:00Z",
  "vehicle": "Toyota Corolla 2020",
  "current_km": 45000,

  "summary": {
    "overall_status": "good | attention | critical",
    "score": 85,
    "good_items": 8,
    "attention_items": 2,
    "critical_items": 0
  },

  "good_condition": [
    "On lastikler iyi durumda",
    "Motor bolgesi temiz",
    "Farlar net ve temiz"
  ],

  "needs_attention": [
    {
      "item": "Arka sol lastik",
      "issue": "Dis derinligi dusuk (3.5mm)",
      "recommendation": "2-3 ay icinde degisim planlayın",
      "urgency": "medium"
    }
  ],

  "critical_issues": [],

  "maintenance_actions": [
    {
      "action": "Yag degisimi",
      "reason": "Son degisimden bu yana 5.000 km",
      "urgency": "soon"
    },
    {
      "action": "Lastik rotasyonu",
      "reason": "On/arka asinma farki",
      "urgency": "soon"
    }
  ],

  "next_maintenance": {
    "recommended_date": "2026-03-17",
    "recommended_km": 50000,
    "reason": "Yag degisim araligi"
  },

  "tips": [
    "Kis lastigi kontrolu yapin",
    "Antifriz seviyesini takip edin"
  ]
}
```

### Test Prompt Sablonu

```
Sen bir arac bakim danismanisin. Analiz sonuclarini kullanici dostu bir rapora donustur.

GOREV:
1. Tum analiz sonuclarini birlesir
2. Iyi/dikkat/kritik olarak kategorize et
3. Anlasilir Turkce aciklamalar yaz
4. Somut bakim onerileri sun
5. Sonraki bakim tarihini oner

RAPOR FORMATI:
- Ozet: Genel durum puani ve ozet
- Iyi Durumda: Sorun olmayan parcalar
- Dikkat Gerektiren: Yakin zamanda bakim gereken
- Kritik: Hemen mudahale gereken (varsa)
- Bakim Aksiyonlari: Yapilmasi gereken islemler
- Sonraki Bakim: Tarih ve km onerisi

DILI VE USLUP:
- Sade Turkce, teknik terimlerden kacin
- Kullaniciyi korkutma, cozum odakli ol
- Pratik ve uygulanabilir oneriler sun
- Pozitif tonla baslat ("Araciniz genel olarak iyi durumda")

ONEMLI:
- Hasar degerlendirmesi YAPMA
- Maliyet tahmini verme (bakima odaklan)
- Servise gitmeyi gerektiren durumlar icin yonlendir

CIKTI: JSON formatinda
```

---

## Bakim Hatirlatma Mantigi

Sistem asagidaki kurallara gore hatirlatma gonderir:

### Zaman Bazli Hatirlatmalar
| Bakim Turu | Varsayilan Aralik |
|------------|-------------------|
| Genel kontrol | 3 ay |
| Yag degisimi | 6 ay veya 10.000 km |
| Lastik kontrolu | 3 ay |
| Fren kontrolu | 12 ay veya 20.000 km |

### Kilometre Bazli Hatirlatmalar
| Bakim Turu | Kilometre Araligi |
|------------|-------------------|
| Yag degisimi | Her 10.000 km |
| Filtre degisimi | Her 15.000 km |
| Lastik rotasyonu | Her 10.000 km |
| Bakim servisi | Her 15.000-20.000 km |

### Hatirlatma Mesaji Ornekleri
```
"Son bakiminizdan bu yana 45 gun gecti. Yeni bir bakim analizi yapmanizi oneririz."

"Araciniz son bakimdan bu yana 5.000 km yol aldi. Yag seviyesi kontrolu onerilir."

"Lastik kontrolu zamani! Son kontrolden bu yana 3 ay gecti."
```

---

## Test Sureci

### Asama 1: Bireysel Modul Testleri
Her modul icin test senaryolari tek tek calistirilacak.

### Asama 2: Entegrasyon Testleri
Fotograflar sirali cekilip tam rapor olusturma testi.

### Asama 3: Prompt Optimizasyonu
Test sonuclarina gore promptlar iyilestirilecek.

### Asama 4: Kullanici Testi
Gercek kullanicilarla test edilecek.

---

## Basari Metrikleri

| Metrik | Hedef | Olcum Yontemi |
|--------|-------|---------------|
| Lastik Analiz Dogrulugu | >85% | Gercek olcum karsilastirma |
| Yanlis Pozitif Orani | <10% | Manuel dogrulama |
| Kullanici Memnuniyeti | >4/5 | Anket |
| Rapor Anlasilirlik | >90% | Kullanici testi |
| Ortalama Analiz Suresi | <30sn | Performans olcumu |

---

## Notlar

- Tum promptlar test sirasinda iteratif olarak gelistirilecek
- Her test sonucu dokumante edilecek
- Basarisiz testler icin prompt revizyonu yapilacak
- Nihai promptlar `prompts/` klasorune kaydedilecek
- Buyuk hasar tespiti KAPSAM DISINDA - kullaniciya bunu belirt

---

*Son Guncelleme: Aralik 2025*
