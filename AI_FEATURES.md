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
   - Onerilen islemler (yag degisimi vb.)
8. Bakim kaydi sisteme kaydedilir
9. Sistem duzenli araliklerla hatirlatma gonderir:
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
- Hasar tespit sistemi (cizik, gocuk, kaporta hasari)
- Kaza sonrasi degerlendirme
- Sigorta hasar raporu
- Ikinci el arac ekspertizi

> **ONEMLI:** Buyuk hasarlar (cizik, gocuk, carpisma izleri) bu uygulamanin kapsaminda DEGILDIR. Odak noktasi BAKIM'dir.

---

## Arac Kategorileri

Araclar guc kaynagina gore 4 kategoriye ayrilir. Her kategorinin farkli bakim gereksinimleri ve fotograf istek listesi vardir.

### Kategori Tanimi

| Kod | Kategori | Kapsam | Ozellik |
|-----|----------|--------|---------|
| **ICE** | Icten Yanmali Motor | Benzinli, Dizel, LPG, CNG | Geleneksel motor, yag degisimi var |
| **HEV** | Hibrit | Self-charging Hybrid | Motor + elektrik, sarj portu YOK |
| **PHEV** | Plug-in Hibrit | Plug-in Hybrid | Motor + elektrik, sarj portu VAR |
| **BEV** | Tam Elektrikli | Battery Electric Vehicle | Sadece elektrik, yag degisimi YOK |

### Kategori Secim Mantigi

```
Kullanici arac eklerken yakit/guc tipi secer:
├── Benzin ──────────→ ICE
├── Dizel ───────────→ ICE
├── LPG ─────────────→ ICE
├── Hibrit ──────────→ HEV
├── Plug-in Hibrit ──→ PHEV
└── Elektrik ────────→ BEV
```

---

## Genel Bakis

MVP'de 5 temel AI modulu bulunacaktir:

| # | Modul | Oncelik | Durum |
|---|-------|---------|-------|
| 1 | Motor Bolgesi Kontrolu | Yuksek | Test Edilecek |
| 2 | Aydinlatma Sistemi Kontrolu | Orta | Test Edilecek |
| 3 | Sivi Seviyeleri Kontrolu | Orta | Test Edilecek |
| 4 | EV Sarj Sistemi Kontrolu | Orta | Test Edilecek |
| 5 | Bakim Raporu Olusturma | Yuksek | Test Edilecek |

---

## Kategorilere Gore Fotograf Gereksinimleri

### Karsilastirma Tablosu

```
Kontrol Noktasi              ICE    HEV    PHEV   BEV
────────────────────────────────────────────────────
MOTOR / GUC UNITESI
  Motor Bolgesi (kaput acik)  ✓      ✓      ✓      ✗
  Guc Elektronigi Bolgesi     ✗      ✗      ✗      ✓

AYDINLATMA
  On Farlar                   ✓      ✓      ✓      ✓
  Arka Stop Lambalari         ✓      ✓      ✓      ✓

SARJ SISTEMI
  Sarj Portu                  ✗      ✗      ✓      ✓

GOSTERGE
  Kilometre/Gosterge Paneli   ✓      ✓      ✓      ✓

EGZOZ
  Egzoz Cikisi                ✓      ✓      ✓      ✗
────────────────────────────────────────────────────
TOPLAM FOTOGRAF               6      6      7      5
```

---

## ICE Kategorisi - Detayli Fotograf Listesi
**Benzinli / Dizel / LPG / CNG Araclar**

### Fotograf Sirasi ve Talimatlari

| Sira | Bolge | Cekim Talimati | Kontrol Amaci |
|------|-------|----------------|---------------|
| 1 | **Motor Bolgesi** | Kaputu acin, motor bolgesinin tamamini cekecek sekilde yukselten bir acidan fotograflayin. Iyi aydinlatma saglayin. | Genel temizlik, sizinti, aku, kayis, hortum durumu |
| 2 | **On Farlar** | Aracin onunden her iki fari gorecek sekilde cekin. | Lens durumu (sari, buzlu), temizlik |
| 3 | **Arka Stop Lambalari** | Aracin arkasindan her iki stopu gorecek sekilde cekin. | Lens durumu, kirlilik, catlak |
| 4 | **Gosterge Paneli** | Kontagi acin (calistirmaya gerek yok), gosterge panelini net gorunecek sekilde cekin. | Kilometre, uyari isiklari |
| 5 | **Egzoz Cikisi** | Egzoz ucunu yakindan cekin. Birden fazla egzoz varsa hepsini cekin. | Pas, korozyon, is birikimi |
| 6 | **Motor Yagi Cubugu** (opsiyonel) | Yag cubugunu cekip temizleyin, tekrar daldirip cikarin ve fotograflayin. | Yag seviyesi ve rengi |

