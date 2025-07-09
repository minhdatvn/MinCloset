// lib/providers/ui_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/tutorial_notifier.dart';
import 'package:mincloset/states/tutorial_state.dart';

/// Provider này sẽ lưu trạng thái của tab đang được chọn trên MainScreen.
/// 0: Trang chủ, 1: Tủ đồ, 2: Trang phục, 3: Cá nhân
final mainScreenIndexProvider = StateProvider<int>((ref) => 0);

/// Provider quản lý trạng thái và logic của luồng hướng dẫn cho người mới.
final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  // <<< XÓA `ref` KHÔNG CẦN THIẾT KHI KHỞI TẠO >>>
  return TutorialNotifier();
});