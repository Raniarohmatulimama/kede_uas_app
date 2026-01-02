// Academic simulation rating logic; extendable for real deployments.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> canSubmit(String orderId) async {
    final snap = await _db.collection('orders').doc(orderId).get();
    return (snap.data()?['orderStatus']) == 'completed';
  }

  Future<void> submitRating({
    required String orderId,
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final ok = await canSubmit(orderId);
    if (!ok) throw Exception('Order not completed');

    final dup = await _db
        .collection('ratings')
        .where('orderId', isEqualTo: orderId)
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (dup.docs.isNotEmpty) {
      throw Exception('You have already rated this product');
    }

    await _db.collection('ratings').add({
      'orderId': orderId,
      'productId': productId,
      'userId': user.uid,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      // Academic simulation: part of UAS; can be extended to real e-commerce.
    });

    await _db.collection('orders').doc(orderId).update({'isRated': true});
  }
}
