class AppConfig {
  // Ganti dengan URL backend Laravel Anda
  // Untuk Android Emulator menggunakan IP lokal host jika backend di Laragon aktif
  // Untuk iOS Simulator gunakan localhost atau 127.0.0.1
  // Untuk device fisik gunakan IP address komputer Anda

  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  // static const String baseUrl =
  //     'http://192.168.100.31:8000/api'; // Physical Device - GANTI x dengan IP Anda
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator

  // Debug: Cek URL yang digunakan
  static void logBaseUrl() {
    print('[AppConfig] Backend URL: $baseUrl');
  }
}
