# CarCheck AI - Firebase Kurulum ve Entegrasyon Rehberi

## Firestore mu, Realtime Database mi?

### Karar: **Cloud Firestore** kullanacagiz

| Ozellik | Realtime Database | Cloud Firestore |
|---------|-------------------|-----------------|
| Veri Modeli | Tek buyuk JSON agaci | Koleksiyon/Dokuman yapisi |
| Sorgulama | Sinirli (tek index) | Guclu (coklu index, compound query) |
| Olceklenebilirlik | Bolgesel | Global, otomatik olceklenir |
| Offline | Sinirli | Tam destek (iOS, Android, Web) |
| Fiyatlandirma | Bant genisligi + depolama | Okuma/yazma islem sayisi |
| Karmasik Sorgular | Zor | Kolay |

**Neden Firestore?**
- Arac -> Raporlar -> Analizler gibi ic ice veri yapimiz var
- Karmasik sorgular gerekiyor (tarihe gore, skora gore filtreleme)
- Mobil uygulama icin offline destek onemli
- Olceklenebilirlik gerekiyor

---

## Adim 1: Firebase Console Ayarlari

### 1.1 Firestore Database Olusturma

1. [Firebase Console](https://console.firebase.google.com) -> Projenizi secin
2. Sol menuden **"Build"** -> **"Firestore Database"** tiklayin
3. **"Create database"** butonuna tiklayin
4. Mod secimi:
   - **Production mode** secin (Security Rules sonra yapilandiracagiz)
5. Lokasyon secimi:
   - **europe-west1 (Belgium)** veya **europe-west3 (Frankfurt)** secin
   - Turkiye'ye yakin oldugu icin dusuk latency saglar
6. **"Enable"** tiklayin

### 1.2 Firebase Storage Olusturma

1. Sol menuden **"Build"** -> **"Storage"** tiklayin
2. **"Get started"** butonuna tiklayin
3. Security rules icin **"Start in production mode"** secin
4. Ayni lokasyonu secin (Firestore ile ayni bolge olmali)
5. **"Done"** tiklayin

### 1.3 Authentication Ayarlari

1. Sol menuden **"Build"** -> **"Authentication"** tiklayin
2. **"Get started"** butonuna tiklayin
3. **"Sign-in method"** sekmesine gidin
4. Asagidaki yontemleri aktif edin:
   - **Email/Password** (Enable)
   - **Google** (Enable - OAuth client ID gerekir)
   - **Apple** (iOS icin - opsiyonel)
   - **Phone** (SMS dogrulama - opsiyonel)

---

## Adim 2: Proje Yapilandirmasi

### 2.1 Firebase CLI Kurulumu

```bash
# Node.js yuklu olmali (v18+)
npm install -g firebase-tools

# Firebase'e giris yap
firebase login

# Proje dizinine git
cd car-check-ai-system

# Firebase'i baslat
firebase init
```

### 2.2 Firebase Init Secenekleri

`firebase init` komutunu calistirdiginizda asagidaki secenekleri secin:

```
? Which Firebase features do you want to set up for this directory?
  [X] Firestore: Configure security rules and indexes for Firestore
  [X] Functions: Configure a Cloud Functions directory (opsiyonel)
  [X] Storage: Configure a default Storage bucket
  [X] Emulators: Set up local emulators for Firebase products

? Please select an existing project or create a new one:
  > Use an existing project
  > carcheck-ai-xxxxx (projenizin adi)

? What file should be used for Firestore Rules?
  > firestore.rules

? What file should be used for Firestore indexes?
  > firestore.indexes.json

? What file should be used for Storage Rules?
  > storage.rules

? Which emulators do you want to set up?
  [X] Authentication Emulator
  [X] Firestore Emulator
  [X] Storage Emulator
```

### 2.3 Olusacak Dosyalar

```
car-check-ai-system/
├── firebase.json           # Firebase yapilandirmasi
├── .firebaserc            # Proje baglantisi
├── firestore.rules        # Firestore guvenlik kurallari
├── firestore.indexes.json # Firestore indeksleri
├── storage.rules          # Storage guvenlik kurallari
└── functions/             # Cloud Functions (opsiyonel)
    ├── package.json
    ├── tsconfig.json
    └── src/
        └── index.ts
```

---

## Adim 3: Firestore Security Rules

`firestore.rules` dosyasini asagidaki icerisle degistirin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ============================================
    // YARDIMCI FONKSIYONLAR
    // ============================================

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function isVehicleOwner(vehicleId) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/vehicles/$(vehicleId)).data.ownerId == request.auth.uid;
    }

    function isValidVehicleCategory(category) {
      return category in ['ICE', 'HEV', 'PHEV', 'BEV'];
    }

    // ============================================
    // USERS KOLEKSIYONU
    // ============================================

    match /users/{userId} {
      // Kullanici kendi profilini okuyabilir
      allow read: if isOwner(userId);

      // Kullanici kendi profilini olusturabilir (sadece kayit sirasinda)
      allow create: if isOwner(userId) &&
        request.resource.data.keys().hasAll(['email', 'displayName', 'createdAt']) &&
        request.resource.data.accountStatus == 'active';

      // Kullanici kendi profilini guncelleyebilir (bazi alanlar haric)
      allow update: if isOwner(userId) &&
        !request.resource.data.diff(resource.data).affectedKeys().hasAny(['uid', 'createdAt', 'subscription']);

      // Silme yasak (soft delete kullanilacak)
      allow delete: if false;

      // Kayitli konumlar alt koleksiyonu
      match /saved_locations/{locationId} {
        allow read, write: if isOwner(userId);
      }
    }

    // ============================================
    // VEHICLES KOLEKSIYONU
    // ============================================

    match /vehicles/{vehicleId} {
      // Sadece arac sahibi okuyabilir
      allow read: if isAuthenticated() &&
        resource.data.ownerId == request.auth.uid;

      // Arac olusturma (sahiplik kontrolu)
      allow create: if isAuthenticated() &&
        request.resource.data.ownerId == request.auth.uid &&
        isValidVehicleCategory(request.resource.data.category) &&
        request.resource.data.keys().hasAll(['plate', 'brand', 'model', 'year', 'category']);

      // Arac guncelleme (sahiplik degistirilemez)
      allow update: if isVehicleOwner(vehicleId) &&
        !request.resource.data.diff(resource.data).affectedKeys().hasAny(['ownerId', 'createdAt']);

      // Arac silme (veya soft delete)
      allow delete: if isVehicleOwner(vehicleId);

      // Hatirlaticilar alt koleksiyonu
      match /reminders/{reminderId} {
        allow read, write: if isVehicleOwner(vehicleId);
      }

      // Bakim gecmisi alt koleksiyonu
      match /maintenance_history/{recordId} {
        allow read, write: if isVehicleOwner(vehicleId);
      }
    }

    // ============================================
    // MAINTENANCE REPORTS KOLEKSIYONU
    // ============================================

    match /maintenance_reports/{reportId} {
      // Rapor sahibi veya paylasilan raporlar okunabilir
      allow read: if isAuthenticated() &&
        (resource.data.userId == request.auth.uid || resource.data.isShared == true);

      // Rapor olusturma (normalde Cloud Functions yapar, ama client da yapabilir)
      allow create: if isAuthenticated() &&
        request.resource.data.userId == request.auth.uid &&
        request.resource.data.keys().hasAll(['vehicleId', 'generatedAt', 'status']);

      // Rapor guncelleme (sadece belirli alanlar)
      allow update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid &&
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['isShared', 'shareToken', 'sharedAt']);

      // Rapor silinemez
      allow delete: if false;

      // Rapor fotograflari alt koleksiyonu
      match /photos/{photoId} {
        allow read: if isAuthenticated() &&
          get(/databases/$(database)/documents/maintenance_reports/$(reportId)).data.userId == request.auth.uid;
        allow create: if isAuthenticated() &&
          get(/databases/$(database)/documents/maintenance_reports/$(reportId)).data.userId == request.auth.uid;
        allow update, delete: if false;
      }
    }

    // ============================================
    // NOTIFICATIONS KOLEKSIYONU
    // ============================================

    match /notifications/{notificationId} {
      // Kullanici kendi bildirimlerini okuyabilir
      allow read: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;

      // Kullanici sadece okundu durumunu guncelleyebilir
      allow update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['readAt', 'status']);

      // Olusturma ve silme yasak (Cloud Functions yapar)
      allow create, delete: if false;
    }

    // ============================================
    // FEEDBACK KOLEKSIYONU
    // ============================================

    match /feedback/{feedbackId} {
      // Kullanici kendi geri bildirimlerini okuyabilir
      allow read: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;

      // Geri bildirim olusturma
      allow create: if isAuthenticated() &&
        request.resource.data.userId == request.auth.uid &&
        request.resource.data.keys().hasAll(['type', 'message', 'createdAt']);

      // Guncelleme ve silme yasak
      allow update, delete: if false;
    }

    // ============================================
    // APP SETTINGS KOLEKSIYONU (Public Read)
    // ============================================

    match /app_settings/{settingId} {
      // Herkes okuyabilir (abonelik planlari, arac katalogu vs.)
      allow read: if true;

      // Yazma yasak (Admin SDK ile yapilir)
      allow write: if false;
    }
  }
}
```

---

## Adim 4: Firestore Indexes

`firestore.indexes.json` dosyasini asagidaki icerisle degistirin:

```json
{
  "indexes": [
    {
      "collectionGroup": "vehicles",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "vehicles",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "isPrimary", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "maintenance_reports",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "generatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "maintenance_reports",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "vehicleId", "order": "ASCENDING" },
        { "fieldPath": "generatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "maintenance_reports",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "generatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "reminders",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "isActive", "order": "ASCENDING" },
        { "fieldPath": "nextTriggerDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "maintenance_history",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "feedback",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## Adim 5: Storage Rules

`storage.rules` dosyasini asagidaki icerisle degistirin:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Yardimci fonksiyonlar
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidImageType() {
      return request.resource.contentType.matches('image/.*');
    }

    function isValidFileSize(maxSizeMB) {
      return request.resource.size < maxSizeMB * 1024 * 1024;
    }

    // ============================================
    // KULLANICI DOSYALARI
    // ============================================

    match /users/{userId}/{allPaths=**} {
      // Kullanici kendi dosyalarini okuyabilir
      allow read: if isAuthenticated() && isOwner(userId);

      // Kullanici kendi dosyalarini yukleyebilir (max 5MB, sadece resim)
      allow write: if isAuthenticated() &&
        isOwner(userId) &&
        isValidImageType() &&
        isValidFileSize(5);
    }

    // ============================================
    // ARAC FOTOGRAFLARI
    // ============================================

    match /vehicles/{vehicleId}/{allPaths=**} {
      // Herkese acik okuma (arac fotograflari paylasilabilir)
      allow read: if isAuthenticated();

      // Sadece arac sahibi yukleyebilir (max 10MB)
      // Not: Firestore'dan owner kontrolu yapilamaz, client-side kontrol gerekir
      allow write: if isAuthenticated() &&
        isValidImageType() &&
        isValidFileSize(10);
    }

    // ============================================
    // ANALIZ FOTOGRAFLARI
    // ============================================

    match /analysis_photos/{reportId}/{allPaths=**} {
      // Rapor sahibi okuyabilir
      allow read: if isAuthenticated();

      // Analiz fotograflari yuklenebilir (max 15MB)
      allow write: if isAuthenticated() &&
        isValidImageType() &&
        isValidFileSize(15);
    }

    // ============================================
    // BAKIM DOKUMANLARI
    // ============================================

    match /maintenance_documents/{vehicleId}/{allPaths=**} {
      allow read: if isAuthenticated();

      // PDF ve resim kabul edilir (max 20MB)
      allow write: if isAuthenticated() &&
        (request.resource.contentType.matches('image/.*') ||
         request.resource.contentType == 'application/pdf') &&
        isValidFileSize(20);
    }

    // ============================================
    // GERI BILDIRIM EKLERI
    // ============================================

    match /feedback_attachments/{feedbackId}/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isValidFileSize(10);
    }
  }
}
```

---

## Adim 6: Firebase'e Deploy

### 6.1 Rules ve Indexes Deploy

```bash
# Sadece Firestore rules deploy
firebase deploy --only firestore:rules

# Sadece Firestore indexes deploy
firebase deploy --only firestore:indexes

# Sadece Storage rules deploy
firebase deploy --only storage

# Hepsini birden deploy
firebase deploy --only firestore,storage
```

### 6.2 Deploy Sonrasi Kontrol

Firebase Console'da kontrol edin:
1. **Firestore Database** -> **Rules** sekmesi -> Rules gorunmeli
2. **Firestore Database** -> **Indexes** sekmesi -> Index'ler olusturuluyor olmali
3. **Storage** -> **Rules** sekmesi -> Rules gorunmeli

---

## Adim 7: Baslangic Verilerini Yukleme

### 7.1 App Settings Verilerini Yukleme

Firebase Console'dan veya script ile baslangic verilerini yukleyin:

```javascript
// scripts/seed-app-settings.js
const admin = require('firebase-admin');

// Service account key dosyasini indirin (Project Settings -> Service Accounts)
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedAppSettings() {

  // Abonelik Planlari
  await db.doc('app_settings/subscription_plans').set({
    plans: {
      free: {
        name: 'Ucretsiz',
        monthlyAnalysisLimit: 2,
        maxVehicles: 1,
        features: ['Temel analiz', '3 aylik gecmis'],
        price: 0,
        currency: 'TRY'
      },
      basic: {
        name: 'Basic',
        monthlyAnalysisLimit: 10,
        maxVehicles: 3,
        features: ['Temel analiz', '1 yillik gecmis', 'Rapor paylasimi'],
        price: 49,
        currency: 'TRY'
      },
      premium: {
        name: 'Premium',
        monthlyAnalysisLimit: 50,
        maxVehicles: 10,
        features: ['Gelismis analiz', '3 yillik gecmis', 'Oncelikli destek', 'Rapor paylasimi'],
        price: 149,
        currency: 'TRY'
      },
      business: {
        name: 'Business',
        monthlyAnalysisLimit: -1,
        maxVehicles: -1,
        features: ['Sinirsiz analiz', 'Sinirsiz gecmis', 'API erisimi', '7/24 destek'],
        price: 499,
        currency: 'TRY'
      }
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  // Bakim Araliklari
  await db.doc('app_settings/maintenance_intervals').set({
    intervals: {
      oil_change: {
        name: 'Yag Degisimi',
        defaultIntervalKm: 10000,
        defaultIntervalDays: 180,
        applicableCategories: ['ICE', 'HEV', 'PHEV']
      },
      tire_rotation: {
        name: 'Lastik Rotasyonu',
        defaultIntervalKm: 15000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV', 'BEV']
      },
      brake_check: {
        name: 'Fren Kontrolu',
        defaultIntervalKm: 20000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV', 'BEV']
      },
      air_filter: {
        name: 'Hava Filtresi',
        defaultIntervalKm: 20000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV']
      },
      cabin_filter: {
        name: 'Polen Filtresi',
        defaultIntervalKm: 15000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV', 'BEV']
      },
      battery_check: {
        name: 'Aku Kontrolu',
        defaultIntervalKm: 30000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV']
      },
      ev_battery_check: {
        name: 'Batarya Saglik Kontrolu',
        defaultIntervalKm: 50000,
        defaultIntervalDays: 365,
        applicableCategories: ['BEV', 'PHEV']
      },
      general_service: {
        name: 'Genel Bakim',
        defaultIntervalKm: 15000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV', 'BEV']
      }
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  // Uygulama Konfigurasyonu
  await db.doc('app_settings/app_config').set({
    minSupportedVersion: {
      ios: '1.0.0',
      android: '1.0.0'
    },
    latestVersion: {
      ios: '1.0.0',
      android: '1.0.0'
    },
    maintenanceMode: {
      enabled: false,
      message: '',
      estimatedEndTime: null
    },
    featureFlags: {
      enableNewAnalysisUI: false,
      enableBetaFeatures: false,
      enableOfflineMode: true
    },
    api: {
      baseUrl: 'https://api.carcheck.app',
      timeout: 30000
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  console.log('App settings seeded successfully!');
}

seedAppSettings().catch(console.error);
```

### 7.2 Script'i Calistirma

```bash
# Gerekli paketleri yukle
npm install firebase-admin

# Service Account Key indir:
# Firebase Console -> Project Settings -> Service Accounts -> Generate New Private Key
# Dosyayi scripts/serviceAccountKey.json olarak kaydet

# Script'i calistir
node scripts/seed-app-settings.js
```

---

## Adim 8: Mobile App Entegrasyonu

### 8.1 React Native icin Firebase SDK

```bash
# React Native Firebase kurulumu
npm install @react-native-firebase/app
npm install @react-native-firebase/auth
npm install @react-native-firebase/firestore
npm install @react-native-firebase/storage

# iOS icin pod install
cd ios && pod install && cd ..
```

### 8.2 Firebase Config Dosyalari

1. **Android**: `google-services.json`
   - Firebase Console -> Project Settings -> Your Apps -> Android
   - `google-services.json` indir
   - `android/app/` klasorune kopyala

2. **iOS**: `GoogleService-Info.plist`
   - Firebase Console -> Project Settings -> Your Apps -> iOS
   - `GoogleService-Info.plist` indir
   - Xcode ile `ios/` klasorune ekle

### 8.3 Ornek Kullanim Kodu

```typescript
// src/services/firebase.ts
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';
import storage from '@react-native-firebase/storage';

// Koleksiyon referanslari
export const usersCollection = firestore().collection('users');
export const vehiclesCollection = firestore().collection('vehicles');
export const reportsCollection = firestore().collection('maintenance_reports');
export const notificationsCollection = firestore().collection('notifications');

// Ornek: Kullanici profili olusturma
export async function createUserProfile(userId: string, data: any) {
  await usersCollection.doc(userId).set({
    uid: userId,
    email: data.email,
    displayName: data.displayName,
    phoneNumber: data.phoneNumber || null,
    photoURL: null,
    accountStatus: 'active',
    emailVerified: false,
    phoneVerified: false,
    createdAt: firestore.FieldValue.serverTimestamp(),
    updatedAt: firestore.FieldValue.serverTimestamp(),
    lastLoginAt: firestore.FieldValue.serverTimestamp(),
    subscription: {
      plan: 'free',
      status: 'active',
      startDate: firestore.FieldValue.serverTimestamp(),
      endDate: null,
      autoRenew: false,
      trialUsed: false
    },
    usage: {
      monthlyAnalysisCount: 0,
      monthlyAnalysisLimit: 2,
      totalAnalysisCount: 0,
      lastAnalysisAt: null,
      currentPeriodStart: firestore.FieldValue.serverTimestamp()
    },
    preferences: {
      language: 'tr',
      theme: 'system',
      measurementUnit: 'metric',
      currency: 'TRY',
      dateFormat: 'DD/MM/YYYY',
      timeFormat: '24h'
    },
    notificationSettings: {
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
      maintenanceReminders: true,
      analysisComplete: true,
      weeklyReport: true,
      promotions: false,
      systemUpdates: true,
      reminderTime: '09:00',
      reminderDaysBefore: 3
    },
    privacySettings: {
      shareAnalyticsData: true,
      showProfilePublicly: false,
      allowLocationTracking: false
    },
    devices: [],
    address: null
  });
}

// Ornek: Arac ekleme
export async function addVehicle(ownerId: string, vehicleData: any) {
  const docRef = await vehiclesCollection.add({
    ownerId,
    ...vehicleData,
    status: 'active',
    isPrimary: false,
    lastAnalysis: null,
    lastMaintenance: null,
    nextMaintenance: null,
    photos: { main: null, gallery: [] },
    notes: null,
    kmHistory: [],
    createdAt: firestore.FieldValue.serverTimestamp(),
    updatedAt: firestore.FieldValue.serverTimestamp()
  });
  return docRef.id;
}

// Ornek: Kullanicinin araclarini getir
export function getUserVehicles(userId: string) {
  return vehiclesCollection
    .where('ownerId', '==', userId)
    .where('status', '==', 'active')
    .orderBy('createdAt', 'desc');
}

// Ornek: Aracin raporlarini getir
export function getVehicleReports(vehicleId: string, limit = 10) {
  return reportsCollection
    .where('vehicleId', '==', vehicleId)
    .where('status', '==', 'completed')
    .orderBy('generatedAt', 'desc')
    .limit(limit);
}

// Ornek: Fotograf yukleme
export async function uploadAnalysisPhoto(
  reportId: string,
  photoType: string,
  filePath: string
) {
  const fileName = `${photoType}_${Date.now()}.jpg`;
  const reference = storage().ref(`analysis_photos/${reportId}/${fileName}`);

  await reference.putFile(filePath);
  const downloadUrl = await reference.getDownloadURL();

  return downloadUrl;
}
```

---

## Adim 9: Local Development (Emulators)

### 9.1 Emulatorleri Baslat

```bash
# Tum emulatorleri baslat
firebase emulators:start

# Belirli emulatorleri baslat
firebase emulators:start --only firestore,auth,storage
```

### 9.2 Emulator UI

Emulatorler basladiginda asagidaki URL'lerde erisebilirsiniz:
- **Emulator UI**: http://localhost:4000
- **Firestore**: http://localhost:8080
- **Auth**: http://localhost:9099
- **Storage**: http://localhost:9199

### 9.3 App'te Emulator Kullanimi

```typescript
// src/config/firebase.ts
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';
import storage from '@react-native-firebase/storage';

if (__DEV__) {
  // Android emulator icin 10.0.2.2, iOS simulator icin localhost
  const host = Platform.OS === 'android' ? '10.0.2.2' : 'localhost';

  firestore().useEmulator(host, 8080);
  auth().useEmulator(`http://${host}:9099`);
  storage().useEmulator(host, 9199);
}
```

---

## Adim 10: Kontrol Listesi

### Deploy Oncesi

- [ ] Firebase projesi olusturuldu
- [ ] Firestore Database olusturuldu (Production mode)
- [ ] Storage olusturuldu
- [ ] Authentication yontemleri aktif edildi
- [ ] `firebase init` ile proje yapilandirildi
- [ ] `firestore.rules` yazildi
- [ ] `firestore.indexes.json` yazildi
- [ ] `storage.rules` yazildi
- [ ] App settings verileri yuklendi

### Deploy Sonrasi

- [ ] Rules basariyla deploy edildi
- [ ] Indexes olusturulmaya basladi (birka dakika surebilir)
- [ ] Mobile app'e config dosyalari eklendi
- [ ] Test kullanicisi ile CRUD islemleri test edildi
- [ ] Security rules test edildi

---

## Sorun Giderme

### Index Hatalari

Eger sorgulariniz "index gerekli" hatasi verirse:
1. Hata mesajindaki linke tiklayin
2. Firebase Console'da otomatik index olusturma ekrani acilacak
3. "Create index" tiklayin

### Permission Denied Hatalari

1. Firebase Console -> Firestore -> Rules sekmesini kontrol edin
2. Rules Playground ile test edin
3. `request.auth` degerinin dogru geldiginden emin olun

### Emulator Baglanti Sorunlari

```bash
# Port kullanimda olabilir, kontrol edin
lsof -i :8080
lsof -i :9099

# Farkli portlar kullanin
firebase emulators:start --project demo-test
```

---

*Bu rehber CarCheck AI mobil uygulamasi icin Firebase entegrasyonunu adim adim aciklar. Sorulariniz icin dokumantasyonu inceleyin veya Firebase Support'a basvurun.*
