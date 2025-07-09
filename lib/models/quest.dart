// lib/models/quest.dart

import 'package:equatable/equatable.dart';

// Enum định nghĩa các trạng thái của một nhiệm vụ
enum QuestStatus {
  locked,
  inProgress,
  completed,
}

// Lớp định nghĩa mục tiêu cần hoàn thành cho một nhiệm vụ
// Ví dụ: 'Tops' -> 3, 'Bottoms' -> 3
class QuestGoal extends Equatable {
  final Map<String, int> requiredCounts;

  const QuestGoal({required this.requiredCounts});

  @override
  List<Object> get props => [requiredCounts];
}

// Lớp định nghĩa tiến trình hiện tại của người dùng đối với một nhiệm vụ
class QuestProgress extends Equatable {
  final Map<String, int> currentCounts;

  const QuestProgress({this.currentCounts = const {}});

  QuestProgress updateProgress(String category) {
    final newCounts = Map<String, int>.from(currentCounts);
    newCounts[category] = (newCounts[category] ?? 0) + 1;
    return QuestProgress(currentCounts: newCounts);
  }

  @override
  List<Object> get props => [currentCounts];
}

// Lớp chính định nghĩa một nhiệm vụ
class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final QuestGoal goal;
  final QuestStatus status;
  final QuestProgress progress;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    this.status = QuestStatus.locked,
    this.progress = const QuestProgress(),
  });

  Quest copyWith({
    QuestStatus? status,
    QuestProgress? progress,
  }) {
    return Quest(
      id: id,
      title: title,
      description: description,
      goal: goal,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  // Kiểm tra xem nhiệm vụ đã hoàn thành chưa
  bool get isCompleted {
    for (final key in goal.requiredCounts.keys) {
      if ((progress.currentCounts[key] ?? 0) < goal.requiredCounts[key]!) {
        return false;
      }
    }
    return true;
  }

  // Lấy ra chuỗi mô tả tiến trình, ví dụ: "Tops: 1/3"
  String getProgressString(String category) {
    final current = progress.currentCounts[category] ?? 0;
    final required = goal.requiredCounts[category] ?? 0;
    return '$current/$required';
  }

  @override
  List<Object> get props => [id, title, description, goal, status, progress];
}