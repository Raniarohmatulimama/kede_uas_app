# Firebase Storage Rules - Untuk Upload Gambar di Chat

Rules ini diperlukan agar user bisa upload & kirim gambar di chat.

## Cara Set di Firebase Console:

1. Buka **Firebase Console**: https://console.firebase.google.com/
2. Pilih project **kelompok2**
3. Klik **Storage** di sidebar kiri
4. Klik tab **"Rules"** di bagian atas
5. **Ganti semua** kode dengan rules di bawah
6. Klik **"Publish"**

---

## Firebase Storage Rules - Versi Lengkap:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ========== CHAT UPLOADS (BARU) ==========
    // Chat images: hanya authenticated user yang bisa upload & read
    match /chat_uploads/{chatId}/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                      request.resource.contentType.matches('image/.*');
    }
    
    // ========== PROFILE PHOTOS (EXISTING) ==========
    // Profile photos: public read, owner write
    match /profile-photos/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ========== PRODUCT IMAGES (EXISTING) ==========
    // Product images: public read, authenticated write
    match /product-images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // ========== DEFAULT (FALLBACK) ==========
    // Deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

---

## Penjelasan Rules:

### 1. **Chat Uploads** (BARU)
```javascript
match /chat_uploads/{chatId}/{imageId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
                  request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                  request.resource.contentType.matches('image/.*');
}
```

- ✅ **Read**: Hanya user yang login
- ✅ **Write**: Hanya user yang login + file harus gambar + max 5MB
- ✅ **Path**: `chat_uploads/{chatId}/{timestamp}.jpg`

### 2. **Profile Photos** (Existing)
- Public read untuk display di UI
- Owner-only write

### 3. **Product Images** (Existing)
- Public read untuk katalog
- Authenticated write

---

## Testing:

Setelah publish Storage Rules:

✅ **Test 1: Upload Gambar di Chat**
- Buka chat dengan teman
- Tap ikon foto (gallery icon)
- Pilih gambar dari gallery
- Tunggu upload selesai
- Gambar muncul di chat ✅

✅ **Test 2: Lihat Gambar**
- Gambar yang dikirim muncul di chat
- Gambar bisa diklik untuk full view
- Gambar load dengan cepat

---

## Troubleshooting:

### ❌ **Error: "User does not have permission to access"**

**Penyebab**: Storage Rules belum diset atau masih menggunakan rules lama.

**Solusi**:
1. Pastikan rules di Firebase Console **SAMA PERSIS** dengan yang di atas
2. Klik **Publish** dan tunggu 1-2 menit
3. Cek status publish (harus ada timestamp terbaru)
4. Restart app dan test lagi

---

### ❌ **Upload stuck / loading terus**

**Penyebab**: File terlalu besar atau koneksi internet lambat.

**Solusi**:
- Pilih gambar yang lebih kecil (< 5MB)
- Cek koneksi internet
- Coba upload lagi

---

### ❌ **Error: "contentType doesn't match"**

**Penyebab**: File yang diupload bukan gambar (video/document).

**Solusi**:
- Hanya upload file gambar (.jpg, .png, .gif)
- Jangan upload video atau PDF

---

## Keamanan:

✅ **Validasi**:
- Hanya user login yang bisa upload
- Hanya file gambar yang diterima
- Max size 5MB untuk prevent abuse

✅ **Privacy**:
- Gambar chat hanya bisa diakses user yang login
- Path menggunakan chatId untuk organize
- Timestamp unique untuk prevent collision

✅ **Performance**:
- imageQuality: 80 untuk compress sebelum upload
- Auto-resize di client side
- CDN Firebase untuk fast delivery

---

## Langkah Lengkap Setup:

1. ✅ **Firestore Rules** → Set di Database Rules
2. ✅ **Storage Rules** → Set di Storage Rules (file ini)
3. ✅ **Firestore Index** → Buat composite index untuk chat list
4. ✅ **Test Upload** → Kirim gambar di chat

Setelah semua setup, fitur chat dengan gambar akan berfungsi sempurna! 🎉
