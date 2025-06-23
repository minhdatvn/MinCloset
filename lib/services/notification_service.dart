// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/widgets/notification_banner.dart';

class NotificationService {
  // Bỏ static, chuyển thành biến của class
  final GlobalKey<NavigatorState> _navigatorKey;
  OverlayEntry? _overlayEntry;

  // Hàm khởi tạo, nhận vào navigatorKey
  NotificationService(this._navigatorKey);

  void showBanner({
    required String message,
    NotificationType type = NotificationType.error,
  }) {
    if (_overlayEntry != null) {
      return;
    }

    // Sử dụng _navigatorKey của class
    final overlayState = _navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      return;
    }

    final context = overlayState.context;
    final mediaQueryData = MediaQuery.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => MediaQuery(
        data: mediaQueryData,
        child: Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: NotificationBanner(
              message: message,
              type: type,
              onBannerClosed: () {
                _overlayEntry?.remove();
                _overlayEntry = null;
              },
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }
}