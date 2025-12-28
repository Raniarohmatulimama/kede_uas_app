# Penjelasan Perubahan Kode - Firebase Integration

## 1. auth_service.dart

### Perubahan Utama

#### Import Statements
```dart
// SEBELUM
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// SESUDAH
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/firebase_config.dart';
```

#### Inisialisasi Services
```dart
// SEBELUM - Hanya SharedPreferences
// (tidak ada backend service)

// SESUDAH
static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
static final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
```

#### Sign In Flow
```dart
// SEBELUM - HTTP Request
static Future<Map<String, dynamic>> signIn(...) async {
  final response = await http.post(
    Uri.parse('${AppConfig.baseUrl}/login'),
    headers: {...},
    body: json.encode({'email': email, 'password': password}),
  );
  // Parse JSON response...
}

// SESUDAH - Firebase Auth + Firestore Query
static Future<Map<String, dynamic>> signIn({...}) async {
  final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  // Get user data from Firestore
  final userDoc = await _firestore
      .collection(FirebaseConfig.usersCollection)
      .doc(user.uid)
      .get();
  
  // Return data dalam format yang sama untuk kompatibilitas
  return {
    'success': true,
    'data': {'user': {...}}
  };
}
```

#### Sign Up Flow
```dart
// SEBELUM
static Future<Map<String, dynamic>> register(...) async {
  final response = await http.post(
    Uri.parse('${AppConfig.baseUrl}/register'),
    // ...
  );
}

// SESUDAH
static Future<Map<String, dynamic>> signUp({...}) async {
  // 1. Buat user di Firebase Auth
  final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  // 2. Simpan data user ke Firestore
  await _firebaseFirestore
      .collection(FirebaseConfig.usersCollection)
      .doc(user.uid)
      .set({
        'id': user.uid,
        'email': email,
        'first_name': firstName,
        // ...
      });
}
```

#### Upload Photo
```dart
// SEBELUM - HTTP Multipart
static Future<Map<String, dynamic>> uploadPhotoToBackend(File imageFile) {
  var request = http.MultipartRequest('POST', Uri.parse(...));
  request.files.add(await http.MultipartFile.fromPath('photo', ...));
  // ...
}

// SESUDAH - Firebase Storage + Firestore Update
static Future<Map<String, dynamic>> uploadPhotoToBackend(File imageFile) {
  // 1. Upload ke Firebase Storage
  final storageRef = _firebaseStorage
      .ref()
      .child(FirebaseConfig.profilePhotosPath)
      .child(fileName);
  await storageRef.putFile(imageFile);
  
  // 2. Get download URL
  final downloadUrl = await storageRef.getDownloadURL();
  
  // 3. Update Firestore
  await _firebaseFirestore
      .collection(FirebaseConfig.usersCollection)
      .doc(user.uid)
      .update({'profile_photo': downloadUrl});
}
```

### Property Baru
```dart
// Akses ke current user dari Firebase
static User? get currentUser => _firebaseAuth.currentUser;
static String? get currentUserId => currentUser?.uid;
static bool get isLoggedIn => currentUser != null;
static Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
```

---

## 2. api_service.dart

### Perubahan Utama

#### Import Statements
```dart
// SEBELUM
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// SESUDAH
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/firebase_config.dart';
```

#### Get Products
```dart
// SEBELUM - REST API
static Future<Map<String, dynamic>> getProducts({...}) async {
  final response = await http.get(
    Uri.parse('${AppConfig.baseUrl}/products?page=$page&per_page=$perPage'),
    headers: {...},
  );
  // Parse JSON response
}

// SESUDAH - Firestore Query
static Future<Map<String, dynamic>> getProducts({...}) async {
  Query query = _firestore.collection(FirebaseConfig.productsCollection);
  
  if (category != null) {
    query = query.where('category', isEqualTo: category);
  }
  
  final products = await query
      .orderBy('created_at', descending: true)
      .limit(perPage)
      .offset(startAt)
      .get();
  
  return {
    'success': true,
    'data': {'data': products.docs.map(...)},
  };
}
```

#### Create Product
```dart
// SEBELUM - HTTP Multipart
static Future<Map<String, dynamic>> createProduct({...}) async {
  var request = http.MultipartRequest('POST', Uri.parse(...));
  // Add fields dan files...
  await request.send();
}

// SESUDAH - Firestore + Firebase Storage
static Future<Map<String, dynamic>> createProduct({...}) async {
  // 1. Upload image ke Storage (jika ada)
  if (imageFile != null) {
    await storageRef.putFile(imageFile);
    imageUrl = await storageRef.getDownloadURL();
  }
  
  // 2. Add dokumen ke Firestore
  final productRef = await _firestore
      .collection(FirebaseConfig.productsCollection)
      .add({
        'name': name,
        'price': price,
        'image': imageUrl,
        'seller_id': userId,
        'created_at': FieldValue.serverTimestamp(),
      });
  
  return {'success': true, 'data': {...}};
}
```

#### Delete Product
```dart
// SEBELUM - HTTP DELETE
static Future<Map<String, dynamic>> deleteProduct(int id) async {
  final response = await http.delete(
    Uri.parse('${AppConfig.baseUrl}/products/$id'),
    headers: {...},
  );
}

// SESUDAH - Firestore Delete + Storage Cleanup
static Future<Map<String, dynamic>> deleteProduct(String id) async {
  // 1. Verify user is owner
  final productDoc = await _firestore
      .collection(FirebaseConfig.productsCollection)
      .doc(id)
      .get();
  
  if (productData['seller_id'] != userId) {
    throw 'Unauthorized';
  }
  
  // 2. Delete image from Storage
  if (productData['image'] != null) {
    await _storage.refFromURL(productData['image']).delete();
  }
  
  // 3. Delete document from Firestore
  await _firestore
      .collection(FirebaseConfig.productsCollection)
      .doc(id)
      .delete();
}
```

