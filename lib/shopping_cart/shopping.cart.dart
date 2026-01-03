import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../CheckoutPage.dart';
import '../services/auth_service.dart';
import '../home/HomePage.dart';

class ShoppingCartPage extends StatefulWidget {
  final List<CartItem> initialItems;
  final bool showBottomNavBar;

  const ShoppingCartPage({
    Key? key,
    this.initialItems = const [],
    this.showBottomNavBar = true,
  }) : super(key: key);

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late List<CartItem> cartItems;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    cartItems = List<CartItem>.from(widget.initialItems);
    // Jika initialItems kosong, load dari Firestore
    if (cartItems.isEmpty) {
      _loadCartFromFirestore();
    } else {
      _saveCartToFirestore();
    }
  }

  Future<void> _loadCartFromFirestore() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final cartList = userData['cart'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            cartItems = cartList
                .map(
                  (item) => CartItem(
                    id: item['id'] ?? '',
                    name: item['name'] ?? '',
                    category: item['category'] ?? '',
                    price: (item['price'] as num?)?.toDouble() ?? 0.0,
                    quantity: item['quantity'] ?? 1,
                    image: item['image'] ?? '',
                  ),
                )
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading cart from Firestore: $e');
    }
  }

  Future<void> _saveCartToFirestore() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    try {
      final cartData = cartItems
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'category': item.category,
              'price': item.price,
              'quantity': item.quantity,
              'image': item.image,
            },
          )
          .toList();

      await _firestore.collection('users').doc(userId).update({
        'cart': cartData,
      });
    } catch (e) {
      print('Error saving cart to Firestore: $e');
    }
  }

  void updateQuantity(String id, int change) {
    setState(() {
      final item = cartItems.firstWhere((item) => item.id == id);
      item.quantity += change;
      if (item.quantity < 0) item.quantity = 0;
    });
    _saveCartToFirestore();
  }

  void removeItem(String id) {
    setState(() {
      cartItems.removeWhere((item) => item.id == id);
    });
    _saveCartToFirestore();
  }

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.1; // Assuming 10% tax
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 13),
          child: Text(
            'Shopping Cart',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                    cartItems: cartItems
                        .map(
                          (item) => {
                            'id': item.id,
                            'name': item.name,
                            'category': item.category,
                            'price': item.price,
                            'quantity': item.quantity,
                            'image': item.image,
                          },
                        )
                        .toList(),
                    subtotal: subtotal,
                    tax: tax,
                    total: total,
                  ),
                ),
              );
            },
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Color(0xFF4CB32B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Keranjang Anda Kosong',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Yuk, mulai belanja dan temukan produk favoritmu!\nKlik ikon Home untuk menjelajah.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    removeItem(item.id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  child: CartItemWidget(
                    item: item,
                    onQuantityChanged: (change) =>
                        updateQuantity(item.id, change),
                  ),
                );
              },
            ),
      // Cegah double bottom nav: hanya render jika showBottomNavBar true
      bottomNavigationBar: widget.showBottomNavBar
          ? Container(
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
                  _buildNavItem(context, Icons.home, 0),
                  _buildNavItem(context, Icons.compare_arrows, 1),
                  _buildNavItemWithBadge(context, Icons.shopping_cart, 2),
                  _buildNavItem(context, Icons.favorite, 3),
                  _buildNavItem(context, Icons.person, 4),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = index == 2; // 2 = Cart
    return InkWell(
      onTap: () {
        // Navigasi ke HomePage dan buka tab sesuai index
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomePage(selectedIndex: index)),
          (route) => false,
        );
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

  Widget _buildNavItemWithBadge(
    BuildContext context,
    IconData icon,
    int index,
  ) {
    final isSelected = index == 2;
    // TODO: Tambahkan badge jika ingin menampilkan jumlah item di cart
    return InkWell(
      onTap: () {
        // Stay on Cart
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
}

class CartItem {
  final String id;
  final String name;
  final String category;
  final double price;
  int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.image,
  });

  double get totalPrice => price * quantity;
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 120, // Increased height to make items taller
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image with price badge
          Stack(
            children: [
              Container(
                width: 100, // Increased width
                height: 100, // Increased height
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.image.startsWith('http')
                      ? Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: 50,
                            );
                          },
                        )
                      : Image.asset(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: 50,
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CB32B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '\$${item.price.toStringAsFixed(1)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24), // Increased spacing between image and text
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                Text(
                  item.category,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFF4CB32B),
                        fontSize: 20, // Increased font size
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => onQuantityChanged(-1),
                            icon: const Icon(
                              Icons.remove,
                              size: 20,
                            ), // Increased icon size
                            color: Colors.grey.shade700,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36, // Increased size
                              minHeight: 36,
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 28,
                            ), // Increased width
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16, // Increased font size
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onQuantityChanged(1),
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                            ), // Increased icon size
                            color: Colors.grey.shade700,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36, // Increased size
                              minHeight: 36,
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
        ],
      ),
    );
  }
}
