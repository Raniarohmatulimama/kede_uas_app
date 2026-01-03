import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiService {
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // If response is not JSON, return a default error structure
      print('[API] Response body (not JSON): ${response.body}');
      return {'message': 'Server error (HTTP ${response.statusCode})'};
    }
  }

  static void _logResponse(String endpoint, http.Response response) {
    print('[API] $endpoint - Status: ${response.statusCode}');
    print('[API] Response body: ${response.body}');
  }

  // Sign In
  static Future<Map<String, dynamic>> signIn(
    String email,
    String password,
  ) async {
    try {
      AppConfig.logBaseUrl();
      print('[API] Sending login request for email: $email');

      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      _logResponse('POST /login', response);

      if (response.statusCode == 200) {
        final data = _parseResponse(response);
        print('[API] Login response data: $data');
        return {'success': true, 'data': data};
      } else {
        final error = _parseResponse(response);
        print('[API] Login error response: $error');
        return {
          'success': false,
          'message':
              error['message'] ?? 'Login failed (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      print('[API] Login exception: $e');
      return {
        'success': false,
        'message':
            'Connection error: $e\nMake sure Laravel is running at ${AppConfig.baseUrl}',
      };
    }
  }

  // Create Account / Register
  static Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      _logResponse('POST /register', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _parseResponse(response)};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Registration failed (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'Connection error. Please check if server is running and URL is correct.',
      };
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      _logResponse('POST /forgot-password', response);

      final parsedData = _parseResponse(response);

      if (response.statusCode == 200) {
        return {'success': true, 'data': parsedData['data']};
      } else {
        final error = parsedData;
        return {
          'success': false,
          'message':
              error['message'] ??
              'Request failed (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'Connection error. Please check if server is running and URL is correct.',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String resetToken,
    String newPassword,
  ) async {
    try {
      print('[DEBUG] Sending reset password request:');
      print('[DEBUG] Email: $email');
      print('[DEBUG] Reset Token: $resetToken');
      print('[DEBUG] Token length: ${resetToken.length}');
      print('[DEBUG] New Password: ${newPassword.length} chars');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'reset_token': resetToken,
          'new_password': newPassword,
        }),
      );

      _logResponse('POST /reset-password', response);

      // Accept both 200 (success) and 401 (but password updated) as success
      if (response.statusCode == 200 || response.statusCode == 401) {
        final responseData = _parseResponse(response);
        // Check if response indicates success
        if (responseData['success'] == true || response.statusCode == 200) {
          return {'success': true, 'data': responseData};
        }
      }

      final error = _parseResponse(response);
      return {
        'success': false,
        'message':
            error['message'] ?? 'Request failed (HTTP ${response.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Connection error. Please check if server is running and URL is correct.',
      };
    }
  }

  // Helper method to get authorization headers with JWT token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Logout user (Protected - requires token)
  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/logout'),
        headers: headers,
      );

      _logResponse('POST /logout', response);

      if (response.statusCode == 200) {
        await AuthService.clearToken();
        return {'success': true, 'data': _parseResponse(response)};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ?? 'Logout failed (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get user profile (Protected - requires token)
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/profile'),
        headers: headers,
      );

      _logResponse('GET /profile', response);

      if (response.statusCode == 200) {
        return {'success': true, 'data': _parseResponse(response)};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to fetch profile (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get all products (Public - no authentication needed)
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 100, // Increased from 15 to 100 to fetch all products
    String? category,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      // Add category filter if provided
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse(
        '${AppConfig.baseUrl}/products',
      ).replace(queryParameters: queryParams);

      print('[API] Fetching products from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      _logResponse('GET /products', response);

      if (response.statusCode == 200) {
        final parsedData = _parseResponse(response);
        print('[API] ===== PRODUCTS RESPONSE DEBUG =====');
        print('[API] Parsed data type: ${parsedData.runtimeType}');
        print('[API] Parsed data keys: ${parsedData.keys}');

        // Check for pagination structure
        if (parsedData.containsKey('data')) {
          final dataContent = parsedData['data'];
          print('[API] data field type: ${dataContent.runtimeType}');
          if (dataContent is List) {
            print('[API] data is List with ${dataContent.length} items');
          } else if (dataContent is Map) {
            print('[API] data is Map with keys: ${dataContent.keys}');
            if (dataContent.containsKey('data')) {
              final innerData = dataContent['data'];
              print('[API] Inner data type: ${innerData.runtimeType}');
              if (innerData is List) {
                print('[API] Inner data list has ${innerData.length} items');
              }
            }
          }
        }
              print('[API] ===== END DEBUG =====');

        return {'success': true, 'data': parsedData};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to fetch products (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      print('[API] Exception in getProducts: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get product detail (Public - no authentication needed)
  static Future<Map<String, dynamic>> getProductDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      _logResponse('GET /products/$id', response);

      if (response.statusCode == 200) {
        return {'success': true, 'data': _parseResponse(response)};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Product not found'};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to fetch product (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Create a new product (requires authentication)
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    File? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/products'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['category'] = category;
      request.fields['stock'] = stock.toString();

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse('POST /products', response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': _parseResponse(response)};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to create product (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Update a product (requires authentication)
  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    File? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/products/$id'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Laravel requires _method field for PUT via POST
      request.fields['_method'] = 'PUT';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['category'] = category;
      request.fields['stock'] = stock.toString();

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse('PUT /products/$id', response);

      if (response.statusCode == 200) {
        return {'success': true, 'data': _parseResponse(response)};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to update product (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Delete a product (requires authentication)
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logResponse('DELETE /products/$id', response);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Product deleted successfully'};
      } else {
        final error = _parseResponse(response);
        return {
          'success': false,
          'message':
              error['message'] ??
              'Failed to delete product (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
