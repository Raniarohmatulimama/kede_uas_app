# 🔥 FIREBASE SETUP - QUICK REFERENCE CARD

**Print this or save untuk reference** 📋

---

## 🎯 15-STEP QUICK SETUP

### PHASE 1: Create Firebase Project (5 min)

```
1. Buka: https://console.firebase.google.com
2. Klik: Create a new project
3. Nama: kede_app
4. Klik: Create project
5. Tunggu: ~2 menit
```

### PHASE 2: Setup Android (5 min)

```
6. Klik: Android (icon) → Register app
7. Package Name: com.example.kelompok2
8. Download: google-services.json
9. Pindahkan: ke android/app/
10. Update: android/build.gradle.kts & android/app/build.gradle.kts
```

### PHASE 3: Setup Flutter (3 min)

```
11. flutter pub get
12. Update main.dart (import & initialize Firebase)
13. flutter run (test)
```

### PHASE 4: Setup Firestore & Auth (5 min)

```
14. Buat Firestore Database (asia-southeast1)
15. Enable Email/Password Auth
```

---

## 📝 FILE YANG PERLU DIUBAH

### ✅ android/build.gradle.kts

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}
```

### ✅ android/app/build.gradle.kts

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // ← ADD
}

dependencies {
    implementation("com.google.firebase:firebase-core:32.5.0")
    implementation("com.google.firebase:firebase-auth:22.3.0")
    implementation("com.google.firebase:firebase-firestore:24.10.0")
    implementation("com.google.firebase:firebase-storage:20.3.0")
}
```

### ✅ lib/main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## 🔗 PENTING LINKS

```
Firebase Console:
https://console.firebase.google.com

Docs:
https://firebase.google.com/docs/flutter

Flutter Docs:
https://flutter.dev/docs
```

---

## ⚡ QUICK COMMANDS

```bash
# Clean & update
flutter clean
flutter pub get

# Run app
flutter run

# Check logs
flutter logs

# Build APK (release)
flutter build apk --release
```

---

## 📍 KEY FOLDERS

```
Project Root:
d:\9.5 MWS PRAK\kelompok2prak\

Android Config:
├── android/build.gradle.kts          ← Update
├── android/app/build.gradle.kts      ← Update
└── android/app/google-services.json  ← Add (from download)

Flutter Config:
├── lib/main.dart                      ← Update
├── lib/config/firebase_config.dart    ← Sudah ada
└── pubspec.yaml                       ← Sudah updated
```

---

## 🚨 ERROR QUICK FIX

| Error | Solution |
|-------|----------|
| google-services.json not found | Download & pindahkan ke android/app/ |
| FirebaseException | Pastikan Firestore database dibuat |
| gradle build failed | flutter clean, flutter pub get |
| Import not found | flutter pub get |

---

## ✅ VERIFICATION CHECKLIST

```
BEFORE FLUTTER RUN:
☐ google-services.json di android/app/
☐ build.gradle files updated
☐ flutter pub get success
☐ main.dart updated
☐ Firestore database created
☐ Auth enabled

AFTER FLUTTER RUN:
☐ App buka tanpa error
☐ "[Firebase] Initialization completed" di logs
☐ Bisa sign up/sign in
☐ Data muncul di Firebase Console
```

---

## 📊 FIREBASE SERVICES YANG DIGUNAKAN

```
1. Authentication
   - Email/Password login
   - User management

2. Firestore Database
   - Store: users, products, orders
   - Real-time sync

3. Firebase Storage (legacy)
   - Phasing out (replaced with Cloudinary)

4. Cloud Functions (optional)
   - Backend logic
```

---

## 🎯 AFTER FIREBASE SETUP

1. Test Auth:
   ```dart
   // Sign up
   FirebaseAuth.instance.createUserWithEmailAndPassword(...)
   
   // Sign in
   FirebaseAuth.instance.signInWithEmailAndPassword(...)
   ```

2. Test Firestore:
   ```dart
   // Write
   FirebaseFirestore.instance.collection('users').add({...})
   
   // Read
   FirebaseFirestore.instance.collection('users').get()
   ```

3. Profile photos → Cloudinary
4. Product images → Cloudinary

---

## 📚 FULL GUIDES

For detailed steps, see:
- `FIREBASE_SETUP_CHECKLIST.md` - Complete step-by-step
- `FIREBASE_VISUAL_GUIDE.md` - Visual diagrams
- `FIREBASE_CONNECTION_SETUP.md` - Detailed guide

---

## 💡 TIPS

✅ **Do:**
- Use asia-southeast1 location (closer to user)
- Enable test mode for development
- Check Firebase Console often
- Use proper security rules

❌ **Don't:**
- Don't hardcode API keys
- Don't commit google-services.json to public repo
- Don't use production rules in development
- Don't skip pub get after adding packages

---

**Setup Time**: ~20 minutes  
**Difficulty**: ⭐⭐ (Easy)  
**Status**: Ready for app development 🚀

Print this page atau bookmark untuk reference! 📌
