import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// Firebase Configuration và Initialization
/// Centralized Firebase setup cho toàn bộ app
class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
  }
}
