# Implementasi Tampilan Rating & Review di Detail Page

## Ringkasan Perubahan

Halaman detail produk (`detail_page.dart`) telah dimodifikasi untuk menampilkan rating dan review dari Firestore secara real-time.

## Fitur yang Ditambahkan

### 1. **Pengambilan Data Review dari Firestore**
   - Fungsi `_loadReviewsFromFirestore()` mengambil semua rating dari koleksi `ratings`
   - Filter berdasarkan `productId` untuk menampilkan review produk yang sesuai
   - Data diambil saat halaman dibuka (di `initState()`)

### 2. **Konversi Data Firestore ke Model Review**
   - Mengambil informasi user dari koleksi `users`
   - Mengformat timestamp Firestore ke format tanggal yang readable
   - Mendukung avatar user (default ke asset jika tidak ada)

### 3. **Tampilan Review yang Disempurnakan**
   - **Ketika belum ada review:**
     - Icon dan pesan yang informatif
     - "Jadilah yang pertama memberikan review"
   
   - **Ketika ada reviews:**
     - Menampilkan nama reviewer
     - Star rating (1-5 bintang)
     - Tanggal review (relative time: "Just now", "2h ago", dll)
     - Komentar lengkap
     - Avatar user

### 4. **Tombol Refresh**
   - Tombol refresh di sudut kanan atas tab Review
   - Pengguna bisa refresh untuk melihat review terbaru tanpa reload halaman

### 5. **Format Tanggal Dinamis**
   - "Just now" untuk review yang baru saja
   - "Xh ago" untuk beberapa jam lalu
   - "Xd ago" untuk beberapa hari lalu
   - Format DD/MM/YYYY untuk review yang lebih lama

## Struktur Data Firestore yang Diharapkan

### Collection: `ratings`
```
{
  orderId: "order123",
  productId: "product123",
  userId: "user123",
  rating: 5,
  comment: "Produk bagus, cepat sampai!",
  userAvatar: "path/to/avatar.jpg",  // optional
  createdAt: Timestamp
}
```

### Collection: `users`
```
{
  displayName: "John Doe",
  ...
}
```

## Cara Kerja

1. User memberi rating dan review menggunakan `RatingService`
2. Data tersimpan di Firestore collection `ratings`
3. Saat membuka halaman detail produk:
   - `initState()` memanggil `_loadReviewsFromFirestore()`
   - Query semua rating dengan `productId` yang sesuai
   - Data dikonversi ke model `Review`
   - UI di-update dengan data review terbaru
4. User bisa klik tombol refresh untuk update review

## Kebutuhan Koleksi Firestore

Pastikan struktur Firestore sudah sesuai:
- ✅ Collection `ratings` dengan field: `orderId`, `productId`, `userId`, `rating`, `comment`, `createdAt`
- ✅ Collection `users` dengan field: `displayName`
- ✅ Security Rules memungkinkan read dari koleksi ini

## Testing

Untuk testing:
1. Submit rating/review melalui halaman review
2. Buka halaman detail produk
3. Review akan otomatis ditampilkan di tab Review
4. Klik refresh icon untuk update data terbaru

