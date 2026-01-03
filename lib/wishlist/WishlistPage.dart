import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../detail_page.dart';

class WishlistPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const WishlistPage({super.key, this.onBackToHome});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Product> wishlistItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getWishlist();

      if (result['success'] == true && mounted) {
        final data = result['data'];
        if (data != null && data['data'] is List) {
          final products = (data['data'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

          setState(() {
            wishlistItems = products;
            isLoading = false;
          });
        } else {
          setState(() {
            wishlistItems = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load wishlist';
          isLoading = false;
        });
      }
    } catch (e) {
      print('[Wishlist] Error loading wishlist: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromWishlist(Product product) async {
    // Remove from state immediately for better UX
    setState(() {
      wishlistItems.removeWhere((item) => item.id == product.id);
    });

    // Remove from database
    final result = await ApiService.removeFromWishlist(product.id);

    if (!result['success']) {
      // Revert on error
      setState(() {
        wishlistItems.add(product);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from wishlist'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? Colors.black : Colors.white,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    if (widget.onBackToHome != null) {
                      print('Wishlist: onBackToHome callback invoked');
                      widget.onBackToHome!();
                    } else {
                      print('Wishlist: no callback, popping route');
                      Navigator.of(context).pop();
                    }
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ),
              Expanded(
                child: Text(
                  'Wishlist',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CB32B)),
              )
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadWishlist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CB32B),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : wishlistItems.isEmpty
            ? _buildEmptyWishlist()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final product = wishlistItems[index];
                    return _buildWishlistCard(product);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildWishlistCard(Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl != null
                  ? Image.network(
                      ApiConfig.assetUrl(product.imageUrl!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
            // Favorite Icon (filled heart)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => _removeFromWishlist(product),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
            // Name and Price at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items you love to your wishlist',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
