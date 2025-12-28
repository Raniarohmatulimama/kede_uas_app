# LAPORAN PROYEK APLIKASI E-COMMERCE KELOMPOK 2

---

## DAFTAR ISI

1. [Pendahuluan](#1-pendahuluan)
2. [Persiapan & Setup](#2-persiapan--setup)
3. [Implementasi Autentikasi & User](#3-implementasi-autentikasi--user)
4. [Implementasi Data](#4-implementasi-data)
5. [Implementasi CRUD & Profil](#5-implementasi-crud--profil)
6. [Tampilan UI](#6-tampilan-ui)
7. [Penggunaan AI](#7-penggunaan-ai)
8. [Konfigurasi Environment](#8-konfigurasi-environment)

---

## 1. PENDAHULUAN

### 1.1 Studi Kasus

Proyek ini merupakan tugas individual Bab 9.5 - **Mobile Web Services Practicum** yang mengembangkan aplikasi e-commerce **KEDE** (Kelompok 2 Electronic Device). Aplikasi dikembangkan dalam dua fase: **Fase 1** mengembangkan mobile frontend menggunakan Flutter dengan SQLite lokal untuk penyimpanan data, fitur-fitur dasar seperti product listing, shopping cart, dan profil pengguna. **Fase 2** melanjutkan dengan implementasi backend REST API menggunakan Laravel, database MySQL terpusat, autentikasi JWT, dan fitur user management serta product CRUD lengkap.

Aplikasi dirancang untuk tiga segmen user: pembeli (browsing & pembelian produk elektronik), penjual (manajemen katalog produk), dan admin (monitoring sistem). Dengan backend, aplikasi mendapatkan keuntungan berupa data terpusat dan sinkronisasi multi-user, autentikasi aman dengan JWT token, password ter-hash bcrypt, multi-user support dengan role-based access, serta kemampuan upload file (foto profil & produk) ke server. Tech stack yang digunakan: **Frontend** (Flutter ↔ HTTP), **Backend** (Laravel API), dan **Database** (MySQL terpusat + SQLite cache lokal).

---

## 1.2 Tujuan Aplikasi

**Tujuan Pembelajaran:**
1. Memahami full-stack development (frontend + backend + database)
2. Mengintegrasikan Flutter dengan REST API Laravel
3. Menerapkan JWT Authentication
4. Implementasi Database Design dan relasi tabel
5. Mengelola File Upload & Storage
6. Best practices dalam API Development

**Tujuan Fungsional:**
1. Autentikasi pengguna yang aman
2. Manajemen profil user dengan foto
3. CRUD produk dengan kategori
4. Sinkronisasi data lokal dengan server
5. Error handling dan validasi
6. Performance optimization

**Tujuan Non-Fungsional:**
1. Code maintainability dan readability
2. Security best practices
3. Scalability untuk ekspansi fitur
4. Dokumentasi komprehensif
5. Testing dan debugging

---

## 2. PERSIAPAN & SETUP

### 2.1 Teknologi yang Digunakan

**Backend:**
- Framework: Laravel 11
- Database: MySQL / SQLite (development)
- Authentication: JWT (Tymon JWTAuth)
- Server: PHP 8.2+

**Frontend:**
- Framework: Flutter 3.x
- Language: Dart
- Local Database: SQLite dengan package `sqflite`
- State Management: Provider / GetX

**Tools & Environment:**
- Laragon 8.3.0 (Apache + MySQL + PHP stack)
- Git untuk version control
- Postman untuk API testing
- VS Code / Android Studio untuk development

### 2.2 Pembuatan Backend (Laravel)

#### Step 1: Inisialisasi Proyek Laravel
Jalankan perintah untuk membuat project Laravel baru bernama `kede-backend`:
```bash
laravel new kede-backend
cd kede-backend
```

Perintah ini akan secara otomatis membuat struktur project, menginstall dependencies, menghasilkan APP_KEY untuk encryption, dan menjalankan migrations awal untuk membuat tabel-tabel dasar (users, cache, jobs). Setelah itu, konfigurasi database dengan mengubah file `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kede_db
DB_USERNAME=root
DB_PASSWORD=
```

#### Step 2: Install Dependensi Authentication
```bash
composer require tymon/jwt-auth
php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider"
php artisan jwt:secret
```

#### Step 3: Persiapan Model, Controller & Migrations
Buat Model dan Migration untuk produk:
```bash
php artisan make:model Product -m
php artisan make:controller Api/AuthController
php artisan make:controller Api/ProductController --resource
```

Kemudian buat custom migrations untuk menambahkan kolom-kolom tambahan ke tabel users:
```bash
php artisan make:migration add_first_name_last_name_to_users_table
php artisan make:migration add_profile_photo_to_users_table
php artisan make:migration add_category_to_products_table
```

#### Step 4: Setup Database & Jalankan Migrations
Jalankan semua migrations untuk membuat tabel-tabel dan kolom-kolom di database:
```bash
php artisan migrate
php artisan db:seed
```

**Struktur Migrations yang dibuat:**

Folder `database/migrations/` berisi file-file migration yang mendefinisikan schema database. Urutan eksekusi migration didasarkan pada timestamp di nama file:

1. **Initial Migrations (Sistem Laravel):**
   - `0001_01_01_000000_create_users_table.php` - Membuat tabel users dasar
   - `0001_01_01_000001_create_cache_table.php` - Membuat tabel untuk caching
   - `0001_01_01_000002_create_jobs_table.php` - Membuat tabel untuk job queue

2. **Custom Migrations (Fitur Aplikasi):**
   - `2025_12_18_093002_create_personal_access_tokens_table.php` - Untuk token management
   - `2025_12_18_093400_create_products_table.php` - Membuat tabel products
   - `2025_12_18_100623_add_first_name_last_name_to_users_table.php` - Menambah first_name & last_name ke users
   - `2025_12_18_100639_add_first_name_last_name_to_users_table.php` - Revisi penambahan kolom users
   - `2025_12_18_100710_add_names_to_users.php` - Final adjustment untuk nama users
   - `2025_12_18_101732_rename_name_to_first_name_in_users_table.php` - Rename kolom name menjadi first_name
   - `2025_12_18_143900_add_category_to_products_table.php` - Menambah kolom category ke products
   - `2025_12_19_000000_add_profile_photo_to_users_table.php` - Menambah profile_photo_path ke users
   - `2025_12_19_000001_add_profile_photo_file_to_users_table.php` - Revisi untuk profile photo
   - `2025_12_19_100000_change_profile_photo_to_file_path.php` - Mengubah tipe kolom profile photo menjadi file path

Ketika menjalankan `php artisan migrate`, Laravel secara otomatis mengeksekusi semua migration file dalam urutan timestamp untuk membangun database schema yang lengkap.

### 2.3 Pembuatan Database

**Struktur Database:**

```sql
-- Tabel Users
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  phone VARCHAR(20) NULLABLE,
  profile_photo_path VARCHAR(255) NULLABLE,
  password_reset_token VARCHAR(255) NULLABLE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Tabel Products
CREATE TABLE products (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT FOREIGN KEY REFERENCES users(id),
  name VARCHAR(255),
  description TEXT,
  price DECIMAL(10,2),
  category VARCHAR(255),
  stock INTEGER,
  image VARCHAR(255) NULLABLE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### 2.4 Pembuatan Flutter App

#### Step 1: Inisialisasi Proyek Flutter
```bash
flutter create kelompok2
cd kelompok2
```

#### Step 2: Tambahkan Dependencies
File `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  sqflite: ^2.3.0
  shared_preferences: ^2.2.0
  provider: ^6.0.0
  image_picker: ^1.0.0
  jwt_decoder: ^2.0.0
```

#### Step 3: Setup Local Database
```bash
flutter pub get
```

### 2.5 Menghubungkan Flutter dengan Backend

#### Step 1: Buat Service untuk API Communication
File `lib/services/api_service.dart`:
```dart
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static Future<http.Response> post(
    String endpoint, 
    Map<String, dynamic> body,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
  
  static Future<http.Response> get(
    String endpoint,
    {String? token}
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}
```

#### Step 2: Buat AuthService untuk Manage Token
File `lib/services/auth_service.dart`:
```dart
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
```

#### Step 3: Jalankan Backend Server
```bash
php artisan serve --host 0.0.0.0 --port 8000
```

---

## 3. IMPLEMENTASI AUTENTIKASI & USER

### 3.1 Alur Login/Registrasi

#### Proses Login:
```
User Input Email & Password
        ↓
POST /api/login (email, password)
        ↓
Backend: Verify Credentials
        ↓
Return: JWT Token + User Data
        ↓
Frontend: Save Token (SharedPreferences)
        ↓
Navigate to Home Screen
```

#### Proses Registrasi:
```
User Input: first_name, last_name, email, password
        ↓
POST /api/register (all fields)
        ↓
Backend: Create User + Hash Password
        ↓
Return: JWT Token + User Data
        ↓
Frontend: Save Token & Redirect to Home
```

### 3.2 Implementasi Backend Autentikasi

File `app/Http/Controllers/Api/AuthController.php`:

```php
class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'first_name' => $user->first_name,
                    'last_name' => $user->last_name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'profile_photo_url' => $this->getProfilePhotoUrl($user->profile_photo_path),
                ],
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => auth('api')->factory()->getTTL() * 60,
            ]
        ], 201);
    }

    /**
     * Login user and create JWT token
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $credentials = $request->only('email', 'password');

        if (!$token = JWTAuth::attempt($credentials)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password'
            ], 401);
        }

        $user = JWTAuth::user();

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'first_name' => $user->first_name,
                    'last_name' => $user->last_name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'profile_photo_url' => $this->getProfilePhotoUrl($user->profile_photo_path),
                ],
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => auth('api')->factory()->getTTL() * 60,
            ]
        ]);
    }

    /**
     * Get authenticated user profile
     */
    public function profile(Request $request)
    {
        $user = auth('api')->user();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'first_name' => $user->first_name,
                    'last_name' => $user->last_name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'profile_photo_url' => $this->getProfilePhotoUrl($user->profile_photo_path),
                ]
            ]
        ]);
    }
}
```

### 3.3 Menyimpan Token di Frontend

File `lib/services/auth_service.dart`:

```dart
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Save token after login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Save user data
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }
  
  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Get user data
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
  
  // Clear on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
