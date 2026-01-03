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
  // Discussion State
  List<Map<String, dynamic>> discussionComments = [];
  final TextEditingController _discussionController = TextEditingController();
  String? editingCommentId;
  String? editingCommentText;
  bool isLoadingDiscussion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDiscussionComments();
  }

  Future<void> _loadDiscussionComments() async {
    setState(() => isLoadingDiscussion = true);
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db
          .collection('products')
          .doc(product.id)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        discussionComments = querySnapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      });
    } catch (e) {
      print('Error loading discussion: $e');
    }
    setState(() => isLoadingDiscussion = false);
  }

  Future<void> _addOrEditDiscussionComment() async {
    final userId = AuthService.currentUserId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login untuk berkomentar!'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
      return;
    }
    final text = _discussionController.text.trim();
    if (text.isEmpty) return;
    final db = FirebaseFirestore.instance;
    try {
      // Ambil data user dari Firestore
      final userDoc = await db.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final displayName = userData != null
          ? ((userData['first_name'] ?? '') +
                    ' ' +
                    (userData['last_name'] ?? ''))
                .trim()
          : 'Anonymous';
      final avatar = userData != null
          ? (userData['profile_photo_url'] ?? '')
          : '';
      final commentsRef = db
          .collection('products')
          .doc(product.id)
          .collection('comments');
      if (editingCommentId != null) {
        // Edit
        await commentsRef.doc(editingCommentId).update({
          'comment': text,
          'editedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add
        await commentsRef.add({
          'userId': userId,
          'displayName': displayName.isNotEmpty ? displayName : 'Anonymous',
          'avatar': avatar,
          'comment': text,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      _discussionController.clear();
      editingCommentId = null;
      editingCommentText = null;
      await _loadDiscussionComments();
    } catch (e) {
      print('Error add/edit discussion: $e');
    }
  }

  Future<void> _deleteDiscussionComment(String commentId) async {
    final db = FirebaseFirestore.instance;
    try {
      await db
          .collection('products')
          .doc(product.id)
          .collection('comments')
          .doc(commentId)
          .delete();
      await _loadDiscussionComments();
    } catch (e) {
      print('Error delete discussion: $e');
    }
  }

  void _startEditComment(String commentId, String commentText) {
    setState(() {
      editingCommentId = commentId;
      editingCommentText = commentText;
      _discussionController.text = commentText;
    });
  }

  void _cancelEditComment() {
    setState(() {
      editingCommentId = null;
      editingCommentText = null;
      _discussionController.clear();
    });
  }

  int get effectiveReviewCount =>
      productReviews.isNotEmpty ? productReviews.length : 0;

  int quantity = 1;
  late TabController _tabController;
  bool isFavorite = false;
  late Product product;
  late List<String> imageUrls;
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
    // Ambil list gambar dari produk, fallback ke 1 gambar jika tidak ada
    imageUrls =
        (widget.product != null &&
            widget.product!.imageUrls != null &&
            widget.product!.imageUrls!.isNotEmpty)
        ? widget.product!.imageUrls!
        : [product.imageUrl ?? 'assets/images/orange.jpg'];
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

  final displayName = AuthService.currentUser?.displayName ?? 'Anonymous';
  final avatar = AuthService.currentUser?.photoURL ?? '';

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

  // Untuk page controller carousel gambar
  int _currentImageIndex = 0;
  late PageController _pageController = PageController();

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
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          // setState di FlexibleSpaceBar tidak bisa langsung, gunakan addPostFrameCallback
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          if (url.startsWith('http')) {
                            return Image.network(
                              url,
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
                            );
                          } else {
                            return Image.asset(
                              url,
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
                            );
                          }
                        },
                      ),
                      // Page Indicators
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageUrls.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentImageIndex == index ? 30 : 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
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
                            Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  if (isLoadingDiscussion)
                                    const Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else ...[
                                    Expanded(
                                      child: discussionComments.isEmpty
                                          ? Center(
                                              child: Text(
                                                'Belum ada diskusi. Jadilah yang pertama! ',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            )
                                          : ListView.separated(
                                              padding: const EdgeInsets.all(16),
                                              itemCount:
                                                  discussionComments.length,
                                              separatorBuilder: (_, __) =>
                                                  const Divider(),
                                              itemBuilder: (context, idx) {
                                                final c =
                                                    discussionComments[idx];
                                                final isOwn =
                                                    AuthService.currentUserId ==
                                                    c['userId'];
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        (c['avatar'] ?? '')
                                                            .toString()
                                                            .startsWith('http')
                                                        ? NetworkImage(
                                                            c['avatar'] ?? '',
                                                          )
                                                        : null,
                                                    child:
                                                        (c['avatar'] ?? '')
                                                            .toString()
                                                            .isEmpty
                                                        ? Icon(
                                                            Icons.person,
                                                            color: Colors.grey,
                                                          )
                                                        : null,
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Text(
                                                        c['displayName'] ??
                                                            'Anonymous',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (isOwn)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 6,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .green[50],
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                            child: const Text(
                                                              'Anda',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        c['comment'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        c['createdAt'] !=
                                                                    null &&
                                                                c['createdAt']
                                                                    is Timestamp
                                                            ? _formatDate(
                                                                (c['createdAt']
                                                                        as Timestamp)
                                                                    .toDate(),
                                                              )
                                                            : '',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.grey[500],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: isOwn
                                                      ? Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.edit,
                                                                size: 20,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              onPressed: () =>
                                                                  _startEditComment(
                                                                    c['id'],
                                                                    c['comment'],
                                                                  ),
                                                              tooltip: 'Edit',
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                size: 20,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () =>
                                                                  _deleteDiscussionComment(
                                                                    c['id'],
                                                                  ),
                                                              tooltip: 'Hapus',
                                                            ),
                                                          ],
                                                        )
                                                      : null,
                                                );
                                              },
                                            ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (AuthService.currentUserId != null &&
                                        AuthService.currentUserId!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _discussionController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      editingCommentId != null
                                                      ? 'Edit komentar...'
                                                      : 'Tulis komentar...',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (editingCommentId != null)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: _cancelEditComment,
                                                tooltip: 'Batal',
                                              ),
                                            IconButton(
                                              icon: Icon(
                                                editingCommentId != null
                                                    ? Icons.check
                                                    : Icons.send,
                                                color: Colors.green,
                                              ),
                                              onPressed:
                                                  _addOrEditDiscussionComment,
                                              tooltip: editingCommentId != null
                                                  ? 'Simpan'
                                                  : 'Kirim',
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Login untuk ikut berdiskusi',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const SignInScreen(),
                                                    ),
                                                  ),
                                              child: const Text(
                                                'Login',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ],
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
