# 💳 Panduan Integrasi Midtrans Payment Gateway dengan Firebase

## 📋 Daftar Isi
1. [Setup Midtrans Account](#1-setup-midtrans-account)
2. [Konfigurasi Firebase Functions](#2-konfigurasi-firebase-functions)
3. [Konfigurasi Flutter App](#3-konfigurasi-flutter-app)
4. [Testing Payment](#4-testing-payment)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. Setup Midtrans Account

### A. Registrasi Sandbox Account
1. Buka https://dashboard.sandbox.midtrans.com/register
2. Isi form pendaftaran dengan data yang valid
3. Verifikasi email Anda
4. Login ke dashboard

### B. Dapatkan API Keys
1. Login ke Midtrans Sandbox Dashboard
2. Navigate ke **Settings** → **Access Keys**
3. Copy dan simpan:
   - **Server Key** (untuk backend/Firebase Functions)
   - **Client Key** (untuk frontend/Flutter - optional)

**⚠️ PENTING:** Jangan pernah commit API keys ke Git!

---

## 2. Konfigurasi Firebase Functions

### A. Install Dependencies

```bash
cd functions
npm install midtrans-client
```

### B. Setup Environment Variables

Buat file `.env` di folder `functions/`:

```env
MIDTRANS_SERVER_KEY=your_server_key_here
MIDTRANS_CLIENT_KEY=your_client_key_here
MIDTRANS_IS_PRODUCTION=false
```

### C. Update `midtrans.js`

Edit file `functions/midtrans.js` dan ganti:

```javascript
const snap = new midtransClient.Snap({
  isProduction: false, // false untuk sandbox
  serverKey: process.env.MIDTRANS_SERVER_KEY, // Gunakan environment variable
  clientKey: process.env.MIDTRANS_CLIENT_KEY
});
```

### D. Deploy Firebase Functions

```bash
firebase deploy --only functions
```

Fungsi yang akan di-deploy:
- `createMidtransTransaction` - Membuat transaksi pembayaran
- `handleMidtransNotification` - Menerima webhook dari Midtrans
- `checkTransactionStatus` - Cek status pembayaran

---

## 3. Konfigurasi Flutter App

### A. Install Dependencies

Sudah ditambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  midtrans_sdk: ^0.2.0
  webview_flutter: ^4.2.0
  cloud_functions: ^5.0.0
  cloud_firestore: ^5.0.0
```

Install packages:
```bash
flutter pub get
```

### B. Files yang Sudah Dibuat

1. **`lib/services/midtrans_service.dart`**
   - Service untuk komunikasi dengan Firebase Functions
   - Methods: createTransaction, checkTransactionStatus, dll

2. **`lib/midtrans_payment_page.dart`**
   - Halaman pembayaran dengan WebView
   - Menampilkan Midtrans payment page
   - Handle callback URLs

3. **`lib/CheckoutPage.dart`** (Updated)
   - Ditambahkan button "PAY WITH MIDTRANS"
   - Method `_proceedToMidtransPayment()`

---

## 4. Testing Payment

### A. Metode Pembayaran yang Tersedia (Sandbox)

#### 1. **Credit Card Testing**

**Kartu yang Berhasil:**
```
Card Number: 4811 1111 1111 1114
Expiry: 01/25
CVV: 123
OTP/3DS: 112233
```

**Kartu yang Gagal:**
```
Card Number: 4911 1111 1111 1113
Expiry: 01/25
CVV: 123
```

#### 2. **GoPay Testing**
- Gunakan nomor HP apapun
- Akan muncul simulator payment
- Klik "Success" untuk simulasi pembayaran berhasil

#### 3. **Bank Transfer**
- **BCA VA:** 5432111111111111
- **BNI VA:** 9883100000000015
- **Mandiri Bill:** 70012 + 12-digit number

#### 4. **E-Wallet Lainnya**
- **OVO, DANA, ShopeePay:** Simulasi otomatis

### B. Flow Testing

1. **Buka Aplikasi**
   ```bash
   flutter run
   ```

2. **Tambah Item ke Cart**
   - Browse produk
   - Add to cart
   - Pergi ke shopping cart

3. **Checkout**
   - Klik checkout
   - Isi shipping information
   - Klik tombol **"PAY WITH MIDTRANS"**

4. **Pilih Metode Pembayaran**
   - Pilih salah satu metode (Credit Card, GoPay, dll)
   - Ikuti instruksi pembayaran
   - Gunakan data testing di atas

5. **Verifikasi**
   - Setelah payment success, akan ada dialog konfirmasi
   - Cek Firestore collection `transactions` untuk melihat data
   - Cek Midtrans Dashboard untuk melihat transaksi

### C. Monitor Transaction Status

**Firebase Console:**
```
Firestore Database → transactions → [order_id]
```

Fields yang disimpan:
- `orderId` - ID order unik
- `status` - pending/success/failed
- `amount` - Total pembayaran
- `paymentUrl` - URL Midtrans
- `token` - Payment token
- `createdAt` - Timestamp dibuat

**Midtrans Dashboard:**
```
Dashboard Sandbox → Transactions
```

---

## 5. Troubleshooting

### Error: "Failed to create transaction"

**Solusi:**
1. Cek API keys sudah benar
2. Pastikan Firebase Functions sudah deployed
3. Cek console logs di Firebase Functions

```bash
firebase functions:log
```

### Error: "CORS Policy"

**Solusi:**
Update Firebase Functions untuk allow CORS:

```javascript
const cors = require('cors')({origin: true});

exports.handleMidtransNotification = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    // Your code here
  });
});
```

### Payment Page Tidak Muncul

**Solusi:**
1. Cek internet connection
2. Cek WebView permissions di Android/iOS
3. Clear app cache dan restart

**Android:** Update `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS:** Update `Info.plist`
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Transaction Status Tidak Update

