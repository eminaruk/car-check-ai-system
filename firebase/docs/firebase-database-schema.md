# CarCheck AI - Firebase Veritabani Semasi

Bu dokuman, CarCheck AI mobil uygulamasi icin Firebase Firestore veritabani yapisini tanimlar.

---

## Genel Bakis

```
firestore-root/
├── users/                      # Kullanici profilleri
├── vehicles/                   # Arac bilgileri
├── maintenance_reports/        # AI analiz raporlari
├── maintenance_records/        # Manuel bakim kayitlari
├── notifications/              # Bildirimler
├── app_settings/               # Uygulama ayarlari (admin)
└── feedback/                   # Kullanici geri bildirimleri
```

---

## 1. Users Koleksiyonu

Kullanici profil bilgileri ve ayarlarini icerir.

```
/users/{userId}
```

### Dokusman Yapisi

```typescript
interface User {
  // Temel Bilgiler
  uid: string;                    // Firebase Auth UID
  email: string;
  displayName: string;
  phoneNumber: string | null;
  photoURL: string | null;        // Profil fotografi (Storage URL)

  // Hesap Durumu
  accountStatus: 'active' | 'suspended' | 'deleted';
  emailVerified: boolean;
  phoneVerified: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLoginAt: Timestamp;

  // Abonelik Bilgileri
  subscription: {
    plan: 'free' | 'basic' | 'premium' | 'business';
    status: 'active' | 'expired' | 'cancelled' | 'trial';
    startDate: Timestamp;
    endDate: Timestamp | null;
    autoRenew: boolean;
    trialUsed: boolean;
  };

  // Kullanim Limitleri
  usage: {
    monthlyAnalysisCount: number;      // Bu ayki analiz sayisi
    monthlyAnalysisLimit: number;      // Abonelige gore limit
    totalAnalysisCount: number;        // Toplam analiz sayisi
    lastAnalysisAt: Timestamp | null;
    currentPeriodStart: Timestamp;
  };

  // Kullanici Tercihleri (Ayarlar)
  preferences: {
    language: 'tr' | 'en';
    theme: 'light' | 'dark' | 'system';
    measurementUnit: 'metric' | 'imperial';  // km vs miles
    currency: 'TRY' | 'USD' | 'EUR';
    dateFormat: 'DD/MM/YYYY' | 'MM/DD/YYYY' | 'YYYY-MM-DD';
    timeFormat: '24h' | '12h';
  };

  // Bildirim Ayarlari
  notificationSettings: {
    pushEnabled: boolean;
    emailEnabled: boolean;
    smsEnabled: boolean;

    // Bildirim Turleri
    maintenanceReminders: boolean;
    analysisComplete: boolean;
    weeklyReport: boolean;
    promotions: boolean;
    systemUpdates: boolean;

    // Hatirlatma Zamanlari
    reminderTime: string;              // "09:00" format
    reminderDaysBefore: number;        // Kac gun once hatirlatilsin
  };

  // Gizlilik Ayarlari
  privacySettings: {
    shareAnalyticsData: boolean;
    showProfilePublicly: boolean;
    allowLocationTracking: boolean;
  };

  // Cihaz Bilgileri
  devices: Array<{
    deviceId: string;
    deviceType: 'ios' | 'android' | 'web';
    deviceName: string;
    fcmToken: string;                  // Push notification token
    lastActiveAt: Timestamp;
    appVersion: string;
  }>;

  // Adres Bilgileri (Opsiyonel)
  address: {
    city: string | null;
    district: string | null;
    country: string;
  } | null;
}
```

### Alt Koleksiyonlar

```
/users/{userId}/saved_locations/{locationId}
```

```typescript
interface SavedLocation {
  id: string;
  name: string;                        // "Ev", "Is", "Servis"
  type: 'home' | 'work' | 'service' | 'other';
  address: string;
  coordinates: GeoPoint;
  createdAt: Timestamp;
}
```

---

## 2. Vehicles Koleksiyonu

Arac bilgileri ve iliskili veriler.

```
/vehicles/{vehicleId}
```

### Dokusman Yapisi