```

---

## 4. IMPLEMENTASI DATA

### 4.1 Struktur Data

#### User Model (Backend)
```php
class User extends Authenticatable implements JWTSubject
{
    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'password',
        'phone',
        'profile_photo_path',
    ];
    
    public function products()
    {
        return $this->hasMany(Product::class);
    }
}
```

Model User di backend berfungsi sebagai representasi tabel users di database. Kelas ini `extends Authenticatable` yang memungkinkan user untuk login, dan `implements JWTSubject` yang memungkinkan user untuk menghasilkan JWT token untuk autentikasi API. Property `$fillable` mendefinisikan field-field mana saja yang boleh diisi melalui mass-assignment, yaitu first_name, last_name, email, password, phone, dan profile_photo_path. Method `products()` mendefinisikan relasi one-to-many yang berarti 1 user bisa memiliki banyak produk, dan Laravel secara otomatis akan mencari foreign key `user_id` di tabel products untuk menghubungkan relasi tersebut.

#### User Model (Frontend - Dart)
```dart
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
```

Di frontend, class User merepresentasikan data user di aplikasi Flutter. Setiap property didefinisikan sebagai `final` untuk membuat data immutable (tidak bisa diubah setelah dibuat), yang memastikan konsistensi data. Type `String?` dengan tanda tanya berarti field tersebut bisa bernilai string atau null. Constructor menerima parameter dengan `required` untuk field wajib dan optional untuk field yang tidak wajib. Factory method `fromJson()` berfungsi untuk mengkonversi JSON response dari API menjadi Dart object dengan mengambil data dari API yang menggunakan snake_case (seperti `first_name`) dan mengkonversinya ke camelCase Dart (seperti `firstName`).

#### Product Model (Backend)
```php
class Product extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'description',
        'price',
        'category',
        'stock',
        'image',
    ];
    
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

