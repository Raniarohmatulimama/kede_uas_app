# Firebase Setup - Quick Start

## 5 Langkah Cepat untuk Menjalankan

### Step 1: Download google-services.json

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik Project Anda → ⚙️ Project Settings
3. Tab "Your apps" → Klik Android
4. Download `google-services.json`
5. Letakkan di: `android/app/google-services.json`

### Step 2: Update firebase_options.dart

Edit `lib/config/firebase_options.dart`:

**Dari `google-services.json`, ambil nilai ini:**
```json
{
  "project_info": {
    "project_id": "YOUR_PROJECT_ID",
    "project_number": "YOUR_PROJECT_NUMBER",
    "name": "YOUR_PROJECT_NAME"
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "YOUR_APP_ID",
      "client_id": "YOUR_CLIENT_ID"
    },
    "api_key": [{
      "current_key": "YOUR_API_KEY"
    }],
    "services": {
      "appinvite_service": {
        "other_platform_oauth_client_id": "YOUR_OTHER_PLATFORM_ID"
      }
    }
  }],
  "configuration_version": "1"
}
```

**Kemudian update file `lib/config/firebase_options.dart`:**

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyB...', // Dari "current_key" di google-services.json
  appId: '1:123456789:android:abcd...', // mobilesdk_app_id
  messagingSenderId: '123456789', // project_number
  projectId: 'kelompok2-prak', // project_id
  databaseURL: 'https://kelompok2-prak.firebaseio.com',
  storageBucket: 'kelompok2-prak.appspot.com',
);
```

### Step 3: Setup Firestore Collections

Di Firebase Console:
1. Klik "Cloud Firestore" → "Create Database"
2. Pilih "Start in test mode" (untuk development)
3. Pilih lokasi region terdekat

**Buat Collection "users":**
```
Collection: users
├── Document: {uid}
│   ├── id: "uid"
│   ├── email: "user@example.com"
│   ├── first_name: "John"
│   ├── last_name: "Doe"
│   ├── phone: ""
│   ├── profile_photo: null
│   ├── created_at: timestamp
│   └── updated_at: timestamp
```

**Buat Collection "products":**
```
Collection: products
├── Document: {productId}
│   ├── name: "Apple"
│   ├── description: "Fresh apples"
│   ├── price: 10000
│   ├── category: "Fruits"
│   ├── stock: 100
│   ├── image: "https://..."
│   ├── seller_id: "uid"
│   ├── created_at: timestamp
│   └── updated_at: timestamp
```

### Step 4: Setup Firestore Security Rules

Di Firebase Console → Firestore → Rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Products
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.seller_id;
    }
    
    // Default - deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 5: Setup Storage Security Rules

Di Firebase Console → Storage → Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Install & Run

```bash
# Clear build cache
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run
```

## Test Aplikasi

### Test Sign Up
1. Buka app
2. Klik "Create Account"
3. Isi form dengan email baru
4. Klik "Create"
5. Cek Firestore → users collection (harus ada dokumen baru)

### Test Sign In
1. Klik "Sign In"
2. Masukkan email dan password dari akun yang sudah dibuat
3. Seharusnya masuk ke HomePage

### Test Products
1. Setelah login, lihat halaman Home
2. Akan menampilkan produk dari Firestore (mungkin kosong jika belum ada data)

### Test Profile Photo Upload
1. Masuk ke User Profile
2. Upload foto
3. Foto akan disimpan di Firebase Storage
4. URL akan tersimpan di Firestore users collection

## Troubleshooting Cepat

**Error: "Firebase.initializeApp() was not called"**
→ Pastikan credentials di `firebase_options.dart` sudah benar

**Error: "PERMISSION_DENIED"**
→ Update Firestore Security Rules (ikuti Step 4)

**Error: "INVALID_API_KEY"**
→ Pastikan API Key di `firebase_options.dart` benar dari `google-services.json`

**Foto tidak muncul**
→ Pastikan Storage Rules allow read access (Step 5)

**Data tidak tersimpan**
→ Cek apakah collection "products" sudah ada di Firestore

## Tips Debugging

### Lihat Console Log
```bash
flutter run -v  # Verbose logging
```

### Lihat Firestore Data Real-time
- Buka Firebase Console
- Klik Firestore
- Lihat data real-time dari app Anda

### Lihat Storage Upload
- Buka Firebase Console  
- Klik Storage
- Lihat uploaded files di folder `profile-photos/` dan `product-images/`

## Next Steps

Setelah basic setup berjalan:
1. Setup Authentication methods lain (Google, Facebook)
2. Implement Firestore offline support
3. Setup Cloud Functions untuk backend logic
4. Setup Firebase Hosting untuk web

Lihat `FIREBASE_SETUP_GUIDE.md` untuk dokumentasi lengkap.
