# 🖼️ Cloudinary Integration - Setup Guide

**Cloud Name**: duqcxzhkr  
**Folder Name**: kede_app  
**Status**: ✅ Integrated

---

## 📝 Overview

Cloudinary telah diintegrasikan untuk menangani image uploads di aplikasi Anda:
- **Profile photos** - User profile pictures
- **Product images** - Product catalog images

---

## ✅ Apa yang Sudah Dilakukan

### 1️⃣ Konfigurasi
- ✅ `lib/config/cloudinary_config.dart` - Konfigurasi Cloudinary
- ✅ Credentials sudah diisi: `duqcxzhkr` (cloud name), `kede_app` (folder)

### 2️⃣ Service
- ✅ `lib/services/cloudinary_service.dart` - Service untuk upload & optimization

### 3️⃣ Integrasi dengan Firebase
- ✅ `lib/services/auth_service.dart` - Updated untuk upload profile photo ke Cloudinary
- ✅ `lib/services/api_service.dart` - Updated untuk upload product images ke Cloudinary

### 4️⃣ Dependencies
- ✅ `pubspec.yaml` - Added `cloudinary_flutter: ^1.1.0`

---

## 🚀 Cara Menggunakan

### Upload Profile Photo

```dart
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

// Pilih image dari gallery
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final File imageFile = File(image.path);
  
  // Upload ke Cloudinary
  final result = await AuthService.uploadPhotoToBackend(imageFile);
  
  if (result['success']) {
    print('Photo URL: ${result['photo']}');
    print('Public ID: ${result['publicId']}');
  }
}
```

### Upload Product Image

```dart
import '../services/api_service.dart';
import 'dart:io';

// Upload product dengan image
final result = await ApiService.createProduct(
  name: 'Apple',
  description: 'Fresh apples',
  price: 10000,
  category: 'Fruits',
  stock: 100,
  imageFile: File(imagePath), // dari image picker
);

if (result['success']) {
  print('Product created with image');
}
```

---

## 🖼️ Image Optimization

Cloudinary otomatis mengoptimalkan image dengan:

### Thumbnail (200x200)
```dart
import '../services/cloudinary_service.dart';

final thumbnailUrl = CloudinaryService.getThumbnailUrl(publicId, size: 200);
```

### Display (500x500)
```dart
final displayUrl = CloudinaryService.getDisplayUrl(publicId);
```

### Custom Optimization
```dart
final customUrl = CloudinaryService.getOptimizedUrl(
  publicId,
  width: 600,
  height: 400,
  crop: 'fill', // atau 'fit', 'scale'
  quality: 'auto',
  format: 'auto', // atau 'webp', 'jpg', etc
);
```

---

## 📊 Firestore Data Structure

### Users Collection
```
users/{uid}
├── profile_photo: "https://res.cloudinary.com/duqcxzhkr/image/upload/..."
├── profile_photo_public_id: "kede_app/user_xyz123" ← Untuk reference
└── ...
```

### Products Collection
```
products/{productId}
├── image: "https://res.cloudinary.com/duqcxzhkr/image/upload/..."
├── image_public_id: "kede_app/product_xyz456" ← Untuk reference
└── ...
```

---

## 📋 API Reference

### CloudinaryService Methods

```dart
// Upload image
Future<Map<String, dynamic>> uploadImage(
  File imageFile,
  {String? resourceType, Map<String, String>? tags}
)

// Get thumbnail URL
String getThumbnailUrl(String publicId, {int size = 200})

// Get display URL
String getDisplayUrl(String publicId)

// Get custom URL dengan optimization
String getOptimizedUrl(
  String publicId,
  {int? width, int? height, String crop, String quality, String format}
)

// Extract public ID dari Cloudinary URL
String extractPublicId(String url)

// Check jika URL adalah Cloudinary URL
bool isCloudinaryUrl(String url)
```

---

## 🔧 Configuration

Konfigurasi ada di `lib/config/cloudinary_config.dart`:

```dart
class CloudinaryConfig {
  static const String cloudName = 'duqcxzhkr';
  static const String uploadPreset = 'kede_app'; // Folder name
  // ... methods ...
}
```

### Setup Cloudinary Folder Structure

Di Cloudinary, images akan diorganisir dalam folder:
```
https://cloudinary.com/console/media_library/
└── kede_app/
    ├── profile-photos/ (implisit dari tagging)
    └── product-images/ (implisit dari tagging)
```

