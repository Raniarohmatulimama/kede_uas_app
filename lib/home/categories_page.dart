import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/api_config.dart';
import 'package:flutter/services.dart';
import '../detail_page.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'add_product_page.dart';
import '../services/auth_service.dart';
import '../sign_in/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const CategoriesPage({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  Map<String, int> categoryCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductCountsFixed();
  }

  // Fixed: load product counts correctly without UI code.
  Future<void> _loadProductCountsFixed() async {
    try {
      final result = await ApiService.getProducts();
      if (result['success'] == true) {
        final data = result['data'];
        List<dynamic> productList = [];

        if (data is List) {
          productList = data;
        } else if (data is Map) {
          if (data['data'] is Map && data['data']['data'] is List) {
            productList = data['data']['data'] as List<dynamic>;
          } else if (data['data'] is List) {
            productList = data['data'] as List<dynamic>;
          }
        }

        // Count by category
        final counts = <String, int>{};
        for (final item in productList) {
          try {
            final product = Product.fromJson(item as Map<String, dynamic>);
            final key = product.category;
            counts[key] = (counts[key] ?? 0) + 1;
          } catch (_) {
            // skip invalid entries
          }
        }

        if (mounted) {
          setState(() {
            categoryCounts = counts;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            categoryCounts = {};
            isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          categoryCounts = {};
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Fruits', 'icon': 'assets/icons/grapes.svg'},
      {'name': 'Vegetables', 'icon': 'assets/icons/leaf.svg'},
      {'name': 'Mushroom', 'icon': 'assets/icons/mushroom.svg'},
      {'name': 'Dairy', 'icon': 'assets/icons/cheese.svg'},
      {'name': 'Oats', 'icon': 'assets/icons/rice.svg'},
      {'name': 'Bread', 'icon': 'assets/icons/bread.svg'},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllProductsPage(
                      categoryName: category['name'] as String?,
                      categoryIcon: category['icon'] as String?,
                    ),
                  ),
                );
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CB32B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.black.withOpacity(0.03),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -40,
                      bottom: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category['name'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isLoading
                                      ? 'Loading...'
                                      : '${categoryCounts[category['name']] ?? 0} Items',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: SvgPicture.asset(
                              category['icon'] as String,
                              width: 48,
                              height: 48,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.95),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Simple Category detail page class (keeps file structure stable).
class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final String itemCount;

  const CategoryDetailPage({
    Key? key,
    required this.categoryName,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CB32B),
        title: Text('$categoryName'),
      ),
      body: Center(child: Text('$itemCount')),
    );
  }
}

// All Products Page
class AllProductsPage extends StatefulWidget {
  final String? categoryName;
  final String? categoryIcon;

  const AllProductsPage({Key? key, this.categoryName, this.categoryIcon})
    : super(key: key);

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    print('[AllProductsPage] Loading products...');
    if (widget.categoryName != null) {
      print('[AllProductsPage] Filtering by category: ${widget.categoryName}');
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getProducts(
        category: widget.categoryName,
      );
      print('[AllProductsPage] API result: $result');

      if (result['success'] == true && mounted) {
        final data = result['data'];
        print('[AllProductsPage] Data received: $data');
        print('[AllProductsPage] Data type: ${data.runtimeType}');

        if (data != null) {
          setState(() {
            // Handle different response structures
            List<dynamic> productList;
            if (data is List) {
              // Direct array response
              print('[AllProductsPage] Data is List with ${data.length} items');
              productList = data;
            } else if (data is Map) {
              // Handle nested structure from Laravel API
              // Structure: {success: true, data: {current_page: 1, data: [products]}}
              if (data['data'] is Map && data['data']['data'] is List) {
                // Nested pagination response
                print('[AllProductsPage] Nested pagination structure found');
                productList = data['data']['data'] as List;
              } else if (data['data'] is List) {
                // Simple pagination response
                print(
                  '[AllProductsPage] Data is Map with data key containing ${(data['data'] as List).length} items',
                );
                productList = data['data'] as List;
              } else {
                print(
                  '[AllProductsPage] Unknown Map structure, using empty list',
                );
                productList = [];
              }
            } else {
              // Fallback to empty list
              print(
                '[AllProductsPage] Unknown data structure, using empty list',
              );
              productList = [];
            }

            // Parse all products
            List<Product> allProducts = productList
                .map((json) => Product.fromJson(json as Map<String, dynamic>))
                .toList();

            // Filter by category if specified
            if (widget.categoryName != null &&
                widget.categoryName!.isNotEmpty) {
              products = allProducts
                  .where(
                    (product) =>
                        product.category.toLowerCase() ==
                        widget.categoryName!.toLowerCase(),
                  )
                  .toList();
              print(
                '[AllProductsPage] Filtered to ${products.length} products in category ${widget.categoryName}',
              );
            } else {
              products = allProducts;
            }

            print('[AllProductsPage] Final product count: ${products.length}');
            isLoading = false;
          });
        } else {
          print('[AllProductsPage] Data is null');
          setState(() {
            products = [];
            isLoading = false;
          });
        }
      } else {
        print('[AllProductsPage] API call failed: ${result['message']}');
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load products';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('[AllProductsPage] Exception: $e');
      print('[AllProductsPage] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Product',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && product.id != null) {
      final result = await ApiService.deleteProduct(product.id!);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Product deleted successfully',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          _loadProducts(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete product'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Product Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrl != null
                        ? Image.network(
                            ApiConfig.assetUrl(product.imageUrl!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),

            // Edit Option
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditProductPage(product: product),
                  ),
                );
                if (result == true) {
                  _loadProducts(); // Refresh if edited
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CB32B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF4CB32B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Update product details',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),

            // Delete Option
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _deleteProduct(product);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delete Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Remove from your products',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data != null;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF4CB32B),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFF4CB32B),
            floatingActionButton: isLoggedIn
                ? FloatingActionButton(
                    onPressed: () async {
                      // Navigate to Add Product page
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditProductPage(),
                        ),
                      );

                      // Refresh products if a product was added
                      if (result == true) {
                        _loadProducts();
                      }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add, color: Color(0xFF4CB32B)),
                  )
                : null, // Don't show FAB if not logged in
            body: Column(
              children: [
                // Green Header
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFF4CB32B)),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button and filter icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoriesPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Category icon dan title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Category Icon
                              if (widget.categoryIcon != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SvgPicture.asset(
                                    widget.categoryIcon!,
                                    width: 40,
                                    height: 40,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              // Title Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.categoryName != null
                                          ? '${widget.categoryName} Category'
                                          : 'All Products',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${products.length} Items',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content area with white background
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
                    child: Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search here',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Product Grid or Loading/Error State
                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4CB32B),
                                  ),
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
                                        onPressed: _loadProducts,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4CB32B,
                                          ),
                                        ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              : products.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_basket_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No products yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap + to add your first product',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.75,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      return _ProductCard(
                                        product: product,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProductDetailPage(),
                                            ),
                                          );
                                        },
                                        onLongPress: () {
                                          _showProductOptions(product);
                                        },
                                        onMorePressed: () {
                                          _showProductOptions(product);
                                        },
                                      );
                                    },
                                  ),
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
      },
    );
  }
}

// Product Card Widget with Heart Icon and proper layout
class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onMorePressed;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onLongPress,
    this.onMorePressed,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool isFavorite = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfInWishlist();
  }

  Future<void> _checkIfInWishlist() async {
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

    try {
      final result = isFavorite
          ? await ApiService.removeFromWishlist(widget.product.id)
          : await ApiService.addToWishlist(widget.product.id);

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (result['success']) {
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
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Product Image - Full coverage
              widget.product.imageUrl != null
                  ? Image.network(
                      ApiConfig.assetUrl(widget.product.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),

              // Heart/Favorite Icon - Top Left
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: _toggleWishlist,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFavorite ? Colors.pink : Colors.grey.shade600,
                              ),
                            ),
                          )
                        : Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.pink
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                  ),
                ),
              ),

              // More Options Icon - Top Right
              if (widget.onMorePressed != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: widget.onMorePressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ),

              // Product Name and Price - Bottom with gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.8),
                      ],
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
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
      ),
    );
  }
}