**Solusi:**
1. Cek Midtrans webhook URL sudah dikonfigurasi
2. Setup webhook di Midtrans Dashboard:
   ```
   Settings → Configuration → Notification URL
   https://your-project.cloudfunctions.net/handleMidtransNotification
   ```

### Testing dengan Real Device

**Untuk Android:**
```bash
flutter run --release
```

**Untuk iOS:**
```bash
flutter run --release
```

---

## 6. Command Reference

### Deploy Firebase Functions
```bash
# Deploy semua functions
firebase deploy --only functions

# Deploy function spesifik
firebase deploy --only functions:createMidtransTransaction

# View logs
firebase functions:log --only createMidtransTransaction
```

### Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build release
flutter build apk
flutter build ios

# Clean build
flutter clean
flutter pub get
```

---

## 7. Important Notes

### 🔐 Security
- **JANGAN** commit API keys ke Git
- Gunakan environment variables untuk production
- Enable Firebase Security Rules untuk Firestore

### 💰 Pricing
- Sandbox: **GRATIS**
- Production: Check https://midtrans.com/pricing

### 📊 Monitoring
- Monitor di Firebase Console
- Monitor di Midtrans Dashboard
- Setup email notifications untuk transaction updates

### 🚀 Production Checklist
- [ ] Ganti API keys dari Sandbox ke Production
- [ ] Update `isProduction: true` di Firebase Functions
- [ ] Setup webhook URL production
- [ ] Test dengan kartu kredit real (amount kecil)
- [ ] Setup proper error handling
- [ ] Enable analytics
- [ ] Setup customer support untuk payment issues

---

## 8. Additional Resources

### Documentation
- Midtrans Docs: https://docs.midtrans.com/
- Firebase Functions: https://firebase.google.com/docs/functions
- Flutter WebView: https://pub.dev/packages/webview_flutter

### Support
- Midtrans Support: support@midtrans.com
- Midtrans Slack: https://midtrans.com/slack

---

## 9. Testing Scenarios

### Scenario 1: Successful Payment
```
1. User memilih produk
2. Add to cart
3. Checkout dengan Midtrans
4. Pilih Credit Card (4811 1111 1111 1114)
5. Payment success
6. Order status: "paid"
```

### Scenario 2: Failed Payment
```
1-3. Same as above
4. Pilih Credit Card (4911 1111 1111 1113)
5. Payment failed
6. Order status: "pending"
```

### Scenario 3: Pending Payment
```
1-3. Same as above
4. Pilih Bank Transfer
5. Close page sebelum transfer
6. Order status: "pending"
7. User bisa cek status dan complete payment
```

---

## 10. Next Steps

Setelah testing berhasil:

1. ✅ Test semua payment methods
2. ✅ Verify transaction status updates
3. ✅ Test error scenarios
4. ✅ Setup proper UI/UX for payment flow
5. ✅ Add order history page
6. ✅ Setup email notifications
7. 🚀 Ready for production!

---

**Selamat Testing! 🎉**

Jika ada pertanyaan atau masalah, silakan check:
- Firebase Functions logs
- Midtrans Dashboard
- Flutter console output
