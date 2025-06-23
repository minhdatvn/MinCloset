// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/widgets/notification_banner.dart';

class NotificationService {
  // Key để truy cập NavigatorState từ bất cứ đâu
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _overlayEntry;

  static void showBanner({
    required String message,
    NotificationType type = NotificationType.error,
  }) {
    // Nếu đang có banner, không hiển thị cái mới
    if (_overlayEntry != null) {
      return;
    }

    // THAY ĐỔI Ở ĐÂY: Lấy OverlayState trực tiếp từ NavigatorState
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      // Nếu không lấy được overlay state, không làm gì cả
      return;
    }
    
    // Lấy context từ overlayState để sử dụng cho builder
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

    // Dùng overlayState để insert
    overlayState.insert(_overlayEntry!);
  }
}