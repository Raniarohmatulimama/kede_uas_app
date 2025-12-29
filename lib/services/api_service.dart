import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_service.dart';
import 'cloudinary_service.dart';
import '../config/firebase_config.dart';

class ApiService {
  /// Add product to user's cart in Firestore
  static Future<Map<String, dynamic>> addToCart({
    required String productId,
    required String name,
    required String category,
    required double price,
    required int quantity,
    required String image,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final userRef = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final cart = List<Map<String, dynamic>>.from(userData['cart'] ?? []);

      // Check if product already in cart
      final index = cart.indexWhere((item) => item['id'] == productId);
      if (index >= 0) {
        // If already in cart, just update quantity
        cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + quantity;
      } else {
        // Add new item
        cart.add({
          'id': productId,
          'name': name,
          'category': category,
          'price': price,
          'quantity': quantity,
          'image': image,
        });
      }

      await userRef.update({'cart': cart});
      return {'success': true, 'message': 'Product added to cart'};
    } catch (e) {
      print('[API] Error adding to cart: $e');
      return {'success': false, 'message': 'Failed to add to cart: $e'};
    }
  }

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============= Authentication =============

  // Sign In
  static Future<Map<String, dynamic>> signIn(
    String email,
    String password,
  ) async {
    try {
      print('[API] Attempting sign in for email: $email');

      final result = await AuthService.signIn(email: email, password: password);

      return result;
    } catch (e) {
      print('[API] Sign in exception: $e');
      return {'success': false, 'message': 'Sign in failed: $e'};
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
      print('[API] Attempting registration for email: $email');

      final result = await AuthService.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      return result;
    } catch (e) {
      print('[API] Registration exception: $e');
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('[API] Sending password reset for email: $email');

      final result = await AuthService.forgotPassword(email);

      return result;
    } catch (e) {
      print('[API] Forgot password exception: $e');
      return {'success': false, 'message': 'Failed to send password reset: $e'};
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String resetToken,
    String newPassword,
  ) async {
    try {
      print('[API] Resetting password for email: $email');
      // Note: Firebase handles password reset differently
      // Users receive reset email and reset through Firebase UI
      // This method is kept for compatibility

      return {
        'success': false,
        'message': 'Password reset should be done through email link',
      };
    } catch (e) {
      return {'success': false, 'message': 'Reset password failed: $e'};
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      print('[API] Logging out');

      final result = await AuthService.signOut();

      return result;
    } catch (e) {
      print('[API] Logout exception: $e');
      return {'success': false, 'message': 'Logout failed: $e'};
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User profile not found'};
      }

      return {
        'success': true,
        'data': {'user': userDoc.data()},
      };
    } catch (e) {
      print('[API] Error fetching profile: $e');
      return {'success': false, 'message': 'Failed to fetch profile: $e'};
    }
  }

  // ============= Products =============

