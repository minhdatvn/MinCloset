// lib/providers/auth_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/repositories/auth_repository.dart';

// Provider cung cấp instance của AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// StreamProvider để lắng nghe và cung cấp trạng thái đăng nhập (User?)
// cho toàn bộ ứng dụng. Các widget có thể "watch" provider này để
// tự động cập nhật khi người dùng đăng nhập hoặc đăng xuất.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider này quản lý trạng thái loading của quá trình sao lưu/phục hồi.
final backupRestoreLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider này sẽ lấy về thông tin sao lưu cuối cùng từ Firestore.
final lastBackupProvider = FutureProvider<DateTime?>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return null;
  }
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()!.containsKey('lastBackup')) {
      final timestamp = doc.data()!['lastBackup'] as Timestamp;
      return timestamp.toDate();
    }
  } catch (e) {
    // Bỏ qua lỗi nếu không thể lấy được dữ liệu
  }
  return null;
});