### ICE Ozel Kontrol Noktalari

#### Motor Bolgesi Detaylari
```
Kontrol Edilecekler:
├── Yag Kapagi Cevresi ─────→ Sizinti izi var mi?
├── Aku Terminalleri ───────→ Beyaz/yesil oksidasyon var mi?
├── V-Kayis / Triger Kayisi ─→ Catlak, asinma var mi?
├── Radyator Hortumu ───────→ Sismis, sert, catlak mi?
├── Antifriz Haznesi ───────→ Seviye min-max arasi mi?
├── Fren Hidrolik Haznesi ──→ Seviye yeterli mi?
├── Cam Suyu Haznesi ───────→ Dolu mu?
└── Hava Filtresi Kutusu ───→ Genel durum
```

#### Egzoz Kontrol Noktalari
```
Kontrol Edilecekler:
├── Pas / Korozyon ─────────→ Delinme riski
├── Is Birikimi ────────────→ Yakit yakim problemi gostergesi
├── Fiziksel Hasar ─────────→ Ezik, kirik
└── Baglanti Noktalari ─────→ Sizinti izleri
```

---

## HEV Kategorisi - Detayli Fotograf Listesi
**Hibrit Araclar (Self-Charging)**

### Fotograf Sirasi ve Talimatlari

| Sira | Bolge | Cekim Talimati | Kontrol Amaci |
|------|-------|----------------|---------------|
| 1 | **Motor Bolgesi** | Kaputu acin, motor bolgesinin tamamini cekin. Hibrit sistemde turuncu kablolara DOKUNMAYIN. | Motor durumu, elektrik bilesenleri |
| 2 | **On Farlar** | Her iki fari gorecek sekilde cekin. | Lens durumu, temizlik |
| 3 | **Arka Stop Lambalari** | Her iki stopu gorecek sekilde cekin. | Lens durumu, kirlilik |
| 4 | **Gosterge Paneli** | Kontagi acin, gosterge panelini cekin. Hibrit batarya gostergesini de icersin. | Kilometre, batarya durumu, uyarilar |
| 5 | **Egzoz Cikisi** | Egzoz ucunu yakindan cekin. | Pas, korozyon |
| 6 | **Hibrit Batarya Sogutucu** (opsiyonel) | Genellikle arka koltuk altinda veya bagajda. Havalandirma izgararini cekin. | Toz birikimi, tikanilik |

### HEV Ozel Kontrol Noktalari

#### Motor Bolgesi (Hibrit)
```
Kontrol Edilecekler:
├── Benzinli Motor Alani ───→ Standart ICE kontrolleri
├── Elektrik Motor Alani ──→ Gorunen hasar, kablo durumu
├── Inverter Unitesi ──────→ Temizlik, hasar
├── 12V Akseuar Akusu ─────→ Terminal durumu
└── Turuncu Yuksek Voltaj Kablolari → SADECE GORSEL (dokunmayin!)
```

#### Hibrit Batarya Sogutma
```
Kontrol Edilecekler:
├── Havalandirma Izgarasi ──→ Toz, kir birikimi
├── Fan Giris/Cikisi ───────→ Tikanilik
└── Genel Temizlik ─────────→ 6 ayda bir temizlik onerilir
```

> **UYARI:** Hibrit araclarda TURUNCU renkli kablolar yuksek voltaj tasir. Kesinlikle dokunmayin, sadece gorsel kontrol yapin.

---

## PHEV Kategorisi - Detayli Fotograf Listesi
**Plug-in Hibrit Araclar**

### Fotograf Sirasi ve Talimatlari

| Sira | Bolge | Cekim Talimati | Kontrol Amaci |
|------|-------|----------------|---------------|
| 1 | **Motor Bolgesi** | Kaputu acin, motor bolgesinin tamamini cekin. | Motor ve elektrik sistem durumu |
| 2 | **On Farlar** | Her iki fari gorecek sekilde cekin. | Lens durumu, temizlik |
| 3 | **Arka Stop Lambalari** | Her iki stopu gorecek sekilde cekin. | Lens durumu, kirlilik |
| 4 | **Gosterge Paneli** | Kontagi acin, gosterge panelini cekin. | Kilometre, batarya, uyarilar |
| 5 | **Egzoz Cikisi** | Egzoz ucunu yakindan cekin. | Pas, korozyon |
| 6 | **Sarj Portu (Kapali)** | Sarj kapagini kapali halde cekin. | Kapak durumu, hasar |
| 7 | **Sarj Portu (Acik)** | Sarj kapagini acin, port icini cekin. | Pin durumu, temizlik, oksidasyon |

