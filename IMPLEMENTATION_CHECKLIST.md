# 📋 Checklist Implementasi Firebase

Berikut adalah langkah-langkah yang harus dilakukan untuk menyelesaikan migrasi dari Laravel ke Firebase:

## ✅ Bagian 1: Kode Sudah Diubah (SELESAI)

### Modified Files
- [x] `pubspec.yaml` - Menambahkan Firebase dependencies
- [x] `lib/main.dart` - Menambahkan Firebase initialization
- [x] `lib/services/auth_service.dart` - Konversi ke Firebase Auth
- [x] `lib/services/api_service.dart` - Konversi ke Firestore
- [x] `lib/models/product_model.dart` - Update untuk Firestore compatibility

### New Files Created
- [x] `lib/config/firebase_config.dart` - Firebase configuration
- [x] `lib/config/firebase_options.dart` - Firebase credentials template

### Documentation Created
- [x] `MIGRATION_SUMMARY.md` - Ringkasan perubahan
- [x] `FIREBASE_SETUP_GUIDE.md` - Panduan setup lengkap
- [x] `FIREBASE_QUICKSTART.md` - Quick start guide
- [x] `CODE_CHANGES_EXPLAINED.md` - Penjelasan detail perubahan kode

### Backup Files Created
- [x] `lib/services/auth_service_old.dart` - Original auth service
- [x] `lib/services/api_service_old.dart` - Original API service

---

## 📌 Bagian 2: Yang Harus Anda Lakukan (TODO)

### Step 1: Setup Firebase Project
- [ ] Buat Firebase project di https://console.firebase.google.com/
- [ ] Buat project dengan nama: `kelompok2-prak` (atau nama lain pilihan Anda)
- [ ] Catat Project ID

### Step 2: Setup Firestore Database
- [ ] Enable Cloud Firestore di Firebase Console
- [ ] Pilih "Start in test mode" untuk development
- [ ] Pilih region terdekat dengan Anda
- [ ] Buat collection: `users`
- [ ] Buat collection: `products`
- [ ] (Opsional) Buat collection: `carts`, `orders`, `wishlist`

### Step 3: Setup Authentication
- [ ] Enable "Email/Password" di Firebase Authentication
- [ ] (Opsional) Enable Google Sign-In
- [ ] (Opsional) Enable Facebook Sign-In

### Step 4: Setup Storage
- [ ] Enable Firebase Storage
- [ ] Gunakan lokasi default atau sesuaikan

### Step 5: Download Credentials
- [ ] Download `google-services.json` untuk Android
- [ ] Letakkan di `android/app/google-services.json`
- [ ] Download `GoogleService-Info.plist` untuk iOS (opsional untuk Android-only)

### Step 6: Update firebase_options.dart
- [ ] Buka `lib/config/firebase_options.dart`
- [ ] Copy credentials dari google-services.json:
  - [ ] `apiKey` - Dari "current_key"
  - [ ] `appId` - Dari "mobilesdk_app_id"
  - [ ] `messagingSenderId` - Project number
  - [ ] `projectId` - Project ID
  - [ ] `databaseURL` - Dari console
  - [ ] `storageBucket` - Project ID + ".appspot.com"

### Step 7: Setup Firestore Security Rules
- [ ] Kunjungi Firebase Console → Cloud Firestore → Rules
- [ ] Copy dari `FIREBASE_SETUP_GUIDE.md` → "Firestore Security Rules"
- [ ] Paste ke Firestore Rules editor
- [ ] Klik "Publish"

### Step 8: Setup Storage Security Rules
- [ ] Kunjungi Firebase Console → Storage → Rules
- [ ] Copy dari `FIREBASE_SETUP_GUIDE.md` → "Firebase Storage Security Rules"
- [ ] Paste ke Storage Rules editor
- [ ] Klik "Publish"

### Step 9: Test Setup
- [ ] Buka terminal di project folder
- [ ] Jalankan: `flutter clean`
- [ ] Jalankan: `flutter pub get`
- [ ] Jalankan: `flutter run`
- [ ] Lihat apakah app berjalan tanpa error Firebase

### Step 10: Test Functionality
- [ ] Test Sign Up dengan email baru
- [ ] Cek Firestore → users collection (harus ada dokumen baru)
- [ ] Test Sign In dengan akun yang sudah dibuat
- [ ] Test Home Page bisa load (mungkin produk kosong)
- [ ] Cek console logs untuk error

---

## 🔧 Struktur File-File Penting

