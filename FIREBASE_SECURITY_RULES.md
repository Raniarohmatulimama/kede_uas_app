# Firebase Firestore Security Rules Setup

## Error: permission-denied

Error ini terjadi karena Firestore security rules terlalu ketat dan tidak mengizinkan user yang sudah login untuk menulis data.

## Solusi: Update Firestore Security Rules

### Langkah 1: Buka Firebase Console
1. Pergi ke https://console.firebase.google.com
2. Pilih project Anda (kelompok2)
3. Di sidebar kiri, klik **Firestore Database**

### Langkah 2: Buka Tab "Rules"
Di Firestore Database, klik tab **"Rules"** di bagian atas

### Langkah 3: Ganti Rules dengan ini

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: hanya pemilik akun boleh baca/tulis dokumen mereka.
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Products: Baca publik. Tulis ketat berdasarkan pemilik (seller_id == uid).
    // Cocok dengan implementasi aplikasi yang menyimpan field `seller_id`.
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null
        && request.resource.data.seller_id == request.auth.uid;
      allow update, delete: if request.auth != null
        && resource.data.seller_id == request.auth.uid;
    }

    // Carts: hanya pemilik yang boleh akses
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Orders: hanya pemilik yang boleh akses
    match /orders/{orderId} {
      allow read, write: if request.auth != null
        && resource.data.user_id == request.auth.uid;
    }

    // Wishlist: hanya pemilik yang boleh akses
    match /wishlist/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Langkah 4: Publikasikan Rules
Klik tombol **"Publish"** di kanan atas

### Langkah 5: Tunggu Update
Firebase akan update rules dalam beberapa detik. Tunggu sampai proses selesai.

## Setelah Update Rules

Kembali ke app dan coba:
1. **Sign Up** - buat akun baru dengan Firebase Authentication
2. Data user akan tersimpan di Firestore collection `users/{uid}`
3. **Sign In** - login dengan email dan password yang sama
4. Selesai! Firebase Authentication sudah terhubung.

## Penjelasan Rules

| Collection | Rule | Penjelasan |
|-----------|------|-----------|
| `users/{userId}` | `request.auth.uid == userId` | Hanya pemilik akun bisa baca/tulis data mereka sendiri |
| `products/{document}` | Read: true, Write: auth != null | Siapa saja bisa lihat produk, hanya user login bisa tambah/edit produk |
| `carts/{userId}` | `request.auth.uid == userId` | Hanya pemilik cart bisa akses cart mereka |
| `orders/{document}` | `user_id == request.auth.uid` | Hanya pemilik order bisa akses order mereka |
| `wishlist/{userId}` | `request.auth.uid == userId` | Hanya pemilik wishlist bisa akses wishlist mereka |

## Troubleshooting

Jika masih error setelah update rules:

1. **Tunggu 30 detik** - Firebase memerlukan waktu untuk sinkronisasi rules
2. **Hot Restart app** - Di terminal tekan `R` (capital R)
3. **Coba buat akun baru** - Gunakan email berbeda

Jika masih tidak bisa, check di Firebase Console → Firestore Database → Data untuk lihat apakah data user berhasil tersimpan.

---

## (Opsional) Firebase Storage Rules untuk Gambar Produk

Jika gambar produk disimpan di Firebase Storage:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /product_images/{allPaths=**} {
      allow read: if true; // gambar dapat dilihat publik
      allow write: if request.auth != null; // upload hanya jika login
    }
  }
}
```

## Deploy Rules

- Console: buka Firestore → tab Rules → paste → Publish.
- CLI:

```
firebase login
firebase use <project-id>
firebase deploy --only firestore:rules
```

Jika Anda menggunakan backend (Laravel/API) untuk produk, pastikan API memverifikasi Firebase ID Token di sisi server dan menolak request tanpa autentikasi.
