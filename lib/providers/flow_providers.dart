// lib/providers/flow_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider cho trạng thái Onboarding
final onboardingCompletedProvider = StateNotifierProvider<StateController<bool>, bool>((ref) {
  // Giá trị mặc định là false, chúng ta sẽ cập nhật nó trong hàm main
  return StateController(false);
});

// Provider cho trạng thái xin Quyền
final permissionsSeenProvider = StateNotifierProvider<StateController<bool>, bool>((ref) {
  // Giá trị mặc định là false
  return StateController(false);
});