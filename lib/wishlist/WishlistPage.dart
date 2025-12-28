import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WishlistPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const WishlistPage({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Sample wishlist items
  final List<Map<String, dynamic>> wishlistItems = [
    {'name': 'Avocado', 'price': '\$6.7', 'image': 'assets/images/avocado.png'},
    {'name': 'Brocoli', 'price': '\$8.7', 'image': 'assets/images/brocoli.png'},
    {
      'name': 'Tomatoes',
      'price': '\$4.9',
      'image': 'assets/images/tomatoes.png',
    },
    {'name': 'Grapes', 'price': '\$7.2', 'image': 'assets/images/grapes.png'},
    {
      'name': 'Avocado',
      'price': '\$6.7',
      'image': 'assets/images/avocado1.jpg',
    },
    {'name': 'Brocoli', 'price': '\$8.7', 'image': 'assets/images/brocoli.png'},
  ];

  void _removeFromWishlist(int index) {
    setState(() {
      wishlistItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from wishlist'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                    // Prefer the provided callback, but fallback to popping the
                    // current route so the back button always works.
                    if (widget.onBackToHome != null) {
                      // add debug print to help trace behavior
                      // ignore: avoid_print
                      print('Wishlist: onBackToHome callback invoked');
                      widget.onBackToHome!();
                    } else {
                      // fallback: pop this route
                      // ignore: avoid_print
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
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          centerTitle: true,
        ),
        body: wishlistItems.isEmpty
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
                    final item = wishlistItems[index];
                    return _buildWishlistCard(
                      item['name'] as String,
                      item['price'] as String,
                      item['image'] as String,
                      index,
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildWishlistCard(
    String name,
    String price,
    String imagePath,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.image, size: 50, color: Colors.grey.shade400),
              ),
            ),
          ),
          // Favorite Icon (filled heart)
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: () => _removeFromWishlist(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.favorite, color: Colors.red, size: 20),
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
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
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
