import 'package:flutter/material.dart';
import 'home/HomePage.dart';
import 'home/categories_page.dart';
import 'shopping_cart/shopping.cart.dart';
import 'wishlist/WishlistPage.dart';

class ProfilePageDetail extends StatelessWidget {
  const ProfilePageDetail({Key? key}) : super(key: key);
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/3.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Richard Brownlee',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Engineer',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Info rows
            _buildInfoRow('Full Name', 'Richard Brownlee'),
            _buildInfoRow('User Name', 'RichBrown'),
            _buildInfoRow('Phone', '(+91) 123 456 7890'),
            _buildInfoRow('Email Address', 'info@example.com'),
            _buildInfoRow('Shipping Address', 'Marmora Road City'),
            _buildInfoRow('Total Order', '05'),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
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
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.grey.shade400,
                          ),
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

              // Profile
              SizedBox(
                width: 56,
                height: 56,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePageDetail(),
                        ),
                      );
                    },
                    child: const Center(
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=12',
                        ),
                      ),
                    ),
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