Folder tersebut otomatis dibuat saat upload.

---

## 🔐 Security Notes

### Upload Preset
- Menggunakan "upload preset" tanpa API key di client (lebih aman)
- API key hanya untuk backend operations jika diperlukan

### Public ID Storage
- Disimpan di Firestore untuk reference
- Berguna untuk management/deletion di masa depan

### Tags
Setiap upload dilengkapi tags:
```dart
{
  'user_id': 'uid',
  'type': 'profile_photo' // atau 'product_image'
}
```

---

## 📦 Folder Organization

```
kede_app/
├── profile_photo_user_abc123
├── profile_photo_user_def456
├── product_image_seller_xyz
└── ...
```

Naming convention otomatis dari timestamp dan context.

---

## 🎨 Image Transformation Examples

### Original URL
```
https://res.cloudinary.com/duqcxzhkr/image/upload/v1234567890/kede_app/xyz.jpg
```

### Thumbnail (200x200)
```
https://res.cloudinary.com/duqcxzhkr/image/upload/w_200,h_200,c_fill,q_auto,f_auto/v1234567890/kede_app/xyz.jpg
```

### Display (500x500)
```
https://res.cloudinary.com/duqcxzhkr/image/upload/w_500,h_500,c_scale,q_auto,f_auto/v1234567890/kede_app/xyz.jpg
```

### High Quality WebP
```
https://res.cloudinary.com/duqcxzhkr/image/upload/q_85,f_webp/v1234567890/kede_app/xyz.jpg
```

---

## 💾 Firestore Queries

### Find user's profile photo
```dart
final users = await Firestore.collection('users')
  .where('profile_photo', '!=', null)
  .get();
```

### Find products dengan image
```dart
final products = await Firestore.collection('products')
  .where('image', '!=', null)
  .get();
```

---

## ⚠️ Important Notes

1. **Upload Preset Required**
   - Pastikan upload preset "kede_app" sudah di-setup di Cloudinary dashboard
   - Settings → Upload → Add upload preset → Unsigned

2. **Firestore Rules**
   - Pastikan Firestore rules mengizinkan update `profile_photo` dan `image`

3. **Image Size**
   - Recommended: Max 5MB per image
   - Cloudinary akan automatically compress

4. **Public IDs**
   - Disimpan untuk future reference (delete, re-upload, etc)

---

## 🚨 Troubleshooting

### Upload Failed

**Error**: "Upload preset not found"
```
Solution: Buat upload preset "kede_app" di Cloudinary dashboard
1. Login ke cloudinary.com
2. Settings → Upload → Add upload preset
3. Name: kede_app
4. Unsigned: On
5. Save
```

**Error**: "Invalid cloud name"
```
Solution: Pastikan cloud name sudah benar di cloudinary_config.dart
Ganti 'duqcxzhkr' dengan cloud name Anda jika berbeda
```

### Image Not Displaying

**Issue**: Gambar tidak muncul di app
```
Solution: 
1. Check URL di browser
2. Pastikan image public (not private)
3. Check Cloudinary CORS settings jika perlu
```

---

## 📈 Monitoring Usage

Di Cloudinary Dashboard:
1. Media Library → Lihat semua uploaded images
2. Settings → Usage → Lihat bandwidth usage
3. Account → Lihat plan details

---

## 🔄 Migration from Firebase Storage

Jika sebelumnya menggunakan Firebase Storage:

```dart
// OLD (Firebase Storage)
final downloadUrl = await storageRef.getDownloadURL();

// NEW (Cloudinary)
final result = await CloudinaryService.uploadImage(imageFile);
final downloadUrl = result['url'];
```

---

## 📚 Resources

- Cloudinary Docs: https://cloudinary.com/documentation
- Upload API: https://cloudinary.com/documentation/upload_widget
- Image Transformation: https://cloudinary.com/documentation/transformation_reference
- Flutter Package: https://pub.dev/packages/cloudinary_flutter

---

## 🎯 Next Steps

1. ✅ Code sudah integrated
2. ❌ Setup upload preset di Cloudinary dashboard
3. ❌ Test upload dari app
4. ❌ Monitor usage di Cloudinary

---

**Setup Cloudinary Integration: COMPLETE** ✅
