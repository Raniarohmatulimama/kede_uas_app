import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  // Base API URL
 
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Emulator


  // Base host (without /api) used for serving files like /storage/...
  static const String _defaultHost = '10.0.2.2'; // Emulator
  static const int _defaultPort = 8000;

  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String profilePhoto = '/profile/photo';

  // Full URLs
  static String get loginUrl => '$baseUrl$login';
  static String get registerUrl => '$baseUrl$register';
  static String get profileUrl => '$baseUrl$profile';
  static String get profilePhotoUrl => '$baseUrl$profilePhoto';

  // Resolve a backend file/image URL (handles localhost on emulator)
  // Accepts either a full URL (http/https) or a relative storage path.
  static String assetUrl(String pathOrUrl) {
    // If it's a full URL
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      final uri = Uri.parse(pathOrUrl);
      // Map localhost/127.0.0.1 to emulator-accessible host
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        final mappedHost = _mappedLocalHost();
        final mappedPort = uri.hasPort ? uri.port : _defaultPort;
        final normalized = Uri(
          scheme: uri.scheme,
          host: mappedHost,
          port: mappedPort,
          path: uri.path,
          query: uri.query,
        ).toString();
        return normalized;
      }
      // Otherwise return as-is
      return pathOrUrl;
    }

    // If it's a relative storage path from backend (e.g., 'profile-photos/abc.jpg')
    if (!pathOrUrl.startsWith('/')) {
      final backendBase = 'http://${_mappedLocalHost()}:$_defaultPort';
      return '$backendBase/storage/$pathOrUrl';
    }

    // Otherwise likely a local filesystem path — return as-is
    return pathOrUrl;
  }

  // Platform-aware mapping for localhost
  static String _mappedLocalHost() {
    if (kIsWeb) {
      // For web, keep localhost; you may proxy via the same origin
      return 'localhost';
    }
    try {
      if (Platform.isAndroid) {
        return _defaultHost; // 10.0.2.2
      }
    } catch (_) {
      // Platform may not be available (e.g., flutter web)
    }
    // iOS simulator/desktop can usually use localhost
    return 'localhost';
  }
}