### PHEV Ozel Kontrol Noktalari

#### Motor Bolgesi (Plug-in Hibrit)
```
Kontrol Edilecekler:
├── Benzinli Motor ─────────→ Standart ICE kontrolleri
├── Elektrik Motor ─────────→ Gorunen hasar
├── Sarj Sistemi Elektronigi → Temizlik
├── 12V Akseuar Akusu ──────→ Terminal durumu
├── Sogutma Sistemi ────────→ Sivi seviyesi (ayri devre olabilir)
└── Yuksek Voltaj Kablolari → SADECE GORSEL
```

#### Sarj Portu Detaylari
```
Kontrol Edilecekler:
├── Kapak Mekanizmasi ──────→ Duzgun acilip kapaniyor mu?
├── Kapak Contasi ──────────→ Yirtik, sert, catlak var mi?
├── Port Temizligi ─────────→ Toz, kir, yaprak vs.
├── Pin/Konnektor Durumu ───→ Egrilis, oksidasyon, hasar
├── Plastik Govde ──────────→ Catlak, kirik
└── Aydinlatma (varsa) ─────→ Calisiyor mu?
```

#### Sarj Portu Tipleri (Turkiye)
```
├── Type 2 (AC) ────────────→ Standart Avrupa prizi, 7 pinli
├── CCS (DC) ───────────────→ Type 2 + 2 ekstra DC pin, hizli sarj
└── CHAdeMO ────────────────→ Japon standarti, bazi modellerde
```

---

## BEV Kategorisi - Detayli Fotograf Listesi
**Tam Elektrikli Araclar**

### Fotograf Sirasi ve Talimatlari

| Sira | Bolge | Cekim Talimati | Kontrol Amaci |
|------|-------|----------------|---------------|
| 1 | **On Bolum (Frunk/Guc Elektronigi)** | Kaputu acin. Bazi modellerde bagaj (frunk), bazilerinde guc elektronigi vardir. | Temizlik, genel durum |
| 2 | **On Farlar** | Her iki fari gorecek sekilde cekin. | Lens durumu, temizlik |
| 3 | **Arka Stop Lambalari** | Her iki stopu gorecek sekilde cekin. | Lens durumu, kirlilik |
| 4 | **Gosterge Paneli / Ekran** | Araci calistirin, ana ekrani/gostergeyi cekin. | Kilometre, batarya %, uyarilar |
| 5 | **Sarj Portu (Kapali)** | Sarj kapagini kapali halde cekin. | Kapak durumu |
| 6 | **Sarj Portu (Acik)** | Sarj kapagini acin, port icini cekin. | Pin durumu, temizlik, oksidasyon |

### BEV Ozel Kontrol Noktalari

#### On Bolum (Motor Bolgesi Yerine)
```
Arac Modeline Gore:
├── Frunk (On Bagaj) ───────→ Sadece temizlik kontrolu
│   └── Tesla, Rivian, Lucid, vb.
│
└── Guc Elektronigi Bolgesi → Inverter, sarj unitesi, sogutma
    └── VW ID, BMW i, Mercedes EQ, vb.

Kontrol Edilecekler:
├── Genel Temizlik ─────────→ Toz, yaprak birikimi
├── 12V Akseuar Akusu ──────→ Bazi modellerde burada (terminal kontrolu)
├── Sogutma Sivisi Haznesi ─→ Varsa seviye kontrolu
├── Cam Suyu Haznesi ───────→ Seviye kontrolu
└── Fren Hidrolik Haznesi ──→ Seviye kontrolu
```

#### Sarj Portu Detaylari (BEV)
```
Kontrol Edilecekler:
├── Kapak Mekanizmasi ──────→ Elektrikli/manuel duzgun calisiyor mu?
├── Kapak Contasi ──────────→ Su sizintisi onlemi icin kritik
├── Port Temizligi ─────────→ Toz, nem, yabanci cisim
├── AC Pinleri ─────────────→ 7 pin, oksidasyon kontrolu
├── DC Pinleri (CCS) ───────→ 2 buyuk pin, temizlik
└── Aydinlatma ─────────────→ Gece sarj icin onemli
```

#### BEV Ozel Notlar
```
OLMAYAN SEYLER (ICE'den farkli):
├── Motor yagi ─────────────→ YOK (yag degisimi yok)
├── V-kayis / Triger ───────→ YOK
├── Egzoz sistemi ──────────→ YOK
├── Radyator (geleneksel) ──→ YOK (farkli sogutma sistemi var)
└── Yakit filtresi ─────────→ YOK

OZEL DIKKAT GEREKTIREN:
├── Fren Balatalari ────────→ Rejeneratif fren nedeniyle daha az asinir
└── 12V Aku ────────────────→ Hala var ve onemli!
```

