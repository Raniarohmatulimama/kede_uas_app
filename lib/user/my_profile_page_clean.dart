import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../home/HomePage.dart';
import '../home/categories_page.dart';
import '../shopping_cart/shopping.cart.dart';
import '../wishlist/WishlistPage.dart';

import '../sign_in/sign_in_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final TextEditingController _phoneController = TextEditingController();
  String? _photoPath;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  bool _isLoading = true;
  bool _isEditingPhone = false;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadData();
  }

  Future<void> _checkLoginAndLoadData() async {
    // Check if user is logged in with Firebase Auth
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      // User not logged in, show dialog and redirect (post-frame)
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Login Required',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You need to login to access your profile.\nPlease sign in to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Go to Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      }
      return;
    }

    // User is logged in, load data
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Muat data cache lebih dulu supaya UI tidak kosong saat fetch API.
    final cachedFirst = await AuthService.getFirstName() ?? '';
    final cachedLast = await AuthService.getLastName() ?? '';
    final cachedEmail = await AuthService.getEmail() ?? '';
    final cachedPhone = await AuthService.getPhone() ?? '';
    final cachedPhoto = await AuthService.getPhoto();

    setState(() {
      _firstName = cachedFirst;
      _lastName = cachedLast;
      _email = cachedEmail;
      _phoneController.text = cachedPhone;
      _photoPath = cachedPhoto;
    });

    // Jika data cache kosong, ambil dari Firebase Auth current user
    if (_email.isEmpty && AuthService.currentUser != null) {
      setState(() {
        _email = AuthService.currentUser!.email ?? '';
      });
    }

    // Coba load dari Firestore jika Firebase Auth aktif
    try {
      final userId = AuthService.currentUserId;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final firstName = (data['first_name'] ?? '') as String;
          final lastName = (data['last_name'] ?? '') as String;
          final email = (data['email'] ?? '') as String;
          final phone = (data['phone'] ?? '') as String;
          final photo = data['profile_photo_url'] ?? data['profile_photo'];

          await AuthService.saveUserData(
            firstName: firstName,
            lastName: lastName,
            email: email,
          );
          if (phone.isNotEmpty) await AuthService.savePhone(phone);
          if (photo is String && photo.isNotEmpty) {
            await AuthService.savePhoto(photo);
          }

          if (!mounted) return;
          setState(() {
            _firstName = firstName;
            _lastName = lastName;
            _email = email;
            _phoneController.text = phone;
            if (photo is String && photo.isNotEmpty) {
              _photoPath = photo;
            }
          });
        }
      }
    } catch (e) {
      print('[Profile] Error loading from Firestore: $e');
      // Abaikan error, gunakan data cache
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;
    final file = File(picked.path);

    // Show beautiful confirmation dialog with preview
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CB32B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF4CB32B),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Preview your new photo',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // Photo preview
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4CB32B).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CB32B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    final result = await AuthService.uploadPhotoToBackend(file);
    if (result['success'] == true) {
      final newPhoto = result['photo'] as String? ?? file.path;
      await AuthService.savePhoto(newPhoto);
      if (!mounted) return;
      setState(() => _photoPath = newPhoto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo updated successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Upload failed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Deleting photo...'),
                          ],
                        ),
                        backgroundColor: Colors.blue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 30),
                      ),
                    );

                    final result = await AuthService.deletePhotoFromBackend();

                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }

                    if (result['success'] == true) {
                      if (!mounted) return;
                      setState(() {
                        _photoPath = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo deleted successfully!'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result['message'] ?? 'Failed to delete photo',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Save to Firestore directly
      final userId = AuthService.currentUserId;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'phone': phone, 'updated_at': FieldValue.serverTimestamp()},
        );

        await AuthService.savePhone(phone);
        setState(() => _isEditingPhone = false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update phone: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPhotoWidget(String photoData) {
    if (photoData.startsWith('data:image')) {
      final base64String = photoData.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, width: 120, height: 120, fit: BoxFit.cover);
    }

    if (photoData.startsWith('http://') || photoData.startsWith('https://')) {
      final normalized = ApiConfig.assetUrl(photoData);
      return Image.network(
        normalized,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Photo load error: $error');
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
            ),
          );
        },
      );
    }

    if (!photoData.startsWith('/')) {
      final fullUrl = ApiConfig.assetUrl(photoData);
      return Image.network(
        fullUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Photo load error: $error');
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
            ),
          );
        },
      );
    }

    return Image.file(
      File(photoData),
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onEdit}) {
    final displayValue = value.isEmpty ? '-' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    displayValue,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: displayValue == '-' ? Colors.grey : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Color(0xFF4CB32B),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarProvider(String? photoData) {
    if (photoData == null || photoData.isEmpty) return null;
    if (photoData.startsWith('data:image')) {
      final base64String = photoData.split(',')[1];
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    }
    if (photoData.startsWith('http://') || photoData.startsWith('https://')) {
      final normalized = ApiConfig.assetUrl(photoData);
      return NetworkImage(normalized);
    }
    if (!photoData.startsWith('/')) {
      final fullUrl = ApiConfig.assetUrl(photoData);
      return NetworkImage(fullUrl);
    }
    return FileImage(File(photoData));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'My Profile',
                style: TextStyle(color: Colors.black87),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: _buildBottomNav(context),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.grey.shade200,
                        ),
                        child: userProvider.photoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: _buildPhotoWidget(
                                  userProvider.photoPath!,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CB32B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  userProvider.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'User',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 4),
                _buildInfoRow('Full Name', userProvider.fullName),
                Divider(color: Colors.grey.shade200, height: 10),
                _buildInfoRow(
                  'User Name',
                  userProvider.firstName.isEmpty ? '-' : userProvider.firstName,
                ),
                Divider(color: Colors.grey.shade200, height: 10),
                _isEditingPhone
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _savePhone,
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      )
                    : _buildInfoRow(
                        'Phone',
                        userProvider.phone,
                        onEdit: () => setState(() => _isEditingPhone = true),
                      ),
                Divider(color: Colors.grey.shade200, height: 10),
                _buildInfoRow(
                  'Email Address',
                  userProvider.email.isEmpty ? 'No email' : userProvider.email,
                ),
                Divider(color: Colors.grey.shade200, height: 10),
                _buildInfoRow('Shipping Address', 'Not set'),
                Divider(color: Colors.grey.shade200, height: 10),
                _buildInfoRow(
                  'Total Order',
                  userProvider.totalOrder.toString(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    const int selectedIndex = 4; // Profile tab
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 0),
          _buildNavItem(context, Icons.compare_arrows, 1),
          _buildNavItemWithBadge(context, Icons.shopping_cart, 2),
          _buildNavItem(context, Icons.favorite, 3),
          _buildProfileNavItem(context, 4, selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    const int selectedIndex = 4;
    final bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesPage()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistPage()),
            );
            break;
          default:
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF4CB32B) : Colors.grey.shade400,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    BuildContext context,
    IconData icon,
    int index,
  ) {
    const int selectedIndex = 4;
    final bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShoppingCartPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4CB32B)
                  : Colors.grey.shade400,
              size: 28,
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CB32B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(
    BuildContext context,
    int index,
    int selectedIndex,
  ) {
    final bool isSelected = selectedIndex == index;
    final avatarProvider = _getAvatarProvider(_photoPath);
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFF4CB32B), width: 2)
              : null,
        ),
        child: avatarProvider != null
            ? CircleAvatar(radius: 18, backgroundImage: avatarProvider)
            : CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
      ),
    );
  }
}
