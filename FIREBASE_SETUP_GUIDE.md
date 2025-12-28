# Panduan Implementasi Firebase Backend

## Ringkasan Perubahan
Proyek ini telah dikonversi dari menggunakan backend Laravel ke Firebase (Firestore + Firebase Auth + Firebase Storage).

## File-File yang Telah Diubah

### 1. **pubspec.yaml**
Menambahkan dependensi Firebase:
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_storage: ^12.0.0
```

### 2. **lib/config/firebase_config.dart** (BARU)
Konfigurasi Firebase dengan collection names dan storage paths

### 3. **lib/config/firebase_options.dart** (BARU)
File template untuk Firebase initialization credentials

### 4. **lib/services/auth_service.dart**
Dikonversi dari HTTP Laravel ke Firebase Authentication:
- `signIn()` → Firebase Auth
- `signUp()` → Firebase Auth + Firestore
- `forgotPassword()` → Firebase Auth
- `uploadPhotoToBackend()` → Firebase Storage + Firestore
- `updatePhoneOnBackend()` → Firestore

### 5. **lib/services/api_service.dart**
Dikonversi dari HTTP REST ke Firestore:
- `getProducts()` → Firestore query
- `createProduct()` → Firestore document + Firebase Storage
- `updateProduct()` → Firestore update
- `deleteProduct()` → Firestore delete

### 6. **lib/models/product_model.dart**
Diperbarui untuk kompatibel dengan Firestore:
- `id` berubah dari `int?` ke `String`
- Menambahkan `sellerId` dan `createdAt`

### 7. **lib/main.dart**
Menambahkan Firebase initialization di main():
```dart
await FirebaseConfig.initialize();
```

## Langkah-Langkah Setup

### 1. Setup Firebase Project

#### a. Buat Firebase Project
1. Kunjungi [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add Project"
3. Masukkan nama project (misalnya "kelompok2-prak")
4. Pilih lokasi region
5. Klik "Create Project"

#### b. Aktifkan Firestore Database
1. Di Firebase Console, pilih project Anda
2. Klik "Cloud Firestore" di sidebar
3. Klik "Create Database"
4. Pilih mode "Start in production mode" atau "Start in test mode"
5. Pilih lokasi region
6. Klik "Create Database"

#### c. Aktifkan Authentication
1. Di Firebase Console, pilih "Authentication"
2. Klik "Get Started"
3. Pilih "Email/Password" provider
4. Aktifkan Email/Password authentication

#### d. Setup Storage
1. Di Firebase Console, pilih "Storage"
2. Klik "Get Started"
3. Baca terms dan klik "Got it"
4. Gunakan lokasi default atau ubah sesuai kebutuhan

### 2. Setup Android
1. Buka Firebase Console untuk project Anda
2. Klik ⚙️ Settings
3. Di tab "General", scroll ke "Your apps" section
4. Klik "Android" untuk menambah app Android
5. Masukkan:
   - Package name: `com.example.kelompok2` (sesuaikan dengan AndroidManifest.xml Anda)
   - Debug SHA-1: Jalankan `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
6. Download `google-services.json`
7. Letakkan di folder `android/app/`
8. Build project

### 3. Setup iOS
1. Di Firebase Console untuk project Anda, klik "iOS" di "Your apps"
2. Masukkan:
   - Bundle ID: `com.example.kelompok2` (atau sesuai Info.plist)
3. Download `GoogleService-Info.plist`
4. Buka `ios/Runner.xcworkspace` (bukan .xcodeproj)
5. Drag `GoogleService-Info.plist` ke Xcode project
6. Pastikan "Copy items if needed" terchecklist

### 4. Update firebase_options.dart
Isi konfigurasi Firebase Anda di `lib/config/firebase_options.dart`:

