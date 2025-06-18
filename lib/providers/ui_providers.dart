// lib/providers/ui_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider này sẽ lưu trạng thái của tab đang được chọn trên MainScreen.
/// 0: Trang chủ, 1: Tủ đồ, 2: Trang phục, 3: Cá nhân
final mainScreenIndexProvider = StateProvider<int>((ref) => 0);