import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// HomePage
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const HistoryPage(),
    const CartPage(),
    const WishlistPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
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
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFF4CB32B), width: 2)
              : null,
        ),
        child: const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
        ),
      ),
    );
  }
}

// HomeContent
class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Good Morning',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Samuel Witwicky',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                height: 160,
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
                      width: 300,
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
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Text(
                              banners[index]['text']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                      onPressed: () {},
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
                      'assets/icons/grapes.svg',
                      'Fruits',
                      true,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      'assets/icons/leaf.svg',
                      'Vegetables',
                      false,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      'assets/icons/mushroom.svg',
                      'Mushroom',
                      false,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      'assets/icons/cheese.svg',
                      'Cheese',
                      false,
                    ),
                    const SizedBox(width: 12),
                    _buildCategoryIcon('assets/icons/rice.svg', 'Rice', false),
                    const SizedBox(width: 12),
                    _buildCategoryIcon(
                      'assets/icons/bread.svg',
                      'Bread',
                      false,
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

              // Product Grid
              SizedBox(
                height: 240,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 180,
                      child: _buildProductCard(
                        'Avocado',
                        '\$6.7',
                        'assets/images/avocado.png',
                        true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: _buildProductCard(
                        'Broccoli',
                        '\$8.7',
                        'assets/images/brocoli.png',
                        false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: _buildProductCard(
                        'Tomatoes',
                        '\$4.9',
                        'assets/images/tomatoes.png',
                        false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: _buildProductCard(
                        'Grapes',
                        '\$7.2',
                        'assets/images/grapes.png',
                        false,
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

  Widget _buildCategoryIcon(String svgPath, String label, bool isSelected) {
    return Column(
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
    );
  }

  Widget _buildProductCard(
    String name,
    String price,
    String imagePath,
    bool isFavorite,
  ) {
    return Container(
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
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: Icon(Icons.image, size: 50, color: Colors.grey.shade400),
              ),
            ),
          ),
          // Favorite Icon
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 20,
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
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
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
    );
  }
}

// Placeholder Pages
class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('History Page'));
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Categories Page'));
  }
}

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cart Page'));
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Wishlist Page'));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Page'));
  }
}

// Notifications Page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Apply Success',
      'message': 'You has apply an job in Queenify Group as UI Designer',
      'time': '10h ago',
      'isRead': false,
      'hasIndicator': true,
      'indicatorColor': Color(0xFF00BCD4),
    },
    {
      'title': 'Interview Calls',
      'message': 'Congratulations! You have interview calls',
      'time': '9h ago',
      'isRead': false,
      'hasIndicator': false,
    },
    {
      'title': 'Apply Success',
      'message': 'You has apply an job in Queenify Group as UI Designer',
      'time': '8h ago',
      'isRead': false,
      'hasIndicator': true,
      'indicatorColor': Color(0xFF4CB32B),
    },
    {
      'title': 'Complete your profile',
      'message':
          'Please verify your profile information to continue using this app',
      'time': '4h ago',
      'isRead': false,
      'hasIndicator': true,
      'indicatorColor': Color(0xFF00BCD4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (notification['hasIndicator'] == true)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: notification['indicatorColor'],
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification['time'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          notifications[index]['isRead'] = true;
                        });
                      },
                      child: Text(
                        'Mark as read',
                        style: TextStyle(
                          fontSize: 13,
                          color: notification['isRead']
                              ? Colors.grey.shade400
                              : const Color(0xFF4CB32B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// All Products Page
class AllProductsPage extends StatefulWidget {
  const AllProductsPage({Key? key}) : super(key: key);

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final List<Map<String, dynamic>> allProducts = [
    {
      'name': 'Avocado',
      'price': '\$6.7',
      'image': 'assets/images/avocado.png',
      'isFavorite': true,
    },
    {
      'name': 'Brocoli',
      'price': '\$8.7',
      'image': 'assets/images/brocoli.png',
      'isFavorite': false,
    },
    {
      'name': 'Tomatoes',
      'price': '\$4.9',
      'image': 'assets/images/tomatoes.png',
      'isFavorite': true,
    },
    {
      'name': 'Grapes',
      'price': '\$7.2',
      'image': 'assets/images/grapes.png',
      'isFavorite': false,
    },
    {
      'name': 'Banana',
      'price': '\$3.5',
      'image': 'assets/images/banana.jpg',
      'isFavorite': true,
    },
    {
      'name': 'Orange',
      'price': '\$5.2',
      'image': 'assets/images/orange.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Tomato Cherry',
      'price': '\$5.5',
      'image': 'assets/images/tomatocherry.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Brocoli',
      'price': '\$8.7',
      'image': 'assets/images/brocoli.png',
      'isFavorite': false,
    },
    {
      'name': 'Tomatoes',
      'price': '\$4.9',
      'image': 'assets/images/tomatoes.png',
      'isFavorite': false,
    },
    {
      'name': 'Grapes',
      'price': '\$7.2',
      'image': 'assets/images/grape1.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Banana',
      'price': '\$3.5',
      'image': 'assets/images/banana.jpg',
      'isFavorite': true,
    },
    {
      'name': 'Tomato Cherry',
      'price': '\$5.5',
      'image': 'assets/images/tomatocherry.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Avocado',
      'price': '\$6.9',
      'image': 'assets/images/avocado1.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Orange',
      'price': '\$5.2',
      'image': 'assets/images/orange.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Tomatoes',
      'price': '\$4.9',
      'image': 'assets/images/tomatoes.png',
      'isFavorite': false,
    },
    {
      'name': 'Grapes',
      'price': '\$7.5',
      'image': 'assets/images/grape1.jpg',
      'isFavorite': true,
    },
    {
      'name': 'Banana',
      'price': '\$3.5',
      'image': 'assets/images/banana.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Avocado',
      'price': '\$6.9',
      'image': 'assets/images/avocado1.jpg',
      'isFavorite': false,
    },
    {
      'name': 'Tomatoes',
      'price': '\$4.9',
      'image': 'assets/images/tomatoes.png',
      'isFavorite': false,
    },
    {
      'name': 'Grapes',
      'price': '\$7.2',
      'image': 'assets/images/grapes.png',
      'isFavorite': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Green bar
            Container(height: 8, color: const Color(0xFF4CB32B)),
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid of products
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: allProducts.length,
                  itemBuilder: (context, index) {
                    final product = allProducts[index];
                    return _buildGridProductCard(
                      product['name'],
                      product['price'],
                      product['image'],
                      product['isFavorite'],
                      index,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridProductCard(
    String name,
    String price,
    String imagePath,
    bool isFavorite,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
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
                color: Colors.grey.shade300,
                child: Icon(Icons.image, size: 50, color: Colors.grey.shade400),
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
                  allProducts[index]['isFavorite'] =
                      !allProducts[index]['isFavorite'];
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
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
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
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
    );
  }
}
