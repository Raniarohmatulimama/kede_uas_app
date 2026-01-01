import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ReviewPage.dart';
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
  @override
  void initState() {
    super.initState();
    _generateCashOptions();
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
  bool isCardHolderPressed = false;
  bool isCardNumberPressed = false;
  bool isMonthYearPressed = false;
  bool isCvvPressed = false;
  bool isCountryPressed = false;
  bool isCodAddressPressed = false;

  final _cardHolderController = TextEditingController(text: 'Samuel Witwicky');
  final _cardNumberController = TextEditingController();
  final _monthYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCountry = '';
  bool _saveShippingAddress = false;
  final List<String> _countries = [
    'Choose your country',
    'USA',
    'China',
    'India',
  ];

  final List<Map<String, dynamic>> _savedCards = [
    {
      'balance': '\$45,662',
      'lastFourDigits': '1234',
      'color': const Color(0xFF5B4E8A),
      'pattern': 'purple',
    },
    {
      'balance': '\$45,662',
      'lastFourDigits': '1234',
      'color': const Color(0xFF2B8C8C),
      'pattern': 'teal',
    },
  ];

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _monthYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_selectedPaymentTab == 'Credit Card') {
      final bool usingSavedCard =
          _monthYearController.text.isEmpty && _cvvController.text.isEmpty;
      if (!usingSavedCard) {
        if (_cardHolderController.text.isEmpty ||
            _cardNumberController.text.isEmpty ||
            _monthYearController.text.isEmpty ||
            _cvvController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please fill in all card details'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        }
      }
    } else if (_selectedPaymentTab == 'COD') {
      // Hanya untuk user login
      if (AuthService.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anda harus login untuk menggunakan COD'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      if (_selectedCash == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pilih nominal uang tunai untuk pembayaran.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    }
    // Navigate to Review Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          orderDetails: {
            'orderId': 'ORD${DateTime.now().millisecondsSinceEpoch}',
            'date': DateTime.now(),
            'items': widget.cartItems,
            'subtotal': widget.subtotal,
            'tax': widget.tax,
            'deliveryFee': widget.deliveryFee,
            'total': widget.total,
            'deliveryAddress': widget.deliveryAddress,
            'customerName': widget.customerName,
            'customerPhone': widget.customerPhone,
            'paymentMethod': _selectedPaymentTab,
            if (_selectedPaymentTab == 'COD') 'cashAmount': _selectedCash,
          },
        ),
      ),
    );
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

                    // Card Display or COD Info
                    if (_selectedPaymentTab == 'Credit Card') ...[
                      _buildSavedCards(),
                      const SizedBox(height: 24),
                      _buildCardForm(),
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
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _savedCards.length,
        itemBuilder: (context, index) {
          final card = _savedCards[index];
          final isSelected = _selectedCardIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCardIndex = index;
              });
            },
            child: Container(
              width: index == 0 ? 300 : 280,
              margin: EdgeInsets.only(right: index == 0 ? 16 : 0),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: card['color'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Credit Card',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card['balance'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '**** **** **** ${card['lastFourDigits']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              child: Icon(
                                Icons.circle,
                                color: Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
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
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _cardHolderController,
          label: 'Card Holder Name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card Number',
          hintText: '1234 5678 9101 1121',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _monthYearController,
                label: 'Month/Year',
                hintText: 'Enter here',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                hintText: 'Enter here',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCountryDropdown(),
        const SizedBox(height: 16),
        _buildSaveAddressCheckbox(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
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
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
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
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCountry.isEmpty ? null : _selectedCountry,
            hint: Text(
              'Choose your country',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CB32B)),
            items: _countries.map((country) {
              return DropdownMenuItem(value: country, child: Text(country));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveAddressCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _saveShippingAddress,
            onChanged: (value) {
              setState(() {
                _saveShippingAddress = value ?? false;
              });
            },
            activeColor: const Color(0xFF4CB32B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Save shipping address',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCODInfo() {
    // Hanya tampilkan pilihan uang tunai jika user login
    final isLoggedIn = AuthService.currentUser != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCodAddressPressed
                  ? const Color(0xFF4CB32B)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _addressController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onTap: () {
              setState(() {
                isCodAddressPressed = true;
              });
            },
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Address',
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
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
