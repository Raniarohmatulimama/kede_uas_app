# 🔥 Firebase Connection Setup Guide

**Panduan Menghubungkan Firebase dengan Flutter**

---

## 🚀 Step 1: Buat Firebase Project

### 1.1 Buka Firebase Console
```
Buka: https://console.firebase.google.com/
Login dengan Google Account Anda
```

### 1.2 Buat Project Baru
```
1. Klik "Create a new project"
2. Nama Project: kede_app (atau nama yang sesuai)
3. Klik "Continue"
4. Disable Google Analytics (opsional)
5. Klik "Create project"
6. Tunggu hingga selesai (~2 menit)
```

---

## 📱 Step 2: Setup untuk Android

### 2.1 Dapatkan Package Name
```
Buka: android/app/build.gradle.kts

Cari baris:
    applicationId = "com.example.kelompok2"
    
Ini adalah package name Anda
Contoh: com.example.kelompok2
```

### 2.2 Register Android App
```
Di Firebase Console:
1. Klik "Android" (icon Android)
2. Masukkan Package Name: com.example.kelompok2
3. Masukkan App nickname: kede_app
4. SHA-1 Certificate (Optional, nanti)
5. Klik "Register app"
```

### 2.3 Download Configuration File
```
1. Download google-services.json
2. Pindahkan ke: android/app/
3. Klik "Next"
```

### 2.4 Update build.gradle Files

**File: android/build.gradle.kts**
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    // ... plugin lainnya
}
```

**File: android/app/build.gradle.kts**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // ← TAMBAH INI
}

dependencies {
    // Firebase
    implementation("com.google.firebase:firebase-core:32.5.0")
    implementation("com.google.firebase:firebase-auth:22.3.0")
    implementation("com.google.firebase:firebase-firestore:24.10.0")
    implementation("com.google.firebase:firebase-storage:20.3.0")
    // ... dependency lainnya
}
```

---

## 🍎 Step 3: Setup untuk iOS

### 3.1 Dapatkan Bundle ID
```
Buka: ios/Runner.xcodeproj/project.pbxproj
Atau: ios/Runner/Info.plist

Cari Bundle Identifier
Contoh: com.example.kelompok2
```

### 3.2 Register iOS App
```
Di Firebase Console:
1. Klik "iOS" (icon Apple)
2. Masukkan Bundle ID: com.example.kelompok2
3. Masukkan App nickname: kede_app
4. Klik "Register app"
```

### 3.3 Download Configuration File
```
1. Download GoogleService-Info.plist
2. Buka Xcode: open ios/Runner.xcworkspace
3. Drag GoogleService-Info.plist ke Xcode
4. Pastikan "Copy items if needed" tercentang
5. Klik "Finish"
```

### 3.4 Update Podfile
```
Buka: ios/Podfile

Tambahkan di bagian bawah (sebelum "end"):

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_ENABLED=1',
      ]
    end
  end
end
```

Lalu jalankan:
```bash
cd ios
pod install
cd ..
```

---

## 🌐 Step 4: Setup untuk Web (Optional)

### 4.1 Register Web App
```
Di Firebase Console:
1. Klik "Web" (icon </> )
2. Masukkan App nickname: kede_app
3. Klik "Register app"
```

### 4.2 Copy Firebase Config
```
Firebase akan memberikan:

const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "kede-app.firebaseapp.com",
  projectId: "kede-app",
  storageBucket: "kede-app.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};

Simpan untuk nanti
```

---

## 📦 Step 5: Update pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase packages
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  
  # Image & File packages
  image_picker: ^1.0.0
  cloudinary_flutter: ^1.1.0
  
  # Utility packages
  http: ^1.1.0
  provider: ^6.0.0
```

Lalu jalankan:
```bash
flutter pub get
```

---

## 🔧 Step 6: Initialize Firebase di main.dart

**File: lib/main.dart**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kede App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Kede App Home'),
    );
  }
}
```

---

## 🔐 Step 7: Firebase Configuration File

**File: lib/config/firebase_config.dart**

```dart
class FirebaseConfig {
  // Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  
  // Storage paths
  static const String profilePhotoPath = 'profile_photos';
  static const String productImagesPath = 'product_images';
  
  // Firestore document fields
  static const String userIdField = 'uid';
  static const String emailField = 'email';
  static const String nameField = 'name';
  static const String createdAtField = 'created_at';
  static const String updatedAtField = 'updated_at';
}
```

---

## 🔑 Step 8: Setup Firestore Database

### 8.1 Buat Firestore Database
```
Di Firebase Console:
1. Klik "Firestore Database" (di menu sebelah kiri)
2. Klik "Create database"
3. Pilih lokasi: asia-southeast1 (Singapore)
4. Pilih mode: Start in test mode (untuk development)
5. Klik "Enable"
```

### 8.2 Buat Collections
```
Klik "Start collection"

Collection 1: users
├─ Document fields:
│  ├─ uid (string)
│  ├─ email (string)
│  ├─ name (string)
│  ├─ profile_photo (string - URL)
│  ├─ phone (string)
│  ├─ role (string - seller/buyer)
│  ├─ created_at (timestamp)
│  └─ updated_at (timestamp)

Collection 2: products
├─ Document fields:
│  ├─ seller_id (string)
│  ├─ name (string)
│  ├─ description (string)
│  ├─ price (number)
│  ├─ image (string - URL)
│  ├─ category (string)
│  ├─ stock (number)
│  ├─ created_at (timestamp)
│  └─ updated_at (timestamp)

(Bisa tambah collection lain sesuai kebutuhan)
```

---

## 🔏 Step 9: Setup Firestore Security Rules

```
Di Firebase Console:
1. Klik "Firestore Database"
2. Klik tab "Rules"
3. Ganti dengan rules di bawah
4. Klik "Publish"
```