```
kelompok2prak/
├── android/
│   └── app/
│       └── google-services.json  ← HARUS DITAMBAHKAN!
│
├── lib/
│   ├── config/
│   │   ├── firebase_config.dart         ✅ BARU
│   │   ├── firebase_options.dart        ✅ BARU (PERLU DIISI)
│   │   └── api_config.dart              (masih ada, untuk referensi)
│   │
│   ├── services/
│   │   ├── auth_service.dart            ✅ DIUBAH (Firebase)
│   │   ├── auth_service_old.dart        (backup)
│   │   ├── api_service.dart             ✅ DIUBAH (Firestore)
│   │   └── api_service_old.dart         (backup)
│   │
│   ├── models/
│   │   └── product_model.dart           ✅ DIUBAH
│   │
│   └── main.dart                        ✅ DIUBAH
│
├── pubspec.yaml                         ✅ DIUBAH
│
├── MIGRATION_SUMMARY.md                 ✅ BARU (BACA INI)
├── FIREBASE_SETUP_GUIDE.md              ✅ BARU (BACA INI)
├── FIREBASE_QUICKSTART.md               ✅ BARU (BACA INI)
└── CODE_CHANGES_EXPLAINED.md            ✅ BARU (UNTUK REFERENSI)
```

---

## 🚀 Quick Reference

### Credentials dari google-services.json
```json
{
  "project_info": {
    "project_id": "YOUR_PROJECT_ID",        ← projectId
    "project_number": "123456789"           ← messagingSenderId
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:123456789:android:xyz"  ← appId
    },
    "api_key": [{"current_key": "AIzaSy..."}]        ← apiKey
  }]
}
```

### URLs
```
- databaseURL: https://YOUR_PROJECT_ID.firebaseio.com
- storageBucket: YOUR_PROJECT_ID.appspot.com
- Console: https://console.firebase.google.com/
```

---

## 📊 Status Summary

| Komponen | Status | Keterangan |
|----------|--------|-----------|
| Code Migration | ✅ SELESAI | Semua file sudah diubah ke Firebase |
| Documentation | ✅ SELESAI | 4 file dokumentasi sudah dibuat |
| Firebase Setup | ❌ TODO | Perlu setup project Firebase |
| Credentials | ❌ TODO | Perlu download google-services.json |
| Testing | ❌ TODO | Perlu test setelah setup selesai |
| Data Migration | ❌ OPTIONAL | Hanya jika ada data di Laravel |

---

## ⚠️ PENTING - Jangan Lupa!

1. **Credentials adalah SECRET** 
   - Jangan commit `google-services.json` ke git
   - Jangan commit `firebase_options.dart` dengan credentials real
   - Tambahkan ke `.gitignore`:
     ```
     **/google-services.json
     ```

2. **Test Mode vs Production**
   - Gunakan "test mode" untuk development
   - Sebelum production, setup proper security rules!

3. **Cost**
   - Firebase memiliki free tier yang cukup generous
   - Monitor usage di Firebase Console

4. **Offline Support**
   - Firebase SDK auto-support offline
   - Data akan sync ketika online kembali

---

## 📚 Referensi Dokumentasi

| File | Isi |
|------|-----|
| MIGRATION_SUMMARY.md | Ringkasan perubahan file |
| FIREBASE_SETUP_GUIDE.md | Panduan setup Firebase lengkap |
| FIREBASE_QUICKSTART.md | Quick start 5 langkah |
| CODE_CHANGES_EXPLAINED.md | Penjelasan detail kode yang berubah |

---

## 🆘 Jika Ada Masalah

### Error: "Firebase.initializeApp() was not called"
```
Solusi: Pastikan credentials di firebase_options.dart sudah benar
```

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"
```
Solusi: Update Firestore Security Rules di Firebase Console
```

### Error: "INVALID_API_KEY"
```
Solusi: Pastikan apiKey di firebase_options.dart benar dari google-services.json
```

### Photo tidak muncul
```
Solusi: Check Storage Security Rules memungkinkan read access
```

### Data tidak tersimpan
```
Solusi: 1. Cek apakah collection exists di Firestore
         2. Cek Firestore Security Rules
         3. Lihat console logs untuk error detail
```

---

## 💡 Saran

1. **Start dengan Android**
   - Lebih mudah testing di emulator
   - iOS bisa ditambahkan nanti

2. **Use Test Mode dulu**
   - Semua user/data bisa diakses
   - Bagus untuk development
   - Sebelum production, tighten security rules

3. **Monitor Firestore Usage**
   - Firebase Console → Firestore → Usage
   - Free tier pretty generous
   - Lihat data cost untuk setiap operasi

4. **Setup Backup**
   - Firestore tidak auto-backup
   - Gunakan Firebase Backup untuk production
   - Atau setup Cloud Functions untuk export data

---

## ✨ Next Steps Setelah Firebase Running

1. **Implementasi Realtime Updates**
   ```dart
   // Listen to products in real-time
   _firestore.collection('products').snapshots()
   ```

2. **Setup Offline Support**
   ```dart
   // Already enabled by default in Firebase SDK
   // Data auto-synced when online
   ```

3. **Add More Auth Methods**
   - Google Sign-In
   - Facebook Login
   - Phone Auth

4. **Setup Cloud Functions**
   - Backend logic tanpa maintain server
   - Trigger dari Firestore events

5. **Implement Search & Filtering**
   - Firestore query lebih powerful
   - Full-text search dengan Algolia (opsional)

---

**Happy Coding! 🎉**

Jika ada pertanyaan, refer ke dokumentasi Firebase:
https://firebase.flutter.dev/