```typescript
interface Vehicle {
  // Kimlik
  id: string;
  ownerId: string;                     // Reference: users/{userId}

  // Temel Bilgiler
  plate: string;                       // "34 ABC 123"
  brand: string;                       // "Toyota"
  model: string;                       // "Corolla"
  year: number;                        // 2020
  color: string | null;
  vin: string | null;                  // Sasi numarasi (opsiyonel)

  // Kategori Bilgileri (AI analizi icin kritik)
  category: 'ICE' | 'HEV' | 'PHEV' | 'BEV';
  fuelType: 'benzin' | 'dizel' | 'lpg' | 'cng' | 'hybrid' | 'plugin_hybrid' | 'electric';

  // Motor/Batarya Bilgileri
  engineSize: string | null;           // "1.6", "2.0" (ICE/HEV/PHEV)
  batteryCapacityKwh: number | null;   // 64, 77 (BEV/PHEV)
  electricRange: number | null;        // Elektrik menzili km (BEV/PHEV)

  // Kilometre Bilgileri
  currentKm: number;
  lastKmUpdateAt: Timestamp;
  kmHistory: Array<{
    km: number;
    date: Timestamp;
    source: 'manual' | 'analysis' | 'service';
  }>;

  // Tescil Bilgileri
  registrationDate: Timestamp | null;
  insuranceExpiryDate: Timestamp | null;
  inspectionExpiryDate: Timestamp | null;  // Muayene tarihi

  // Satin Alma Bilgileri
  purchaseDate: Timestamp | null;
  purchaseKm: number | null;
  isSecondHand: boolean;

  // Durum
  status: 'active' | 'sold' | 'scrapped' | 'inactive';
  isPrimary: boolean;                  // Ana arac mi

  // Son Analiz Ozeti
  lastAnalysis: {
    reportId: string;
    date: Timestamp;
    healthScore: number;
    status: 'good' | 'attention' | 'critical';
  } | null;

  // Son Bakim Bilgileri
  lastMaintenance: {
    date: Timestamp;
    km: number;
    type: string;
  } | null;

  // Sonraki Bakim Tahmini
  nextMaintenance: {
    recommendedDate: Timestamp | null;
    recommendedKm: number | null;
    type: string;
    reason: string;
  } | null;

  // Fotograflar
  photos: {
    main: string | null;               // Ana fotograf URL
    gallery: string[];                 // Diger fotograflar
  };

  // Ozel Notlar
  notes: string | null;

  // Meta
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### Alt Koleksiyonlar

#### Bakim Hatirlticilari

```
/vehicles/{vehicleId}/reminders/{reminderId}
```

```typescript
interface MaintenanceReminder {
  id: string;
  vehicleId: string;

  // Hatirlatma Turu
  type: 'oil_change' | 'tire_rotation' | 'brake_check' | 'filter_change' |
        'inspection' | 'insurance' | 'general_service' | 'battery_check' | 'custom';
  customName: string | null;           // type='custom' ise

  // Tetikleme Kosullari
  triggerType: 'date' | 'km' | 'both';

  // Tarih Bazli
  intervalDays: number | null;         // Her X gunde bir
  nextTriggerDate: Timestamp | null;

  // Km Bazli
  intervalKm: number | null;           // Her X km'de bir
  nextTriggerKm: number | null;

  // Durum
  isActive: boolean;
  lastTriggeredAt: Timestamp | null;
  lastCompletedAt: Timestamp | null;

  // Bildirim
  notifyDaysBefore: number;            // Kac gun once bildir
  notifyKmBefore: number;              // Kac km once bildir

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Bakim Kayitlari Gecmisi

```
/vehicles/{vehicleId}/maintenance_history/{recordId}
```

```typescript
interface MaintenanceHistoryRecord {
  id: string;
  vehicleId: string;

  // Bakim Bilgileri
  date: Timestamp;
  km: number;
  type: 'oil_change' | 'tire_rotation' | 'brake_service' | 'filter_change' |
        'general_service' | 'repair' | 'inspection' | 'other';

  // Detaylar
  title: string;
  description: string | null;

  // Maliyet
  cost: {
    amount: number;
    currency: 'TRY' | 'USD' | 'EUR';
  } | null;

  // Servis Bilgileri
  serviceProvider: {
    name: string | null;
    location: string | null;
    phone: string | null;
  } | null;

  // Belgeler
  documents: Array<{
    type: 'invoice' | 'receipt' | 'report' | 'photo' | 'other';
    url: string;
    name: string;
  }>;

  // Kaynak
  source: 'manual' | 'ai_report' | 'service_import';
  linkedReportId: string | null;       // AI raporuyla iliskilendirilmisse

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

---

## 3. Maintenance Reports Koleksiyonu

AI tarafindan olusturulan analiz raporlari.

```
/maintenance_reports/{reportId}
```

### Dokusman Yapisi

```typescript
interface MaintenanceReport {
  // Kimlik
  id: string;                          // "RPT-2026-000123" format

