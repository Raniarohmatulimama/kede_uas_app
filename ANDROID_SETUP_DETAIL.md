# Setup Firebase untuk Android - Detail

## Prerequisites

- Android Studio installed
- Flutter SDK installed
- Git (untuk version control)
- Firebase project sudah dibuat

---

## Step 1: Download google-services.json

### Dari Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik project Anda
3. Klik ⚙️ **Project Settings** (gear icon)
4. Buka tab **"Your apps"**
5. Lihat section **"Your apps"** → Klik app Android Anda
6. Jika belum ada, klik **"Add app"** dan pilih **"Android"**

### Setup Android App

Jika menambah app baru:

```
1. Package name: com.example.kelompok2
   (sesuaikan dengan package di AndroidManifest.xml)
   
2. Debug signing certificate SHA-1:
   a. Buka Terminal
   b. Jalankan:
      Windows:
      keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" ^
        -alias androiddebugkey -storepass android -keypass android
      
      Mac/Linux:
      keytool -list -v -keystore ~/.android/debug.keystore \
        -alias androiddebugkey -storepass android -keypass android
   
   c. Copy SHA-1 value (format: XX:XX:XX:...)
   d. Paste ke Firebase Console
   
3. App nickname: kelompok2-app (opsional)
```

### Download File

7. Scroll ke section **"google-services.json"**
8. Klik **Download "google-services.json"**
9. File akan di-download

---

## Step 2: Letakkan google-services.json

### File Location

```
kelompok2prak/
└── android/
    └── app/
        └── google-services.json  ← Letakkan di sini!
```

**PENTING**: Jangan rename file, harus persis `google-services.json`

---

## Step 3: Update build.gradle Files

### android/build.gradle

Buka file `android/build.gradle`:

```gradle
// Di section buildscript → dependencies, tambahkan:
dependencies {
  classpath 'com.google.gms:google-services:4.3.15'  // Tambah ini!
}

buildscript {
  // ... existing code ...
}
```

### android/app/build.gradle

Buka file `android/app/build.gradle`:

```gradle
// Di paling akhir file (sebelum closing brace), tambahkan:
apply plugin: 'com.google.gms.google-services'  // Tambah ini!

dependencies {
  // ... existing dependencies ...
  
  // Firebase Core
  implementation 'com.google.firebase:firebase-core:21.1.1'
  
  // Jika menggunakan specific Firebase services:
  implementation 'com.google.firebase:firebase-auth:21.0.8'
  implementation 'com.google.firebase:firebase-firestore:24.7.0'
  implementation 'com.google.firebase:firebase-storage:20.2.0'
}
```

---

## Step 4: Verify Package Name

Buka `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.kelompok2">  ← Pastikan sama dengan Firebase!
```

Package name di sini HARUS sama dengan yang didaftar di Firebase Console!

---

## Step 5: Update flutter_local_notifications (jika digunakan)

Jika app menggunakan notifications, tambahkan ke `AndroidManifest.xml`:

```xml
<application>
    <!-- ... existing tags ... -->
    
    <service
        android:name="io.flutter.embedding.engine.FlutterEngineCache"
        android:enabled="true"
        android:exported="false" />
</application>
```

---

## Step 6: Sync & Build

### Clean & Sync

```bash
cd kelompok2prak

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Update Gradle files
cd android
./gradlew clean  # Windows: gradlew.bat clean
cd ..
```

### Verify Integration

```bash
# Check if google-services.json is recognized
flutter packages get
```

Anda seharusnya TIDAK melihat error tentang google-services.json

---

## Step 7: Update firebase_options.dart

Edit `lib/config/firebase_options.dart`:

### Ambil Value dari google-services.json

Buka file `android/app/google-services.json`:

```json
{
  "type": "service_account",
  "project_id": "kelompok2-prak",  ← PROJECT_ID
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----...",
  "client_email": "firebase-adminsdk-xyz@kelompok2-prak.iam.gserviceaccount.com",
  "client_id": "123456789",  ← CLIENT_ID
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xyz%40kelompok2-prak.iam.gserviceaccount.com"
}
```

Juga lihat di Firebase Console → Project Settings:

```
Project ID: kelompok2-prak
Web API Key: AIzaSy...
Project Number: 123456789
Storage Bucket: kelompok2-prak.appspot.com
```

