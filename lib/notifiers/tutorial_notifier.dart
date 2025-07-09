// lib/notifiers/tutorial_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/states/tutorial_state.dart';

class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier() : super(const TutorialState());

  void startTutorial() {
    state = const TutorialState(isActive: true, currentStep: TutorialStep.welcome);
  }

  // Logic nextStep giờ đơn giản hơn
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