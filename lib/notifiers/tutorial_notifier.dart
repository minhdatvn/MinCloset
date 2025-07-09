// lib/notifiers/tutorial_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/states/tutorial_state.dart';
// <<< XÓA IMPORT KHÔNG SỬ DỤNG: package:showcaseview/showcaseview.dart >>>

class TutorialNotifier extends StateNotifier<TutorialState> {
  // <<< XÓA `Ref` KHÔNG SỬ DỤNG >>>
  TutorialNotifier() : super(const TutorialState());

  void startTutorial() {
    state = const TutorialState(isActive: true, currentStep: TutorialStep.welcome);
  }

  void nextStep(BuildContext context) {
    if (!state.isActive) return;

    switch (state.currentStep) {
      case TutorialStep.welcome:
        state = state.copyWith(currentStep: TutorialStep.introduce);
        break;
      case TutorialStep.introduce:
        state = state.copyWith(currentStep: TutorialStep.showAddItem);
        break;
      default:
        dismissTutorial();
        break;
    }
  }

  void dismissTutorial() {
    state = const TutorialState(isActive: false, currentStep: TutorialStep.finished);
  }
}