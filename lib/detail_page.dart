import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/api_config.dart';
import 'shopping_cart/shopping.cart.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'sign_in/sign_in_screen.dart';
import 'models/product_model.dart';

class Review {
  final String name;
  final String date;
  final String comment;
  final double rating;
  final String avatar;

  const Review({
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
  final VoidCallback? onGoToCart;

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
  late Product product;
  List<Review> productReviews = [];
  List<String> imageUrls = [];
  late TabController _tabController;
  late PageController _pageController;
  int quantity = 1;
  bool isFavorite = false;
  bool isLoadingDiscussion = false;
  List<Map<String, dynamic>> discussionComments = [];
  String? editingCommentId;
  String? editingCommentText;
  String? replyToCommentId;
  String? replyToUserName;
  final TextEditingController _discussionController = TextEditingController();
  final FocusNode _discussionFocusNode = FocusNode();
  final Set<String> expandedReplies = {};

  int get effectiveReviewCount =>
      productReviews.isNotEmpty ? productReviews.length : 0;

  // Page controller carousel gambar
  int _currentImageIndex = 0;
  double get effectiveRating {
    if (productReviews.isNotEmpty) {
      final total = productReviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );
      return total / productReviews.length;
    }
    return 0;
  }

  List<String> get reviewerAvatars => productReviews.isNotEmpty
      ? productReviews.take(3).map((review) => review.avatar).toList()
      : [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

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

    imageUrls =
        (widget.product != null &&
            widget.product!.imageUrls != null &&
            widget.product!.imageUrls!.isNotEmpty)
        ? widget.product!.imageUrls!
        : [product.imageUrl ?? 'assets/images/orange.jpg'];

    productReviews = widget.reviews ?? [];

    _checkIfInWishlist();
    _loadReviewsFromFirestore();
    _loadDiscussionComments();
  }

  Future<void> _loadDiscussionComments() async {
    setState(() => isLoadingDiscussion = true);
    try {
      final db = FirebaseFirestore.instance;
      final snap = await db
          .collection('products')
          .doc(product.id)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      if (mounted) {
        setState(() {
          discussionComments = snap.docs
              .map((d) => {...d.data(), 'id': d.id})
              .toList();
        });
      }
    } catch (e) {
      print('Error load discussion: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingDiscussion = false);
      }
    }
  }

  Future<void> _addOrEditDiscussionComment() async {
    final text = _discussionController.text.trim();
    if (text.isEmpty) return;

    final userId = AuthService.currentUserId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk berdiskusi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String displayName = 'Anonymous';
    String avatar = '';
    final db = FirebaseFirestore.instance;

    try {
      final firstName = await AuthService.getFirstName() ?? '';
      final lastName = await AuthService.getLastName() ?? '';
      final fullName = '$firstName $lastName'.trim();
      final photo = await AuthService.getPhoto();

      if (fullName.isNotEmpty) {
        displayName = fullName;
      }
      if (photo != null && photo.isNotEmpty) {
        avatar = photo;
      }

      if (displayName == 'Anonymous' || avatar.isEmpty) {
        final userDoc = await db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (displayName == 'Anonymous') {
            final fsFirstName = userData?['first_name'] ?? '';
            final fsLastName = userData?['last_name'] ?? '';
            final fsFullName = '$fsFirstName $fsLastName'.trim();
            displayName = fsFullName.isNotEmpty
                ? fsFullName
                : userData?['displayName'] ??
                      userData?['name'] ??
                      AuthService.currentUser?.displayName ??
                      'Anonymous';
          }
          if (avatar.isEmpty) {
            avatar =
                userData?['profile_photo_url'] ??
                userData?['profile_photo'] ??
                AuthService.currentUser?.photoURL ??
                '';
          }
        }
      }

      if (editingCommentId != null) {
        await db
            .collection('products')
            .doc(product.id)
            .collection('comments')
            .doc(editingCommentId)
            .update({
              'comment': text,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      } else {
        await db
            .collection('products')
            .doc(product.id)
            .collection('comments')
            .add({
              'comment': text,
              'userId': userId,
              'displayName': displayName,
              'avatar': avatar,
              'parentCommentId': replyToCommentId,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        setState(() {
          editingCommentId = null;
          editingCommentText = null;
          replyToCommentId = null;
          replyToUserName = null;
          _discussionController.clear();
        });
      }

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
      replyToCommentId = null;
      replyToUserName = null;
      _discussionController.clear();
    });
  }

  void _cancelReplyComment() {
    setState(() {
      replyToCommentId = null;
      replyToUserName = null;
      _discussionController.clear();
    });
  }

  void _startReplyComment(String commentId, String userName) {
    setState(() {
      replyToCommentId = commentId;
      replyToUserName = userName;
      editingCommentId = null;
      editingCommentText = null;
      _discussionController.clear();
    });
    _discussionFocusNode.requestFocus();
  }

  Future<void> _loadReviewsFromFirestore() async {
    try {
      print('DEBUG: Loading reviews for productId: ${product.id}');
      final db = FirebaseFirestore.instance;

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
        }
      } else {
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
    _discussionController.dispose();
    _discussionFocusNode.dispose();
    _pageController.dispose();
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
          CustomScrollView(
            slivers: [
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
                          setState(() {
                            _currentImageIndex = index;
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
                            Text(
                              product.category,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                      ? '($effectiveReviewCount reviews)'
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
                            Tab(text: 'Discussion'),
                          ],
                        ),
                      ),
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
                            _buildReviewTab(),
                            // Discussion Tab
                            _buildDiscussionTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        fill: isFavorite ? 1 : 0,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CB32B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: addToCart,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${(product.price * quantity).toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

  Widget _buildReviewTab() {
    return Container(
      color: Colors.grey[50],
      child: productReviews.isEmpty
          ? Center(
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jadilah yang pertama memberikan review',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24.0),
              itemCount: productReviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final review = productReviews[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: review.avatar.startsWith('http')
                          ? NetworkImage(review.avatar)
                          : null,
                      onBackgroundImageError: review.avatar.startsWith('http')
                          ? (exception, stackTrace) {
                              print('❌ ERROR loading avatar: $exception');
                            }
                          : null,
                      child: review.avatar.startsWith('http')
                          ? null
                          : Text(
                              review.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CB32B),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  review.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < 5; i++)
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: i < review.rating.toInt()
                                          ? Colors.orange
                                          : Colors.grey[300],
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
    );
  }

  Widget _buildDiscussionTab() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                if (isLoadingDiscussion)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (discussionComments.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Belum ada diskusi. Jadilah yang pertama!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: discussionComments
                          .where((c) => c['parentCommentId'] == null)
                          .length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, idx) {
                        final parentComments = discussionComments
                            .where((c) => c['parentCommentId'] == null)
                            .toList();
                        final c = parentComments[idx];
                        final isOwn = AuthService.currentUserId == c['userId'];
                        final replies = discussionComments
                            .where(
                              (reply) => reply['parentCommentId'] == c['id'],
                            )
                            .toList();

                        return _buildCommentItem(c, isOwn, replies);
                      },
                    ),
                  ),
              ],
            ),
          ),
          _buildDiscussionInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    Map<String, dynamic> c,
    bool isOwn,
    List<Map<String, dynamic>> replies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (c['avatar'] ?? '').toString().startsWith('http')
                  ? NetworkImage(c['avatar'] ?? '')
                  : null,
              child: (c['avatar'] ?? '').toString().isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c['displayName'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (isOwn) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4EDDA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Anda',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF155724),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['comment'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c['createdAt'] != null && c['createdAt'] is Timestamp
                              ? _formatDate(
                                  (c['createdAt'] as Timestamp).toDate(),
                                )
                              : 'baru saja',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _startReplyComment(
                          c['id'],
                          c['displayName'] ?? 'Anonymous',
                        ),
                        child: Text(
                          'Balas',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isOwn) ...[
                        const Text(' • ', style: TextStyle(color: Colors.grey)),
                        InkWell(
                          onTap: () => _startEditComment(c['id'], c['comment']),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Text(' • ', style: TextStyle(color: Colors.grey)),
                        InkWell(
                          onTap: () => _deleteDiscussionComment(c['id']),
                          child: Text(
                            'Hapus',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (replies.isNotEmpty) _buildReplies(c['id'], replies),
      ],
    );
  }

  Widget _buildReplies(String parentId, List<Map<String, dynamic>> replies) {
    return Padding(
      padding: const EdgeInsets.only(left: 52, top: 12),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (expandedReplies.contains(parentId)) {
                      expandedReplies.remove(parentId);
                    } else {
                      expandedReplies.add(parentId);
                    }
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expandedReplies.contains(parentId)
                          ? 'Sembunyikan ${replies.length} balasan'
                          : 'Lihat ${replies.length} balasan komentar',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expandedReplies.contains(parentId)
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
            if (expandedReplies.contains(parentId))
              ...replies.map((reply) {
                final isReplyOwn = AuthService.currentUserId == reply['userId'];
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            (reply['avatar'] ?? '').toString().startsWith(
                              'http',
                            )
                            ? NetworkImage(reply['avatar'] ?? '')
                            : null,
                        child: (reply['avatar'] ?? '').toString().isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  reply['displayName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• ${reply['createdAt'] != null && reply['createdAt'] is Timestamp ? _formatDate((reply['createdAt'] as Timestamp).toDate()) : 'baru saja'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reply['comment'] ?? '',
                              style: const TextStyle(fontSize: 13, height: 1.3),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _startReplyComment(
                                parentId,
                                reply['displayName'] ?? 'Anonymous',
                              ),
                              child: Text(
                                'Balas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyToCommentId != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Membalas: $replyToUserName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: _cancelReplyComment,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          if (editingCommentId != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Mengedit komentar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _cancelEditComment,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _discussionController,
                  focusNode: _discussionFocusNode,
                  maxLines: null,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: replyToCommentId != null
                        ? 'Balas $replyToUserName...'
                        : 'Tulis komentar...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 0,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _addOrEditDiscussionComment,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CB32B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
