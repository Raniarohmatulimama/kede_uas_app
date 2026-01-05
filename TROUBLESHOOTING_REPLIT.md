# 🔧 Troubleshooting Midtrans Payment Error

## ❌ Error yang Terjadi:
```
Failed host lookup: 'kede-midtrans.replit.dev'
(OS Error: No address associated with hostname, errno = 7)
```

---

## 🎯 Penyebab:
**Android Emulator tidak bisa resolve DNS Replit.**

Ini masalah umum dengan emulator Android yang tidak bisa akses beberapa hostname eksternal.

---

## ✅ Solusi (Pilih Salah Satu):

### **Solusi 1: Test di Real Device** ⭐ **RECOMMENDED**

1. Connect HP Android ke komputer
2. Enable USB Debugging
3. Run: `flutter run`
4. Test payment di HP real

**Real device TIDAK ada masalah DNS!**

---

### **Solusi 2: Check Server Replit Masih Hidup**

Buka browser, akses:
```
https://kede-midtrans.replit.dev/
```

**Expected output:**
```json
{"message":"Kede Midtrans Backend is running!"}
```

**Jika tidak muncul:**
- Server mati/sleep
- Buka Replit tab
- Run: `npm start`

---

### **Solusi 3: Keep Replit Server Alive**

Replit free tier **auto-sleep setelah 5 menit idle**.

**Workaround:**
- Keep tab Replit terbuka
- Atau klik preview setiap 4 menit
- Atau upgrade Replit (bayar)

---

### **Solusi 4: Test di Browser Dulu**

Sebelum test di app, pastikan backend bisa diakses:

```bash
# Test endpoint
curl https://kede-midtrans.replit.dev/
```

**Atau buka di browser:**
```
https://kede-midtrans.replit.dev/
```

---

## 🚀 **Quick Fix untuk Testing Sekarang:**

1. ✅ Buka tab Replit
2. ✅ Cek terminal: `Server running on port 3000`
3. ✅ Kalau tidak ada, run: `npm start`
4. ✅ Test di browser: `https://kede-midtrans.replit.dev/`
5. ✅ Kalau OK, test lagi di app

---

## 📱 **Emulator vs Real Device:**

| Aspek | Emulator | Real Device |
|-------|----------|-------------|
| **DNS Replit** | ❌ Sering error | ✅ Tidak masalah |
| **Speed** | Lambat | Cepat |
| **Testing** | Limited | Full functionality |
| **Recommendation** | Development | **Testing payment** |

---

## 💡 **Kesimpulan:**

**Untuk test Midtrans payment:**
1. **BEST:** Test di real device (HP Android)
2. **GOOD:** Pastikan Replit server aktif
3. **OK:** Keep Replit tab terbuka

**Error yang Anda lihat normal untuk emulator!**

---

**Status Saat Ini:**
- ✅ Backend Replit: Running
- ✅ Firestore Rules: Deployed
- ✅ Flutter App: OK
- ⚠️ Emulator: DNS issue (expected)

**Next Step: Test di real device untuk hasil terbaik!** 📱