  // Get all products
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 100,
    String? category,
  }) async {
    try {
      print('[API] Fetching products, category: $category');

      Query query = _firestore.collection(FirebaseConfig.productsCollection);

      // Apply category filter if provided
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Apply pagination
      final startAt = (page - 1) * perPage;
      final allProducts = await query
          .orderBy('created_at', descending: true)
          .get();
      // Pagination: skip startAt records, take perPage records
      final paginatedDocs = allProducts.docs
          .skip(startAt)
          .take(perPage)
          .toList();

      final data = paginatedDocs.map((doc) {
        final docData = doc.data() as Map<String, dynamic>;
        return {...docData, 'id': doc.id};
      }).toList();

      return {
        'success': true,
        'data': {
          'data': data,
          'pagination': {
            'page': page,
            'per_page': perPage,
            'total': data.length,
          },
        },
      };
    } catch (e) {
      print('[API] Error fetching products: $e');
      return {'success': false, 'message': 'Failed to fetch products: $e'};
    }
  }

  // Get product detail
  static Future<Map<String, dynamic>> getProductDetail(String id) async {
    try {
      final productDoc = await _firestore
          .collection(FirebaseConfig.productsCollection)
          .doc(id)
          .get();

      if (!productDoc.exists) {
        return {'success': false, 'message': 'Product not found'};
      }

      final data = productDoc.data() as Map<String, dynamic>;
      return {
        'success': true,
        'data': {
          'data': {...data, 'id': productDoc.id},
        },
      };
    } catch (e) {
      print('[API] Error fetching product detail: $e');
      return {'success': false, 'message': 'Failed to fetch product: $e'};
    }
  }

  // Create a new product
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    File? imageFile,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      String? imageUrl;
      String? imagePublicId;

      // Upload image to Cloudinary if provided
      if (imageFile != null) {
        print('[API] Uploading product image to Cloudinary...');

        final result = await CloudinaryService.uploadImage(
          imageFile,
          tags: {
            'seller_id': userId,
            'type': 'product_image',
            'product_name': name,
          },
        );

        if (!result['success']) {
          return {
            'success': false,
            'message': 'Image upload failed: ${result['message']}',
          };
        }

        imageUrl = result['url'] as String;
        imagePublicId = result['publicId'] as String;

        print('[API] Product image uploaded: $imagePublicId');
      }

      // Create product document
      final productRef = await _firestore
          .collection(FirebaseConfig.productsCollection)
          .add({
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'stock': stock,
            'image': imageUrl,
            'image_public_id': imagePublicId, // Store public_id for reference
            'seller_id': userId,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      return {
        'success': true,
        'data': {
          'data': {
            'id': productRef.id,
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'stock': stock,
            'image': imageUrl,
          },
        },
      };
    } catch (e) {
      print('[API] Error creating product: $e');
      return {'success': false, 'message': 'Failed to create product: $e'};
    }
  }

  // Update a product
  static Future<Map<String, dynamic>> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    File? imageFile,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Verify user is the product owner
      final productDoc = await _firestore
          .collection(FirebaseConfig.productsCollection)
          .doc(id)
          .get();

      if (!productDoc.exists) {
        return {'success': false, 'message': 'Product not found'};
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      if (productData['seller_id'] != userId) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      String? imageUrl = productData['image'];
      String? imagePublicId = productData['image_public_id'];

      // Upload new image to Cloudinary if provided
      if (imageFile != null) {
        print('[API] Uploading updated product image to Cloudinary...');

        final result = await CloudinaryService.uploadImage(
          imageFile,
          tags: {
            'seller_id': userId,
            'type': 'product_image',
            'product_name': name,
          },
        );

        if (!result['success']) {
          return {
            'success': false,
            'message': 'Image upload failed: ${result['message']}',
          };
        }

        imageUrl = result['url'] as String;
        imagePublicId = result['publicId'] as String;

        print('[API] Product image updated: $imagePublicId');
      }

      // Update product
      await _firestore
          .collection(FirebaseConfig.productsCollection)
          .doc(id)
          .update({
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'stock': stock,
            'image': imageUrl,
            'image_public_id': imagePublicId,
            'image': imageUrl,
            'updated_at': FieldValue.serverTimestamp(),
          });

      return {'success': true, 'message': 'Product updated successfully'};
    } catch (e) {
      print('[API] Error updating product: $e');
      return {'success': false, 'message': 'Failed to update product: $e'};
    }
  }

  // Delete a product
  static Future<Map<String, dynamic>> deleteProduct(String id) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Verify user is the product owner
      final productDoc = await _firestore
          .collection(FirebaseConfig.productsCollection)
          .doc(id)
          .get();

      if (!productDoc.exists) {
        return {'success': false, 'message': 'Product not found'};
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      if (productData['seller_id'] != userId) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      // Delete product image from Cloudinary if exists
      if (productData['image_public_id'] != null) {
        try {
          // Note: Cloudinary deletion requires API key, which should be done from backend
          // For now, we're just logging the public ID for reference
          print(
            '[API] Product image public ID for deletion: ${productData['image_public_id']}',
          );
          print(
            '[API] Note: Image deletion from Cloudinary should be done from secure backend',
          );
        } catch (e) {
          print('[API] Error deleting product image: $e');
          // Continue even if image deletion fails
        }
      }

      // Delete product document
      await _firestore
          .collection(FirebaseConfig.productsCollection)
          .doc(id)
          .delete();

      return {'success': true, 'message': 'Product deleted successfully'};
    } catch (e) {
      print('[API] Error deleting product: $e');
      return {'success': false, 'message': 'Failed to delete product: $e'};
    }
  }

  // ============= Wishlist =============

  /// Add product to wishlist
  static Future<Map<String, dynamic>> addToWishlist(String productId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get current user's wishlist
      final userRef = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final wishlist = List<String>.from(userData['wishlist'] ?? []);

      // Add product if not already in wishlist
      if (!wishlist.contains(productId)) {
        wishlist.add(productId);
        await userRef.update({'wishlist': wishlist});
        print('[API] Product $productId added to wishlist');
      }

      return {'success': true, 'message': 'Product added to wishlist'};
    } catch (e) {
      print('[API] Error adding to wishlist: $e');
      return {'success': false, 'message': 'Failed to add to wishlist: $e'};
    }
  }

  /// Remove product from wishlist
  static Future<Map<String, dynamic>> removeFromWishlist(
    String productId,
  ) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get current user's wishlist
      final userRef = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final wishlist = List<String>.from(userData['wishlist'] ?? []);

      // Remove product if in wishlist
      wishlist.removeWhere((id) => id == productId);
      await userRef.update({'wishlist': wishlist});
      print('[API] Product $productId removed from wishlist');

      return {'success': true, 'message': 'Product removed from wishlist'};
    } catch (e) {
      print('[API] Error removing from wishlist: $e');
      return {
        'success': false,
        'message': 'Failed to remove from wishlist: $e',
      };
    }
  }

  /// Get user's wishlist products
  static Future<Map<String, dynamic>> getWishlist() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get current user's wishlist
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final wishlistIds = List<String>.from(userData['wishlist'] ?? []);

      // If wishlist is empty, return empty list
      if (wishlistIds.isEmpty) {
        return {
          'success': true,
          'data': {'data': []},
        };
      }

      // Fetch wishlist products
      final productsQuery = await _firestore
          .collection(FirebaseConfig.productsCollection)
          .where(FieldPath.documentId, whereIn: wishlistIds)
          .get();

      final products = productsQuery.docs.map((doc) {
        final docData = doc.data() as Map<String, dynamic>;
        return {...docData, 'id': doc.id};
      }).toList();

      return {
        'success': true,
        'data': {'data': products},
      };
    } catch (e) {
      print('[API] Error fetching wishlist: $e');
      return {'success': false, 'message': 'Failed to fetch wishlist: $e'};
    }
  }

  /// Check if product is in user's wishlist
  static Future<bool> isInWishlist(String productId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return false;
      }

      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final wishlist = List<String>.from(userData['wishlist'] ?? []);

      return wishlist.contains(productId);
    } catch (e) {
      print('[API] Error checking wishlist: $e');
      return false;
    }
  }

  // ============= Helper Methods =============

  /// Get user's wishlist IDs only
  static Future<Map<String, dynamic>> getUserWishlist() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final wishlist = List<String>.from(userData['wishlist'] ?? []);

      return {'success': true, 'wishlist': wishlist};
    } catch (e) {
      print('[API] Error getting user wishlist: $e');
      return {'success': false, 'message': 'Failed to get wishlist: $e'};
    }
  }

  /// Helper method to extract token from response (for backward compatibility)
  static String? extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['token'] as String?;
    }
    return null;
  }
}
