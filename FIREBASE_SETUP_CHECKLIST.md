# ✅ FIREBASE SETUP VERIFICATION CHECKLIST

**Status**: Checking your Firebase setup  
**Date**: Hari ini

---

## 📋 Pre-Flight Checklist

### ✅ Sudah Ada di Project Anda

```
✅ firebase_core dependency
✅ firebase_auth dependency
✅ cloud_firestore dependency
✅ firebase_storage dependency
✅ lib/config/firebase_config.dart
✅ lib/config/firebase_options.dart
✅ lib/services/auth_service.dart
✅ lib/services/api_service.dart
```

### ⏳ YANG MASIH PERLU DILAKUKAN

Berikut adalah langkah-langkah yang Anda perlu lakukan:

---

## 🚀 LANGKAH PERTAMA: Buat Firebase Project

### 1️⃣ Buka Firebase Console
```
1. Buka: https://console.firebase.google.com/
2. Login dengan Google Account Anda
3. Klik "Create a new project" (atau lihat project list)
```

### 2️⃣ Buat Project Baru
```
Jika belum ada project:
1. Klik "Create a new project"
2. Nama Project: kede_app
3. Klik "Continue"
4. Disable Google Analytics (opsional)
5. Klik "Create project"
6. Tunggu ~2 menit
```

✅ **Jika sudah ada project Firebase, skip ke step berikutnya**

---

## 📱 LANGKAH KEDUA: Setup Android

### 3️⃣ Register Android App
```
Di Firebase Console:
1. Klik icon "Android" (untuk register Android app)
2. Masukkan Package Name: com.example.kelompok2
   (Bisa dilihat di: android/app/build.gradle.kts)
3. Masukkan App nickname: kede_app
4. Klik "Register app"
```

### 4️⃣ Download google-services.json
```
1. Klik "Download google-services.json"
2. Simpan file ini
3. Pindahkan ke folder: android/app/
4. Klik "Next"
```

✅ **PENTING**: File harus di `android/app/google-services.json`

### 5️⃣ Update Android Build Files

**Buka file: android/build.gradle.kts**
```
Pastikan sudah ada:

plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    // ... plugins lainnya
}
```

**Buka file: android/app/build.gradle.kts**
```
1. Pastikan di bagian plugins ada:
   id("com.google.gms.google-services")

2. Pastikan di bagian dependencies ada:
   implementation("com.google.firebase:firebase-core:32.5.0")
   implementation("com.google.firebase:firebase-auth:22.3.0")
   implementation("com.google.firebase:firebase-firestore:24.10.0")
   implementation("com.google.firebase:firebase-storage:20.3.0")
```

---

## 🍎 LANGKAH KETIGA: Setup iOS (Jika perlu)

### 6️⃣ Register iOS App
```
Di Firebase Console:
1. Klik icon "iOS" (Apple)
2. Masukkan Bundle ID: com.example.kelompok2
3. Masukkan App nickname: kede_app
4. Klik "Register app"
```

### 7️⃣ Download GoogleService-Info.plist
```
1. Klik "Download GoogleService-Info.plist"
2. Buka Xcode: open ios/Runner.xcworkspace
3. Drag GoogleService-Info.plist ke Xcode
4. Pastikan "Copy items if needed" tercentang
5. Klik "Finish"
6. Klik "Next" di Firebase
```

### 8️⃣ Update Podfile
```
Buka: ios/Podfile

Cari baris terakhir sebelum "end":
    flutter_additional_ios_build_settings(target)

Tambahkan setelah baris itu:

    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_ENABLED=1',
      ]
    end

Lalu jalankan:
cd ios && pod install && cd ..
```

---

## 💾 LANGKAH KEEMPAT: Setup Flutter Dependencies

### 9️⃣ Jalankan pub get
```bash
flutter pub get
```

✅ Tunggu sampai selesai. Tidak boleh ada error.

---

## 🔧 LANGKAH KELIMA: Update main.dart

**File: lib/main.dart**

Pastikan sudah ada:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase ← PENTING!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

---

## 🗄️ LANGKAH KEENAM: Setup Firestore Database

### 🔟 Buat Firestore Database
```
Di Firebase Console:
1. Klik "Build" → "Firestore Database"
2. Klik "Create database"
3. Pilih lokasi: asia-southeast1 (Singapore)
4. Pilih mode: Start in test mode
5. Klik "Enable"
6. Tunggu ~1 menit
```

✅ Jika sudah ada Firestore Database, skip ke step berikutnya

### 1️⃣1️⃣ Buat Collections (Optional - untuk struktur data)

**Collection: users**
```
Docs → Add document
Document ID: (auto)
Fields:
- uid: string
- email: string
- name: string
- profile_photo: string (URL)
- created_at: timestamp
- role: string (buyer/seller)
```

**Collection: products**
```
Docs → Add document
Document ID: (auto)
Fields:
- seller_id: string
- name: string
- description: string
- price: number
- image: string (URL)
- category: string
- stock: number
- created_at: timestamp
```

Atau bisa langsung skip - akan auto-create saat pertama kali app write data.

---