Model Product merepresentasikan tabel products dengan field-field yang dapat diisi termasuk user_id (foreign key), name, description, price, category, stock, dan image. Property `$fillable` mendefinisikan field mana yang aman untuk mass-assignment dari request. Method `user()` mendefinisikan inverse relationship (relasi many-to-one) dimana setiap produk hanya dimiliki oleh 1 user. Melalui relasi ini, kita bisa mengakses user pemilik produk dengan cara `$product->user()`.

#### Product Model (Frontend - Dart)
```dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final String? image;
  final int userId;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    this.image,
    required this.userId,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      stock: json['stock'],
      image: json['image'],
      userId: json['user_id'],
    );
  }
}
```

Product model di frontend serupa dengan User model, namun menyimpan data produk. Type `double` untuk price dipilih agar lebih akurat untuk nilai desimal dibandingkan `int`. Factory method `fromJson()` melakukan parsing dengan konversi tipe data - price dari API mungkin berbentuk string atau integer, maka diperlukan `double.parse()` untuk mengkonversinya menjadi double. Field `userId` menyimpan referensi ke user pemilik produk (foreign key), sehingga kita tahu siapa yang membuat produk tersebut. Pattern `fromJson()` adalah best practice standard untuk menangani JSON deserialization di Dart.

### 4.2 Relasi User dan Produk

**Relasi Database:**
- 1 User : Many Products (One-to-Many)
- Setiap user dapat memiliki multiple produk
- Setiap produk hanya dimiliki oleh 1 user

```
Users Table
    ↓ (1)
    ├─── (Many) ─→ Products Table
```

### 4.3 Pemanggilan API

#### Login API Call (Frontend)
```dart
Future<bool> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['access_token'];
      final user = data['data']['user'];
      
      await AuthService.saveToken(token);
      await AuthService.saveUser(user);
      return true;
    }
    return false;
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}
```

Fungsi login melakukan POST request ke endpoint `/api/login` dengan mengirimkan email dan password user. Alamat `10.0.2.2` adalah IP khusus untuk mengakses localhost dari emulator Android. Header `Content-Type: application/json` memberi tahu server bahwa data yang dikirim dalam format JSON. Setelah server merespons dengan status code 200 (berhasil), kode akan melakukan parsing pada JSON response menggunakan `jsonDecode()`, kemudian mengekstrak JWT token dan data user dari response. Token tersebut disimpan ke SharedPreferences menggunakan `AuthService.saveToken()` agar dapat digunakan untuk request-request berikutnya tanpa perlu login ulang. Jika ada error atau status code tidak 200, fungsi akan return false yang menunjukkan login gagal.

#### Get Products API Call (Frontend)
```dart
Future<List<Product>> getProducts() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/products'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> products = data['data'];
      return products.map((p) => Product.fromJson(p)).toList();
    }
    return [];
  } catch (e) {
    print('Get products error: $e');
    return [];
  }
}
```

Fungsi getProducts melakukan GET request ke endpoint `/api/products` untuk mengambil list semua produk dari server. Response yang didapat di-parse dengan `jsonDecode()` dan mengekstrak array products dari field `data` dalam JSON response. Kemudian menggunakan `.map()` untuk melakukan transformasi setiap item dari JSON object menjadi Dart object Product dengan memanggil `Product.fromJson()` untuk setiap item. Setelah itu `.toList()` digunakan untuk mengkonversi hasil map (iterable) menjadi List. Jika ada error atau status code tidak 200, fungsi akan mengembalikan list kosong `[]`.

---

## 5. IMPLEMENTASI CRUD & PROFIL

### 5.1 CRUD Produk

#### CREATE - Tambah Produk Baru

**Backend (Laravel):**
```php
public function store(Request $request)
{
    $request->validate([
        'name' => 'required|string|max:255',
        'description' => 'nullable|string',
        'price' => 'required|numeric|min:0',
        'category' => 'required|string|max:255',
        'stock' => 'required|integer|min:0',
        'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
    ]);

    $data = $request->only(['name', 'description', 'price', 'category', 'stock']);
    $data['user_id'] = $request->user()->id;

    if ($request->hasFile('image')) {
        $imagePath = $request->file('image')->store('products', 'public');
        $data['image'] = $imagePath;
    }

    $product = Product::create($data);

    return response()->json([
        'success' => true,
        'message' => 'Product created successfully',
        'data' => $product->load('user:id,name,email')
    ], 201);
}
```

