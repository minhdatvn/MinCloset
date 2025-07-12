// file: lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import
import 'package:uuid/uuid.dart'; // Thêm import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Đảm bảo CSDL đã sẵn sàng
    await DatabaseHelper.instance.database;

    // === LOGIC MỚI: TẠO TỦ ĐỒ MẶC ĐỊNH ===
    final prefs = await SharedPreferences.getInstance();
    // Kiểm tra xem chúng ta đã từng tạo tủ đồ mặc định chưa
    final bool hasCreatedDefault = prefs.getBool('has_created_default_closet') ?? false;

    if (!hasCreatedDefault) {
      // Nếu chưa, tạo một tủ đồ mới
      final defaultCloset = Closet(
        id: const Uuid().v4(),
        name: 'My first closet',
      );
      await DatabaseHelper.instance.insertCloset(defaultCloset.toMap());
      
      // Đánh dấu là đã tạo để không tạo lại ở các lần mở sau
      await prefs.setBool('has_created_default_closet', true);
    }
     // === LOGIC MỚI ĐỂ KIỂM TRA ONBOARDING ===
    final bool hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;

    // Giữ lại độ trễ nhỏ để hiển thị logo
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (hasCompletedOnboarding) {
        // Nếu đã hoàn thành, đi tới màn hình chính
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      } else {
        // Nếu chưa, đi tới màn hình onboarding
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Cleaning closet...'),
          ],
        ),
      ),
    );
  }
}