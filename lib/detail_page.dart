import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/api_config.dart';
import 'shopping_cart/shopping.cart.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'sign_in/sign_in_screen.dart';
import 'models/product_model.dart';
import 'home/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Detail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      // Ganti home ke HomePage agar navigasi selalu lewat tab bar
      home: HomePage(),
    );
  }
}

class Review {
  final String name;
  final String date;
  final String comment;
  final double rating;
  final String avatar;

  Review({
    required this.name,
    required this.date,
    required this.comment,
    required this.rating,
    required this.avatar,
  });
}

class ProductDetailPage extends StatefulWidget {
  final Product? product;
  final List<Review>? reviews;
  final Function()? onGoToCart;

  const ProductDetailPage({
    Key? key,
    this.product,
    this.reviews,
    this.onGoToCart,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  int quantity = 1;
  late TabController _tabController;
  bool isFavorite = false;
  late Product product;
  late List<Review> productReviews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    product =
        widget.product ??
        Product(
          id: 'default-product',
          name: 'Fresh Orange',
          category: 'FRUITS',
          imageUrl: 'assets/images/orange.jpg',
          description:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
          price: 4.9,
          stock: 0,
        );
    productReviews = widget.reviews ?? [];
    _checkIfInWishlist();
    _loadReviewsFromFirestore();
  }

  Future<void> _loadReviewsFromFirestore() async {
    try {
      print('DEBUG: Loading reviews for productId: ${product.id}');
      final db = FirebaseFirestore.instance;

      // Query tanpa orderBy untuk avoid index requirement
      final querySnapshot = await db
          .collection('ratings')
          .where('productId', isEqualTo: product.id)
          .get();

      print('DEBUG: Found ${querySnapshot.docs.length} reviews');

      if (querySnapshot.docs.isNotEmpty) {
        final reviews = <Review>[];
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          print('DEBUG: Review data: $data');

          final createdAt = data['createdAt'] as Timestamp?;
          final formattedDate = createdAt != null
              ? _formatDate(createdAt.toDate())
              : 'Unknown date';

          final avatarUrl =
              data['userAvatar'] ?? 'assets/images/default_avatar.png';
          print('DEBUG: Avatar URL for ${data['displayName']}: $avatarUrl');
          print(
            'DEBUG: Avatar starts with http: ${avatarUrl.startsWith('http')}',
          );

          reviews.add(
            Review(
              name: data['displayName'] ?? 'Anonymous',
              date: formattedDate,
              comment: data['comment'] ?? 'No comment',
              rating: (data['rating'] ?? 0).toDouble(),
              avatar: avatarUrl,
            ),
          );
        }

        if (mounted) {
          setState(() {
            productReviews = reviews;
          });
          print(
            'DEBUG: Updated productReviews count: ${productReviews.length}',
          );
        }
      } else {
        print('DEBUG: No reviews found, clearing productReviews');
        if (mounted) {
          setState(() {
            productReviews = [];
          });
        }
      }
    } catch (e) {
      print('ERROR loading reviews: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reviews: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        return 'Just now';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _checkIfInWishlist() async {
    final userId = AuthService.currentUserId;
    if (userId == null || userId.isEmpty) return;

    try {
      final result = await ApiService.getUserWishlist();
      if (result['success'] == true && result['wishlist'] != null) {
        final wishlist = List<String>.from(result['wishlist']);
        if (mounted) {
          setState(() {
            isFavorite = wishlist.contains(product.id);
          });
        }
      }
    } catch (e) {
      print('Error checking wishlist: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  double get effectiveRating {
    if (productReviews.isNotEmpty) {
      final total = productReviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );
      return total / productReviews.length;
    }
    return 0.0;
  }

  int get effectiveReviewCount =>
      productReviews.isNotEmpty ? productReviews.length : 0;

  List<String> get reviewerAvatars =>
      productReviews.take(3).map((review) => review.avatar).toList();

  Future<void> toggleFavorite() async {
    final userId = AuthService.currentUserId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk menambahkan ke wishlist'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
      return;
    }

    try {
      if (isFavorite) {
        // Remove from wishlist
        final result = await ApiService.removeFromWishlist(product.id);
        if (result['success'] == true) {
          setState(() {
            isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk dihapus dari wishlist'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Gagal menghapus dari wishlist',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Add to wishlist
        final result = await ApiService.addToWishlist(product.id);
        if (result['success'] == true) {
          setState(() {
            isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk disimpan ke wishlist'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Gagal menambahkan ke wishlist',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> addToCart() async {
    final userId = AuthService.currentUserId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk menambahkan ke keranjang'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
      return;
    }

    // Add to Firestore cart using ApiService
    final result = await ApiService.addToCart(
      productId: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      quantity: quantity,
      image: product.imageUrl ?? 'assets/images/orange.jpg',
    );

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk ditambahkan ke keranjang'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to ShoppingCartPage after adding to cart
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ShoppingCartPage(showBottomNavBar: true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menambahkan ke keranjang'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Image Section
              SliverAppBar(
                expandedHeight: 400,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.imageUrl != null &&
                              product.imageUrl!.startsWith('http')
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.orange[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              product.imageUrl ?? 'assets/images/orange.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.orange[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                      // Page Indicators
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // White Content Section
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category
                            Text(
                              product.category,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Product Name
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Price and Quantity Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                // Quantity Selector
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: decrementQuantity,
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: incrementQuantity,
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Rating and Reviewers
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  effectiveRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  effectiveReviewCount > 0
                                      ? '(${effectiveReviewCount} reviews)'
                                      : '(Belum ada review)',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                if (reviewerAvatars.isNotEmpty)
                                  SizedBox(
                                    width: 100,
                                    height: 40,
                                    child: Stack(
                                      children: [
                                        for (
                                          int i = 0;
                                          i < reviewerAvatars.length;
                                          i++
                                        )
                                          Positioned(
                                            left: i * 25.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 18,
                                                backgroundImage: NetworkImage(
                                                  ApiConfig.assetUrl(
                                                    reviewerAvatars[i],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (reviewerAvatars.isEmpty)
                                  Text(
                                    'Belum ada reviewer',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Tabs
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.grey[400],
                          indicatorColor: Colors.green,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Description'),
                            Tab(text: 'Review'),
                            Tab(text: 'Disscussion'),
                          ],
                        ),
                      ),
                      // Tab Content
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Description Tab
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            ),
                            // Review Tab
                            if (productReviews.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.rate_review_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada review',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Jadilah yang pertama memberikan review',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Stack(
                                children: [
                                  ListView.separated(
                                    padding: const EdgeInsets.all(24.0),
                                    itemCount: productReviews.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 20),
                                    itemBuilder: (context, index) {
                                      final review = productReviews[index];
                                      print(
                                        'DEBUG: Rendering avatar for ${review.name} - URL: ${review.avatar}',
                                      );
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.grey[200],
                                            backgroundImage:
                                                review.avatar.startsWith('http')
                                                ? NetworkImage(review.avatar)
                                                : null,
                                            child:
                                                review.avatar.startsWith('http')
                                                ? null
                                                : Text(
                                                    review.name[0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF4CB32B),
                                                    ),
                                                  ),
                                            onBackgroundImageError:
                                                review.avatar.startsWith('http')
                                                ? (exception, stackTrace) {
                                                    print(
                                                      '❌ ERROR loading avatar for ${review.name}: $exception',
                                                    );
                                                    print(
                                                      '❌ Avatar URL was: ${review.avatar}',
                                                    );
                                                    print(
                                                      '❌ Stack trace: $stackTrace',
                                                    );
                                                  }
                                                : null,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        review.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        for (
                                                          int i = 0;
                                                          i < 5;
                                                          i++
                                                        )
                                                          Icon(
                                                            Icons.star,
                                                            size: 16,
                                                            color:
                                                                i <
                                                                    review
                                                                        .rating
                                                                        .toInt()
                                                                ? Colors.orange
                                                                : Colors
                                                                      .grey[300],
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  review.date,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  review.comment,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            // Discussion Tab
                            SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Favorite Button
                  GestureDetector(
                    onTap: toggleFavorite,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add to Cart Button
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: addToCart,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'ADD TO CART',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${(product.price * quantity).toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