Method store() menangani pembuatan produk baru. Pertama, kode melakukan validasi input dengan `$request->validate()` yang memastikan semua data sesuai dengan aturan (name wajib string max 255 karakter, description opsional, price harus numeric minimal 0, category wajib string, stock harus integer minimal 0, dan image opsional dengan tipe jpeg/png/jpg/gif maksimal 2MB). Kemudian mengambil data dari request dengan `only()` untuk keamanan, dan menambahkan `user_id` dari user yang sedang login agar produk ter-assign ke pemiliknya. Jika ada file image yang di-upload, kode akan menyimpannya ke storage folder `products` dengan disk `public` dan menyimpan path-nya. Setelah itu produk dibuat dengan `Product::create()` dan method `load('user:id,name,email')` digunakan untuk eager loading relasi user dengan hanya mengambil kolom id, name, dan email. Response mengembalikan status 201 (Created) beserta data produk yang baru dibuat.

**Frontend (Flutter):**
```dart
Future<bool> createProduct(Product product, File? imageFile) async {
  try {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/products'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = product.name;
    request.fields['description'] = product.description;
    request.fields['price'] = product.price.toString();
    request.fields['category'] = product.category;
    request.fields['stock'] = product.stock.toString();
    
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }
    
    final response = await request.send();
    return response.statusCode == 201;
  } catch (e) {
    print('Create product error: $e');
    return false;
  }
}
```

Fungsi createProduct di frontend mengirim data produk baru ke server dengan format multipart untuk mendukung upload file image. Menggunakan `MultipartRequest` karena perlu mengirim form data dan file bersamaan. Token JWT diambil dari storage dan ditambahkan ke header Authorization untuk autentikasi. Semua field produk ditambahkan ke `request.fields` dengan konversi toString() untuk price dan stock karena multipart hanya menerima string. Jika ada imageFile, file tersebut ditambahkan ke request menggunakan `MultipartFile.fromPath()` yang membaca file dari path lokal. Request dikirim dengan `request.send()` dan mengecek apakah status code 201 yang menandakan produk berhasil dibuat.

#### READ - Ambil Data Produk
```php
// Get all products
public function index()
{
    $products = Product::with('user:id,name,email')->latest()->get();
    return response()->json([
        'success' => true,
        'data' => $products
    ]);
}

// Get single product
public function show(string $id)
{
    $product = Product::with('user:id,name,email')->find($id);
    if (!$product) {
        return response()->json(['success' => false], 404);
    }
    return response()->json(['success' => true, 'data' => $product]);
}
```

Method index() mengambil semua produk dari database dengan `Product::with('user:id,name,email')` untuk eager loading relasi user (hanya mengambil kolom id, name, email untuk efisiensi). Method `latest()` mengurutkan produk berdasarkan tanggal terbaru terlebih dahulu, dan `get()` mengeksekusi query untuk mendapatkan semua data. Method show() mengambil 1 produk spesifik berdasarkan id dengan `find($id)`. Jika produk tidak ditemukan, akan return response dengan status 404 (Not Found). Jika ditemukan, return data produk beserta informasi user pemiliknya. Kedua method menggunakan eager loading untuk menghindari N+1 query problem dan meningkatkan performa.

#### UPDATE - Edit Produk
```php
public function update(Request $request, string $id)
{
    $product = Product::find($id);
    if (!$product) {
        return response()->json(['success' => false], 404);
    }
    
    if ($product->user_id !== $request->user()->id) {
        return response()->json(['success' => false], 403);
    }
    
    $product->update($request->only(['name', 'description', 'price', 'category', 'stock']));
    
    return response()->json([
        'success' => true,
        'message' => 'Product updated successfully',
        'data' => $product
    ]);
}
```

Method update() menangani edit produk existing. Pertama mencari produk berdasarkan id dengan `find($id)`, jika tidak ada return 404. Kemudian melakukan authorization check dengan membandingkan `$product->user_id` dengan id user yang sedang login untuk memastikan hanya pemilik produk yang bisa edit. Jika user_id tidak cocok, return status 403 (Forbidden) yang artinya user tidak punya permission untuk action tersebut. Jika validasi lolos, produk di-update dengan `$product->update()` menggunakan data dari request. Method `only()` memastikan hanya field yang diizinkan saja yang bisa diubah (name, description, price, category, stock), mencegah mass-assignment vulnerability. Response mengembalikan status success beserta data produk yang sudah di-update.

#### DELETE - Hapus Produk
```php
public function destroy(Request $request, string $id)
{
    $product = Product::find($id);
    if (!$product) {
        return response()->json(['success' => false], 404);
    }
    
    if ($product->user_id !== $request->user()->id) {
        return response()->json(['success' => false], 403);
    }
    
    if ($product->image) {
        Storage::disk('public')->delete($product->image);
    }
    
    $product->delete();
    
    return response()->json(['success' => true, 'message' => 'Product deleted']);
}
```

Method destroy() menangani penghapusan produk. Sama seperti update, pertama mencari produk dengan `find($id)` dan return 404 jika tidak ada. Kemudian melakukan authorization check untuk memastikan hanya pemilik produk yang bisa menghapus dengan membandingkan user_id, return 403 jika tidak match. Sebelum menghapus record dari database, kode mengecek apakah produk punya image. Jika ada, image file di-delete dari storage dengan `Storage::disk('public')->delete($product->image)` untuk mencegah file orphan yang memakan disk space. Setelah file image dihapus, baru produk dihapus dari database dengan `$product->delete()`. Response mengembalikan pesan sukses bahwa produk telah dihapus.

### 5.2 Edit Profil User

#### Update Profile

**Backend:**
```php
public function updateProfile(Request $request)
{
    $user = auth('api')->user();

    $request->validate([
        'first_name' => 'sometimes|required|string|max:255',
        'last_name' => 'sometimes|required|string|max:255',
        'email' => 'sometimes|required|email|max:255|unique:users,email,' . $user->id,
        'phone' => 'sometimes|required|string|max:20',
    ]);

    $user->update($request->only(['first_name', 'last_name', 'email', 'phone']));

    return response()->json([
        'success' => true,
        'message' => 'Profile updated successfully',
        'data' => ['user' => $user]
    ]);
}
```