### Development Rules (untuk testing)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write untuk semua (DEVELOPMENT ONLY!)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Production Rules (lebih aman)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if true;  // Siapa saja bisa baca
      allow create, update, delete: if request.auth.uid == resource.data.seller_id;
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.buyer_id || 
                     request.auth.uid == resource.data.seller_id;
      allow create: if request.auth != null;
    }
  }
}
```

---

## 🔐 Step 10: Setup Firebase Authentication

### 10.1 Aktifkan Sign-in Methods
```
Di Firebase Console:
1. Klik "Authentication" (di menu sebelah kiri)
2. Klik tab "Sign-in method"
3. Enable providers:
   - Email/Password
   - Google (optional)
   - Phone (optional)
```

### 10.2 Configure Email/Password
```
1. Klik "Email/Password"
2. Enable "Email/Password"
3. Klik "Save"
```

### 10.3 Configure Google Sign-In (Optional)
```
1. Klik "Google"
2. Enable "Google"
3. Masukkan email support project
4. Klik "Save"
```

---

## ✅ Step 11: Test Firebase Connection

### 11.1 Test dari Flutter

**File: lib/test_firebase.dart** (Temporary)
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebase() async {
  try {
    // Test 1: Firebase initialized
    print('✅ Firebase initialized successfully');
    
    // Test 2: Firestore connection
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').limit(1).get();
    print('✅ Firestore connection OK');
    
    // Test 3: Auth state
    final auth = FirebaseAuth.instance;
    print('Current user: ${auth.currentUser}');
    print('✅ Firebase Auth OK');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

// Panggil dari main atau button untuk test
```

### 11.2 Jalankan di Terminal
```bash
flutter run
```

Jika muncul di console:
```
✅ Firebase initialized successfully
✅ Firestore connection OK
✅ Firebase Auth OK
```

Berarti Firebase sudah berhasil terhubung! 🎉

---

## 🔍 Step 12: Troubleshooting

### Error: "google-services.json not found"
```
Solution:
1. Download google-services.json dari Firebase Console
2. Pindahkan ke android/app/
3. Run: flutter clean
4. Run: flutter pub get
5. Run: flutter run
```

### Error: "GoogleService-Info.plist not found"
```
Solution:
1. Download GoogleService-Info.plist dari Firebase Console
2. Buka Xcode: open ios/Runner.xcworkspace
3. Drag file ke Xcode
4. Pastikan "Copy items if needed" tercentang
5. Run: flutter clean
6. Run: flutter run
```

### Error: "PlatformException: com.google.firebase.FirebaseException"
```
Solution:
1. Pastikan Firebase project ID match dengan config
2. Pastikan Firestore sudah dibuat
3. Pastikan Security Rules sudah di-publish
4. Cek internet connection
```

### Error: "FirebaseAuthException: The password is invalid"
```
Solution:
1. Pastikan password minimal 6 karakter
2. Pastikan email valid
3. Pastikan user sudah terdaftar
```

---

## 📝 Summary Langkah Firebase

```
✅ 1. Buat Firebase Project
✅ 2. Setup Android
   └─ Register app
   └─ Download google-services.json
   └─ Update build.gradle
   
✅ 3. Setup iOS (if needed)
   └─ Register app
   └─ Download GoogleService-Info.plist
   └─ Update Podfile
   
✅ 4. Setup Web (if needed)
   └─ Get Firebase config
   
✅ 5. Update pubspec.yaml
   └─ flutter pub get
   
✅ 6. Update main.dart
   └─ Initialize Firebase
   
✅ 7. Setup Firestore
   └─ Create database
   └─ Create collections
   └─ Setup security rules
   
✅ 8. Setup Authentication
   └─ Enable sign-in methods
   
✅ 9. Test Connection
   └─ Jalankan flutter run
   └─ Verifikasi error
```

---

## 🎯 Testing Authentication

### Test Sign Up
```dart
Future<void> testSignUp() async {
  try {
    UserCredential userCredential = 
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "test@example.com",
        password: "password123",
      );
    print('✅ Sign up successful: ${userCredential.user?.email}');
  } catch (e) {
    print('❌ Sign up error: $e');
  }
}
```

### Test Sign In
```dart
Future<void> testSignIn() async {
  try {
    UserCredential userCredential = 
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "test@example.com",
        password: "password123",
      );
    print('✅ Sign in successful: ${userCredential.user?.email}');
  } catch (e) {
    print('❌ Sign in error: $e');
  }
}
```

### Test Firestore Write
```dart
Future<void> testFirestoreWrite() async {
  try {
    await FirebaseFirestore.instance
      .collection('users')
      .doc('test_user')
      .set({
        'name': 'Test User',
        'email': 'test@example.com',
        'created_at': Timestamp.now(),
      });
    print('✅ Firestore write successful');
  } catch (e) {
    print('❌ Firestore write error: $e');
  }
}
```

---

## 🚀 Next Steps

1. ✅ Buat Firebase Project
2. ✅ Setup platform (Android, iOS, Web)
3. ✅ Update pubspec.yaml & main.dart
4. ✅ Setup Firestore & Auth
5. ✅ Test koneksi
6. ✅ Update auth_service.dart & api_service.dart

Setelah semua langkah selesai, app siap untuk menggunakan Firebase! 🎉

---

## 📚 Resources

- Firebase Console: https://console.firebase.google.com
- Firebase Docs: https://firebase.google.com/docs/flutter
- Firestore Docs: https://firebase.google.com/docs/firestore
- Firebase Auth: https://firebase.google.com/docs/auth/flutter

---

**Status**: Step-by-step guide untuk Firebase Connection  
**Updated**: Hari ini  
**Version**: 1.0.0
