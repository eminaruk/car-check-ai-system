# CarCheck AI - Akilli Arac Bakim Analiz Sistemi

AI destekli gorsel analiz ve akilli bakim takibi ozelliklerini birlestiren yenilikci bir arac bakim uygulamasi.

## Proje Hakkinda

CarCheck AI, tuketicilere yonelik AI gorsel analiz ve akilli bakim takibi kombinasyonunu sunan ilk uygulama olmasi hedeflenmektedir. Mevcut pazarda bu iki teknolojiyi birlestiren tuketici odakli bir cozum bulunmamaktadir.

### Pazar Konumu

| Mevcut Cozumler | Eksiklikleri |
|-----------------|--------------|
| Bakim uygulamalari (CARFAX, FIXD) | AI gorsel analiz yok |
| AI gorsel analiz (Ravin AI, Monk AI) | Sadece B2B, tuketiciye hizmet yok |

**Firsatimiz:** Her iki teknolojiyi birlestiren ilk tuketici uygulamasi olmak.

## Ozellikler

### MVP - Temel Ozellikler (v1.0)

#### Arac Yonetimi
- Arac ekleme (Marka, Model, Yil, Motor tipi, Yakit/Elektrik)
- Coklu arac destegi (garaj ozelligi)
- Kilometre takibi (manuel veya OBD2 entegrasyonu)
- Arac fotografi ve belgeleri yukleme
- Plaka tanima ile hizli arac ekleme

#### AI Gorsel Bakim Analizi
- Rehberli fotograf cekimi (on, arka, yanlar, motor bolumu, lastikler)
- Video tabanli 360° tarama secenegi
- AI hasar tespiti (cizik, gocuk, pas, cam hasari)
- Lastik durumu analizi (dis derinligi tahmini)
- Gorsel rapor olusturma (iyi/dikkat/kritik durumlar)
- Hasar seviyesi ve aciliyet derecesi belirleme

#### Akilli Bakim Takibi
- Bakim gecmisi kaydi (yag, fren, filtre, aku vb.)
- Kilometre bazli hatirlaticilar
- Zaman bazli hatirlaticilar
- Ureticinin bakim programina gore oneriler
- Fatura ve makbuz yukleme

#### Bildirim Sistemi
- Push bildirimler (bakim zamani, tekrar analiz)
- E-posta bildirimleri
- SMS bildirimleri (opsiyonel)
- Ozellestirilebilir hatirlatma sureleri

### Gelismis Ozellikler (v2.0)

#### Elektrikli Arac (EV) Destegi
- Batarya sagligi takibi
- Sarj gecmisi ve istatistikleri
- Sarj istasyonu gorsel kontrolu (AI)
- Menzil tahmini ve optimizasyonu

#### Prediktif Analiz
- Makine ogrenimi ile ariza tahmini
- Benzer araclardan ogrenilen kaliplar
- Mevsimsel bakim onerileri
- Kullanim aliskanliklarina gore kisisellestrilmis tavsiyeler

#### OBD2 Entegrasyonu
- Bluetooth OBD2 adaptor destegi
- Canli motor verileri
- Hata kodu okuma ve aciklama
- Yakit tuketimi analizi

#### Maliyet Yonetimi
- Bakim masraflari takibi
- Yakit/sarj maliyeti hesaplama
- Aylik/yillik maliyet raporlari
- Onarim maliyet tahmini (AI tabanli)

### Premium Ozellikler (Abonelik)

#### Servis Entegrasyonu
- Yakindaki servisleri bulma
- Fiyat karsilastirma
- Online randevu alma
- Servis degerlendirmeleri ve puanlari

#### AI Mekanik Asistan
- Chatbot ile anlik soru-cevap
- Ses tanima ile ariza tarifleme
- DIY onarim rehberleri
- Video egitimler

#### Arac Deger Takibi
- Guncel piyasa degeri tahmini
- Deger kaybi projeksiyonu
- Satis icin en uygun zaman onerisi
- Satis raporu olusturma

