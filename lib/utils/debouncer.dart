// lib/utils/debouncer.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    // Nếu có một timer cũ đang chạy, hãy hủy nó
    _timer?.cancel();
    // Tạo một timer mới, sau khi hết thời gian `delay`, nó sẽ thực thi `action`
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}