  // Iliskiler
  userId: string;
  vehicleId: string;

  // Zaman Bilgileri
  generatedAt: Timestamp;
  analyzedAt: Timestamp;

  // Arac Bilgileri (Snapshot - raporun olustugu andaki durum)
  vehicleSnapshot: {
    plate: string;
    brand: string;
    model: string;
    year: number;
    category: 'ICE' | 'HEV' | 'PHEV' | 'BEV';
    fuelType: string;
    currentKm: number;
  };

  // Genel Ozet
  overallSummary: {
    healthScore: number;               // 0-100
    status: 'good' | 'attention' | 'critical';
    statusText: string;                // "Araciniz iyi durumda"
    analyzedPartsCount: number;
    goodCount: number;
    attentionCount: number;
    criticalCount: number;
  };

  // Parca Analizleri
  partAnalyses: Array<{
    partId: string;                    // 'engine_bay', 'headlights', etc.
    partName: string;                  // "Motor Bolgesi"
    order: number;
    healthScore: number;
    status: 'good' | 'attention' | 'critical';
    photoUrl: string;                  // Analiz edilen fotograf

    // Parca Ozel Analiz Sonucu (JSON)
    analysisResult: {
      [key: string]: any;              // Parcaya gore degisir
    };

    // Tespitler
    findings: Array<{
      type: 'good' | 'attention' | 'critical';
      component: string;
      description: string;
      recommendation: string | null;
    }>;

    confidence: number;                // 0-1 arasi
  }>;

  // Oneriler
  recommendations: {
    immediate: Array<{
      title: string;
      description: string;
      estimatedCost: string | null;
      relatedPart: string;
    }>;
    soon: Array<{
      title: string;
      description: string;
      estimatedCost: string | null;
      relatedPart: string;
    }>;
    scheduled: Array<{
      title: string;
      description: string;
      estimatedCost: string | null;
      relatedPart: string;
    }>;
  };

  // Sonraki Bakim Onerisi
  nextMaintenance: {
    recommendedDate: Timestamp | null;
    recommendedKm: number | null;
    reason: string;
  };

  // Ipuclari
  tips: string[];

  // Meta Bilgiler
  metadata: {
    analysisDurationMs: number;
    modelUsed: string;                 // "gemini-2.0-flash"
    photosAnalyzed: number;
    averageConfidence: number;
    appVersion: string;
    deviceType: string;
  };

  // Durum
  status: 'processing' | 'completed' | 'failed' | 'expired';
  errorMessage: string | null;

  // Paylasim
  isShared: boolean;
  shareToken: string | null;           // Paylasim linki icin token
  sharedAt: Timestamp | null;
}
```

### Alt Koleksiyon - Analiz Fotograflari

```
/maintenance_reports/{reportId}/photos/{photoId}
```

```typescript
interface AnalysisPhoto {
  id: string;
  reportId: string;

  // Fotograf Bilgileri
  photoType: 'engine_bay' | 'headlights' | 'taillights' | 'dashboard' |
             'exhaust' | 'charging_port_closed' | 'charging_port_open' |
             'oil_dipstick' | 'frunk' | 'other';
  photoTypeName: string;               // "Motor Bolgesi"

  // Dosya Bilgileri
  originalUrl: string;                 // Storage URL
  thumbnailUrl: string;
  fileName: string;
  fileSize: number;                    // bytes
  mimeType: string;

  // Boyutlar
  width: number;
  height: number;

