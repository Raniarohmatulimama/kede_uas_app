import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../config/firebase_config.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String? _photoPath;
  bool _isLoading = true;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get phone => _phone;
  String? get photoPath => _photoPath;
  bool get isLoading => _isLoading;

  String get fullName {
    final name = '$_firstName $_lastName'.trim();
    return name.isNotEmpty ? name : 'User';
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firstName = await AuthService.getFirstName() ?? '';
      final lastName = await AuthService.getLastName() ?? '';
      final email = await AuthService.getEmail() ?? '';
      final phone = await AuthService.getPhone() ?? '';
      final photo = await AuthService.getPhoto();

      _firstName = firstName;
      _lastName = lastName;
      _email = email;
      _phone = phone;
      _photoPath = photo;

      // Jika user logged in, refresh data dari Firebase
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        await _refreshFromFirebase(currentUser.uid);
      }
    } catch (e) {
      print('[UserProvider] Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user data dari Firebase
  Future<void> _refreshFromFirebase(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';
        final email = data['email'] ?? '';
        final phone = data['phone'] ?? '';
        final photoPath =
            data['profile_photo_path'] ?? data['profile_photo_url'];

        // Update local storage
        await AuthService.saveUserData(
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        if (phone.isNotEmpty) {
          await AuthService.savePhone(phone);
        }

        if (photoPath is String && photoPath.isNotEmpty) {
          await AuthService.savePhoto(photoPath);
        }

        // Update state
        _firstName = firstName;
        _lastName = lastName;
        _email = email;
        _phone = phone;
        _photoPath = photoPath;
        notifyListeners();
      }
    } catch (e) {
      print('[UserProvider] Error refreshing from Firebase: $e');
      // Abaikan error, gunakan data cache
    }
  }

  // Update user data
  void updateUserData({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photoPath,
  }) {
    if (firstName != null) _firstName = firstName;
    if (lastName != null) _lastName = lastName;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (photoPath != null) _photoPath = photoPath;
    notifyListeners();
  }

  // Clear user data
  void clearUserData() {
    _firstName = '';
    _lastName = '';
    _email = '';
    _phone = '';
    _photoPath = null;
    notifyListeners();
  }
}
