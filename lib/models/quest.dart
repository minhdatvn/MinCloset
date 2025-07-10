// lib/models/quest.dart
import 'package:equatable/equatable.dart';

// THAY ĐỔI 1: Thêm các sự kiện cụ thể hơn
enum QuestEvent {
  topAdded,
  bottomAdded,
  suggestionReceived,
  outfitCreated,
  closetCreated,
  logAdded,
}

enum QuestStatus {
  locked,
  inProgress,
  completed,
}

class QuestGoal extends Equatable {
  final Map<QuestEvent, int> requiredCounts;
  const QuestGoal({required this.requiredCounts});
  @override
  List<Object> get props => [requiredCounts];
}

class QuestProgress extends Equatable {
  final Map<QuestEvent, int> currentCounts;
  const QuestProgress({this.currentCounts = const {}});

  QuestProgress updateProgress(QuestEvent event) {
    final newCounts = Map<QuestEvent, int>.from(currentCounts);
    newCounts[event] = (newCounts[event] ?? 0) + 1;
    return QuestProgress(currentCounts: newCounts);
  }

  @override
  List<Object> get props => [currentCounts];
}

class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final QuestGoal goal;
  final QuestStatus status;
  final QuestProgress progress;
  // THAY ĐỔI 2: Thêm trường để xác định nhiệm vụ điều kiện
  final String? prerequisiteQuestId;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    this.status = QuestStatus.locked,
    this.progress = const QuestProgress(),
    this.prerequisiteQuestId, // Thêm vào constructor
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
      prerequisiteQuestId: prerequisiteQuestId,
    );
  }

  bool get isCompleted {
    for (final event in goal.requiredCounts.keys) {
      if ((progress.currentCounts[event] ?? 0) < goal.requiredCounts[event]!) {
        return false;
      }
    }
    return true;
  }
  
  String getProgressString(QuestEvent event) {
    final current = progress.currentCounts[event] ?? 0;
    final required = goal.requiredCounts[event] ?? 0;
    return '$current/$required';
  }
  
  String getProgressDescription() {
    return goal.requiredCounts.keys.map((event) {
      final eventName = event.toString().split('.').last;
      return '$eventName: ${getProgressString(event)}';
    }).join(' | ');
  }

  @override
@override
List<Object?> get props => [id, title, description, goal, status, progress, prerequisiteQuestId];}