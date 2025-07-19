// lib/providers/auth_providers.dart
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