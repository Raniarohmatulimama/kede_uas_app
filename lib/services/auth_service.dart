import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';
import '../config/api_config.dart';
import 'cloudinary_service.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static const String _tokenKey = 'auth_token';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _emailKey = 'user_email';
  static const String _phoneKey = 'user_phone';
  static const String _photoKey = 'user_photo';
  static const String _userIdKey = 'user_id';

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
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_photoKey);
  }

  // Save user data
  static Future<void> saveUserData({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
    await prefs.setString(_emailKey, email);
  }

  // Get user first name
  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstNameKey);
  }

  // Get user last name
  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastNameKey);
  }

  // Get user email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Get full name
  static Future<String> getFullName() async {
    final firstName = await getFirstName() ?? '';
    final lastName = await getLastName() ?? '';
    return '$firstName $lastName'.trim();
  }

  // Phone methods
  static Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Update phone number on backend and persist locally on success
  static Future<Map<String, dynamic>> updatePhoneOnBackend(String phone) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final uri = Uri.parse(ApiConfig.profileUrl);
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({'phone': phone});

      final response = await http
          .put(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        await savePhone(phone);
        return {
          'success': true,
          'message': data['message'] ?? 'Phone updated successfully',
          'data': data,
        };
      }

      // Some backends use POST + _method=PUT. Try fallback once.
      if (response.statusCode == 405 || response.statusCode == 404) {
        var request = http.MultipartRequest('POST', uri);
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
        request.fields['_method'] = 'PUT';
        request.fields['phone'] = phone;
        final streamed = await request.send();
        final postResponse = await http.Response.fromStream(streamed);
        Map<String, dynamic> postData = {};
        try {
          postData = jsonDecode(postResponse.body) as Map<String, dynamic>;
        } catch (_) {}
        if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
          await savePhone(phone);
          return {
            'success': true,
            'message': postData['message'] ?? 'Phone updated successfully',
            'data': postData,
          };
        }
        return {
          'success': false,
          'message': postData['message'] ?? 'Failed to update phone',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update phone',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Photo methods
  static Future<void> savePhoto(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoKey, photoPath);
  }

  static Future<String?> getPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoKey);
  }

  static Future<void> deletePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_photoKey);
  }

  // Get current user
  static User? get currentUser => _firebaseAuth.currentUser;

  // Get current user ID
  static String? get currentUserId => _firebaseAuth.currentUser?.uid;

  // Sign Up with Email & Password
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      print('[Auth] Sign up successful: ${userCredential.user?.email}');
      return {
        'success': true,
        'message': 'Sign up successful',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Sign up failed'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Sign In with Email & Password
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get Firebase ID token and save it
      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        await saveToken(idToken);
        print('[Auth] Firebase ID token saved');
      }

      // Load user data from Firestore and cache it
      if (userCredential.user != null) {
        final userDoc = await _firebaseFirestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          await saveUserData(
            firstName: userData['first_name'] ?? '',
            lastName: userData['last_name'] ?? '',
            email: userData['email'] ?? email,
          );

          // Save phone if exists
          if (userData['phone'] != null) {
            await savePhone(userData['phone']);
          }

          // Save photo if exists
          if (userData['profile_photo_url'] != null) {
            await savePhoto(userData['profile_photo_url']);
          }
        }
      }

      print('[Auth] Sign in successful: ${userCredential.user?.email}');
      return {
        'success': true,
        'message': 'Sign in successful',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Sign in failed'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Sign Out
  static Future<Map<String, dynamic>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await clearToken();
      print('[Auth] Sign out successful');
      return {'success': true, 'message': 'Sign out successful'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('[Auth] Password reset email sent to $email');
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Failed to send reset email',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Upload photo to backend (Cloudinary)
  static Future<Map<String, dynamic>> uploadPhotoToBackend(
    File imageFile,
  ) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      print('[Auth] Uploading photo to Cloudinary...');

      // Upload ke Cloudinary
      final result = await CloudinaryService.uploadImage(
        imageFile,
        tags: {'user_id': user.uid, 'type': 'profile_photo'},
      );

      if (!result['success']) {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to upload photo',
        };
      }

      final photoUrl = result['url'] as String;
      final publicId = result['publicId'] as String;

      print('[Auth] Photo uploaded to Cloudinary: $publicId');
      print('[Auth] URL: $photoUrl');

      // Update Firestore dengan URL dari Cloudinary
      await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .update({
            'profile_photo_url': photoUrl,
            'profile_photo_public_id':
                publicId, // Simpan public_id untuk reference
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Save locally
      await savePhoto(photoUrl);

      return {
        'success': true,
        'message': 'Photo uploaded successfully',
        'photo': photoUrl,
        'publicId': publicId,
      };
    } catch (e) {
      print('[Auth] Error uploading photo: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete photo from backend
  static Future<Map<String, dynamic>> deletePhotoFromBackend() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.profilePhotoUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Delete photo locally
        await deletePhoto();
        return {
          'success': true,
          'message': responseData['message'] ?? 'Photo deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete photo',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Helper method to get MIME type from file extension
  static String _getMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Try to extract token from various common response shapes
  /// Returns null if not found
  static String? extractToken(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map<String, dynamic>) {
        if (data['token'] is String) return data['token'] as String;
        if (data['access_token'] is String)
          return data['access_token'] as String;
        // Laravel JWT often returns { authorisation: { token: '...' } }
        final auth = data['authorisation'];
        if (auth is Map && auth['token'] is String)
          return auth['token'] as String;
        // Some APIs wrap payload under 'data'
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          if (inner['token'] is String) return inner['token'] as String;
          if (inner['access_token'] is String)
            return inner['access_token'] as String;
        }
      }
    } catch (_) {}
    return null;
  }
}
