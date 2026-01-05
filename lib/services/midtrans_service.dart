import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MidtransService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // WARNING: Server key di klien adalah tidak aman. Hanya untuk uji coba.
  static const String _midtransServerKey =
      'REDACTED_MIDTRANS_SERVER_KEY';
  static const String _midtransClientKey =
      'REDACTED_MIDTRANS_CLIENT_KEY'; // tersedia jika ingin ditampilkan di UI
  // Rate konversi USD→IDR untuk pengiriman ke Midtrans (IDR wajib tanpa cent)
  static const double _usdToIdrRate = 15500.0;

  String get _authHeader {
    final creds = base64Encode(utf8.encode('$_midtransServerKey:'));
    return 'Basic $creds';
  }

  /// Create Midtrans payment transaction
  Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Konversi USD → IDR dan pastikan integer tanpa cent
      final itemDetails = items.map((item) {
        final priceUsd = (item['price'] as num?) ?? 0;
        final qty = (item['quantity'] as num?)?.round() ?? 1;
        final priceIdr = (priceUsd * _usdToIdrRate).round();
        return {
          'id': item['id'] ?? 'item',
          'price': priceIdr,
          'quantity': qty,
          'name': item['name'] ?? 'Item',
        };
      }).toList();

      final int itemsTotal = itemDetails.fold(
        0,
        (prev, it) => prev + ((it['price'] as int) * (it['quantity'] as int)),
      );

      final int grossAmount = itemsTotal > 0
          ? itemsTotal
          : (amount * _usdToIdrRate).round();

      final body = {
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': grossAmount,
        },
        'customer_details': {
          'first_name': customerName,
          'email': customerEmail,
          'phone': customerPhone ?? '',
        },
        'item_details': itemDetails,
        'credit_card': {'secure': true},
      };

      // Debug log to verify target endpoint and payload during testing
      print(
        '[MIDTRANS] createTransaction → https://app.sandbox.midtrans.com/snap/v1/transactions',
      );
      print('[MIDTRANS] payload: ' + jsonEncode(body));

      final response = await http.post(
        Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': _authHeader,
        },
        body: jsonEncode(body),
      );

      print('[MIDTRANS] status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'redirectUrl': data['redirect_url'],
          'clientKey': _midtransClientKey,
        };
      }

      print('[MIDTRANS] body: ${response.body}');
      return {
        'success': false,
        'error': 'Failed to create transaction: ${response.statusCode}',
        'body': response.body,
      };
    } catch (e) {
      print('Error creating Midtrans transaction: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkTransactionStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.sandbox.midtrans.com/v2/$orderId/status'),
        headers: {'Accept': 'application/json', 'Authorization': _authHeader},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'status': data, 'orderId': orderId};
      }

      return {
        'success': false,
        'error': 'Failed to check status: ${response.statusCode}',
        'body': response.body,
      };
    } catch (e) {
      print('Error checking transaction status: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Listen to transaction status changes from Firestore
  Stream<DocumentSnapshot> listenToTransactionStatus(String orderId) {
    return _firestore.collection('transactions').doc(orderId).snapshots();
  }

  /// Get transaction details
  Future<Map<String, dynamic>?> getTransactionDetails(String orderId) async {
    try {
      final doc = await _firestore
          .collection('transactions')
          .doc(orderId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting transaction details: $e');
      return null;
    }
  }

  /// Generate unique order ID
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final randomPart = userId.substring(0, 5);
    return 'ORDER-$timestamp-$randomPart';
  }
}
