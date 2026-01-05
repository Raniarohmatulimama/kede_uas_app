# 🚀 Quick Start - Midtrans Payment Testing

## 📱 Cara Cepat Testing Midtrans Payment Gateway

### 1️⃣ Setup API Keys (5 menit)

1. **Buka Midtrans Sandbox:**
   ```
   https://dashboard.sandbox.midtrans.com/register
   ```

2. **Dapatkan API Keys:**
   - Login → Settings → Access Keys
   - Copy **Server Key** dan **Client Key**

3. **Update `functions/midtrans.js`:**
   Ganti baris 5-7:
   ```javascript
   serverKey: 'YOUR_MIDTRANS_SERVER_KEY',  // <-- Ganti ini
   clientKey: 'YOUR_MIDTRANS_CLIENT_KEY'   // <-- Ganti ini
   ```

### 2️⃣ Deploy Firebase Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 3️⃣ Jalankan Aplikasi

```bash
flutter run
```

### 4️⃣ Testing Payment Flow

1. **Pilih Produk** → Add to Cart
2. **Go to Cart** → Checkout
3. **Isi Form Shipping**
4. **Klik: "PAY WITH MIDTRANS"** ⬅️ Tombol baru!
5. **Pilih Metode Pembayaran**

---

## 💳 Data Testing (Sandbox)

### ✅ Credit Card - BERHASIL
```
Card Number: 4811 1111 1111 1114
Expiry Date: 01/25
CVV: 123
OTP/3DS: 112233
```

### ❌ Credit Card - GAGAL
```
Card Number: 4911 1111 1111 1113
Expiry Date: 01/25
CVV: 123
```

### 📱 GoPay
- Masukkan nomor HP apa saja
- Klik "Success" di simulator

### 🏦 Bank Transfer
- **BCA VA:** 5432111111111111
- **BNI VA:** 9883100000000015
- **Mandiri Bill:** 70012 + 12 digit angka

---

## 🎯 Test Scenarios

### Scenario 1: Pembayaran Berhasil
```
1. Add produk ke cart (Total: Rp 100,000)
2. Checkout → Isi alamat
3. Klik "PAY WITH MIDTRANS"
4. Pilih Credit Card
5. Masukkan: 4811 1111 1111 1114
6. CVV: 123, Expiry: 01/25
7. OTP: 112233
8. ✅ Payment Success!
```

### Scenario 2: Pembayaran Gagal
```
1-3. Same as above
4. Pilih Credit Card
5. Masukkan: 4911 1111 1111 1113
6. CVV: 123
7. ❌ Payment Failed
```

### Scenario 3: Pending Payment
```
1-3. Same as above
4. Pilih Bank Transfer (BCA)
5. Catat VA Number
6. Close page (simulasi belum bayar)
7. ⏳ Status: Pending
```

---

## 🔍 Verifikasi

### Cek di Firebase Console
```
1. Buka: https://console.firebase.google.com
2. Pilih Project Anda
3. Firestore Database → transactions
4. Lihat document dengan order_id Anda
```

Fields yang tersimpan:
- `orderId` - ID order
- `status` - pending/success/failed
- `amount` - Total pembayaran
- `paymentUrl` - URL Midtrans
- `token` - Payment token

### Cek di Midtrans Dashboard
```
1. Login: https://dashboard.sandbox.midtrans.com
2. Menu: Transactions
3. Lihat transaksi terbaru
```

---

## 🐛 Troubleshooting

### Error: "Failed to create transaction"
**Solusi:**
- Pastikan API keys sudah benar
- Deploy ulang Firebase Functions
- Check logs: `firebase functions:log`

### Payment Page Tidak Muncul
**Solusi:**
- Check internet connection
- Restart aplikasi
- Clear cache: `flutter clean && flutter pub get`

### Status Tidak Update
**Solusi:**
- Wait 5-10 detik untuk webhook
- Klik button "Check Status" di app
- Manual check di Firestore

---

## 📊 Flow Diagram

```
User                      Flutter App              Firebase              Midtrans
 |                             |                       |                     |
 |--[1. Checkout]------------->|                       |                     |
 |                             |--[2. Create Order]--->|                     |
 |                             |                       |--[3. Create Tx]---->|
 |                             |                       |<---[4. Token]-------|
 |                             |<---[5. Payment URL]---|                     |
 |<--[6. Show WebView]---------|                       |                     |
 |                             |                       |                     |
 |--[7. Pay]--------------------------------------------->|                  |
 |<--[8. Success]----------------------------------------------|              |
 |                             |                       |<--[9. Webhook]------|
 |                             |<--[10. Status Update]-|                     |
 |<--[11. Confirmation]--------|                       |                     |
```

---

## ✅ Checklist Testing

- [ ] Install dependencies berhasil
- [ ] API keys sudah dikonfigurasi
- [ ] Firebase Functions deployed
- [ ] App bisa jalan tanpa error
- [ ] Button "PAY WITH MIDTRANS" muncul
- [ ] Payment page terbuka
- [ ] Test dengan Credit Card berhasil
- [ ] Test dengan Credit Card gagal
- [ ] Test dengan GoPay
- [ ] Test dengan Bank Transfer
- [ ] Status transaction tersimpan di Firestore
- [ ] Transaction muncul di Midtrans Dashboard

---

## 🎓 Learning Points

1. **Midtrans Sandbox** = Environment untuk testing (gratis)
2. **Server Key** = Untuk backend (Firebase Functions)
3. **Client Key** = Untuk frontend (opsional)
4. **Webhook** = Notifikasi dari Midtrans ke Firebase
5. **Transaction Token** = Unique ID untuk setiap pembayaran

---

## 📚 Dokumentasi Lengkap

Lihat file: [MIDTRANS_INTEGRATION_GUIDE.md](MIDTRANS_INTEGRATION_GUIDE.md)

---

## 🆘 Butuh Bantuan?

1. Check console output: `flutter run -v`
2. Check Firebase logs: `firebase functions:log`
3. Check Midtrans Dashboard → Transactions
4. Lihat dokumentasi lengkap di atas

---

**Happy Testing! 🎉**

Testing di Sandbox adalah **GRATIS** dan **UNLIMITED**!
