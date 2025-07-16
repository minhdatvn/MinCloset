// lib/providers/event_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/models/achievement.dart';

/// Provider này hoạt động như một tín hiệu.
/// Mỗi khi một vật phẩm mới được thêm, chúng ta sẽ tăng giá trị của nó lên 1.
/// Các widget khác sẽ lắng nghe sự thay đổi này để thực hiện hành động.
final itemChangedTriggerProvider = StateProvider<int>((ref) => 0);

/// Provider này hoạt động như một kênh giao tiếp cho sự kiện hoàn thành nhiệm vụ.
/// Các notifier khác sẽ "ghi" vào đây, và UI sẽ "đọc" từ đây.
final completedQuestProvider = StateProvider<Quest?>((ref) => null);

/// Provider này gửi tín hiệu khi một thành tích mới được mở khóa.
final unlockedAchievementProvider = StateProvider<Achievement?>((ref) => null);

/// Provider này sẽ được kích hoạt khi nhóm nhiệm vụ tân thủ hoàn thành.
final beginnerAchievementProvider = StateProvider<Achievement?>((ref) => null);

/// Provider này hoạt động như một kênh để gửi các sự kiện lỗi từ Notifier đến UI
/// một cách tức thời mà không cần lưu vào state chính.
final itemDetailErrorProvider = StateProvider<String?>((ref) => null);