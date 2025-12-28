import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/firebase_config.dart';

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

  // Get current Firebase user
  static User? get currentUser => _firebaseAuth.currentUser;

  // Get current user UID
  static String? get currentUserId => currentUser?.uid;

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Stream of authentication state
  static Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Save token (for compatibility, Firebase handles tokens internally)
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final user = currentUser;
    if (user != null) {
      try {
        return await user.getIdToken();
      } catch (e) {
        print('[AuthService] Error getting token: $e');
      }
    }
    // Fallback to cached token
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear token and user data
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_photoKey);
    await prefs.remove(_userIdKey);
  }

  // Sign up / Register
  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      if (password != passwordConfirmation) {
        return {'success': false, 'message': 'Passwords do not match'};
      }

      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to create user account'};
      }

      // Save user data to Firestore
      await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .set({
            'id': user.uid,
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
            'phone': '',
            'profile_photo': null,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Save locally
      await saveUserData(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      await prefs.setString(_userIdKey, user.uid);

      // Get ID token
      final token = await user.getIdToken();
      if (token != null) {
        await saveToken(token);
      }

      return {
        'success': true,
        'data': {
          'user': {
            'id': user.uid,
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
          },
        },
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists with that email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid';
      } else {
        errorMessage = e.message ?? 'Registration failed';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Sign in
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to sign in'};
      }

      // Get user data from Firestore
      final userDoc = await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      // Save user data locally
      await saveUserData(
        firstName: userData['first_name'] ?? '',
        lastName: userData['last_name'] ?? '',
        email: user.email ?? '',
      );
      await savePhone(userData['phone'] ?? '');
      if (userData['profile_photo'] != null) {
        await savePhoto(userData['profile_photo']);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, user.uid);

      // Get ID token
      final token = await user.getIdToken();
      if (token != null) {
        await saveToken(token);
      }

      return {
        'success': true,
        'data': {
          'user': {
            'id': user.uid,
            'email': user.email,
            'first_name': userData['first_name'] ?? '',
            'last_name': userData['last_name'] ?? '',
            'phone': userData['phone'] ?? '',
            'profile_photo': userData['profile_photo'],
          },
        },
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign in failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled';
      } else {
        errorMessage = e.message ?? 'Sign in failed';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Sign out
  static Future<Map<String, dynamic>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await clearToken();
      return {'success': true, 'message': 'Signed out successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your email.',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send password reset email';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid';
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Save user data locally
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

  // Get first name
  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstNameKey);
  }

  // Get last name
  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastNameKey);
  }

  // Get email
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

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
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

  // Update phone on backend (Firestore)
  static Future<Map<String, dynamic>> updatePhoneOnBackend(String phone) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .update({'phone': phone, 'updated_at': FieldValue.serverTimestamp()});

      await savePhone(phone);
      return {'success': true, 'message': 'Phone updated successfully'};
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

  // Upload photo to Firebase Storage
  static Future<Map<String, dynamic>> uploadPhotoToBackend(
    File imageFile,
  ) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Create storage reference
      final fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _firebaseStorage
          .ref()
          .child(FirebaseConfig.profilePhotosPath)
          .child(fileName);

      // Upload file
      await storageRef.putFile(imageFile);

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update user data in Firestore
      await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .update({
            'profile_photo': downloadUrl,
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Save locally
      await savePhoto(downloadUrl);

      return {
        'success': true,
        'message': 'Photo uploaded successfully',
        'photo': downloadUrl,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete photo from Firebase Storage
  static Future<Map<String, dynamic>> deletePhotoFromBackend() async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final photoUrl = await getPhoto();
      if (photoUrl == null) {
        return {'success': false, 'message': 'No photo to delete'};
      }

      try {
        // Delete from storage
        final storageRef = _firebaseStorage.refFromURL(photoUrl);
        await storageRef.delete();
      } catch (e) {
        print('[AuthService] Error deleting from storage: $e');
        // Continue even if storage delete fails
      }

      // Update Firestore
      await _firebaseFirestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .update({
            'profile_photo': null,
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Delete locally
      await deletePhoto();

      return {'success': true, 'message': 'Photo deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Helper method - extract token from response (for compatibility)
  static String? extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['token'] as String?;
    }
    return null;
  }

  // Lazy load prefs for backward compatibility
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