```dart
// Untuk Android
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY', // dari google-services.json
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  databaseURL: 'https://YOUR_PROJECT_ID.firebaseio.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

Dapatkan nilai-nilai ini dari:
- `google-services.json` (untuk Android)
- `GoogleService-Info.plist` (untuk iOS)
- Firebase Console

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Setup Firestore Collections

#### a. Users Collection
Buat collection bernama "users" dengan struktur dokumen:
```
users/{uid}
├── id: string (uid)
├── email: string
├── first_name: string
├── last_name: string
├── phone: string
├── profile_photo: string (nullable, URL from Firebase Storage)
├── created_at: timestamp
└── updated_at: timestamp
```

#### b. Products Collection
Buat collection bernama "products" dengan struktur dokumen:
```
products/{productId}
├── name: string
├── description: string
├── price: number
├── category: string
├── stock: number
├── image: string (nullable, URL from Firebase Storage)
├── seller_id: string (referensi ke uid user)
├── created_at: timestamp
└── updated_at: timestamp
```

#### c. Carts Collection (opsional)
```
carts/{cartId}
├── user_id: string
├── product_id: string
├── quantity: number
├── created_at: timestamp
└── updated_at: timestamp
```

### 7. Firestore Security Rules

Update security rules di Firebase Console:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Anyone can read products
    match /products/{productId} {
      allow read: if true;
      // Only seller can update/delete
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.seller_id;
    }
    
    // Carts are private to user
    match /carts/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.user_id;
    }
    
    // Allow authenticated users to upload files
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 8. Firebase Storage Security Rules

Update storage rules di Firebase Console:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow read access to all files
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Struktur Firestore yang Direkomendasikan

### Collections:
1. **users** - Menyimpan data user
2. **products** - Menyimpan katalog produk
3. **carts** - Menyimpan shopping cart items
4. **orders** - Menyimpan order history
5. **wishlist** - Menyimpan wishlist items

### Storage Paths:
- `/profile-photos/{userId}_timestamp.jpg` - Foto profil user
- `/product-images/{productId}_timestamp.jpg` - Gambar produk

## Migrasi Data dari Laravel

Jika Anda memiliki data di Laravel:

### Mengekspor dari Laravel:
```bash
# Di Laravel project
php artisan tinker

# Export users
$users = User::all();
$users->each(function($user) {
    echo json_encode([
        'id' => $user->id,
        'email' => $user->email,
        'first_name' => $user->first_name,
        'last_name' => $user->last_name,
        'phone' => $user->phone,
    ]) . "\n";
});
```

### Import ke Firebase:
Gunakan Firebase Admin SDK (Node.js / Python) untuk bulk import.

## Fitur-Fitur Penting

### Authentication
- ✅ Sign in dengan email/password
- ✅ Sign up/Register
- ✅ Forgot password (password reset email)
- ✅ Automatic session management
- ✅ Profile photo upload

### Products
- ✅ Get all products
- ✅ Get product detail
- ✅ Create product (seller)
- ✅ Update product (seller)
- ✅ Delete product (seller)
- ✅ Category filtering

### User Profile
- ✅ Get user profile
- ✅ Update phone number
- ✅ Upload profile photo
- ✅ Delete profile photo

## Testing

### Test Authentication
```dart
// Sign up
await ApiService.register(
  'John', 'Doe', 'john@example.com', 'password123', 'password123'
);

// Sign in
await ApiService.signIn('john@example.com', 'password123');
```

### Test Products
```dart
// Get all products
await ApiService.getProducts();

// Create product
await ApiService.createProduct(
  name: 'Apple',
  description: 'Fresh red apples',
  price: 10000,
  category: 'Fruits',
  stock: 100,
);
```

## Troubleshooting

### Issue: Firebase not initialized
```
Error: Firebase.initializeApp() not called
```
**Solusi**: Pastikan `FirebaseConfig.initialize()` dipanggil di main() sebelum runApp()

### Issue: Firestore permission denied
```
Error: PERMISSION_DENIED: Missing or insufficient permissions
```
**Solusi**: Update Firestore security rules di Firebase Console

### Issue: Storage upload fails
```
Error: User is not authenticated
```
**Solusi**: Pastikan user sudah login sebelum upload file

### Issue: Image tidak tampil dari URL
```
URL dari Firebase Storage tidak accessible
```
**Solusi**: Periksa Firebase Storage security rules dan pastikan allow read access

## Referensi

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Plugin](https://firebase.flutter.dev/)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

## Backup File Lama

File-file backend Laravel lama telah disimpan dengan suffix `_old`:
- `lib/services/api_service_old.dart`
- `lib/services/auth_service_old.dart`
- `lib/config/api_config.dart` (masih ada untuk referensi)

Anda bisa menghapus file-file ini setelah yakin dengan implementasi Firebase baru.