---

## Fotograf Cekim Kilavuzu

### Genel Kurallar

1. **Aydinlatma:** Dogal isik veya iyi aydinlatilmis ortam
2. **Mesafe:** Detay gorunecek kadar yakin, tum alan gorunecek kadar uzak
3. **Odak:** Bulanik fotograf kabul edilmez, net cekim sarti
4. **Aci:** Kontrol noktasini en iyi gosteren aci

### Ornek Cekim Acilar

```
MOTOR BOLGESI:
    ┌─────────────┐
    │   Kaput     │
    │   ______    │
    │  /      \   │
    │ | MOTOR  |  │  ← Yukselten aci
    │  \______/   │
    └─────────────┘

SARJ PORTU:
    ┌───┐
    │ O │  ← Dik aci, pinler net gorunmeli
    │O O│
    │ O │
    └───┘
```

---

## 1. Motor Bolgesi Kontrolu

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
- Emin olmadigin durumlar icin "serviste kontrol ettirin" oner

CIKTI: JSON formatinda
```

### Test Senaryolari

| Senaryo | Aciklama | Beklenen Sonuc |
|---------|----------|----------------|
| TS-1.1 | Temiz motor bolgesi | cleanliness: clean |
| TS-1.2 | Tozlu motor | cleanliness: dusty |
| TS-1.3 | Yag sizintisi belirtisi | leak_detection.detected: true |
| TS-1.4 | Oksitlenmis aku | battery_terminals: oxidized |
| TS-1.5 | Yaslanmis hortumlar | hoses: aged |

---

## 2. Aydinlatma Sistemi Kontrolu

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
| TS-2.1 | Temiz, net far | lens: clear, action: none |
| TS-2.2 | Buzlu far | lens: cloudy, action: polish |
| TS-2.3 | Sarimis far | lens: yellowed, action: polish/replace |
| TS-2.4 | Kirli far | cleanliness: dirty |

---

## 3. Sivi Seviyeleri Kontrolu

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

## 4. EV Sarj Sistemi Kontrolu (Elektrikli Araclar)

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

## 5. Bakim Raporu Olusturma

### Amac
Tum analizleri birlestirerek kullanici dostu, anlasilir bir bakim raporu olusturmak.

### Rapor Icerigi
- Genel arac bakim durumu
- Iyi durumda olan parcalar
- Dikkat gerektiren parcalar
- Acil bakim gerektiren parcalar
- Onerilen islemler listesi
- Sonraki bakim tarihi/km onerisi

---

## Bakim Hatirlatma Mantigi

Sistem asagidaki kurallara gore hatirlatma gonderir:

### Zaman Bazli Hatirlatmalar
| Bakim Turu | Varsayilan Aralik |
|------------|-------------------|
| Genel kontrol | 3 ay |
| Yag degisimi | 6 ay veya 10.000 km |
| Fren kontrolu | 12 ay veya 20.000 km |

### Kilometre Bazli Hatirlatmalar
| Bakim Turu | Kilometre Araligi |
|------------|-------------------|
| Yag degisimi | Her 10.000 km |
| Filtre degisimi | Her 15.000 km |
| Bakim servisi | Her 15.000-20.000 km |

### Hatirlatma Mesaji Ornekleri
```
"Son bakiminizdan bu yana 45 gun gecti. Yeni bir bakim analizi yapmanizi oneririz."

"Araciniz son bakimdan bu yana 5.000 km yol aldi. Yag seviyesi kontrolu onerilir."
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

## Rapor JSON Formati

Bakim analizi sonucunda olusturulan rapor asagidaki JSON yapisini kullanir.
Ornek dosya: `data/sample_report.json`

### Ana Yapi

```
{
  report_id          : Benzersiz rapor kimliği (RPT-YYYY-NNNNNN)
  generated_at       : Rapor olusturma zamani (ISO 8601)
  vehicle            : Arac bilgileri
  overall_summary    : Genel ozet ve saglik puani
  part_analyses[]    : Her parcanin detayli analizi
  recommendations    : Bakim onerileri
  next_maintenance   : Sonraki bakim tarihi/km
  tips               : Kullanici icin ipuclari
  metadata           : Teknik bilgiler
}
```

### Saglik Puani (health_score)