---

## 3. product_model.dart

### Perubahan Tipe Data

```dart
// SEBELUM
class Product {
  final int? id;              // Database ID (integer)
  
  // ... fields lain

  // Constructor & methods
}

// SESUDAH
class Product {
  final String id;            // Firestore Document ID (string)
  final String? sellerId;     // Siapa yang menjual
  final DateTime? createdAt;  // Kapan dibuat
  
  // ... fields lain
}
```

### fromJson Factory Update
```dart
// SEBELUM - Parse response dari REST API
factory Product.fromJson(Map<String, dynamic> json) {
  // Convert relative path ke full URL
  if (!imagePath.startsWith('http')) {
    final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
    imageUrl = '$baseUrl/storage/$imagePath';
  }
}

// SESUDAH - Parse dari Firestore (URL sudah full)
factory Product.fromJson(Map<String, dynamic> json) {
  String? imageUrl = json['image'];  // Sudah full URL dari Firebase Storage
  
  // Handle timestamp dari Firestore
  DateTime? createdAt;
  final createdAtValue = json['created_at'];
  if (createdAtValue is DateTime) {
    createdAt = createdAtValue;
  }
  
  final id = json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  return Product(
    id: id,
    // ... fields lain
    sellerId: json['seller_id'],
    createdAt: createdAt,
  );
}
```

---

## 4. main.dart

### Inisialisasi Firebase

```dart
// SEBELUM
void main() {
  runApp(...);
}

// SESUDAH
void main() async {
  // 1. Ensure Flutter bindings initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase
  await FirebaseConfig.initialize();
  
  // 3. Run app
  runApp(...);
}
```

**Mengapa penting:**
- `WidgetsFlutterBinding.ensureInitialized()` memastikan Flutter ready sebelum async operations
- `FirebaseConfig.initialize()` setup Firebase dengan credentials dari `firebase_options.dart`
- Tanpa ini, Firebase tidak akan bekerja

---

## 5. firebase_config.dart (NEW)

```dart
class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Collection names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  
  // Storage paths
  static const String profilePhotosPath = 'profile-photos';
  static const String productImagesPath = 'product-images';
}
```

---

## 6. firebase_options.dart (NEW)

Template untuk Firebase credentials per platform:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // ... other platforms
    }
  }
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '...', // TODO: Isi dari google-services.json
    appId: '...',
    projectId: '...',
    // ...
  );
}
```

**Catatan:** File ini WAJIB diisi dengan credentials Firebase project Anda!

---

## Perbandingan Data Flow

### Sebelum (Laravel)
```
App → HTTP Request → Laravel Server → MySQL Database
    ← JSON Response ← Laravel Server
```

### Sesudah (Firebase)
```
App → Firebase Auth/Firestore → Firebase Backend
    ← Real-time Updates ← Firebase
    
Photo Upload:
App → Firebase Storage → CDN
    ← Download URL ← Firebase
    
Simpan URL ke Firestore
```

---

## Kompatibilitas dengan UI Existing

Semua widget UI tetap bisa menggunakan API yang sama:

```dart
// UI Code - TIDAK PERLU DIUBAH!

// Dalam HomePage
final result = await ApiService.getProducts();
if (result['success']) {
  final products = result['data']['data'] as List;
  // Render products...
}

// Dalam SignInScreen
final result = await ApiService.signIn(email, password);
if (result['success']) {
  // Navigate to home...
}
```

Interface tetap sama, hanya implementasi yang berubah!

---

## Security Improvements

### Sebelum
- JWT token disimpan di local storage
- Expired token perlu di-refresh manual
- Password hashing di-handle oleh Laravel

### Sesudah
- Firebase Auth handle token management otomatis
- Refresh token transparent (Firebase SDK)
- Password hashing lebih aman (Firebase standard)
- Firestore Security Rules untuk fine-grained access control

---

## Error Handling

### Common Errors dan Solusi

```dart
// Error: "User not authenticated"
try {
  final userId = AuthService.currentUserId;
  if (userId == null) throw 'Not authenticated';
} catch (e) {
  return {'success': false, 'message': e.toString()};
}

// Error: "Unauthorized" (non-owner trying to update)
if (productData['seller_id'] != userId) {
  return {'success': false, 'message': 'Unauthorized'};
}

// Error: "Document not found"
if (!productDoc.exists) {
  return {'success': false, 'message': 'Product not found'};
}
```

---

## Testing Migration

```dart
// Test 1: Sign Up
final result = await ApiService.register(
  'John', 'Doe', 'john@example.com', 'pass123', 'pass123'
);
assert(result['success'] == true);

// Test 2: Sign In
final result = await ApiService.signIn('john@example.com', 'pass123');
assert(result['success'] == true);

// Test 3: Get Products
final result = await ApiService.getProducts();
assert(result['data']['data'] is List);

// Test 4: Current User
assert(AuthService.currentUser != null);
assert(AuthService.isLoggedIn == true);
```

Semua test harus PASS dengan implementasi baru!
