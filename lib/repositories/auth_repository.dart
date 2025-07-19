// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mincloset/utils/logger.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Dán Web Client ID của bạn vào đây (lấy từ Google Cloud Console)
  static const String _webClientId = '35306730291-oatctq90b5v9jtf5m8d43dhbfaaa3ada.apps.googleusercontent.com';

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        // Sửa lỗi 1: Lấy instance thông qua `GoogleSignIn.instance`
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      // THAY ĐỔI QUAN TRỌNG: Gọi `initialize` để cung cấp serverClientId
      // Thư viện sẽ bỏ qua nếu đã được khởi tạo rồi.
      await _googleSignIn.initialize(serverClientId: _webClientId);

      // SỬA LỖI 2: Phương thức đăng nhập mới là `authenticate()`
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      // SỬA LỖI 4: `authentication` là một getter, không cần `await`
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        // SỬA LỖI 3: `accessToken` không còn trong googleAuth,
        // ta chỉ cần `idToken` để xác thực với Firebase.
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e, s) {
      logger.e('Lỗi đăng nhập với Google', error: e, stackTrace: s);
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