Method updateProfile() menangani update data profil user yang sedang login. User diambil dengan `auth('api')->user()` yang menggunakan JWT token untuk identifikasi. Validasi menggunakan rule `sometimes` yang berarti field hanya divalidasi jika ada di request (partial update), sehingga user bisa update hanya beberapa field tanpa harus kirim semua. Untuk email, rule `unique:users,email,' . $user->id` memastikan email unique tapi mengecualikan email user sendiri (agar user bisa keep email yang sama). Setelah validasi, user data di-update dengan `$user->update()` menggunakan hanya field yang diizinkan. Response mengembalikan data user yang sudah ter-update.

**Frontend:**
```dart
Future<bool> updateProfile({
  String? firstName,
  String? lastName,
  String? email,
  String? phone,
}) async {
  try {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await AuthService.saveUser(data['data']['user']);
      return true;
    }
    return false;
  } catch (e) {
    print('Update profile error: $e');
    return false;
  }
}
```

Fungsi updateProfile di frontend mengirim PUT request untuk update profil user. Parameter function menggunakan named optional parameters dengan nullable type (String?) sehingga caller bisa pilih field mana saja yang mau di-update (partial update). Body request dibuat secara dynamic dengan mengecek parameter mana yang tidak null, hanya field yang diisi yang akan dikirim ke server. Token JWT ditambahkan ke Authorization header untuk autentikasi. Menggunakan `http.put()` karena operasi update biasanya menggunakan HTTP method PUT. Jika response berhasil (status 200), data user yang baru dari server disimpan ke local storage dengan `AuthService.saveUser()` untuk sinkronisasi, sehingga UI langsung reflect perubahan tanpa perlu reload atau fetch ulang.

#### Upload Foto Profil

**Backend:**
```php
public function upload(Request $request)
{
    $request->validate([
        'photo' => 'required|image|mimes:jpeg,png,jpg|max:2048',
    ]);
    
    $user = auth('api')->user();
    
    if ($user->profile_photo_path) {
        Storage::disk('public')->delete($user->profile_photo_path);
    }
    
    $path = $request->file('photo')->store('profile-photos', 'public');
    $user->profile_photo_path = $path;
    $user->save();
    
    return response()->json([
        'success' => true,
        'message' => 'Profile photo uploaded',
        'data' => ['photo_url' => $this->getProfilePhotoUrl($path)]
    ]);
}
```

Method upload() menangani upload foto profil user. Validasi memastikan file yang di-upload adalah image dengan format jpeg/png/jpg dan ukuran maksimal 2MB (2048 KB). User yang sedang login diambil dengan `auth('api')->user()`. Sebelum upload foto baru, kode mengecek apakah user sudah punya foto profil sebelumnya dengan `$user->profile_photo_path`. Jika ada, foto lama dihapus dari storage dengan `Storage::disk('public')->delete()` untuk mencegah penumpukan file yang tidak terpakai. Foto baru disimpan ke folder `profile-photos` di disk `public` dengan `store()` yang otomatis generate unique filename. Path file disimpan ke field `profile_photo_path` di database user dan di-save. Response mengembalikan URL lengkap foto profil dengan helper `getProfilePhotoUrl($path)` agar frontend bisa langsung display image tersebut.

---

## 6. TAMPILAN UI

### 6.1 Alur Navigasi Aplikasi

```
Splash Screen
    ↓
┌─── Check Token ───┐
│                   │
NO TOKEN         HAS TOKEN
│                   │
↓                   ↓
Welcome Screen   Home Screen
│                   ├─ All Products
├─ Login            ├─ My Products
├─ Register         ├─ Shopping Cart
└─ Forgot Password  ├─ Profile
                    │  ├─ Edit Profile
                    │  ├─ Upload Photo
                    │  └─ Change Password
                    └─ Logout
```

### 6.2 Deskripsi Layar Utama

#### 1. **Splash Screen**
- Menampilkan logo/branding aplikasi
- Melakukan pengecekan auto-login menggunakan token tersimpan
- Loading animation selama proses inisialisasi

#### 2. **Welcome Screen** (Belum Login)
- Tombol Login
- Tombol Register
- Link Forgot Password

#### 3. **Login Screen**
- Input Email
- Input Password (dengan eye icon toggle)
- Tombol Login
- Link Register & Forgot Password

#### 4. **Register Screen**
- Input First Name
- Input Last Name
- Input Email
- Input Password
- Input Confirm Password
- Tombol Register
- Link Login

#### 5. **Home Screen** (Dashboard)
- Navbar dengan navigasi:
  - All Products (tabel/grid view)
  - My Products
  - Shopping Cart
  - Profile
- Search & Filter produk

#### 6. **All Products Screen**
- Grid/List view produk
- Setiap card menampilkan:
  - Foto produk
  - Nama & kategori
  - Harga
  - Stock
  - Tombol detail/add to cart

#### 7. **Product Detail Screen**
- Foto produk (swipeable)
- Deskripsi lengkap
- Harga & stock
- Nama seller
- Tombol Add to Cart / Buy Now
- Reviews & rating

#### 8. **My Products Screen** (Admin)
- List produk milik user
- Tombol Add Product
- Edit & Delete untuk setiap produk

#### 9. **Shopping Cart Screen**
- List item di keranjang
- Quantity adjuster
- Total harga
- Tombol Checkout

#### 10. **Profile Screen**
- Foto profil (dengan upload button)
- Nama & email (dengan edit button)
- Nomor telepon
- Tombol Edit Profile
- Tombol Change Password
- Tombol Logout

