import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/midtrans_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<Map<String, dynamic>> items;

  const MidtransPaymentPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
  }) : super(key: key);

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  final MidtransService _midtransService = MidtransService();
  bool _isLoading = true;
  String? _paymentUrl;
  String? _error;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _createTransaction();
    _listenToTransactionStatus();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
          },
        ),
      );
  }

  void _handleUrlChange(String url) {
    // Handle callback URLs
    if (url.contains('payment-success')) {
      _showPaymentResult('success');
    } else if (url.contains('payment-error')) {
      _showPaymentResult('failed');
    } else if (url.contains('payment-pending')) {
      _showPaymentResult('pending');
    }
  }

  Future<void> _createTransaction() async {
    try {
      final result = await _midtransService.createTransaction(
        orderId: widget.orderId,
        amount: widget.amount,
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        customerPhone: widget.customerPhone,
        items: widget.items,
      );

      if (result['success'] == true) {
        setState(() {
          _paymentUrl = result['redirectUrl'];
          _isLoading = false;
        });

        // Load payment URL
        if (_paymentUrl != null) {
          _webViewController.loadRequest(Uri.parse(_paymentUrl!));
        }
      } else {
        setState(() {
          _error = result['error'] ?? 'Failed to create transaction';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _listenToTransactionStatus() {
    _midtransService.listenToTransactionStatus(widget.orderId).listen((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'success') {
          _showPaymentResult('success');
        } else if (status == 'failed') {
          _showPaymentResult('failed');
        }
      }
    });
  }

  void _showPaymentResult(String status) {
    if (!mounted) return;

    String title;
    String message;
    IconData icon;
    Color color;

    switch (status) {
      case 'success':
        title = 'Payment Success';
        message = 'Your payment has been processed successfully!';
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'failed':
        title = 'Payment Failed';
        message = 'Your payment could not be processed. Please try again.';
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'pending':
        title = 'Payment Pending';
        message = 'Your payment is being processed. Please wait.';
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(
                context,
              ).pop(status); // Return to previous page with status
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _midtransService.checkTransactionStatus(
      widget.orderId,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      final status = result['status'] as String;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment Status: $status')));

      if (status == 'settlement' || status == 'capture') {
        _showPaymentResult('success');
      } else if (status == 'deny' || status == 'cancel' || status == 'expire') {
        _showPaymentResult('failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPaymentStatus,
            tooltip: 'Check Payment Status',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _createTransaction();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading payment page...'),
          ],
        ),
      );
    }

    if (_paymentUrl != null) {
      return WebViewWidget(controller: _webViewController);
    }

    return const Center(child: Text('Something went wrong'));
  }
}
