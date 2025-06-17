// lib/providers/event_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider này hoạt động như một tín hiệu.
/// Mỗi khi một vật phẩm mới được thêm, chúng ta sẽ tăng giá trị của nó lên 1.
/// Các widget khác sẽ lắng nghe sự thay đổi này để thực hiện hành động.
final itemAddedTriggerProvider = StateProvider<int>((ref) => 0);