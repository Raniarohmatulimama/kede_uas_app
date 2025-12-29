import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../shopping_cart/shopping.cart.dart';
import '../wishlist/WishlistPage.dart';
import '../detail_page.dart';
import '../user/user_page.dart';
import '../notifications_page.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../providers/user_provider.dart';
import 'categories_page.dart';
import 'add_product_page.dart';

// HomePage

class HomePage extends StatefulWidget {
  final int selectedIndex;
  const HomePage({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  String? _photoPath;
  int _lastIndexBeforeWishlist = 0;

  late final List<Widget> _pages;
  void goToCartTab() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadPhoto();
    _pages = [
      HomeContent(onGoToCart: goToCartTab),
      CategoriesPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0; // Go back to Home tab
          });
        },
        onGoToCart: goToCartTab,
      ),
      const ShoppingCartPage(showBottomNavBar: false),
      WishlistPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = _lastIndexBeforeWishlist;
          });
        },
      ),
      const ProfilePage(),
    ];
  }

  Future<void> _loadPhoto() async {
    final photo = await AuthService.getPhoto();
    if (mounted) {
      setState(() {
        _photoPath = photo;
      });
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadPhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _selectedIndex == 1
          ? null // Hide bottom nav on Categories page
          : Container(
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
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.compare_arrows, 1),
                  _buildNavItemWithBadge(Icons.shopping_cart, 2),
                  _buildNavItem(Icons.favorite, 3),
                  _buildProfileNavItem(4),
                ],
              ),
            ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 3) {
          // Navigating to Wishlist: remember where we came from
          _lastIndexBeforeWishlist = _selectedIndex;
        }
        setState(() {
          _selectedIndex = index;
        });
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

  Widget _buildNavItemWithBadge(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 3) {
          _lastIndexBeforeWishlist = _selectedIndex;
        }
        setState(() {
          _selectedIndex = index;
        });
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

  Widget _buildProfileNavItem(int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () async {
        setState(() {
          _selectedIndex = index;
        });
        // Reload foto setelah kembali dari halaman profile
        await Future.delayed(const Duration(milliseconds: 100));
        _loadPhoto();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFF4CB32B), width: 2)
              : null,
        ),
        child: _photoPath != null && _photoPath!.isNotEmpty
            ? CircleAvatar(
                radius: 18,
                backgroundImage: _getPhotoProvider(_photoPath!),
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

  // Helper method to get image provider (base64, URL, or file)
  ImageProvider _getPhotoProvider(String photoData) {
    // Check if it's base64 string from backend
    if (photoData.startsWith('data:image')) {
      final base64String = photoData.split(',')[1];
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    }

    // Check if it's a full URL (http/https)
    if (photoData.startsWith('http://') || photoData.startsWith('https://')) {
      final normalized = ApiConfig.assetUrl(photoData);
      return NetworkImage(normalized);
    }

    // Check if it's a relative path from backend (storage/profile-photos/...)
    if (!photoData.startsWith('/')) {
      final fullUrl = ApiConfig.assetUrl(photoData);
      return NetworkImage(fullUrl);
    }

    // Otherwise it's a local file path
    return FileImage(File(photoData));
  }
}

