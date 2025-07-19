// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mincloset/utils/logger.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Dán Web Client ID của bạn vào đây (lấy từ Google Cloud Console)
  static const String _webClientId = '35306730291-p910ctseu69ornk23cvogeauvvga6hpl.apps.googleusercontent.com';

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e, s) {
      // Khối catch này sẽ bắt tất cả các lỗi, bao gồm cả khi người dùng hủy.
      logger.e('Lỗi đăng nhập với Google (hoặc người dùng đã hủy)', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e, s) {
      logger.e('Lỗi khi đăng xuất', error: e, stackTrace: s);
    }
  }
}