  // Analiz
  wasAnalyzed: boolean;
  analysisResult: object | null;

  // Meta
  uploadedAt: Timestamp;
  takenAt: Timestamp | null;           // EXIF'ten
  deviceInfo: string | null;
}
```

---

## 4. Notifications Koleksiyonu

Kullanici bildirimleri.

```
/notifications/{notificationId}
```

### Dokusman Yapisi

```typescript
interface Notification {
  id: string;
  userId: string;

  // Bildirim Icerigi
  type: 'maintenance_reminder' | 'analysis_complete' | 'analysis_failed' |
        'subscription_expiring' | 'subscription_expired' | 'weekly_report' |
        'insurance_reminder' | 'inspection_reminder' | 'promotion' |
        'system_update' | 'tip';

  title: string;
  body: string;

  // Iliskili Veriler
  data: {
    vehicleId?: string;
    reportId?: string;
    reminderId?: string;
    actionUrl?: string;                // Deep link
    [key: string]: any;
  };

  // Gorseller
  imageUrl: string | null;
  icon: string | null;

  // Oncelik
  priority: 'low' | 'normal' | 'high' | 'urgent';

  // Durum
  status: 'pending' | 'sent' | 'delivered' | 'read' | 'failed';
  readAt: Timestamp | null;
  sentAt: Timestamp | null;

  // Gonderim Kanallari
  channels: {
    push: boolean;
    email: boolean;
    sms: boolean;
    inApp: boolean;
  };

  // Zamanlama
  scheduledFor: Timestamp | null;      // Ileri tarihli bildirim
  expiresAt: Timestamp | null;         // Gecerlilik suresi

  createdAt: Timestamp;
}
```

---

## 5. Feedback Koleksiyonu

Kullanici geri bildirimleri ve destek talepleri.

```
/feedback/{feedbackId}
```

### Dokusman Yapisi

```typescript
interface Feedback {
  id: string;
  userId: string;

  // Tur
  type: 'bug_report' | 'feature_request' | 'complaint' | 'praise' |
        'question' | 'analysis_feedback' | 'other';

  // Icerik
  subject: string;
  message: string;

  // Iliskili Veriler
  relatedData: {
    vehicleId?: string;
    reportId?: string;
    screenName?: string;
    errorCode?: string;
  };

  // Analiz Geri Bildirimi (AI sonucu icin)
  analysisRating: {
    accuracy: number;                  // 1-5
    usefulness: number;                // 1-5
    comments: string | null;
  } | null;

  // Ekler
  attachments: Array<{
    type: 'screenshot' | 'log' | 'document';
    url: string;
    name: string;
  }>;

  // Cihaz Bilgileri
  deviceInfo: {
    platform: 'ios' | 'android' | 'web';
    osVersion: string;
    appVersion: string;
    deviceModel: string;
  };

  // Durum
  status: 'new' | 'in_review' | 'in_progress' | 'resolved' | 'closed';
  assignedTo: string | null;
  resolution: string | null;

