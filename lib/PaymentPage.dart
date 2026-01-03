// Import shared_preferences
// ...existing code...
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'order_detail_page.dart';
import 'services/auth_service.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String customerName;
  final String customerPhone;
  final String notes;

  const PaymentPage({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.customerName,
    required this.customerPhone,
    required this.notes,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Untuk pilihan uang tunai COD
  final List<double> _cashOptions = [];
  double? _selectedCash;
  final NumberFormat _currencyFormatter = NumberFormat.simpleCurrency();
  final _functions = FirebaseFunctions.instance;
  final _auth = FirebaseAuth.instance;
  String? _orderId;

  // Restored fields for address and country
  final TextEditingController _fullAddressController = TextEditingController();
  bool _saveShippingAddress = false;
  final List<String> countries = [
    'Choose your country',
    'USA',
    'China',
    'Indonesia',
    'India',
  ];
  String selectedCountry = 'Indonesia';
  @override
  void initState() {
    super.initState();
    _generateCashOptions();
    _loadSavedCards();
    _loadSavedAddress();
    // Optionally, restore selectedCountry from saved address if needed
  }

  Future<void> _loadSavedAddress() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('shipping_address_${user.uid}');
    if (savedAddress != null && savedAddress.isNotEmpty) {
      setState(() {
        _fullAddressController.text = savedAddress;
        _saveShippingAddress = true;
      });
    }
  }

  Future<void> _loadSavedCards() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedCards')
          .get();

      if (mounted) {
        setState(() {
          _savedCards.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            _savedCards.add({
              'cardHolderName': data['cardHolderName'],
              'lastFourDigits': data['lastFourDigits'],
              'expiryDate': data['expiryDate'],
              'themeIndex': data['themeIndex'] ?? 0,
              'country': data['country'],
              'docId': doc.id,
            });
          }
          if (_savedCards.isNotEmpty) {
            _selectedCardIndex = 0;
          }
        });
      }
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  Future<void> _saveCardToFirebase({
    required String cardHolderName,
    required String lastFourDigits,
    required String expiryDate,
    required int themeIndex,
    required String country,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Ensure user document exists
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Then save card
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedCards')
          .add({
            'cardHolderName': cardHolderName,
            'lastFourDigits': lastFourDigits,
            'expiryDate': expiryDate,
            'themeIndex': themeIndex,
            'country': country,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving card: $e');
      rethrow;
    }
  }

  void _generateCashOptions() {
    // Contoh kelipatan: 10, 20, 30, 50, 100, 200, 500, dst
    final total = widget.total;
    final List<double> options = [10, 20, 30, 50, 100, 200, 500, 1000];
    _cashOptions.clear();
    for (final o in options) {
      if (o > total) _cashOptions.add(o);
    }
    // Jika tidak ada yang lebih besar, tambahkan total*2
    if (_cashOptions.isEmpty) {
      _cashOptions.add(total * 2);
    }
    // Pilihan default
    if (_cashOptions.isNotEmpty) _selectedCash = _cashOptions.first;
  }

  String _selectedPaymentTab = 'Credit Card';
  int _selectedCardIndex = 0;

  final List<Map<String, dynamic>> _savedCards = [];

  double get _totalAmount {
    final itemsTotal = widget.cartItems.fold<double>(0, (sum, item) {
      final price = (item['price'] ?? 0).toDouble();
      final qty = (item['quantity'] ?? 1).toDouble();
      return sum + price * qty;
    });
    return itemsTotal + widget.tax + widget.deliveryFee;
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    super.dispose();
  }

  void _showPaymentSuccessDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade50, Colors.white],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pesanan Anda telah berhasil dibuat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(
                            orderId: orderId,
                            showNotification: true,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Detail Pesanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
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

  void _showCODConfirmationDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.blue.shade600,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesanan Dikonfirmasi!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan lakukan pembayaran saat barang tiba',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(
                            orderId: orderId,
                            showNotification: true,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Detail Pesanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
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

  void _showAddCardDialog() {
    // ...existing code...
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    // ...existing code...

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add New Card',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDialogTextField(
                        controller: nameController,
                        label: 'Card Holder Name',
                        hintText: 'Enter card holder name',
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: numberController,
                        label: 'Card Number',
                        hintText: '1234 5678 9012 3456',
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogTextField(
                              controller: expiryController,
                              label: 'Expiry Date',
                              hintText: 'MM/YY',
                              maxLength: 5,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDialogTextField(
                              controller: cvvController,
                              label: 'CVV',
                              hintText: '123',
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDialogCountryDropdown(
                        countries: countries,
                        selected: selectedCountry,
                        onChanged: (val) {
                          setInnerState(() {
                            selectedCountry = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isEmpty ||
                                numberController.text.isEmpty ||
                                expiryController.text.isEmpty ||
                                cvvController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please fill in all card details',
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            if (selectedCountry == countries.first) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please select a country',
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            // Validate card number (should be 16 digits)
                            final cardNumber = numberController.text.replaceAll(
                              ' ',
                              '',
                            );
                            if (cardNumber.length != 16) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Card number must be 16 digits',
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            // Validate expiry date format (MM/YY)
                            if (!RegExp(
                              r'^\d{2}/\d{2}$',
                            ).hasMatch(expiryController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Expiry date must be in MM/YY format',
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            // Validate CVV (should be 3 digits)
                            if (cvvController.text.length != 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('CVV must be 3 digits'),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            // Save card to Firebase
                            final themeIndex = _savedCards.length % 3;
                            final lastFourDigits = cardNumber.substring(12);

                            _saveCardToFirebase(
                                  cardHolderName: nameController.text,
                                  lastFourDigits: lastFourDigits,
                                  expiryDate: expiryController.text,
                                  themeIndex: themeIndex,
                                  country: selectedCountry,
                                )
                                .then((_) {
                                  setState(() {
                                    _savedCards.add({
                                      'cardHolderName': nameController.text,
                                      'lastFourDigits': lastFourDigits,
                                      'expiryDate': expiryController.text,
                                      'themeIndex': themeIndex,
                                      'country': selectedCountry,
                                    });
                                    _selectedCardIndex = _savedCards.length - 1;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Card saved successfully',
                                      ),
                                      backgroundColor: const Color(0xFF4CB32B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                })
                                .catchError((e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error saving card: $e'),
                                      backgroundColor: Colors.red.shade400,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                });
                            return;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CB32B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CB32B)),
            ),
          ),
          onChanged: (value) {
            // Auto-format card number
            if (label == 'Card Number') {
              final text = value.replaceAll(' ', '');
              if (text.length <= 16) {
                final buffer = StringBuffer();
                for (int i = 0; i < text.length; i++) {
                  buffer.write(text[i]);
                  if ((i + 1) % 4 == 0 && i + 1 != text.length) {
                    buffer.write(' ');
                  }
                }
                final newValue = buffer.toString();
                controller.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: newValue.length),
                );
              }
            }
            // Auto-format expiry date
            if (label == 'Expiry Date') {
              final text = value.replaceAll('/', '');
              if (text.length <= 4) {
                final buffer = StringBuffer();
                for (int i = 0; i < text.length; i++) {
                  buffer.write(text[i]);
                  if (i == 1 && text.length > 2) {
                    buffer.write('/');
                  }
                }
                final newValue = buffer.toString();
                controller.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: newValue.length),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDialogCountryDropdown({
    required List<String> countries,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selected,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4CB32B),
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4CB32B),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4CB32B),
                width: 1.6,
              ),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CB32B)),
          items: countries
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }

  // Shipping address UI intentionally removed; address is already collected and stored in Firestore.

  Future<String> _ensureOrderCreated(String userId) async {
    if (_orderId != null) return _orderId!;

    // Ensure user document exists
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'email': _auth.currentUser?.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final newId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final items = widget.cartItems.map((e) {
      return {
        'name': e['name'],
        'price': e['price'],
        'quantity': e['quantity'],
        'productId': e['productId'] ?? e['id'],
      };
    }).toList();

    final orderData = {
      'userId': userId,
      'items': items,
      'totalPrice': widget.total,
      'paymentMethod': _selectedPaymentTab == 'Credit Card' ? 'Card' : 'COD',
      'orderStatus': 'processing',
      'deliveryAddress': widget.deliveryAddress,
      'seen': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(newId)
        .set(orderData, SetOptions(merge: true));
    _orderId = newId;
    return newId;
  }

  void _processPayment() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to continue')));
      return;
    }

    // Simpan alamat lengkap jika checkbox dicentang
    if (_saveShippingAddress && _fullAddressController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'shipping_address_${user.uid}',
        _fullAddressController.text,
      );
    }

    if (_selectedPaymentTab == 'Credit Card' && _savedCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a card first'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_selectedPaymentTab == 'COD' && _selectedCash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select cash amount for payment'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final orderId = await _ensureOrderCreated(user.uid);
      String cardLast4 = '';
      String cardHolder = '';
      String cardCountry = '';
      if (_selectedPaymentTab == 'Credit Card' && _savedCards.isNotEmpty) {
        final card = _savedCards[_selectedCardIndex];
        cardLast4 = card['lastFourDigits'] ?? '';
        cardHolder = card['cardHolderName'] ?? '';
        cardCountry = card['country'] ?? '';
      }

      // Pastikan metode pembayaran yang tersimpan sesuai pilihan terbaru
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'paymentMethod': _selectedPaymentTab == 'Credit Card' ? 'Card' : 'COD',
        'orderStatus': 'processing',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save payment record directly to Firestore (instead of Cloud Function)
      await FirebaseFirestore.instance.collection('payments').doc(orderId).set({
        'userId': user.uid,
        'orderId': orderId,
        'paymentMethod': _selectedPaymentTab == 'Credit Card' ? 'Card' : 'COD',
        'cardLast4': cardLast4,
        'cardHolder': cardHolder,
        'cardCountry': cardCountry,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update order status
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'orderStatus': 'confirmed', 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Kosongkan cart user setelah checkout sukses
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'cart': []},
      );

      if (!mounted) return;

      // Tampilkan dialog konfirmasi pembayaran
      if (_selectedPaymentTab == 'Credit Card') {
        _showPaymentSuccessDialog(context, orderId);
      } else if (_selectedPaymentTab == 'COD') {
        _showCODConfirmationDialog(context, orderId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
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
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Method Tabs
                    _buildPaymentTabs(),
                    const SizedBox(height: 24),

                    // ...existing code...

                    // Card Display or COD Info
                    if (_selectedPaymentTab == 'Credit Card') ...[
                      _buildSavedCards(),
                      const SizedBox(height: 24),
                    ] else ...[
                      _buildCODInfo(),
                    ],
                  ],
                ),
              ),
            ),

            // Next Button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // Draw a single line that stretches from the center of the left circle
    // to the center of the right circle using a Stack, so it appears
    // visually connected to the circles without overshooting.
    const double circleDiameter = 36; // match _buildStepIndicator
    const double edgeInset =
        circleDiameter; // start after left circle, end before right circle
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // The connecting line with left half green, right half grey
            Positioned(
              top: circleDiameter / 2, // center vertically with the circles
              left: edgeInset + circleDiameter / 2,
              right: edgeInset + circleDiameter / 2,
              child: Row(
                children: [
                  Expanded(
                    child: Container(height: 2, color: const Color(0xFF4CB32B)),
                  ),
                  Expanded(
                    child: Container(height: 2, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            // The two step indicators sitting above the line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepIndicator('completed', 'Shipping Address'),
                _buildStepIndicator('active', 'Payment Method'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String status, String label) {
    // status: 'inactive', 'active', 'completed'
    bool isActive = status == 'active';
    bool isCompleted = status == 'completed';
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF4CB32B)
                : (isActive ? Colors.white : Colors.grey.shade300),
            border: Border.all(
              color: isActive || isCompleted
                  ? const Color(0xFF4CB32B)
                  : Colors.grey.shade300,
              width: isActive ? 4 : 0,
            ),
          ),
          child: null, // Remove checkmark
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isCompleted
                ? const Color(0xFF4CB32B)
                : (isActive ? Colors.black : Colors.grey.shade400),
            fontWeight: isActive || isCompleted
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentTypeButton(
            'COD',
            _selectedPaymentTab == 'COD',
            () {
              setState(() {
                _selectedPaymentTab = 'COD';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 160,
          margin: const EdgeInsets.only(right: 50),
          child: _buildPaymentTypeButton(
            'Credit Card',
            _selectedPaymentTab == 'Credit Card',
            () {
              setState(() {
                _selectedPaymentTab = 'Credit Card';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedCards() {
    if (_savedCards.isEmpty) {
      // Empty state with Add Card button
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No saved cards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a card to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showAddCardDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add Card',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CB32B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Display saved cards with Add Card button at the end
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _savedCards.length + 1, // +1 for Add Card button
            itemBuilder: (context, index) {
              if (index == _savedCards.length) {
                // Add Card button
                return GestureDetector(
                  onTap: _showAddCardDialog,
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CB32B),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CB32B).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF4CB32B),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Add Card',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CB32B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final card = _savedCards[index];
              final isSelected = _selectedCardIndex == index;
              final formattedTotal = _currencyFormatter.format(_totalAmount);
              final themeIndex = (card['themeIndex'] as int?) ?? 0;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCardIndex = index;
                  });
                },
                child: Container(
                  width: 320,
                  margin: EdgeInsets.only(right: 16),
                  child: _buildThemedCard(
                    card: card,
                    formattedTotal: formattedTotal,
                    isSelected: isSelected,
                    themeIndex: themeIndex,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThemedCard({
    required Map<String, dynamic> card,
    required String formattedTotal,
    required bool isSelected,
    required int themeIndex,
  }) {
    final maskedNumber = '**** **** **** ${card['lastFourDigits']}';
    final theme = themeIndex % 3;
    late final Widget body;

    if (theme == 0) {
      body = _purpleMinimalCard(formattedTotal, maskedNumber);
    } else if (theme == 1) {
      body = _tealFriendlyCard(formattedTotal, maskedNumber);
    } else {
      body = _premiumGradientCard(formattedTotal, maskedNumber);
    }

    return Stack(
      children: [
        body,
        if (isSelected)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF4CB32B),
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _purpleMinimalCard(String formattedTotal, String maskedNumber) {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3C1F74), Color(0xFF4B278A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            right: 40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Credit Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _networkLogo(light: true),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Total Payment',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                maskedNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tealFriendlyCard(String formattedTotal, String maskedNumber) {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A9D8F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: 24,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1F8074).withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF1B6E64).withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            right: 22,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            right: -14,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5ECF).withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Credit Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _networkLogo(light: true),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Total Payment',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                maskedNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _premiumGradientCard(String formattedTotal, String maskedNumber) {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: 10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -16,
            right: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            right: 18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.1,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _indoFlag(),
                      const SizedBox(width: 8),
                      const Text(
                        'KARTU REKENING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  _networkLogo(light: true),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Total Payment',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                maskedNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _networkLogo({bool light = true}) {
    final Color base = light ? Colors.white : Colors.black;
    return SizedBox(
      width: 52,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: base.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: base.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indoFlag() {
    return Container(
      width: 20,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFCE1126))),
          Expanded(child: Container(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCODInfo() {
    // Hanya tampilkan pilihan uang tunai jika user login
    final isLoggedIn = AuthService.currentUser != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (isLoggedIn) ...[
          // Card: Rincian Biaya
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFe8f5e9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4CB32B), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF388e3c),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'USD ${widget.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF388e3c),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tax:',
                      style: TextStyle(fontSize: 15, color: Color(0xFF388e3c)),
                    ),
                    Text(
                      'USD ${widget.tax.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF388e3c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery Fee:',
                      style: TextStyle(fontSize: 15, color: Color(0xFF388e3c)),
                    ),
                    Text(
                      'USD ${widget.deliveryFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF388e3c),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18, color: Color(0xFF4CB32B)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF2e7d32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'USD ${widget.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2e7d32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Text(
            'Pilih uang tunai untuk pembayaran:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4CB32B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _cashOptions
                .map(
                  (nominal) => ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        'USD ${nominal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedCash == nominal
                              ? Colors.white
                              : const Color(0xFF388e3c),
                        ),
                      ),
                    ),
                    selected: _selectedCash == nominal,
                    selectedColor: const Color(0xFF4CB32B),
                    backgroundColor: const Color(0xFFe8f5e9),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCash = nominal;
                      });
                    },
                    elevation: _selectedCash == nominal ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selectedCash == nominal
                            ? const Color(0xFF388e3c)
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pilih nominal di atas total belanja anda.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentTypeButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CB32B) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CB32B) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cart Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.cartItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(
                        item['image'] ?? 'assets/placeholder.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Item',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item['quantity'] ?? 1}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${(item['price'] ?? 0.0) * (item['quantity'] ?? 1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        // Subtotal, Tax, Delivery Fee, Total
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Subtotal',
                '\$${widget.subtotal.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow('Tax', '\$${widget.tax.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Delivery Fee',
                '\$${widget.deliveryFee.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Total',
                '\$${widget.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CB32B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'NEXT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