#### 11. **Edit Profile Screen**
- Form edit first name, last name, email, phone
- Tombol Save Changes
- Validation & error messages

#### 12. **Change Password Screen**
- Input password lama
- Input password baru
- Input konfirmasi password baru
- Tombol Update Password

### 6.3 Fitur-Fitur Penting Aplikasi

#### 1. Authentication (Autentikasi)
Sistem autentikasi memungkinkan pengguna untuk membuat akun baru, login, dan reset password. Fitur Sign In menerima input email dan password untuk masuk ke akun. Fitur Create Account meminta user mengisi nama depan, nama belakang, email, dan password dengan menyetujui terms and condition. Fitur Forgot Password membantu user yang lupa password dengan memverifikasi email mereka terlebih dahulu, kemudian user dapat membuat password baru. Setelah berhasil reset password, user akan diarahkan kembali ke halaman Sign In.

#### 2. Home/Dashboard
Halaman utama menampilkan personalisasi sapaan berdasarkan status login user. Untuk user yang sudah login, sapaan menampilkan nama mereka (contoh: "Good Morning Bagus Rizky"), sedangkan user yang belum login hanya mendapat sapaan "Good Morning pengguna". Halaman ini menampilkan banner promosi, kategori produk dalam bentuk icon yang dapat diklik, dan section Trending Deals yang menampilkan produk-produk populer dengan gambar, nama, harga, dan icon wishlist.

#### 3. Product Management (Manajemen Produk)
Sistem manajemen produk yang komprehensif memungkinkan user untuk melihat, menambah, mengedit, dan menghapus produk. Halaman All Products menampilkan seluruh produk dalam grid format dengan search bar untuk pencarian. Setiap produk ditampilkan dalam card yang berisi gambar, nama, dan harga. User dapat menambah produk baru melalui form Add Product yang meminta input foto, nama produk, deskripsi, kategori, harga, dan stok. Namun, fitur penambahan produk ini hanya tersedia untuk user yang sudah login—user yang belum login akan mendapat peringatan dan diarahkan ke halaman Sign In.

#### 4. Categories (Kategori)
Sistem kategori mengorganisir produk berdasarkan jenisnya: Fruits, Vegetables, Mushroom, Dairy, Oats, dan Bread. Setiap kategori menampilkan jumlah item yang ada di dalamnya secara dinamis sesuai dengan jumlah produk aktual. User dapat mengklik icon kategori dari homepage untuk langsung masuk ke halaman kategori spesifik tersebut, atau mengklik tombol panah di section Categories untuk melihat semua produk di halaman All Products.

#### 5. My Profile
Halaman My Profile adalah halaman profil user yang menampilkan informasi lengkap user termasuk foto profil, Full Name, User Name, Email Address, dan Phone Number. Fitur ini hanya dapat diakses oleh pengguna yang sudah login—jika pengguna belum login, sistem akan menampilkan dialog "Login Required" dengan pesan "You need to login to access your profile. Please sign in to continue" dan tombol "Go to Sign In" untuk mengarahkan ke halaman login.

**Fitur CRUD Foto Profil:**
User dapat melakukan CRUD (Create, Read, Update, Delete) pada foto profil dengan tiga opsi:
- **Create/Take Photo**: Mengambil foto baru menggunakan kamera perangkat
- **Update/Choose from Gallery**: Memilih foto dari galeri perangkat untuk mengganti foto profil yang ada
- **Delete/Remove Photo**: Menghapus foto profil yang ada

Setiap kali melakukan operasi pada foto profil, sistem akan menghapus foto lama terlebih dahulu sebelum menyimpan foto baru untuk menghemat storage, kemudian menampilkan preview foto yang telah diupload.

**Fitur Penambahan Nomor Telepon:**
Field nomor telepon dapat ditambahkan atau diubah melalui halaman My Profile. User dapat mengklik icon edit hijau di sebelah nomor telepon untuk menambahkan atau mengubah nomor. Setelah memasukkan nomor telepon baru, user harus mengklik tombol "Save" atau "Update" untuk menyimpan perubahan. Sistem akan memvalidasi format nomor telepon dan menampilkan notifikasi "Profile updated successfully" ketika data berhasil disimpan.

**Fitur Edit Informasi:**
Semua field informasi profil (Full Name, User Name, Email Address) dapat diedit dengan mengklik icon edit berwarna hijau di samping masing-masing field. Setelah mengedit, sistem akan menampilkan notifikasi "Profile updated successfully" untuk mengkonfirmasi bahwa perubahan berhasil disimpan.

**Akses Terbatas:**
Fitur My Profile hanya tersedia untuk pengguna yang sudah login. Sistem menggunakan JWT token yang tersimpan di SharedPreferences untuk mengidentifikasi user. Jika token tidak ditemukan atau sudah expired, pengguna akan diminta untuk login kembali sebelum dapat mengakses dan memodifikasi informasi profil mereka.

#### 6. Logout
Fitur logout dilengkapi dengan konfirmasi untuk mencegah logout yang tidak disengaja. Ketika user memilih logout, muncul dialog "Logout Confirmation" dengan pesan konfirmasi. User dapat memilih "Cancel" untuk membatalkan atau "Logout" untuk melanjutkan. Setelah logout berhasil, user akan dikembalikan ke halaman Welcome Page sebagai halaman awal aplikasi.

#### 7. Wishlist
Fitur wishlist memungkinkan user menyimpan produk-produk favorit mereka untuk dilihat atau dibeli nanti. Setiap card produk memiliki icon hati yang dapat diklik untuk menambah atau menghapus produk dari wishlist. Daftar produk wishlist dapat diakses melalui navigation bar di bagian bawah aplikasi.