### Update android Option

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyB1234567890...',  // Dari google-services.json
                                    // Atau dari Firebase Console
  
  appId: '1:123456789:android:abcd1234567890ef',  // mobilesdk_app_id
                                                   // dari google-services.json
  
  messagingSenderId: '123456789',  // project_number
  
  projectId: 'kelompok2-prak',  // project_id
  
  databaseURL: 'https://kelompok2-prak.firebaseio.com',
  
  storageBucket: 'kelompok2-prak.appspot.com',
);
```

---

## Step 8: Test Build

### Build APK

```bash
flutter build apk --debug

# Output: build/app/outputs/flutter-apk/app-debug.apk
```

Jika success, berarti integration berhasil!

### Debug Output

Jika ada error, check:

```bash
flutter run -v  # Verbose mode untuk lihat detail
```

---

## Step 9: First Run

```bash
flutter run
```

### Expected Console Output

```
[INFO] Connected to: emulator-5554 (Android)
[INFO] Using hardware rendering with device AOSP on IA Emulator.
...
[Firebase/Core] I-COR000000: Initializing Google Mobile Ads SDK... (note: Firebase SDK not initialized yet)
[Firebase/Core] I-COR000010: Google Mobile Ads SDK initialization complete.
```

Atau di logcat:

```
I/Choreographer: Skipped X frames!
D/FirebaseCore: Finished initialization
I/Flutter: [Firebase] Initialization completed successfully
```

---

## Troubleshooting

### Error 1: "google-services.json not found"

```
Error: File not found at android/app/google-services.json
```

**Solusi:**
- Pastikan file di path yang benar: `android/app/google-services.json`
- Nama file persis `google-services.json` (case-sensitive di Mac/Linux)
- Jangan di-rename

### Error 2: "Package name doesn't match"

```
Error: Package name in AndroidManifest.xml doesn't match Firebase app
```

**Solusi:**
- Edit `android/app/src/main/AndroidManifest.xml`
- Ubah package ke match Firebase project
- Atau re-register app di Firebase dengan package name yang ada

### Error 3: "SHA-1 doesn't match"

```
Error: This key doesn't match any registered SHA keys
```

**Solusi:**
- Di Firebase Console, lihat SHA-1 yang terdaftar
- Copy SHA-1 dari `keytool` command
- Edit di Firebase Console Project Settings
- Atau gunakan command keytool lagi dengan benar

### Error 4: "Plugin not found"

```
Error: Plugin 'com.google.gms.google-services' not found
```

**Solusi:**
- Pastikan `apply plugin: 'com.google.gms.google-services'` di `android/app/build.gradle`
- Pastikan classpath di `android/build.gradle` sudah ditambah
- Run `flutter clean` dan `flutter pub get` lagi

### Error 5: "API Key invalid"

```
Error: API key is not valid for use with Google Firebase APIs
```

**Solusi:**
- Pastikan apiKey di `firebase_options.dart` dari `google-services.json`
- Check typo (copy-paste dari file, jangan manual)
- Atau ambil dari Firebase Console → API Keys

---

## Verification Checklist

- [ ] `android/app/google-services.json` exists
- [ ] Package name matches Firebase
- [ ] `android/build.gradle` has google-services plugin in buildscript
- [ ] `android/app/build.gradle` has:
  - apply plugin: 'com.google.gms.google-services'
  - Firebase dependencies
- [ ] `firebase_options.dart` has correct credentials
- [ ] `flutter clean` ran
- [ ] `flutter pub get` ran successfully
- [ ] `flutter build apk --debug` builds without error
- [ ] Console shows Firebase initialization log
- [ ] App runs without Firebase-related errors

---

## Add Permissions (if needed)

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet permission (required for Firebase) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- For Firestore -->
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    
    <!-- For Storage access (if needed) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- For image_picker package -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

---

## Testing Firebase Connection

Tambahkan ke `main()` untuk verify:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await FirebaseConfig.initialize();
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    rethrow;
  }
  
  runApp(...);
}
```

---

## Next: Setup iOS (Optional)

Lihat dokumentasi terpisah untuk iOS setup jika diperlukan.

---

**Android setup selesai!** 🎉

Next: Jalankan app dan test dengan `flutter run`