// HomeContent
class HomeContent extends StatefulWidget {
  final VoidCallback? onGoToCart;
  const HomeContent({Key? key, this.onGoToCart}) : super(key: key);
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final Set<String> _favorites = {'Avocado'};
  List<Product> trendingProducts = [];
  bool isLoadingTrending = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Load user data when HomeContent is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
      _loadTrendingProducts();
    });
  }

  Future<void> _loadTrendingProducts() async {
    try {
      setState(() {
        isLoadingTrending = true;
        errorMessage = null;
      });

      final result = await ApiService.getProducts();

      if (result['success'] == true && mounted) {
        final data = result['data'];
        if (data != null && data['data'] is List) {
          final allProducts = (data['data'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

          // Sort by price (lowest first) and take 4 products
          allProducts.sort((a, b) => a.price.compareTo(b.price));
          final trending = allProducts.take(4).toList();

          if (mounted) {
            setState(() {
              trendingProducts = trending;
              isLoadingTrending = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              trendingProducts = [];
              isLoadingTrending = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage =
                result['message'] ?? 'Failed to load trending products';
            isLoadingTrending = false;
          });
        }
      }
    } catch (e) {
      print('[HomePage] Error loading trending products: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoadingTrending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      final isLoggedIn = AuthService.currentUser != null;
                      final fullName = userProvider.fullName;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good Morning',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoggedIn ? fullName : 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Banner Slider
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final banners = [
                      {
                        'text': 'Recommended Recipe Today',
                        'image': 'assets/images/recomended recipe.png',
                      },
                      {
                        'text': 'Fresh Fruits Delivery',
                        'image': 'assets/images/fresh fruits.png',
                      },
                      {
                        'text': 'Recommended Recipe Today',
                        'image': 'assets/images/recomended recipe.png',
                      },
                      {
                        'text': 'Fresh Fruits Delivery',
                        'image': 'assets/images/fresh fruits.png',
                      },
                    ];
                    return Container(
                      width: 330,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              banners[index]['image']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade300,
                                          Colors.green.shade700,
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          // Dark overlay
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                color: Colors.black.withOpacity(0.35),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 20,
                            right: 16,
                            child: Text(
                              banners[index]['text']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CB32B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      iconSize: 20,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoriesPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Icons - Horizontal Scrollable
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryIcon(
                      context,
                      'assets/icons/grapes.svg',
                      'Fruits',
                      true,
                      '87 Items',
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      context,
                      'assets/icons/leaf.svg',
                      'Vegetables',
                      false,
                      '24 Items',
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      context,
                      'assets/icons/mushroom.svg',
                      'Mushroom',
                      false,
                      '43 Items',
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      context,
                      'assets/icons/cheese.svg',
                      'Dairy',
                      false,
                      '22 Items',
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      context,
                      'assets/icons/rice.svg',
                      'Oats',
                      false,
                      '64 Items',
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      context,
                      'assets/icons/bread.svg',
                      'Bread',
                      false,
                      '43 Items',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trending Deals Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trending Deals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CB32B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      iconSize: 20,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllProductsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Grid (2-column GridView to match mockup)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: isLoadingTrending
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CB32B),
                        ),
                      )
                    : errorMessage != null
                    ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                        children: trendingProducts.isNotEmpty
                            ? trendingProducts
                                  .map(
                                    (product) =>
                                        _TrendingProductCard(product: product),
                                  )
                                  .toList()
                            : [
                                // Fallback if no products
                                _buildProductCard(
                                  context,
                                  Product(
                                    id: 'avocado',
                                    name: 'Avocado',
                                    category: 'FRUITS',
                                    description: 'Fresh avocado',
                                    price: 6.7,
                                    imageUrl: 'assets/images/avocado.png',
                                    stock: 10,
                                  ),
                                ),
                                _buildProductCard(
                                  context,
                                  Product(
                                    id: 'broccoli',
                                    name: 'Broccoli',
                                    category: 'VEGETABLES',
                                    description: 'Fresh broccoli',
                                    price: 8.7,
                                    imageUrl: 'assets/images/brocoli.png',
                                    stock: 10,
                                  ),
                                ),
                                _buildProductCard(
                                  context,
                                  Product(
                                    id: 'tomatoes',
                                    name: 'Tomatoes',
                                    category: 'VEGETABLES',
                                    description: 'Fresh tomatoes',
                                    price: 4.9,
                                    imageUrl: 'assets/images/tomatoes.png',
                                    stock: 10,
                                  ),
                                ),
                                _buildProductCard(
                                  context,
                                  Product(
                                    id: 'grapes',
                                    name: 'Grapes',
                                    category: 'FRUITS',
                                    description: 'Fresh grapes',
                                    price: 7.2,
                                    imageUrl: 'assets/images/grapes.png',
                                    stock: 10,
                                  ),
                                ),
                              ],
                      ),
              ),
              const SizedBox(height: 24),

              // Load More Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllProductsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CB32B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LOAD MORE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    String svgPath,
    String label,
    bool isSelected,
    String itemCount,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AllProductsPage(categoryName: label, categoryIcon: svgPath),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CB32B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4CB32B)
                    : const Color(0xFF4CB32B),
                width: 1.5,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 35,
                height: 35,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : const Color(0xFF4CB32B),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final isFav = _favorites.contains(product.name);

    return GestureDetector(
      onTap: () {
        // Navigate to product detail page when the product card is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              onGoToCart: widget.onGoToCart,
            ),
          ),
        );
      },
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
            // Favorite Icon
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  // allow tapping the heart to also toggle
                  setState(() {
                    if (_favorites.contains(product.name)) {
                      _favorites.remove(product.name);
                    } else {
                      _favorites.add(product.name);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
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
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${product.price.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildDynamicProductCard(BuildContext context, Product product) {
    // Check if product is in favorites
    final isFav = _favorites.contains(product.name);

    return GestureDetector(
      onTap: () {
        // Navigate to product detail page when the product card is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              onGoToCart: widget.onGoToCart,
            ),
          ),
        );
      },
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Image from Network
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl != null
                  ? Image.network(
                      ApiConfig.assetUrl(product.imageUrl!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
            // Favorite Icon
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_favorites.contains(product.name)) {
                      _favorites.remove(product.name);
                    } else {
                      _favorites.add(product.name);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
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
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${product.price.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  // Dedicated stateful card for Trending Deals with Wishlist integration
}

class _TrendingProductCard extends StatefulWidget {
  final Product product;

  final VoidCallback? onGoToCart;
  const _TrendingProductCard({Key? key, required this.product, this.onGoToCart})
    : super(key: key);

  @override
  State<_TrendingProductCard> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<_TrendingProductCard> {
  bool isFavorite = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initFavorite();
  }

  Future<void> _initFavorite() async {
    final inWishlist = await ApiService.isInWishlist(widget.product.id);
    if (mounted) {
      setState(() {
        isFavorite = inWishlist;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final result = isFavorite
        ? await ApiService.removeFromWishlist(widget.product.id)
        : await ApiService.addToWishlist(widget.product.id);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? '${widget.product.name} added to wishlist'
                : '${widget.product.name} removed from wishlist',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: isFavorite ? Colors.green : Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result['message'] ?? 'Action failed'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: widget.product,
              onGoToCart: widget.onGoToCart,
            ),
          ),
        );
      },
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Image from Network
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.product.imageUrl != null
                  ? Image.network(
                      ApiConfig.assetUrl(widget.product.imageUrl!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
            // Favorite Icon
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: _toggleWishlist,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
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
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}

// Placeholder Pages
class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = List.generate(
      8,
      (i) => {
        'title': 'Order #${1000 + i}',
        'date': 'Oct ${i + 1}, 2025',
        'amount': '\$${(10 + i).toStringAsFixed(2)}',
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final e = entries[index];
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Text(
                e['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(e['date']!),
              trailing: Text(
                e['amount']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