## 🔐 LANGKAH KETUJUH: Setup Firestore Security Rules

### 1️⃣2️⃣ Update Security Rules

**Di Firebase Console:**
```
1. Klik "Firestore Database"
2. Klik tab "Rules"
3. Ganti semua isi dengan code di bawah
4. Klik "Publish"
```

**Copy-paste rules ini (untuk DEVELOPMENT):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **CATATAN**: Rules ini untuk development/testing saja. Untuk production, gunakan rules yang lebih ketat.

---

## 🔐 LANGKAH KEDELAPAN: Setup Authentication

### 1️⃣3️⃣ Aktifkan Email/Password Sign-in

**Di Firebase Console:**
```
1. Klik "Build" → "Authentication"
2. Klik tab "Sign-in method"
3. Klik "Email/Password"
4. Klik toggle untuk "Enable"
5. Klik "Save"
```

✅ Sekarang users bisa sign up/sign in dengan email & password

---

## 🧪 LANGKAH KESEMBILAN: Test Firebase Connection

### 1️⃣4️⃣ Jalankan App

```bash
flutter clean
flutter pub get
flutter run
```

### 1️⃣5️⃣ Lihat Logs

Jika melihat di console:
```
[Firebase] Initialization completed successfully
```

✅ **SUKSES!** Firebase sudah terhubung

Jika error, lihat bagian "Troubleshooting" di bawah.

---

## ✅ CHECKLIST VERIFICATION

Sebelum lanjut, pastikan sudah:

```
Android Setup:
☐ google-services.json sudah di android/app/
☐ android/build.gradle.kts sudah update
☐ android/app/build.gradle.kts sudah update dengan Firebase deps

iOS Setup (jika perlu):
☐ GoogleService-Info.plist di Xcode
☐ ios/Podfile sudah update
☐ pod install sudah dijalankan

Flutter Setup:
☐ flutter pub get berhasil (no errors)
☐ main.dart sudah import Firebase
☐ Firebase.initializeApp() di main()

Firebase Console:
☐ Firebase Project sudah dibuat
☐ Android app sudah didaftarkan
☐ Firestore Database sudah dibuat
☐ Authentication sudah diaktifkan
☐ Security Rules sudah di-publish

Testing:
☐ flutter run berhasil
☐ Lihat "[Firebase] Initialization completed successfully"
```

---

## 🚨 TROUBLESHOOTING

### Error: "google-services.json not found"
```
Solution:
1. Download google-services.json dari Firebase Console
2. Pindahkan ke: android/app/google-services.json
3. flutter clean
4. flutter pub get
5. flutter run
```

### Error: "FirebaseException: com.google.firebase.FirebaseException"
```
Solution:
1. Pastikan Firestore Database sudah dibuat
2. Pastikan Security Rules sudah di-publish
3. Pastikan internet connection aktif
4. Cek di Firebase Console apakah ada error
```

### Error: "PlatformException: INVALID_PROVIDER"
```
Solution:
1. Pastikan package name di Firebase Console sama dengan di gradle
2. Pastikan google-services.json di lokasi yang benar
3. flutter clean dan rebuild
```

### Error: "FirebaseAuthException: The password should be at least 6 characters"
```
Solution:
1. Password harus minimal 6 karakter
2. Email harus valid format
3. Pastikan user belum terdaftar
```

---

## 🎯 QUICK COMMANDS

**Jalankan app setelah setup:**
```bash
cd d:\9.5 MWS PRAK\kelompok2prak
flutter clean
flutter pub get
flutter run
```

**Lihat Firebase logs:**
```bash
flutter logs
```

**Check Firebase initialization:**
Tambah di main.dart:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('[Firebase] ✅ Connected successfully!');
  } catch (e) {
    print('[Firebase] ❌ Error: $e');
  }
  
  runApp(const MyApp());
}
```

---

## 📞 PERLU BANTUAN?

### Jika error saat setup Android:
→ Lihat: FIREBASE_CONNECTION_SETUP.md → Troubleshooting

### Jika error saat setup iOS:
→ Buka ios/Runner.xcworkspace dan check configuration

### Jika error saat initialize Firebase:
→ Pastikan fireabse_options.dart sudah benar

### Jika error saat test auth:
→ Pastikan Authentication sudah di-enable di Firebase Console

---

## 🎉 SETELAH SETUP SELESAI

Setelah Firebase berhasil terhubung:

1. ✅ Auth service sudah bisa digunakan
2. ✅ API service sudah bisa query Firestore
3. ✅ Profile photo uploads bisa pakai Cloudinary
4. ✅ Product image uploads bisa pakai Cloudinary

---

## 📝 NEXT STEPS

1. ✅ Setup Firebase (langkah-langkah di atas)
2. ✅ Jalankan: flutter pub get
3. ✅ Jalankan: flutter clean && flutter run
4. ✅ Test: Sign up / Sign in
5. ✅ Check: Firestore console apakah ada data baru

---

**Status**: Firebase Setup Verification Checklist  
**Updated**: Hari ini  
**Time to Complete**: ~30 minutes

**Next**: Follow langkah 1-15 di atas untuk setup Firebase! 🚀
