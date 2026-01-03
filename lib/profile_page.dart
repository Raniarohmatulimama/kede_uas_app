import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/HomePage.dart';
import 'home/categories_page.dart';
import 'shopping_cart/shopping.cart.dart';
import 'wishlist/WishlistPage.dart';
import 'providers/user_provider.dart';

class ProfilePageDetail extends StatefulWidget {
  const ProfilePageDetail({super.key});

  @override
  State<ProfilePageDetail> createState() => _ProfilePageDetailState();
}

class _ProfilePageDetailState extends State<ProfilePageDetail> {
  @override
  void initState() {
    super.initState();
    // Load user data immediately when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUserData();
    });
  }

  Future<void> _refreshUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
  }

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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return RefreshIndicator(
            onRefresh: _refreshUserData,
            color: const Color(0xFF4CB32B),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: userProvider.photoPath != null
                        ? Image.network(
                            userProvider.photoPath!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  'assets/images/3.jpg',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                          )
                        : Image.asset(
                            'assets/images/3.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userProvider.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userProvider.email.isNotEmpty
                        ? userProvider.email
                        : 'No email provided',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Info rows
                  _buildInfoRow(
                    'Full Name',
                    userProvider.fullName.isNotEmpty
                        ? userProvider.fullName
                        : 'N/A',
                  ),
                  _buildInfoRow(
                    'Phone',
                    userProvider.phone.isNotEmpty
                        ? userProvider.phone
                        : 'Not set',
                  ),
                  _buildInfoRow(
                    'Email Address',
                    userProvider.email.isNotEmpty ? userProvider.email : 'N/A',
                  ),
                  _buildInfoRow(
                    'Total Order',
                    userProvider.totalOrder.toString(),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
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
