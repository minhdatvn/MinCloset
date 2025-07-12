// lib/widgets/page_scaffold.dart
import 'package:flutter/material.dart';

/// Một widget Scaffold (khung sườn) cơ bản được sử dụng cho các trang phụ.
/// Nó tự động áp dụng SafeArea cho phần đáy để tránh các thành phần
/// giao diện của hệ thống (như thanh điều hướng trên Android/iOS).
class PageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const PageScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Chúng ta chỉ áp dụng SafeArea cho phần dưới (bottom: true)
    // vì phần trên đã được AppBar xử lý.
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
      ),
    );
  }
}