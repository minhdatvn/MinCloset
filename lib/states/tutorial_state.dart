// lib/states/tutorial_state.dart
import 'package:equatable/equatable.dart';

// Enum để quản lý các bước của tutorial, giữ nguyên từ file main_screen.dart
enum TutorialStep { none, welcome, introduce, showAddItem, finished }

class TutorialState extends Equatable {
  /// Xác định xem tutorial có đang hiển thị hay không.
  final bool isActive;

  /// Bước hiện tại của tutorial.
  final TutorialStep currentStep;

  const TutorialState({
    this.isActive = false,
    this.currentStep = TutorialStep.none,
  });

  TutorialState copyWith({
    bool? isActive,
    TutorialStep? currentStep,
  }) {
    return TutorialState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object> get props => [isActive, currentStep];
}