  // Yanit
  adminResponse: {
    message: string;
    respondedBy: string;
    respondedAt: Timestamp;
  } | null;

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

---

## 6. App Settings Koleksiyonu (Admin)

Uygulama genelinde ayarlar ve konfigurasyonlar.

```
/app_settings/{settingId}
```

### Ornek Dokusmanlari

#### Abonelik Planlari

```
/app_settings/subscription_plans
```

```typescript
interface SubscriptionPlans {
  plans: {
    free: {
      name: string;
      monthlyAnalysisLimit: number;    // 2
      maxVehicles: number;             // 1
      features: string[];
      price: number;                   // 0
    };
    basic: {
      name: string;
      monthlyAnalysisLimit: number;    // 10
      maxVehicles: number;             // 3
      features: string[];
      price: number;
      currency: string;
    };
    premium: {
      name: string;
      monthlyAnalysisLimit: number;    // 50
      maxVehicles: number;             // 10
      features: string[];
      price: number;
      currency: string;
    };
    business: {
      name: string;
      monthlyAnalysisLimit: number;    // -1 (unlimited)
      maxVehicles: number;             // -1 (unlimited)
      features: string[];
      price: number;
      currency: string;
    };
  };
  updatedAt: Timestamp;
}
```

#### Bakim Araliklari

```
/app_settings/maintenance_intervals
```

```typescript
interface MaintenanceIntervals {
  intervals: {
    oil_change: {
      name: string;
      defaultIntervalKm: number;       // 10000
      defaultIntervalDays: number;     // 180
      applicableCategories: string[];  // ['ICE', 'HEV', 'PHEV']
    };
    tire_rotation: {
      name: string;
      defaultIntervalKm: number;
      defaultIntervalDays: number;
      applicableCategories: string[];
    };
    // ... diger bakimlar
  };
  updatedAt: Timestamp;
}
```

#### Arac Markalari ve Modelleri

```
/app_settings/vehicle_catalog
```

```typescript
interface VehicleCatalog {
  brands: Array<{
    id: string;
    name: string;
    logo: string;
    models: Array<{
      id: string;
      name: string;
      years: number[];
      categories: string[];
      fuelTypes: string[];
    }>;
  }>;
  updatedAt: Timestamp;
}
```

#### Uygulama Versiyonu

```
/app_settings/app_config
```

```typescript
interface AppConfig {
  // Minimum Versiyon
  minSupportedVersion: {
    ios: string;
    android: string;
  };

  // Guncel Versiyon
  latestVersion: {
    ios: string;
    android: string;
  };

  // Bakim Modu
  maintenanceMode: {
    enabled: boolean;
    message: string;
    estimatedEndTime: Timestamp | null;
  };

  // Feature Flags
  featureFlags: {
    enableNewAnalysisUI: boolean;
    enableBetaFeatures: boolean;
    enableOfflineMode: boolean;
    [key: string]: boolean;
  };

  // API Ayarlari
  api: {
    baseUrl: string;
    timeout: number;
  };

  updatedAt: Timestamp;
}
```

---

## 7. Firebase Storage Yapisi

```
storage-root/
├── users/
│   └── {userId}/
│       ├── profile/
│       │   └── avatar.jpg
│       └── documents/
│           └── {documentId}.pdf
│
├── vehicles/
│   └── {vehicleId}/
│       ├── main.jpg
│       └── gallery/
│           ├── photo_1.jpg
│           └── photo_2.jpg
│
├── analysis_photos/
│   └── {reportId}/
│       ├── engine_bay.jpg
│       ├── engine_bay_thumb.jpg
│       ├── headlights.jpg
│       ├── headlights_thumb.jpg
│       └── ...
│
├── maintenance_documents/
│   └── {vehicleId}/
│       └── {recordId}/
│           ├── invoice.pdf
│           └── receipt.jpg
│
└── feedback_attachments/
    └── {feedbackId}/
        └── screenshot.png
```

---

## 8. Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Yardimci fonksiyonlar
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isVehicleOwner(vehicleId) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/vehicles/$(vehicleId)).data.ownerId == request.auth.uid;
    }

    // Users
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false; // Soft delete kullan

      // Alt koleksiyonlar
      match /saved_locations/{locationId} {
        allow read, write: if isOwner(userId);
      }
    }

    // Vehicles
    match /vehicles/{vehicleId} {
      allow read: if isAuthenticated() &&
        resource.data.ownerId == request.auth.uid;
      allow create: if isAuthenticated() &&
        request.resource.data.ownerId == request.auth.uid;
      allow update: if isVehicleOwner(vehicleId);
      allow delete: if isVehicleOwner(vehicleId);

      // Alt koleksiyonlar
      match /reminders/{reminderId} {
        allow read, write: if isVehicleOwner(vehicleId);
      }

      match /maintenance_history/{recordId} {
        allow read, write: if isVehicleOwner(vehicleId);
      }
    }

    // Maintenance Reports
    match /maintenance_reports/{reportId} {
      allow read: if isAuthenticated() &&
        (resource.data.userId == request.auth.uid ||
         resource.data.isShared == true);
      allow create: if isAuthenticated() &&
        request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      allow delete: if false;

      match /photos/{photoId} {
        allow read: if isAuthenticated() &&
          get(/databases/$(database)/documents/maintenance_reports/$(reportId)).data.userId == request.auth.uid;
        allow write: if isAuthenticated() &&
          get(/databases/$(database)/documents/maintenance_reports/$(reportId)).data.userId == request.auth.uid;
      }
    }

    // Notifications
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['readAt', 'status']);
      allow delete: if false;
    }

    // Feedback
    match /feedback/{feedbackId} {
      allow read: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() &&
        request.resource.data.userId == request.auth.uid;
      allow update: if false;
      allow delete: if false;
    }

    // App Settings (read-only for clients)
    match /app_settings/{settingId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## 9. Firestore Indeksler

Firebase Console veya `firestore.indexes.json` ile olusturulacak indeksler:

```json
{
  "indexes": [
    {
      "collectionGroup": "vehicles",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "vehicles",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ownerId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
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
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
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
        { "fieldPath": "vehicleId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## 10. Ornek Veri Yapilari

### Ornek Kullanici

```json
{
  "uid": "user_abc123",
  "email": "ahmet@example.com",
  "displayName": "Ahmet Yilmaz",
  "phoneNumber": "+905551234567",
  "photoURL": "https://storage.googleapis.com/...",
  "accountStatus": "active",
  "emailVerified": true,
  "phoneVerified": true,
  "createdAt": "2026-01-01T10:00:00Z",
  "updatedAt": "2026-01-03T14:30:00Z",
  "lastLoginAt": "2026-01-03T14:30:00Z",
  "subscription": {
    "plan": "premium",
    "status": "active",
    "startDate": "2026-01-01T00:00:00Z",
    "endDate": "2026-02-01T00:00:00Z",
    "autoRenew": true,
    "trialUsed": true
  },
  "usage": {
    "monthlyAnalysisCount": 5,
    "monthlyAnalysisLimit": 50,
    "totalAnalysisCount": 23,
    "lastAnalysisAt": "2026-01-02T16:00:00Z",
    "currentPeriodStart": "2026-01-01T00:00:00Z"
  },
  "preferences": {
    "language": "tr",
    "theme": "dark",
    "measurementUnit": "metric",
    "currency": "TRY",
    "dateFormat": "DD/MM/YYYY",
    "timeFormat": "24h"
  },
  "notificationSettings": {
    "pushEnabled": true,
    "emailEnabled": true,
    "smsEnabled": false,
    "maintenanceReminders": true,
    "analysisComplete": true,
    "weeklyReport": true,
    "promotions": false,
    "systemUpdates": true,
    "reminderTime": "09:00",
    "reminderDaysBefore": 3
  },
  "privacySettings": {
    "shareAnalyticsData": true,
    "showProfilePublicly": false,
    "allowLocationTracking": true
  },
  "devices": [
    {
      "deviceId": "device_xyz789",
      "deviceType": "android",
      "deviceName": "Samsung Galaxy S24",
      "fcmToken": "fcm_token_here...",
      "lastActiveAt": "2026-01-03T14:30:00Z",
      "appVersion": "1.2.0"
    }
  ],
  "address": {
    "city": "Istanbul",
    "district": "Kadikoy",
    "country": "TR"
  }
}
```

### Ornek Arac (BEV)

```json
{
  "id": "vehicle_ev001",
  "ownerId": "user_abc123",
  "plate": "34 EV 2024",
  "brand": "Tesla",
  "model": "Model 3",
  "year": 2023,
  "color": "Beyaz",
  "vin": "5YJ3E1EA1PF000001",
  "category": "BEV",
  "fuelType": "electric",
  "engineSize": null,
  "batteryCapacityKwh": 60,
  "electricRange": 450,
  "currentKm": 15000,
  "lastKmUpdateAt": "2026-01-02T10:00:00Z",
  "kmHistory": [
    { "km": 15000, "date": "2026-01-02T10:00:00Z", "source": "analysis" },
    { "km": 12000, "date": "2025-11-15T09:00:00Z", "source": "manual" }
  ],
  "registrationDate": "2023-06-15T00:00:00Z",
  "insuranceExpiryDate": "2026-06-15T00:00:00Z",
  "inspectionExpiryDate": "2025-06-15T00:00:00Z",
  "purchaseDate": "2023-06-10T00:00:00Z",
  "purchaseKm": 0,
  "isSecondHand": false,
  "status": "active",
  "isPrimary": true,
  "lastAnalysis": {
    "reportId": "RPT-2026-000045",
    "date": "2026-01-02T10:30:00Z",
    "healthScore": 92,
    "status": "good"
  },
  "lastMaintenance": {
    "date": "2025-12-01T00:00:00Z",
    "km": 12000,
    "type": "general_service"
  },
  "nextMaintenance": {
    "recommendedDate": "2026-06-01T00:00:00Z",
    "recommendedKm": 24000,
    "type": "general_service",
    "reason": "Periyodik bakim araligi"
  },
  "photos": {
    "main": "https://storage.googleapis.com/.../main.jpg",
    "gallery": []
  },
  "notes": "Supercharger uyeligi mevcut",
  "createdAt": "2023-06-15T12:00:00Z",
  "updatedAt": "2026-01-02T10:30:00Z"
}
```

### Ornek Analiz Raporu

```json
{
  "id": "RPT-2026-000045",
  "userId": "user_abc123",
  "vehicleId": "vehicle_ev001",
  "generatedAt": "2026-01-02T10:30:00Z",
  "analyzedAt": "2026-01-02T10:29:45Z",
  "vehicleSnapshot": {
    "plate": "34 EV 2024",
    "brand": "Tesla",
    "model": "Model 3",
    "year": 2023,
    "category": "BEV",
    "fuelType": "electric",
    "currentKm": 15000
  },
  "overallSummary": {
    "healthScore": 92,
    "status": "good",
    "statusText": "Araciniz cok iyi durumda. Duzgun bakim devam edin.",
    "analyzedPartsCount": 5,
    "goodCount": 4,
    "attentionCount": 1,
    "criticalCount": 0
  },
  "partAnalyses": [
    {
      "partId": "frunk",
      "partName": "On Bolum (Frunk)",
      "order": 1,
      "healthScore": 95,
      "status": "good",
      "photoUrl": "https://storage.googleapis.com/.../frunk.jpg",
      "analysisResult": {
        "overall_cleanliness": "clean",
        "visible_components": {
          "wiper_fluid": "adequate",
          "brake_fluid": "full"
        }
      },
      "findings": [
        {
          "type": "good",
          "component": "Genel Temizlik",
          "description": "On bolum temiz ve duzgun durumda",
          "recommendation": null
        }
      ],
      "confidence": 0.91
    },
    {
      "partId": "charging_port",
      "partName": "Sarj Portu",
      "order": 5,
      "healthScore": 78,
      "status": "attention",
      "photoUrl": "https://storage.googleapis.com/.../charging_port.jpg",
      "analysisResult": {
        "port_cleanliness": "dusty",
        "pin_condition": "good",
        "cap_condition": "good"
      },
      "findings": [
        {
          "type": "attention",
          "component": "Port Temizligi",
          "description": "Sarj portunda toz birikmesi mevcut",
          "recommendation": "Kuru bir bezle hafifce temizleyin"
        }
      ],
      "confidence": 0.88
    }
  ],
  "recommendations": {
    "immediate": [],
    "soon": [
      {
        "title": "Sarj Portu Temizligi",
        "description": "Sarj portundaki tozu temizleyin",
        "estimatedCost": null,
        "relatedPart": "charging_port"
      }
    ],
    "scheduled": [
      {
        "title": "Periyodik Bakim",
        "description": "24.000 km'de genel bakim yaptiriniz",
        "estimatedCost": "2000-3000 TL",
        "relatedPart": "general"
      }
    ]
  },
  "nextMaintenance": {
    "recommendedDate": "2026-06-01T00:00:00Z",
    "recommendedKm": 24000,
    "reason": "Periyodik bakim araligi"
  },
  "tips": [
    "Elektrikli araclar daha az bakim gerektirir ancak duzgun sarj aliskanliklari batarya omrunu uzatir",
    "Soguk havalarda menzil dususu normaldir, araci onceden isitmak etkilidir"
  ],
  "metadata": {
    "analysisDurationMs": 4500,
    "modelUsed": "gemini-2.0-flash",
    "photosAnalyzed": 5,
    "averageConfidence": 0.89,
    "appVersion": "1.2.0",
    "deviceType": "android"
  },
  "status": "completed",
  "errorMessage": null,
  "isShared": false,
  "shareToken": null,
  "sharedAt": null
}
```

---

## 11. Veritabani Iliskileri Diagrami

```
┌─────────────────┐
│     users       │
│  (kullanicilar) │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐       ┌─────────────────────┐
│    vehicles     │──────▶│  maintenance_reports│
│    (araclar)    │  1:N  │   (ai raporlari)    │
└────────┬────────┘       └─────────────────────┘
         │
         │ 1:N (subcollections)
         ▼
┌─────────────────┐       ┌─────────────────────┐
│   reminders     │       │ maintenance_history │
│(hatirlaticilar) │       │   (bakim gecmisi)   │
└─────────────────┘       └─────────────────────┘

┌─────────────────┐       ┌─────────────────────┐
│  notifications  │       │      feedback       │
│  (bildirimler)  │       │ (geri bildirimler)  │
└─────────────────┘       └─────────────────────┘
         │                         │
         └─────────┬───────────────┘
                   │
                   ▼
            ┌─────────────────┐
            │     users       │
            └─────────────────┘
```

---

## 12. Abonelik Planlari ve Limitler

| Ozellik | Free | Basic | Premium | Business |
|---------|------|-------|---------|----------|
| Aylik Analiz | 2 | 10 | 50 | Sinirsiz |
| Maksimum Arac | 1 | 3 | 10 | Sinirsiz |
| Bakim Hatirlatic | 2 | 5 | Sinirsiz | Sinirsiz |
| Gecmis Raporlar | 3 ay | 1 yil | 3 yil | Sinirsiz |
| Rapor Paylasimi | Hayir | Evet | Evet | Evet |
| Oncelikli Destek | Hayir | Hayir | Evet | Evet |
| API Erisimi | Hayir | Hayir | Hayir | Evet |
| Fiyat (TL/ay) | 0 | 49 | 149 | 499 |

---

## 13. Onemli Notlar

### Performans

1. **Pagination**: Buyuk koleksiyonlar icin `limit()` ve `startAfter()` kullanin
2. **Subcollections**: Vehicles altindaki reminders ve history subcollection olarak tasarlandi
3. **Denormalization**: `vehicleSnapshot` raporda tutulur (arac silinse bile rapor korunur)

### Guvenlik

1. Security Rules ile tum erisimler kontrol edilir
2. Kullanici sadece kendi verilerine erisebilir
3. Admin islemleri Cloud Functions uzerinden yapilir

### Offline Destek

1. Firestore offline persistence aktif edilmeli
2. Kritik veriler local cache'te tutulur
3. Sync conflict stratejisi: server-wins

### GDPR/KVKK Uyumlulugu

1. Kullanici veri silme hakki (soft delete)
2. Veri export fonksiyonu
3. Aydinlatma metni onay kaydi

---

## 14. Cloud Functions Onerileri

Asagidaki islemler icin Cloud Functions kullanilmalidir:

```typescript
// Ornek fonksiyon isimleri
functions/
├── onUserCreated          // Yeni kullanici olusturuldiginda
├── onUserDeleted          // Kullanici silindiginde (cleanup)
├── onVehicleCreated       // Yeni arac eklendiginde
├── onReportGenerated      // Rapor tamamlandiginda (bildirim gonder)
├── checkMaintenanceReminders  // Scheduled: Her gun hatirlaticlari kontrol et
├── sendPushNotification   // Push bildirim gonderme
├── cleanupExpiredReports  // Scheduled: Suresi dolan raporlari temizle
├── processAnalysisRequest // AI analiz istegi isleme
├── generateWeeklyReport   // Scheduled: Haftalik ozet olustur
└── handleSubscriptionChange // Abonelik degisikliklerinde
```

---

*Bu dokuman CarCheck AI mobil uygulamasi icin Firebase veritabani tasarimini tanimlar. Herhangi bir degisiklik oncelikle bu dokumanda yapilmali ve tum ekiplerle paylasılmalıdır.*