| Puan Araligi | Durum | Renk | Aciklama |
|--------------|-------|------|----------|
| 90-100 | `good` | Yesil | Mukemmel durumda |
| 70-89 | `attention` | Sari | Dikkat gerektiriyor |
| 0-69 | `critical` | Kirmizi | Acil mudahale gerekli |

### overall_summary Alani

```json
{
  "health_score": 82,
  "status": "good | attention | critical",
  "status_text": "Kullaniciya gosterilecek Turkce mesaj",
  "analyzed_parts_count": 5,
  "good_count": 3,
  "attention_count": 2,
  "critical_count": 0
}
```

### part_analyses[] Alani

Her analiz edilen parca icin:

```json
{
  "part_id": "engine_bay",
  "part_name": "Motor Bolgesi",
  "order": 1,
  "health_score": 75,
  "status": "attention",
  "analysis": {
    // Parcaya ozel analiz detaylari
    // Her parca tipi icin farkli alanlar
  },
  "findings": [
    {
      "type": "good | attention | critical",
      "component": "Alt bilesen adi",
      "description": "Tespit edilen durum",
      "recommendation": "Onerilen aksiyon"
    }
  ],
  "confidence": 0.85
}
```

### Parca Bazli Analiz Detaylari

#### Motor Bolgesi (engine_bay)
```json
{
  "overall_cleanliness": "clean | dusty | dirty",
  "leak_detection": {
    "detected": true | false,
    "type": "oil | coolant | brake_fluid | none",
    "severity": "none | minor | moderate | severe"
  },
  "visible_components": {
    "battery_terminals": "good | oxidized | corroded | not_visible",
    "belts": "good | worn | cracked | not_visible",
    "hoses": "good | aged | cracked | not_visible"
  },
  "fluid_levels": {
    "coolant": "full | adequate | low | not_visible",
    "washer": "full | adequate | low | not_visible",
    "brake_fluid": "full | adequate | low | not_visible"
  }
}
```

#### Farlar (headlights / taillights)
```json
{
  "lens_condition": "clear | cloudy | yellowed | damaged",
  "cleanliness": "clean | dirty",
  "visible_issues": ["sorun1", "sorun2"]
}
```

#### Gosterge Paneli (dashboard)
```json
{
  "odometer_reading": 45230,
  "fuel_level": "full | 3/4 | half | 1/4 | low | not_visible",
  "warning_lights": [
    {
      "type": "uyari_turu",
      "color": "red | yellow | green",
      "description": "aciklama"
    }
  ],
  "critical_warnings": true | false
}
```

#### Egzoz (exhaust)
```json
{
  "overall_condition": "good | fair | poor",
  "rust_corrosion": {
    "detected": true | false,
    "severity": "none | minor | moderate | severe",
    "description": "aciklama"
  },
  "soot_buildup": "none | light | moderate | heavy",
  "physical_damage": {
    "detected": true | false,
    "description": "aciklama veya null"
  }
}
```

#### Sarj Portu (charging_port) - PHEV/BEV
```json
{
  "port_cleanliness": "clean | dusty | dirty",
  "pin_condition": "good | oxidized | damaged | not_visible",
  "cap_condition": "good | damaged",
  "visible_damage": true | false
}
```

### recommendations Alani

```json
{
  "immediate": [
    // Hemen yapilmasi gereken islemler (kritik)
  ],
  "soon": [
    // Yakin zamanda yapilmasi gereken islemler
    {
      "action": "Yapilacak islem",
      "reason": "Neden gerekli",
      "estimated_priority": "high | medium | low"
    }
  ],
  "scheduled": [
    // Planlanan bakimda yapilacaklar
    {
      "action": "Yapilacak islem",
      "reason": "Neden gerekli",
      "recommended_km": 50000
    }
  ]
}
```

### metadata Alani

```json
{
  "analysis_duration_ms": 4500,
  "model_used": "gemini-2.0-flash",
  "photos_analyzed": 5,
  "average_confidence": 0.87
}
```

### Frontend Kullanim Ornekleri

#### Saglik Puani Gostergesi
```
[████████████████████░░░░] 82%
Araciniz iyi durumda
```

#### Parca Listesi
```
✅ On Farlar .............. 90%
✅ Arka Stoplar ........... 95%
✅ Gosterge Paneli ........ 85%
⚠️ Motor Bolgesi .......... 75%
⚠️ Egzoz .................. 70%
```

#### Bulgular Karti
```
⚠️ Aku terminalleri
   Hafif oksidasyon mevcut
   → Terminal temizligi yapilmali

⚠️ Cam suyu
   Seviye dusuk
   → Cam suyu eklenmeli
```

---

*Son Guncelleme: Ocak 2026*
