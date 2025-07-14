// lib/models/quest.dart
import 'package:equatable/equatable.dart';

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
  final String? prerequisiteQuestId;
  final String? hintKey;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    this.status = QuestStatus.locked,
    this.progress = const QuestProgress(),
    this.prerequisiteQuestId,
    this.hintKey,
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
      hintKey: hintKey, // Giữ lại hintKey
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
  List<Object?> get props => [id, title, description, goal, status, progress, prerequisiteQuestId, hintKey]; 
}