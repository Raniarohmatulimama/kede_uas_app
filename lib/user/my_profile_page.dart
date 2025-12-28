import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../home/HomePage.dart';
import '../home/categories_page.dart';
import '../shopping_cart/shopping.cart.dart';
import '../wishlist/WishlistPage.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
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
      BuildContext context, IconData icon, int index) {
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
              color:
                  isSelected ? const Color(0xFF4CB32B) : Colors.grey.shade400,
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
      BuildContext context, int index, int selectedIndex) {
    final bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        // Already on profile
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              isSelected ? Border.all(color: const Color(0xFF4CB32B), width: 2) : null,
        ),
        child: _photoPath != null && _photoPath!.isNotEmpty
            ? CircleAvatar(
                radius: 18,
                backgroundImage: _getAvatarProvider(_photoPath!),
              )
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
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    result['message'] ??
                                        'Failed to delete photo',
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await AuthService.updatePhoneOnBackend(phone);

    if (!mounted) return;
    if (result['success'] == true) {
      await AuthService.savePhone(phone);
      setState(() => _isEditingPhone = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan nomor telepon'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper widget to display photo (base64, URL, or file path)
  Widget _buildPhotoWidget(String photoData) {
    // Check if it's base64 string from backend
    if (photoData.startsWith('data:image')) {
      final base64String = photoData.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, width: 120, height: 120, fit: BoxFit.cover);
    }

    // Check if it's a full URL (http/https)
    if (photoData.startsWith('http://') || photoData.startsWith('https://')) {
      final normalized = ApiConfig.assetUrl(photoData);
      return Image.network(
        normalized,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 60, color: Colors.grey.shade400);
        },
      );
    }

    // Check if it's a relative path from backend (storage/profile-photos/...)
    if (!photoData.startsWith('/')) {
      // Convert relative path to full URL
      final fullUrl = ApiConfig.assetUrl(photoData);
      return Image.network(
        fullUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 60, color: Colors.grey.shade400);
        },
      );
    }

    // Otherwise it's a local file path
    return Image.file(
      File(photoData),
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error, size: 60, color: Colors.grey.shade400);
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value.isEmpty ? '-' : value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: value.isEmpty ? Colors.grey : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFF4CB32B),
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

  // Helper to produce a small avatar ImageProvider for bottom nav
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

  Widget _buildBottomNav(BuildContext context) {
    final avatarProvider = _getAvatarProvider(_photoPath);
    return BottomAppBar(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Center(
                    child: Icon(Icons.home, color: Color(0xFF4CB32B)),
                  ),
                ),
              ),
            ),

            // Categories
            SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesPage(),
                      ),
                    );
                  },
                  child: Center(
                    child: Icon(
                      Icons.compare_arrows,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),

            // Cart
            SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShoppingCartPage(),
                      ),
                    );
                  },
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.grey.shade400),
                        Positioned(
                          right: -6,
                          top: -6,
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
                ),
              ),
            ),

            // Wishlist
            SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistPage(),
                      ),
                    );
                  },
                  child: Center(
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),

            // Profile (current)
            SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    // Already on profile; optionally do nothing or refresh
                  },
                  child: Center(
                    child: avatarProvider != null
                        ? CircleAvatar(
                            radius: 12,
                            backgroundImage: avatarProvider,
                          )
                        : const Icon(Icons.person, color: Color(0xFF4CB32B)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    if (!_isEditingPhone) {
      return _buildInfoRow(
        'Phone',
        _phoneController.text,
        onEdit: () => setState(() => _isEditingPhone = true),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phone',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF4CB32B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _savePhone,
                icon: const Icon(Icons.check, color: Colors.green),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditingPhone = false;
                    _phoneController.text = '';
                    _loadUserData();
                  });
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
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
            // Profile Photo with Edit Button
            Stack(
              children: [
                GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                    ),
                    child: _photoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildPhotoWidget(_photoPath!),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
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
            const SizedBox(height: 16),

            // Full Name
            Text(
              '$_firstName $_lastName'.trim(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              _email.isNotEmpty ? _email : 'No email',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 8),

            // Info Section
            _buildInfoRow('Full Name', '$_firstName $_lastName'.trim()),
            _buildInfoRow('User Name', _firstName),
            _buildInfoRow('Email Address', _email),
            _buildPhoneField(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
}
