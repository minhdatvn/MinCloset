// lib/widgets/persistent_header_delegate.dart

import 'package:flutter/material.dart';

class PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  PersistentHeaderDelegate({required this.child, this.height = 72.0});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Thêm Material để có hiệu ứng đổ bóng nhẹ khi nội dung cuộn bên dưới
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2.0 : 0.0,
      child: child,
    );
  }

  // Chỉ build lại khi child hoặc height thay đổi
  @override
  bool shouldRebuild(covariant PersistentHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}