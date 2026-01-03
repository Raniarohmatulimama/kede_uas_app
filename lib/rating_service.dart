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
    print(
      'DEBUG RatingService: submitRating called - orderId: $orderId, productId: $productId, rating: $rating',
    );

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

    // Get user data to store with rating
    String userName =
        user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';
    String userAvatar =
        user.photoURL ??
        'https://ui-avatars.com/api/?name=$userName&background=4CB32B&color=fff';

    // Try to get additional user data from Firestore if available
    try {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      print('DEBUG RatingService: User doc exists: ${userDoc.exists}');
      if (userDoc.exists) {
        final userData = userDoc.data();
        print('DEBUG RatingService: User data from Firestore: $userData');

        // Match actual Firestore field names (priority order)
        final fullName =
            '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'
                .trim();
        userName =
            userData?['displayName'] ??
            userData?['name'] ??
            userData?['fullName'] ??
            (fullName.isNotEmpty ? fullName : null) ??
            userData?['username'] ??
            userName;

        // Priority: profile_photo_url > profile_photo > other fields
        userAvatar =
            userData?['profile_photo_url'] ?? // ← Prioritas pertama!
            userData?['profile_photo'] ??
            userData?['profilePicture'] ??
            userData?['avatar'] ??
            userData?['photoURL'] ??
            userData?['imageUrl'] ??
            userAvatar;
      } else {
        print('DEBUG RatingService: User document not found, using auth data');
      }
    } catch (e) {
      print('ERROR RatingService: getting user data: $e');
      // Continue with default values
    }

    print(
      'DEBUG RatingService: Final userName: $userName, userAvatar: $userAvatar',
    );

    final ratingData = {
      'orderId': orderId,
      'productId': productId,
      'userId': user.uid,
      'rating': rating,
      'comment': comment,
      'displayName': userName,
      'userAvatar': userAvatar,
      'createdAt': FieldValue.serverTimestamp(),
    };

    print('DEBUG RatingService: Saving rating data: $ratingData');

    await _db.collection('ratings').add(ratingData);

    print('DEBUG RatingService: Rating successfully saved to Firestore');

    await _db.collection('orders').doc(orderId).update({'isRated': true});
  }
}
