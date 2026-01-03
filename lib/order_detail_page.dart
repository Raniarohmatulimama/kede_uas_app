import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ReviewPage.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final bool showNotification;
  final bool fromNotification;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    this.showNotification = false,
    this.fromNotification = false,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  bool _statusUpdated = false;
  bool _notificationShown = false;
  bool _notificationTapped = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    // Tampilkan notifikasi hanya jika dibuka langsung dari payment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showNotification && !_notificationShown) {
        _showPaymentNotification();
        _notificationShown = true;
      }

      // Update seen ke true hanya jika dibuka dari notification page
      if (widget.fromNotification) {
        _markNotificationAsSeen();
      }
    });
  }

  Future<void> _markNotificationAsSeen() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'seen': true, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      // Silent fail, jangan perlu menampilkan error ke user
      print('Error marking notification as seen: $e');
    }
  }

  Future<void> _handleNotificationTap(String orderId) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CB32B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memproses pesanan...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
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
    );

    try {
      // Update status pesanan ke 'shipped'
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'orderStatus': 'shipped', 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Tunggu sebentar agar user bisa lihat loading
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Mark notification as seen
        _markNotificationAsSeen();

        // Set flag dan trigger UI update
        setState(() {
          _notificationTapped = true;
          _statusUpdated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
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

  void _showCompletionNotification() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: () {
                overlayEntry.remove();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 60, left: 12, right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pesanan Anda telah selesai!',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terima kasih telah berbelanja di KEDE!',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Reset animation controller untuk notifikasi baru
    _animationController.reset();
    _animationController.forward();

    // Auto remove setelah 2.5 detik dengan animasi slide up (total 3 detik dengan animasi)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        _animationController.reverse().then((_) {
          overlayEntry.remove();
        });
      }
    });
  }

  void _showPaymentNotification() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: () {
                overlayEntry.remove();
                // Handle tap dengan loading
                _handleNotificationTap(widget.orderId);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 60, left: 12, right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pesanan akan segera diantar!',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terima kasih telah berbelanja. Klik untuk melihat detail pesanan dan konfirmasi penerimaan.',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Mulai animasi slide down
    _animationController.forward();

    // Auto remove setelah 5 detik dengan animasi slide up
    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        _animationController.reverse().then((_) {
          overlayEntry.remove();
        });
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return const Color(0xFF2196F3);
      case 'processing':
        return const Color(0xFFFFA500);
      case 'shipped':
        return const Color(0xFF9C27B0);
      case 'completed':
        return const Color(0xFF4CB32B);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Sudah Dibayar';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dalam Pengiriman';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'processing':
        return Icons.hourglass_bottom;
      case 'shipped':
        return Icons.local_shipping;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CB32B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            tooltip: 'Close and go to Home',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>? ?? {};
          final items = (data['items'] as List?) ?? [];
          final status = (data['orderStatus'] ?? 'processing').toString();
          final paymentMethod = (data['paymentMethod'] ?? '-').toString();
          final totalPrice = (data['totalPrice'] ?? 0).toDouble();
          final canComplete = status == 'shipped';
          final showTerimaButton =
              (widget.fromNotification || _notificationTapped) &&
              status == 'shipped';

          // Update status ke 'shipped' jika dari notifikasi atau tap notifikasi slide-down
          if ((widget.fromNotification || _notificationTapped) &&
              !_statusUpdated &&
              status != 'shipped' &&
              status != 'completed') {
            _statusUpdated = true;
            Future.microtask(() async {
              await docRef.update({
                'orderStatus': 'shipped',
                'updatedAt': FieldValue.serverTimestamp(),
              });
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CB32B),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ID Pesanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.orderId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Pesanan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              paymentMethod == 'Card'
                                  ? Icons.credit_card
                                  : Icons.money,
                              color: const Color(0xFF4CB32B),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              paymentMethod == 'Card' ? 'Kartu Kredit' : 'COD',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Products Section
                  const Text(
                    'Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value as Map<String, dynamic>;
                    final price = (item['price'] ?? 0).toDouble();
                    final quantity = (item['quantity'] ?? 1).toInt();
                    final subtotal = price * quantity;

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 12,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Produk',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harga: \$${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: $quantity',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4CB32B,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4CB32B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Total Payment Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CB32B), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CB32B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol "Pesanan telah diterima" jika dari notifikasi dan status shipped
                  if (showTerimaButton) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            await docRef.update({
                              'orderStatus': 'completed',
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog
                              // Tampilkan notifikasi completion
                              _showCompletionNotification();

                              // Add orderId to data before passing to ReviewPage
                              final orderData = Map<String, dynamic>.from(data);
                              orderData['orderId'] = widget.orderId;

                              // Langsung navigasi ke ReviewPage, notifikasi tetap muncul 4 detik
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReviewPage(orderDetails: orderData),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: \'${e.toString()}\''),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
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
                          'Pesanan telah diterima',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ] else if (canComplete) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            await docRef.update({
                              'orderStatus': 'completed',
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog
                              // Add orderId to data before passing to ReviewPage
                              final orderData = Map<String, dynamic>.from(data);
                              orderData['orderId'] = widget.orderId;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReviewPage(orderDetails: orderData),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: \'${e.toString()}\''),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
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
                          'Pesanan Selesai',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          status == 'completed'
                              ? '✓ Pesanan telah selesai'
                              : 'Tunggu pesanan dikirim',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
