const admin = require('firebase-admin');

// Emulator'a baglan (service account gerekmez)
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';
process.env.FIREBASE_STORAGE_EMULATOR_HOST = '127.0.0.1:9199';

admin.initializeApp({
  projectId: 'carcheck-1967f'
});

const db = admin.firestore();
const auth = admin.auth();

async function seedData() {
  console.log('Test verileri ekleniyor...\n');

  // ========================================
  // 1. TEST KULLANICILARI (Auth)
  // ========================================
  console.log('1. Kullanicilar olusturuluyor...');

  const users = [
    {
      uid: 'user_ahmet123',
      email: 'ahmet@test.com',
      password: 'test123456',
      displayName: 'Ahmet Yilmaz'
    },
    {
      uid: 'user_mehmet456',
      email: 'mehmet@test.com',
      password: 'test123456',
      displayName: 'Mehmet Demir'
    },
    {
      uid: 'user_ayse789',
      email: 'ayse@test.com',
      password: 'test123456',
      displayName: 'Ayse Kaya'
    }
  ];

  for (const user of users) {
    try {
      await auth.createUser({
        uid: user.uid,
        email: user.email,
        password: user.password,
        displayName: user.displayName,
        emailVerified: true
      });
      console.log(`   + ${user.displayName} (${user.email})`);
    } catch (e) {
      if (e.code === 'auth/uid-already-exists') {
        console.log(`   ~ ${user.displayName} zaten var`);
      } else {
        console.log(`   ! Hata: ${e.message}`);
      }
    }
  }

  // ========================================
  // 2. KULLANICI PROFILLERI (Firestore)
  // ========================================
  console.log('\n2. Kullanici profilleri olusturuluyor...');

  const userProfiles = [
    {
      id: 'user_ahmet123',
      data: {
        uid: 'user_ahmet123',
        email: 'ahmet@test.com',
        displayName: 'Ahmet Yilmaz',
        phoneNumber: '+905551234567',
        photoURL: null,
        accountStatus: 'active',
        emailVerified: true,
        phoneVerified: false,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        lastLoginAt: admin.firestore.Timestamp.now(),
        subscription: {
          plan: 'premium',
          status: 'active',
          startDate: admin.firestore.Timestamp.now(),
          endDate: admin.firestore.Timestamp.fromDate(new Date('2026-02-01')),
          autoRenew: true,
          trialUsed: true
        },
        usage: {
          monthlyAnalysisCount: 5,
          monthlyAnalysisLimit: 50,
          totalAnalysisCount: 23,
          lastAnalysisAt: admin.firestore.Timestamp.now(),
          currentPeriodStart: admin.firestore.Timestamp.now()
        },
        preferences: {
          language: 'tr',
          theme: 'dark',
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
        address: {
          city: 'Istanbul',
          district: 'Kadikoy',
          country: 'TR'
        }
      }
    },
    {
      id: 'user_mehmet456',
      data: {
        uid: 'user_mehmet456',
        email: 'mehmet@test.com',
        displayName: 'Mehmet Demir',
        phoneNumber: '+905559876543',
        photoURL: null,
        accountStatus: 'active',
        emailVerified: true,
        phoneVerified: false,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        lastLoginAt: admin.firestore.Timestamp.now(),
        subscription: {
          plan: 'free',
          status: 'active',
          startDate: admin.firestore.Timestamp.now(),
          endDate: null,
          autoRenew: false,
          trialUsed: false
        },
        usage: {
          monthlyAnalysisCount: 1,
          monthlyAnalysisLimit: 2,
          totalAnalysisCount: 1,
          lastAnalysisAt: admin.firestore.Timestamp.now(),
          currentPeriodStart: admin.firestore.Timestamp.now()
        },
        preferences: {
          language: 'tr',
          theme: 'light',
          measurementUnit: 'metric',
          currency: 'TRY',
          dateFormat: 'DD/MM/YYYY',
          timeFormat: '24h'
        },
        notificationSettings: {
          pushEnabled: true,
          emailEnabled: false,
          smsEnabled: false,
          maintenanceReminders: true,
          analysisComplete: true,
          weeklyReport: false,
          promotions: false,
          systemUpdates: true,
          reminderTime: '10:00',
          reminderDaysBefore: 2
        },
        privacySettings: {
          shareAnalyticsData: false,
          showProfilePublicly: false,
          allowLocationTracking: false
        },
        devices: [],
        address: {
          city: 'Ankara',
          district: 'Cankaya',
          country: 'TR'
        }
      }
    }
  ];

  for (const profile of userProfiles) {
    await db.collection('users').doc(profile.id).set(profile.data);
    console.log(`   + ${profile.data.displayName}`);
  }

  // ========================================
  // 3. ARACLAR (Vehicles)
  // ========================================
  console.log('\n3. Araclar olusturuluyor...');

  const vehicles = [
    {
      id: 'vehicle_ice001',
      data: {
        ownerId: 'user_ahmet123',
        plate: '34 ABC 123',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2020,
        color: 'Beyaz',
        vin: 'JTDKN3DU5A0123456',
        category: 'ICE',
        fuelType: 'benzin',
        engineSize: '1.6',
        batteryCapacityKwh: null,
        electricRange: null,
        currentKm: 45000,
        lastKmUpdateAt: admin.firestore.Timestamp.now(),
        kmHistory: [
          { km: 45000, date: admin.firestore.Timestamp.now(), source: 'manual' },
          { km: 40000, date: admin.firestore.Timestamp.fromDate(new Date('2025-10-01')), source: 'analysis' }
        ],
        registrationDate: admin.firestore.Timestamp.fromDate(new Date('2020-03-15')),
        insuranceExpiryDate: admin.firestore.Timestamp.fromDate(new Date('2026-03-15')),
        inspectionExpiryDate: admin.firestore.Timestamp.fromDate(new Date('2026-03-15')),
        purchaseDate: admin.firestore.Timestamp.fromDate(new Date('2020-03-10')),
        purchaseKm: 0,
        isSecondHand: false,
        status: 'active',
        isPrimary: true,
        lastAnalysis: {
          reportId: 'report_001',
          date: admin.firestore.Timestamp.now(),
          healthScore: 85,
          status: 'good'
        },
        lastMaintenance: {
          date: admin.firestore.Timestamp.fromDate(new Date('2025-11-15')),
          km: 42000,
          type: 'oil_change'
        },
        nextMaintenance: {
          recommendedDate: admin.firestore.Timestamp.fromDate(new Date('2026-05-15')),
          recommendedKm: 52000,
          type: 'oil_change',
          reason: 'Periyodik yag degisimi'
        },
        photos: {
          main: null,
          gallery: []
        },
        notes: 'Duzenli bakim yapiliyor',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    },
    {
      id: 'vehicle_bev001',
      data: {
        ownerId: 'user_ahmet123',
        plate: '34 EV 2024',
        brand: 'Tesla',
        model: 'Model 3',
        year: 2023,
        color: 'Kirmizi',
        vin: '5YJ3E1EA1PF000001',
        category: 'BEV',
        fuelType: 'electric',
        engineSize: null,
        batteryCapacityKwh: 60,
        electricRange: 450,
        currentKm: 15000,
        lastKmUpdateAt: admin.firestore.Timestamp.now(),
        kmHistory: [
          { km: 15000, date: admin.firestore.Timestamp.now(), source: 'manual' }
        ],
        registrationDate: admin.firestore.Timestamp.fromDate(new Date('2023-06-15')),
        insuranceExpiryDate: admin.firestore.Timestamp.fromDate(new Date('2026-06-15')),
        inspectionExpiryDate: admin.firestore.Timestamp.fromDate(new Date('2025-06-15')),
        purchaseDate: admin.firestore.Timestamp.fromDate(new Date('2023-06-10')),
        purchaseKm: 0,
        isSecondHand: false,
        status: 'active',
        isPrimary: false,
        lastAnalysis: {
          reportId: 'report_002',
          date: admin.firestore.Timestamp.now(),
          healthScore: 95,
          status: 'good'
        },
        lastMaintenance: {
          date: admin.firestore.Timestamp.fromDate(new Date('2025-12-01')),
          km: 12000,
          type: 'general_service'
        },
        nextMaintenance: {
          recommendedDate: admin.firestore.Timestamp.fromDate(new Date('2026-06-01')),
          recommendedKm: 24000,
          type: 'general_service',
          reason: 'Periyodik bakim'
        },
        photos: {
          main: null,
          gallery: []
        },
        notes: 'Supercharger uyeligi var',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    },
    {
      id: 'vehicle_hev001',
      data: {
        ownerId: 'user_mehmet456',
        plate: '06 HYB 789',
        brand: 'Toyota',
        model: 'Corolla Hybrid',
        year: 2022,
        color: 'Gri',
        vin: 'JTDKN3DU5A0789012',
        category: 'HEV',
        fuelType: 'hybrid',
        engineSize: '1.8',
        batteryCapacityKwh: 1.3,
        electricRange: null,
        currentKm: 35000,
        lastKmUpdateAt: admin.firestore.Timestamp.now(),
        kmHistory: [
          { km: 35000, date: admin.firestore.Timestamp.now(), source: 'manual' }
        ],
        registrationDate: admin.firestore.Timestamp.fromDate(new Date('2022-09-01')),
        insuranceExpiryDate: admin.firestore.Timestamp.fromDate(new Date('2026-09-01')),
        inspectionExpiryDate: admin.firestore.Timestamp.fromDate(new Date('2026-09-01')),
        purchaseDate: admin.firestore.Timestamp.fromDate(new Date('2022-08-25')),
        purchaseKm: 0,
        isSecondHand: false,
        status: 'active',
        isPrimary: true,
        lastAnalysis: null,
        lastMaintenance: {
          date: admin.firestore.Timestamp.fromDate(new Date('2025-08-15')),
          km: 30000,
          type: 'oil_change'
        },
        nextMaintenance: {
          recommendedDate: admin.firestore.Timestamp.fromDate(new Date('2026-02-15')),
          recommendedKm: 40000,
          type: 'oil_change',
          reason: 'Periyodik yag degisimi'
        },
        photos: {
          main: null,
          gallery: []
        },
        notes: null,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    }
  ];

  for (const vehicle of vehicles) {
    await db.collection('vehicles').doc(vehicle.id).set(vehicle.data);
    console.log(`   + ${vehicle.data.brand} ${vehicle.data.model} (${vehicle.data.plate})`);
  }

  // ========================================
  // 4. BAKIM HATIRLATICLARI (Reminders)
  // ========================================
  console.log('\n4. Bakim hatirlaticlari olusturuluyor...');

  const reminders = [
    {
      vehicleId: 'vehicle_ice001',
      reminderId: 'reminder_001',
      data: {
        vehicleId: 'vehicle_ice001',
        type: 'oil_change',
        customName: null,
        triggerType: 'both',
        intervalDays: 180,
        nextTriggerDate: admin.firestore.Timestamp.fromDate(new Date('2026-05-15')),
        intervalKm: 10000,
        nextTriggerKm: 52000,
        isActive: true,
        lastTriggeredAt: null,
        lastCompletedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-15')),
        notifyDaysBefore: 7,
        notifyKmBefore: 500,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    },
    {
      vehicleId: 'vehicle_ice001',
      reminderId: 'reminder_002',
      data: {
        vehicleId: 'vehicle_ice001',
        type: 'inspection',
        customName: null,
        triggerType: 'date',
        intervalDays: 365,
        nextTriggerDate: admin.firestore.Timestamp.fromDate(new Date('2026-03-15')),
        intervalKm: null,
        nextTriggerKm: null,
        isActive: true,
        lastTriggeredAt: null,
        lastCompletedAt: null,
        notifyDaysBefore: 30,
        notifyKmBefore: 0,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    }
  ];

  for (const reminder of reminders) {
    await db.collection('vehicles').doc(reminder.vehicleId)
      .collection('reminders').doc(reminder.reminderId).set(reminder.data);
    console.log(`   + ${reminder.data.type} (${reminder.vehicleId})`);
  }

  // ========================================
  // 5. BAKIM GECMISI (Maintenance History)
  // ========================================
  console.log('\n5. Bakim gecmisi olusturuluyor...');

  const maintenanceHistory = [
    {
      vehicleId: 'vehicle_ice001',
      recordId: 'history_001',
      data: {
        vehicleId: 'vehicle_ice001',
        date: admin.firestore.Timestamp.fromDate(new Date('2025-11-15')),
        km: 42000,
        type: 'oil_change',
        title: 'Yag ve Filtre Degisimi',
        description: 'Motor yagi ve yag filtresi degistirildi. Castrol 5W-30 kullanildi.',
        cost: {
          amount: 2500,
          currency: 'TRY'
        },
        serviceProvider: {
          name: 'Toyota Yetkili Servis',
          location: 'Istanbul, Kadikoy',
          phone: '+902161234567'
        },
        documents: [],
        source: 'manual',
        linkedReportId: null,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    },
    {
      vehicleId: 'vehicle_ice001',
      recordId: 'history_002',
      data: {
        vehicleId: 'vehicle_ice001',
        date: admin.firestore.Timestamp.fromDate(new Date('2025-05-20')),
        km: 32000,
        type: 'general_service',
        title: 'Periyodik Bakim',
        description: 'Yag, filtre, fren balatalari kontrol edildi.',
        cost: {
          amount: 4500,
          currency: 'TRY'
        },
        serviceProvider: {
          name: 'Toyota Yetkili Servis',
          location: 'Istanbul, Kadikoy',
          phone: '+902161234567'
        },
        documents: [],
        source: 'manual',
        linkedReportId: null,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    }
  ];

  for (const record of maintenanceHistory) {
    await db.collection('vehicles').doc(record.vehicleId)
      .collection('maintenance_history').doc(record.recordId).set(record.data);
    console.log(`   + ${record.data.title} (${record.data.date.toDate().toLocaleDateString('tr-TR')})`);
  }

  // ========================================
  // 6. AI ANALIZ RAPORLARI
  // ========================================
  console.log('\n6. AI analiz raporlari olusturuluyor...');

  const reports = [
    {
      id: 'report_001',
      data: {
        userId: 'user_ahmet123',
        vehicleId: 'vehicle_ice001',
        generatedAt: admin.firestore.Timestamp.now(),
        analyzedAt: admin.firestore.Timestamp.now(),
        vehicleSnapshot: {
          plate: '34 ABC 123',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2020,
          category: 'ICE',
          fuelType: 'benzin',
          currentKm: 45000
        },
        overallSummary: {
          healthScore: 85,
          status: 'good',
          statusText: 'Araciniz genel olarak iyi durumda. Birkac kucuk dikkat noktasi mevcut.',
          analyzedPartsCount: 5,
          goodCount: 4,
          attentionCount: 1,
          criticalCount: 0
        },
        partAnalyses: [
          {
            partId: 'engine_bay',
            partName: 'Motor Bolgesi',
            order: 1,
            healthScore: 80,
            status: 'attention',
            photoUrl: null,
            analysisResult: {
              overall_cleanliness: 'dusty',
              leak_detection: {
                detected: false,
                type: 'none',
                severity: 'none',
                location: null
              },
              visible_components: {
                battery_terminals: 'good',
                belts: 'good',
                hoses: 'aged'
              },
              fluid_levels: {
                coolant: 'adequate',
                washer: 'low',
                brake_fluid: 'full'
              }
            },
            findings: [
              {
                type: 'good',
                component: 'Aku',
                description: 'Aku terminalleri temiz durumda',
                recommendation: null
              },
              {
                type: 'attention',
                component: 'Cam Suyu',
                description: 'Cam suyu seviyesi dusuk',
                recommendation: 'Cam suyu eklenmeli'
              },
              {
                type: 'attention',
                component: 'Hortumlar',
                description: 'Bazi hortumlar eskimis gorunuyor',
                recommendation: 'Sonraki bakimda kontrol edilmeli'
              }
            ],
            confidence: 0.87
          },
          {
            partId: 'headlights',
            partName: 'On Farlar',
            order: 2,
            healthScore: 90,
            status: 'good',
            photoUrl: null,
            analysisResult: {
              lens_condition: 'clear',
              cleanliness: 'clean',
              visible_issues: []
            },
            findings: [
              {
                type: 'good',
                component: 'Far Lensler',
                description: 'Farlar temiz ve berrak',
                recommendation: null
              }
            ],
            confidence: 0.92
          },
          {
            partId: 'taillights',
            partName: 'Arka Stoplar',
            order: 3,
            healthScore: 95,
            status: 'good',
            photoUrl: null,
            analysisResult: {
              lens_condition: 'clear',
              cleanliness: 'clean',
              visible_issues: []
            },
            findings: [
              {
                type: 'good',
                component: 'Stop Lambalari',
                description: 'Stop lambalari iyi durumda',
                recommendation: null
              }
            ],
            confidence: 0.94
          },
          {
            partId: 'dashboard',
            partName: 'Gosterge Paneli',
            order: 4,
            healthScore: 85,
            status: 'good',
            photoUrl: null,
            analysisResult: {
              warning_lights: [],
              odometer_reading: 45000,
              visible_issues: []
            },
            findings: [
              {
                type: 'good',
                component: 'Uyari Isiklari',
                description: 'Herhangi bir uyari isigi yanmiyor',
                recommendation: null
              }
            ],
            confidence: 0.88
          },
          {
            partId: 'exhaust',
            partName: 'Egzoz',
            order: 5,
            healthScore: 75,
            status: 'attention',
            photoUrl: null,
            analysisResult: {
              condition: 'worn',
              rust_level: 'minor',
              visible_damage: false
            },
            findings: [
              {
                type: 'attention',
                component: 'Egzoz Borusu',
                description: 'Hafif paslanma mevcut',
                recommendation: 'Izlenmeli, su an mudahale gerektirmiyor'
              }
            ],
            confidence: 0.82
          }
        ],
        recommendations: {
          immediate: [],
          soon: [
            {
              title: 'Cam Suyu Ekle',
              description: 'Cam suyu seviyesi dusuk, takviye yapilmali',
              estimatedCost: '50-100 TL',
              relatedPart: 'engine_bay'
            }
          ],
          scheduled: [
            {
              title: 'Hortum Kontrolu',
              description: 'Motor hortumlarinin detayli kontrolu',
              estimatedCost: null,
              relatedPart: 'engine_bay'
            },
            {
              title: 'Egzoz Kontrolu',
              description: 'Paslanma takibi yapilmali',
              estimatedCost: null,
              relatedPart: 'exhaust'
            }
          ]
        },
        nextMaintenance: {
          recommendedDate: admin.firestore.Timestamp.fromDate(new Date('2026-05-15')),
          recommendedKm: 52000,
          reason: 'Periyodik yag degisimi'
        },
        tips: [
          'Duzenli yag degisimi motor omrunu uzatir',
          'Kis aylarinda antifriz seviyesini kontrol edin',
          'Lastik basinclarini ayda bir kontrol edin'
        ],
        metadata: {
          analysisDurationMs: 4500,
          modelUsed: 'gemini-2.0-flash',
          photosAnalyzed: 5,
          averageConfidence: 0.87,
          appVersion: '1.0.0',
          deviceType: 'android'
        },
        status: 'completed',
        errorMessage: null,
        isShared: false,
        shareToken: null,
        sharedAt: null
      }
    },
    {
      id: 'report_002',
      data: {
        userId: 'user_ahmet123',
        vehicleId: 'vehicle_bev001',
        generatedAt: admin.firestore.Timestamp.now(),
        analyzedAt: admin.firestore.Timestamp.now(),
        vehicleSnapshot: {
          plate: '34 EV 2024',
          brand: 'Tesla',
          model: 'Model 3',
          year: 2023,
          category: 'BEV',
          fuelType: 'electric',
          currentKm: 15000
        },
        overallSummary: {
          healthScore: 95,
          status: 'good',
          statusText: 'Araciniz mukemmel durumda!',
          analyzedPartsCount: 5,
          goodCount: 5,
          attentionCount: 0,
          criticalCount: 0
        },
        partAnalyses: [
          {
            partId: 'frunk',
            partName: 'On Bolum (Frunk)',
            order: 1,
            healthScore: 95,
            status: 'good',
            photoUrl: null,
            analysisResult: {
              overall_cleanliness: 'clean',
              visible_components: {
                wiper_fluid: 'full',
                brake_fluid: 'full'
              }
            },
            findings: [
              {
                type: 'good',
                component: 'Genel Durum',
                description: 'On bolum temiz ve duzgun',
                recommendation: null
              }
            ],
            confidence: 0.93
          },
          {
            partId: 'charging_port',
            partName: 'Sarj Portu',
            order: 5,
            healthScore: 95,
            status: 'good',
            photoUrl: null,
            analysisResult: {
              port_cleanliness: 'clean',
              pin_condition: 'good',
              cap_condition: 'good',
              visible_damage: false
            },
            findings: [
              {
                type: 'good',
                component: 'Sarj Portu',
                description: 'Sarj portu temiz ve iyi durumda',
                recommendation: null
              }
            ],
            confidence: 0.96
          }
        ],
        recommendations: {
          immediate: [],
          soon: [],
          scheduled: [
            {
              title: 'Periyodik Bakim',
              description: '24.000 km\'de genel kontrol',
              estimatedCost: '2000-3000 TL',
              relatedPart: 'general'
            }
          ]
        },
        nextMaintenance: {
          recommendedDate: admin.firestore.Timestamp.fromDate(new Date('2026-06-01')),
          recommendedKm: 24000,
          reason: 'Periyodik bakim araligi'
        },
        tips: [
          'Elektrikli araclar daha az bakim gerektirir',
          'Batarya sagligini korumak icin %20-80 arasi sarj yapin',
          'Soguk havalarda menzil azalmasi normaldir'
        ],
        metadata: {
          analysisDurationMs: 3200,
          modelUsed: 'gemini-2.0-flash',
          photosAnalyzed: 5,
          averageConfidence: 0.94,
          appVersion: '1.0.0',
          deviceType: 'ios'
        },
        status: 'completed',
        errorMessage: null,
        isShared: false,
        shareToken: null,
        sharedAt: null
      }
    }
  ];

  for (const report of reports) {
    await db.collection('maintenance_reports').doc(report.id).set(report.data);
    console.log(`   + Rapor: ${report.id} (Skor: ${report.data.overallSummary.healthScore})`);
  }

  // ========================================
  // 7. BILDIRIMLER
  // ========================================
  console.log('\n7. Bildirimler olusturuluyor...');

  const notifications = [
    {
      id: 'notif_001',
      data: {
        userId: 'user_ahmet123',
        type: 'analysis_complete',
        title: 'Analiz Tamamlandi',
        body: 'Toyota Corolla aracinin analizi tamamlandi. Saglik skoru: 85',
        data: {
          vehicleId: 'vehicle_ice001',
          reportId: 'report_001',
          actionUrl: '/reports/report_001'
        },
        imageUrl: null,
        icon: 'check_circle',
        priority: 'normal',
        status: 'delivered',
        readAt: null,
        sentAt: admin.firestore.Timestamp.now(),
        channels: {
          push: true,
          email: false,
          sms: false,
          inApp: true
        },
        scheduledFor: null,
        expiresAt: null,
        createdAt: admin.firestore.Timestamp.now()
      }
    },
    {
      id: 'notif_002',
      data: {
        userId: 'user_ahmet123',
        type: 'maintenance_reminder',
        title: 'Bakim Hatirlat',
        body: 'Toyota Corolla icin yag degisimi zamani yaklasti (7 gun kaldi)',
        data: {
          vehicleId: 'vehicle_ice001',
          reminderId: 'reminder_001',
          actionUrl: '/vehicles/vehicle_ice001'
        },
        imageUrl: null,
        icon: 'build',
        priority: 'high',
        status: 'pending',
        readAt: null,
        sentAt: null,
        channels: {
          push: true,
          email: true,
          sms: false,
          inApp: true
        },
        scheduledFor: admin.firestore.Timestamp.fromDate(new Date('2026-05-08')),
        expiresAt: null,
        createdAt: admin.firestore.Timestamp.now()
      }
    }
  ];

  for (const notif of notifications) {
    await db.collection('notifications').doc(notif.id).set(notif.data);
    console.log(`   + ${notif.data.title}`);
  }

  // ========================================
  // 8. UYGULAMA AYARLARI
  // ========================================
  console.log('\n8. Uygulama ayarlari olusturuluyor...');

  // Abonelik Planlari
  await db.collection('app_settings').doc('subscription_plans').set({
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
  console.log('   + Abonelik planlari');

  // Bakim Araliklari
  await db.collection('app_settings').doc('maintenance_intervals').set({
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
      general_service: {
        name: 'Genel Bakim',
        defaultIntervalKm: 15000,
        defaultIntervalDays: 365,
        applicableCategories: ['ICE', 'HEV', 'PHEV', 'BEV']
      }
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  console.log('   + Bakim araliklari');

  // Uygulama Config
  await db.collection('app_settings').doc('app_config').set({
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
  console.log('   + Uygulama config');

  // ========================================
  console.log('\n========================================');
  console.log('Test verileri basariyla eklendi!');
  console.log('========================================');
  console.log('\nOzet:');
  console.log('  - 3 kullanici (Auth)');
  console.log('  - 2 kullanici profili (Firestore)');
  console.log('  - 3 arac (ICE, BEV, HEV)');
  console.log('  - 2 bakim hatirlatic');
  console.log('  - 2 bakim gecmisi kaydi');
  console.log('  - 2 AI analiz raporu');
  console.log('  - 2 bildirim');
  console.log('  - 3 uygulama ayari');
  console.log('\nTest giris bilgileri:');
  console.log('  Email: ahmet@test.com');
  console.log('  Sifre: test123456');
  console.log('\nEmulator UI: http://127.0.0.1:4000');
}

seedData()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Hata:', err);
    process.exit(1);
  });