#### 8. Shopping Cart
Keranjang belanja memungkinkan user menambahkan produk yang ingin dibeli. User dapat mengatur jumlah quantity untuk setiap produk, melihat total harga, dan melanjutkan ke proses checkout. Icon cart di navigation bar menampilkan jumlah item yang ada di keranjang.

#### 9. Search & Filter
Sistem pencarian tersedia di berbagai halaman seperti All Products dan halaman kategori. User dapat mengetik keyword di search bar untuk mencari produk berdasarkan nama. Filter kategori membantu user menyaring produk berdasarkan jenis kategori tertentu.

#### 10. Load More
Tombol "LOAD MORE" berwarna hijau memungkinkan user memuat lebih banyak produk tanpa harus scroll terlalu jauh. Ketika diklik, tombol ini akan mengarahkan user ke halaman All Products yang menampilkan seluruh katalog produk.

#### 11. Notifications
Sistem notifikasi memberikan feedback kepada user tentang berbagai aksi seperti profile berhasil diupdate, produk berhasil ditambahkan, atau peringatan ketika user belum login namun mencoba mengakses fitur yang memerlukan autentikasi.

#### 12. Navigation
Navigation bar di bagian bawah aplikasi menyediakan akses cepat ke 5 halaman utama: Home, Explore, Cart, Wishlist, dan Profile. Desain ini memudahkan user untuk berpindah antar halaman dengan cepat dan intuitif.

---

## 7. PENGGUNAAN AI

### 7.1 AI yang Digunakan

**GitHub Copilot** - Asisten coding berbasis AI yang membantu dalam:
- Code completion dan suggestions
- Debugging dan error resolution
- Code generation untuk boilerplate dan struktur code
- Best practices recommendations dalam penulisan kode

**ChatGPT** - Model language AI yang membantu dalam:
- Konsultasi desain API dan architecture
- Troubleshooting kompleks dan error handling
- Dokumentasi & penjelasan konsep teknis
- Research & problem solving untuk berbagai masalah development

### 7.2 Kontribusi AI dalam Proyek

#### 1. **Backend Development**
- Membantu struktur folder dan naming conventions
- Generate migration code untuk database changes
- Code review dan optimization suggestions
- API endpoint design consultation

#### 2. **Frontend Development**
- Flutter widget implementation suggestions
- State management pattern recommendations
- Form validation logic generation
- UI/UX flow optimization

#### 3. **Problem Solving**
- Debug "Connection closed" error saat upload foto
- Resolve pagination issue (10 produk limit → all produk)
- Token validation flow optimization
- SQLite sync dengan backend API

#### 4. **Documentation & Testing**
- Generate API documentation
- Create test cases & scenarios
- Write comprehensive comments
- Create troubleshooting guides

### 7.3 Contoh Bantuan AI dalam Proyek

**Kasus 1: Foto Profil Tidak Ter-load**
- **Masalah**: URL foto return "Connection closed"
- **Solusi AI**: 
  - Suggest membuat dedicated API route untuk file serving
  - Recommend response headers untuk caching
  - Provide implementation untuk `getProfilePhotoUrl()` helper

**Kasus 2: Reset Password Invalid Token**
- **Masalah**: Frontend dapat 401 saat reset password
- **Solusi AI**:
  - Explain Hash::check() vs plaintext comparison
  - Debug token flow (forgot → reset)
  - Provide test script untuk verify flow

**Kasus 3: Pagination Produk**
- **Masalah**: Hanya 10 produk ter-load, padahal ada 15
- **Solusi AI**:
  - Identify hardcoded `paginate(10)` di controller
  - Suggest `->get()` untuk get all atau configurable pagination
  - Provide updated code

---

## 8. KONFIGURASI ENVIRONMENT

### 8.1 File .env Backend

File lokasi: `d:/laragon/www/kede-backend/.env`

