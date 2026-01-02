# Review Display - Troubleshooting Guide

## Masalah: Review tidak muncul setelah user submit rating

### Flow Pengiriman Rating (yang seharusnya)
```
Notification → Order Detail → Review Page → Rating Page Integration → Submit → Home
                    ↓
              Pesanan Selesai
                    ↓
              Review Page
                    ↓
              Rating Page Integration (show products untuk rating)
                    ↓
              Submit Rating (save ke Firestore)
```

### Debugging Steps

#### 1. **Cek apakah items/produk terlihat dengan benar**
- Buka `ReviewPage.dart` dan lihat console log:
  ```
  DEBUG ReviewPage: orderDetails keys: {...}
  DEBUG ReviewPage: items count: X
  DEBUG ReviewPage: First item: {...}
  ```
- Pastikan `items.length > 0` dan setiap item memiliki `productId` atau `id`

#### 2. **Cek apakah RatingService.submitRating dipanggil dengan benar**
- Di console, cari:
  ```
  DEBUG RatingService: submitRating called - orderId: X, productId: Y, rating: Z
  DEBUG RatingService: Saving rating data: {...}
  DEBUG RatingService: Rating successfully saved to Firestore
  ```
- Pastikan `productId` yang dikirim cocok dengan yang ada di database

#### 3. **Cek struktur data yang disimpan di Firestore**
- Buka Firebase Console → Firestore → `ratings` collection
- Cek apakah dokumen yang baru dibuat memiliki field:
  ```
  {
    orderId: "...",
    productId: "...",      ← PENTING: harus sama dengan product.id
    userId: "...",
    rating: 5,
    comment: "...",
    displayName: "...",
    userAvatar: "...",
    createdAt: Timestamp
  }
```

#### 4. **Cek apakah detail_page.dart load reviews dengan benar**
- Buka halaman detail produk
- Lihat console:
  ```
  DEBUG: Loading reviews for productId: X
  DEBUG: Found Y reviews
  DEBUG: Review data: {...}
  DEBUG: Updated productReviews count: Y
  ```

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Items count: 0" | `orderDetails['items']` tidak ada atau null | Cek OrderDetailPage apakah passing items dengan benar ke ReviewPage |
| "productId: null" | Item structure berbeda (mungkin 'id' bukan 'productId') | Update filter di rating_page_integration.dart: `final pid = m['productId'] ?? m['id'] ?? m['product_id'];` |
| "Found 0 reviews" | Product.id di detail_page.dart berbeda dengan yang di Firestore | Cek apakah product.id sama persis (case-sensitive) |
| Duplicate rating error | User sudah pernah memberi rating produk ini di order ini | Normal - cegah duplicate dengan pengecekan di RatingService |

### Firestore Security Rules Check

Pastikan rules memungkinkan:
```javascript
match /ratings/{document=**} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
}
```

### Next Steps untuk Testing

1. **Bersihkan cache & rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Lakukan flow lengkap:**
   - Pesan produk
   - Buka notification
   - Klik "Pesanan telah diterima"
   - Isi rating & review
   - Submit
   - Buka detail produk tersebut
   - Lihat apakah review muncul di tab Review

3. **Monitor console logs untuk debug messages**

### Manual Testing di Firebase Console

1. Buka Firestore Console
2. Buat dokumen test di collection `ratings`:
   ```json
   {
     "productId": "YOUR_PRODUCT_ID",
     "displayName": "Test User",
     "rating": 5,
     "comment": "Test review",
     "userAvatar": "assets/images/default_avatar.png",
     "createdAt": (current timestamp),
     "userId": "test_user",
     "orderId": "test_order"
   }
   ```
3. Buka halaman detail produk dengan ID yang sesuai
4. Klik tab Review
5. Klik refresh button - review harus muncul

