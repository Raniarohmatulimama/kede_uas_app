# Firestore Security Rules - Versi Lengkap dengan Chat Feature

Ini adalah rules lengkap yang menggabungkan semua existing rules + chat feature baru.

## Cara Set di Firebase Console:

1. Buka **Firebase Console** → Pilih project Anda
2. Masuk ke **Firestore Database** → Tab **Rules**
3. **Ganti** semua kode dengan rules di bawah ini
4. **Publish**

## Security Rules - Versi Lengkap:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: hanya pemilik akun boleh baca/tulis dokumen mereka (PRIVATE)
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Saved cards subcollection
      match /savedCards/{cardId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Shipping addresses subcollection
      match /shippingAddresses/{addressId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Products: Baca publik. Tulis hanya oleh pemilik (seller_id == uid)
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.seller_id == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.seller_id == request.auth.uid;
    }

    // Carts: hanya pemilik yang boleh akses
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Orders: hanya pemilik yang boleh akses
    match /orders/{orderId} {
      allow read, write: if request.auth != null && (
        (request.resource.data.userId == request.auth.uid) ||
        (resource.data.userId == request.auth.uid)
      );
    }

    // Payments: hanya pemilik yang boleh akses
    match /payments/{paymentId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Ratings: baca publik, tulis hanya user yang login
    match /ratings/{ratingId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Notifications: hanya pemilik yang boleh baca/tulis
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    // Wishlist: hanya pemilik yang boleh akses
    match /wishlist/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // ========== CHAT FEATURE (BARU) ==========
    // Chats: hanya participant dalam chat yang bisa baca/tulis
    match /chats/{chatId} {
      allow read: if request.auth != null && 
                     request.auth.uid in resource.data.participants;
      allow create: if request.auth != null &&
                       request.auth.uid in request.resource.data.participants &&
                       request.resource.data.participants.size() == 2;
      allow update: if request.auth != null &&
                       request.auth.uid in resource.data.participants;

      // Messages subcollection: hanya participant yang bisa baca, pengirim bisa tulis
      match /messages/{messageId} {
        allow read: if request.auth != null &&
                       request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null &&
                         request.auth.uid == request.resource.data.senderId &&
                         request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

## Perubahan dari Rules Sebelumnya:

### ✅ **KEAMANAN PROFIL** (DIUPDATE)
```javascript
// Sebelum: allow read: if true;  (publik bisa baca)
// Sekarang: allow read, write: if request.auth != null && request.auth.uid == userId;
```
Alasan: **Profil hanya bisa dilihat pemiliknya sendiri** (lebih aman).

Untuk **add friend**: User tinggal **copy-paste User ID mereka** ke teman. User ID adalah string publik yang aman, tidak ada data sensitif di dalamnya.

### ✅ **CHAT FEATURE - TETAP AMAN**
Saat membuat chat:
- App tidak perlu baca profil user lain (sudah aman private)
- Cukup gunakan User ID untuk membuat chat
- Nama teman bisa di-update nanti saat first chat message atau dari local cache

### ✅ **KEAMANAN DATA CHAT**
- Hanya 2 participant yang bisa akses chat
- Pesan hanya bisa dibaca participant
- Hanya pengirim yang bisa send message

---

## Langkah-langkah Implementasi:

### **Step 1: Update Firestore Security Rules**

1. **Login ke Firebase Console**: https://console.firebase.google.com/
2. **Pilih Project**: Pilih proyek Anda (kelompok2)
3. **Firestore Database**: Klik di sidebar
4. **Rules Tab**: Klik tab "Rules" di bagian atas
5. **Copy & Paste**: Salin seluruh rules di atas ke editor
6. **Publish**: Klik tombol "Publish"
7. **Tunggu**: 1-2 menit untuk rules ter-deploy

### **Step 2: Upload Gambar Chat via Cloudinary** ✅ **SUDAH INTEGRATED**

Gambar chat akan diupload ke **Cloudinary** (bukan Firebase Storage):

**Setup sudah lengkap:**
- ✅ Cloudinary cloud name: `duqcxzhkr`
- ✅ Upload preset: `kede_app`
- ✅ Code sudah integrated di `lib/message_page.dart`
- ✅ Tidak perlu setup Firebase Storage Rules

**Flow Upload Gambar Chat:**
1. User tap ikon foto di chat
2. Pilih gambar dari gallery
3. App upload ke Cloudinary API langsung
4. Dapatkan Cloudinary URL (https://res.cloudinary.com/...)
5. Simpan URL di Firestore messages
6. Gambar muncul di chat dengan CDN fast delivery ✅

**Test Upload Gambar:**
- Buka chat dengan teman
- Tap ikon foto (gallery icon)
- Pilih gambar
- Cek Logcat: Harus ada `[Chat] Image uploaded to Cloudinary: ...`
- Gambar muncul di chat ✅

---

### **Step 3: Buat Firestore Composite Index** ⚠️ **PENTING**

Saat pertama kali run app, Anda akan melihat error di Logcat:
```
The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/...
```

**Solusi - Ada 2 Cara:**

#### **Cara A: Auto-create via Link** (TERCEPAT) ⭐
1. **Copy link lengkap** dari error log di Logcat
2. **Paste ke browser** dan tekan Enter
3. Firebase Console akan terbuka otomatis dengan form index
4. Klik tombol **"Create Index"**
5. Tunggu sampai status **"Enabled"** (biasa 5-10 menit)
6. **Hot restart app** atau tutup & buka kembali app

#### **Cara B: Manual di Firebase Console**
1. Buka **Firebase Console** → **Firestore Database** → Tab **"Indexes"**
2. Klik **"Create Index"**
3. Isi form:
   - **Collection ID**: `chats`
   - **Fields to index**:
     - Field path: `participants` | Index type: **Array** | Order: (leave blank)
     - Field path: `updatedAt` | Index type: **Descending**
4. Klik **"Create Index"**
5. Tunggu status **"Enabled"** (5-10 menit)
6. **Hot restart app**

> 📌 **Catatan**: Index hanya perlu dibuat **SATU KALI** saja. Setelah enabled, query akan berjalan normal selamanya.

---

## Testing:

Setelah publish, coba fitur chat dengan aman:

✅ **Test 1: Copy-Paste User ID**
- Buka **Profil Anda** → Ketuk chip User ID dengan ikon kunci → Disalin
- Buka **Profil Teman** → Tidak bisa dilihat (aman - hanya pemilik yang bisa baca)
- Minta teman share User ID mereka via WhatsApp/SMS/Email (cara manual share ID)

✅ **Test 2: Add Friend via User ID**
- Buka **Messages** → Tap + icon
- Paste User ID teman (yang mereka share)
- Tap "Cari"
- Chat room terbuat ✅

✅ **Test 3: Chat Normal**
- Buka chat dengan teman
- Kirim pesan text
- Kirim foto/gambar
- Semua berfungsi normal

---

## 🔐 **Keamanan Flow:**

1. **Profil Aman** - Hanya pemilik akun yang bisa lihat profile-nya
   - First name, last name, phone, email, foto - AMAN tersimpan private
   - User ID adalah string publik (seperti username) - AMAN untuk dibagikan

2. **Share User ID** - User tinggal copy-paste ID mereka
   ```
   Cara share: WhatsApp, Email, SMS, DM, QR Code
   Format: "My User ID: abc123xyz456..."
   ```

3. **Buat Chat** - Hanya perlu User ID target
   - Tidak perlu membaca profil target (rules protect)
   - Chat langsung terbuat dan bisa chat

4. **Chat Aman** - Hanya 2 participant yang akses
   - Hanya participant yang bisa baca pesan
   - Hanya pengirim yang bisa send message
   - Orang lain tidak bisa lihat atau intercept chat

---

## Troubleshooting:

### ❌ **Error: "The query requires an index"**

**Penyebab**: Firestore belum punya composite index untuk query chat list.

**Solusi**:
1. Copy link dari error message di Logcat (starts with `https://console.firebase.google.com/...`)
2. Paste ke browser → Auto-create form muncul
3. Klik **"Create Index"**
4. Tunggu status **"Enabled"** (5-10 menit)
5. Hot restart app ✅

---

### ❌ **Error: "permission-denied" saat membuat chat**

**Penyebab**: Firestore Rules belum ter-deploy atau salah.

**Solusi**:
1. Cek **Firestore Rules** tab di Firebase Console
2. Pastikan status **"Published"** dengan timestamp terbaru
3. Tunggu 2-3 menit untuk propagation
4. Restart app

---

### ❌ **Error: "Upload ke Cloudinary gagal"**

**Penyebab**: API response error atau network error.

**Solusi**:
1. Cek koneksi internet (harus stabil)
2. Cek Logcat untuk error detail:
   - `[Chat] Upload response status: ...` → Status code
   - Lihat error body untuk detail error Cloudinary
3. Gambar harus format .jpg/.png (< 5MB)
4. Coba upload lagi

**Cek Cloudinary Status:**
- Buka: https://cloudinary.com/console
- Login dengan email yang setup upload preset
- Cek "kede_app" folder ada images yang terupload
- Jika ada, Cloudinary working normal ✅

---

### ❌ **Chat list kosong setelah create chat**

**Penyebab**: Composite index masih building (belum enabled).

**Solusi**:
1. Buka **Firebase Console** → **Firestore** → Tab **"Indexes"**
2. Cek status index untuk collection `chats`:
   - ⏳ **Building** → Tunggu sampai selesai (5-10 menit)
   - ✅ **Enabled** → Hot restart app
3. Setelah enabled, chat list akan muncul otomatis

---

### ✅ **Tips Debug:**

- **Cek Logcat**: `[Chat]` logs menunjukkan progress
- **Rules Simulator**: Test rules di Firebase Console
- **Index Status**: Monitor di tab Indexes
- **Hot Restart**: Cmd+\ or flutter run after changes

---

## Catatan Keamanan:

- ✅ **Users PRIVATE**: Hanya pemilik yang bisa baca profil sendiri (tidak publik)
- ✅ **Chats participant-only**: Hanya 2 participant yang bisa akses chat
- ✅ **Messages secure**: Hanya participant & pengirim yang bisa baca pesan
- ✅ **User ID safe**: User ID adalah string publik (seperti UUID) - aman dibagikan
- ✅ **Share User ID**: Via WhatsApp, Email, SMS, atau cara manual lainnya

**Catatan**: Jika ada masalah permission-denied setelah publish, tunggu 2-3 menit agar rules ter-deploy sempurna.