#### Sigorta Entegrasyonu
- Sigorta policesi yonetimi
- Kaza aninda hizli rapor olusturma
- AI hasar fotograflarini sigorta formatinda disa aktarma

## Teknik Mimari

```
car-check-ai-system/
├── backend/                 # Backend API (ayri ekip)
│   ├── src/
│   │   ├── api/            # REST API endpoints
│   │   ├── services/       # Is mantigi
│   │   ├── models/         # Veritabani modelleri
│   │   ├── ai/             # AI/ML modulleri
│   │   └── utils/          # Yardimci fonksiyonlar
│   ├── tests/
│   └── config/
│
├── frontend/               # Frontend uygulamasi (ayri ekip)
│   ├── src/
│   │   ├── components/     # UI bilesenleri
│   │   ├── pages/          # Sayfa bilesenleri
│   │   ├── services/       # API istemcisi
│   │   ├── store/          # State yonetimi
│   │   └── utils/          # Yardimci fonksiyonlar
│   ├── public/
│   └── tests/
│
├── shared/                 # Ortak tipler ve kontratlar
│   ├── types/              # TypeScript tipleri
│   └── api-contracts/      # API sözlesmeleri
│
├── docs/                   # Dokumantasyon
│   ├── api/                # API dokumantasyonu
│   ├── architecture/       # Mimari diyagramlar
│   └── guides/             # Kullanim kilavuzlari
│
└── infrastructure/         # DevOps ve altyapi
    ├── docker/
    └── ci-cd/
```

## Git Workflow

Bu proje branch-based gelistirme stratejisi kullanmaktadir.

### Branch Yapisi

```
main                        # Production-ready kod
├── develop                 # Entegrasyon branch'i
│   ├── feature/backend-*   # Backend ozellikleri
│   └── feature/frontend-*  # Frontend ozellikleri
```

### Branch Kurallari

| Branch | Amac | Merge Hedefi |
|--------|------|--------------|
| `main` | Production kodu | - |
| `develop` | Entegrasyon | main |
| `feature/backend-*` | Backend ozellikleri | develop |
| `feature/frontend-*` | Frontend ozellikleri | develop |
| `hotfix/*` | Acil duzeltmeler | main & develop |

### Gelistirme Sureci

1. `develop` branch'inden yeni feature branch olustur
2. Degisikliklerini yap ve commit et
3. Pull Request (PR) ac
4. Code review sonrasi merge et

## Kurulum

### Gereksinimler

- Node.js >= 18.x
- Python >= 3.10 (AI modulleri icin)
- Docker & Docker Compose
- Git

### Baslangic

```bash
# Repoyu klonla
git clone https://github.com/eminaruk/car-check-ai-system.git
cd car-check-ai-system

# Backend kurulumu (detaylar backend/README.md'de)
cd backend
# ...

# Frontend kurulumu (detaylar frontend/README.md'de)
cd frontend
# ...
```

## Ekip Yapisi

| Alan | Sorumluluk |
|------|------------|
| **Backend Ekibi** | API gelistirme, AI/ML entegrasyonu, veritabani |
| **Frontend Ekibi** | UI/UX, mobil uygulama, web uygulamasi |

## Basari Kriterleri

1. **AI Dogrulugu:** Gorsel analizin guvenilir ve tutarli olmasi
2. **Kullanici Deneyimi:** Basit, sezgisel arayuz tasarimi
3. **Gizlilik:** Kullanici verilerinin korunmasi
4. **Deger Onerisi:** Ucretsiz surumde bile gercek deger sunma
5. **Lokalizasyon:** Turkiye pazarina ozel ozellikler (muayene hatirlatma, trafik sigortasi vb.)

## Hedef Pazar

- **Turkiye:** 25+ milyon kayitli arac
- **Akilli telefon penetrasyonu:** %80+
- **Referans:** CARFAX 30M, FIXD 2M kullanici

## Lisans

Bu proje ozel mulkiyettir. Tum haklari saklidir.

## Iletisim

Proje hakkinda sorulariniz icin repository issues bolumunu kullanabilirsiniz.

---

*Bu proje Aralik 2025'te baslatilmistir.*
