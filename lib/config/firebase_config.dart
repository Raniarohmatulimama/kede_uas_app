import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Firebase initialization configuration
class FirebaseConfig {
  static bool _initialized = false;

  /// Initialize Firebase for the application
  static Future<void> initialize() async {
    // Skip if already initialized
    if (_initialized) {
      print('[Firebase] Already initialized, skipping init');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      print('[Firebase] Initialization completed successfully');
    } catch (e) {
      // Ignore duplicate app error - it means Firebase was already initialized
      if (e.toString().contains('duplicate-app')) {
        _initialized = true;
        print('[Firebase] Already initialized (caught duplicate-app)');
      } else {
        print('[Firebase] Initialization error: $e');
        rethrow;
      }
    }
  }

  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String cartsCollection = 'carts';
  static const String ordersCollection = 'orders';
  static const String chatsCollection = 'chats';
  static const String wishlistCollection = 'wishlist';

  // Storage buckets
  static const String profilePhotosPath = 'profile-photos';
  static const String productImagesPath = 'product-images';
}