```env
# ===== APPLICATION CONFIGURATION =====
# Nama aplikasi yang akan ditampilkan di log dan error page
APP_NAME=KEDE-Backend

# Environment mode: local (development), staging, production
# Mempengaruhi error handling dan logging behavior
APP_ENV=local

# Encryption key untuk mengenkripsi data sensitif di Laravel
# Generate otomatis dengan: php artisan key:generate
APP_KEY=base64:your_app_key_here

# Debug mode - true untuk development (tampilkan error detail)
# HARUS false di production untuk keamanan
APP_DEBUG=true

# URL aplikasi yang diakses oleh client
APP_URL=http://127.0.0.1:8000

# ===== LOGGING CONFIGURATION =====
# Channel untuk logging: stack, single, daily, syslog
LOG_CHANNEL=stack

# Level logging: debug, info, notice, warning, error, critical, alert, emergency
# Debug = tampilkan semua log, Production biasanya warning ke atas
LOG_LEVEL=debug

# ===== DATABASE CONFIGURATION =====
# Driver database: mysql, sqlite, pgsql, sqlserver
DB_CONNECTION=mysql

# Host server database (127.0.0.1 = localhost)
DB_HOST=127.0.0.1

# Port database MySQL (default 3306)
DB_PORT=3306

# Nama database yang dibuat di MySQL
DB_DATABASE=kede_db

# Username untuk akses database (default root di Laragon)
DB_USERNAME=root

# Password database (kosong jika tidak ada password)
DB_PASSWORD=

# ===== JWT AUTHENTICATION CONFIGURATION =====
# Secret key untuk signing JWT token
# Generate dengan: php artisan jwt:secret
JWT_SECRET=your_jwt_secret_key

# Algorithm untuk JWT: HS256, HS384, HS512, RS256, RS384, RS512
# HS256 = HMAC dengan SHA256 (paling umum dan cepat)
JWT_ALGORITHM=HS256

# JWT expiration time dalam detik (3600 = 1 jam)
# Setelah waktu expired, user harus login ulang
JWT_EXPIRES=3600

# ===== CACHE & SESSION CONFIGURATION =====
# Driver caching: file, database, redis, memcached
# File = menyimpan cache di folder storage/framework/cache
CACHE_DRIVER=file

# Driver session storage: file, cookie, database, redis
# File = menyimpan session di storage/framework/sessions
SESSION_DRIVER=file

# Queue connection: sync, database, redis, beanstalkd, sqs, null
# Sync = execute job langsung (blocking), development biasanya gunakan ini
QUEUE_CONNECTION=sync

# ===== MAIL CONFIGURATION (OPTIONAL) =====
# Mail service: smtp, sendmail, mailgun, postmark, ses, log, array
# Log = hanya log email ke storage/logs (tidak benar-benar kirim)
MAIL_MAILER=log

# Email address yang digunakan sebagai pengirim (From)
MAIL_FROM_ADDRESS=noreply@example.com

# ===== FILE STORAGE CONFIGURATION =====
# Disk untuk menyimpan file: local, public, s3
# Public = menyimpan di public/storage (accessible via URL)
FILESYSTEM_DISK=public

# Base URL untuk akses file yang disimpan (relative path)
# Lengkap: http://127.0.0.1:8000/storage
FILESYSTEM_URL=/storage

# ===== REDIS CONFIGURATION (OPTIONAL) =====
# Host server Redis untuk caching/session yang lebih cepat
# Hanya diperlukan jika menggunakan Redis
REDIS_HOST=127.0.0.1

# Password Redis (null = tidak ada password)
REDIS_PASSWORD=null

# Port Redis (default 6379)
REDIS_PORT=6379

# ===== API & CORS CONFIGURATION =====
# Domain yang diizinkan untuk stateful API (Sanctum)
# Untuk multi-domain: 127.0.0.1:3000, localhost:3000
SANCTUM_STATEFUL_DOMAINS=127.0.0.1:3000

# Origins yang diizinkan akses API (CORS - Cross-Origin Resource Sharing)
# http://localhost:* = izinkan semua port dari localhost
# Untuk production, spesifik domain: https://example.com
CORS_ALLOWED_ORIGINS=http://localhost:*

# Base URL API untuk Flutter development
# 10.0.2.2 = cara emulator Android mengakses localhost host machine
# Di device fisik, ganti dengan IP LAN server: http://192.168.x.x:8000/api
API_BASE_URL=http://10.0.2.2:8000/api
```

### 8.2 Penjelasan Variabel Environment

| Variable | Penjelasan |
|----------|-----------|
| `APP_NAME` | Nama aplikasi backend |
| `APP_ENV` | Environment: local, staging, production |
| `APP_KEY` | Encryption key untuk Laravel |
| `APP_DEBUG` | Debug mode (true untuk development) |
| `DB_CONNECTION` | Driver database (mysql, sqlite, dll) |
| `DB_DATABASE` | Nama database |
| `DB_USERNAME` | Username database |
| `DB_PASSWORD` | Password database |
| `JWT_SECRET` | Secret key untuk JWT signing |
| `JWT_EXPIRES` | JWT expiration time (dalam detik) |
| `MAIL_MAILER` | Service email provider |
| `FILESYSTEM_DISK` | Disk untuk file storage (local, public, s3) |
| `API_BASE_URL` | URL dasar API (untuk client) |

### 8.3 File pubspec.yaml Flutter

File lokasi: `lib/pubspec.yaml`

```yaml
name: kelompok2
description: "E-commerce Flutter Application"
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Networking
  http: ^1.1.0
  
  # Local Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # State Management
  provider: ^6.0.0
  
  # Local Storage
  shared_preferences: ^2.2.0
  
  # Authentication
  jwt_decoder: ^2.0.0
  
  # Image Handling
  image_picker: ^1.0.0
  
  # UI/UX
  google_fonts: ^6.0.0
  smooth_page_indicator: ^1.1.0
  
  # Date & Time
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

### 8.4 Struktur Folder Backend

```
kede-backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       ├── AuthController.php
│   │   │       ├── ProductController.php
│   │   │       └── ProfilePhotoController.php
│   │   └── Middleware/
│   ├── Models/
│   │   ├── User.php
│   │   └── Product.php
│   └── Rules/
│       └── Base64Image.php
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
├── storage/
│   ├── app/
│   │   └── public/
│   │       ├── profile-photos/
│   │       └── products/
│   └── logs/
├── .env
├── .env.example
└── composer.json
```

### 8.5 Struktur Folder Frontend

```
kelompok2/
├── lib/
│   ├── main.dart
│   ├── config/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── product_model.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── database_service.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       └── edit_profile_screen.dart
│   ├── widgets/
│   └── utils/
├── assets/
│   ├── images/
│   └── icons/
├── pubspec.yaml
└── README.md
```

---

## KESIMPULAN

Aplikasi e-commerce ini menggabungkan teknologi modern (Flutter + Laravel + JWT) dengan best practices dalam development. Implementasi mencakup:

✅ Autentikasi aman dengan JWT
✅ RESTful API yang terstruktur
✅ Database relasional yang efisien
✅ UI/UX yang user-friendly
✅ Fitur CRUD lengkap
✅ File upload & storage management
✅ Error handling & validation
✅ Dokumentasi komprehensif

Dengan bantuan AI tools, proses development menjadi lebih cepat dan efisien, namun tetap memperhatikan best practices dan code quality.

---

**END OF REPORT**
