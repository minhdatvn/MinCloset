// lib/notifiers/guides_page_notifier.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';

// Lớp State mới, đơn giản hơn rất nhiều
class GuidesPageState extends Equatable {
  final bool isLoading;
  final List<Quest> inProgressGuides;
  final List<Quest> completedGuides;

  const GuidesPageState({
    this.isLoading = true,
    this.inProgressGuides = const [],
    this.completedGuides = const [],
  });

  GuidesPageState copyWith({
    bool? isLoading,
    List<Quest>? inProgressGuides,
    List<Quest>? completedGuides,
  }) {
    return GuidesPageState(
      isLoading: isLoading ?? this.isLoading,
      inProgressGuides: inProgressGuides ?? this.inProgressGuides,
      completedGuides: completedGuides ?? this.completedGuides,
    );
  }

  @override
  List<Object?> get props => [isLoading, inProgressGuides, completedGuides];
}

// Lớp Notifier mới
class GuidesPageNotifier extends StateNotifier<GuidesPageState> {
  final Ref _ref;

  GuidesPageNotifier(this._ref) : super(const GuidesPageState()) {
    loadGuides();
    
    // Tự động tải lại khi có quest được hoàn thành
    _ref.listen<Quest?>(completedQuestProvider, (previous, next) {
      if (next != null) {
        loadGuides();
      }
    });
  }

  Future<void> loadGuides() async {
    state = state.copyWith(isLoading: true);

    final questRepo = _ref.read(questRepositoryProvider);
    final allQuests = questRepo.getCurrentQuests();

    state = state.copyWith(
      isLoading: false,
      inProgressGuides: allQuests.where((q) => q.status == QuestStatus.inProgress).toList(),
      completedGuides: allQuests.where((q) => q.status == QuestStatus.completed).toList(),
    );
  }
}

// Provider mới
final guidesPageProvider = StateNotifierProvider.autoDispose<GuidesPageNotifier, GuidesPageState>((ref) {
  return GuidesPageNotifier(ref);
});