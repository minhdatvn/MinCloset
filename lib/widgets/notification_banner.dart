// lib/widgets/notification_banner.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mincloset/models/notification_type.dart';

class NotificationBanner extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onBannerClosed;

  const NotificationBanner({
    super.key,
    required this.message,
    required this.type,
    required this.onBannerClosed,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _dismissTimer = Timer(const Duration(seconds: 3), () {
      _closeBanner();
    });
  }

  void _closeBanner() {
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onBannerClosed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  ({Color backgroundColor, Color contentColor, IconData icon}) _getTheme() {
    switch (widget.type) {
      case NotificationType.success:
        return (
          backgroundColor: Colors.green.shade50,
          contentColor: Colors.green.shade800,
          icon: Icons.check_circle_outline,
        );
      case NotificationType.warning:
        return (
          backgroundColor: Colors.orange.shade50,
          contentColor: Colors.orange.shade800,
          icon: Icons.warning_amber_rounded,
        );
      // SỬA LỖI 1: Bỏ từ khóa "default" thừa
      case NotificationType.error:
        return (
          backgroundColor: Colors.red.shade50,
          contentColor: Colors.red.shade800,
          icon: Icons.error_outline,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();
    final topPadding = MediaQuery.of(context).padding.top;

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -1.0) {
            _closeBanner();
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPadding + 4, 16, 12),
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              Icon(theme.icon, color: theme.contentColor, size: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: theme.contentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                // SỬA LỖI 2: Thay thế `withOpacity` bằng `withAlpha`
                icon: Icon(Icons.close, color: theme.contentColor.withAlpha(179)),
                onPressed: _closeBanner,
              )
            ],
          ),
        ),
      ),
    );
  }
}