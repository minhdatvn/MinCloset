// file: lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/screens/main_screen.dart';

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

  // Hàm để thực hiện các tác vụ khởi tạo nặng
  Future<void> _initializeApp() async {
    // Tác vụ quan trọng nhất: "đánh thức" CSDL.
    // Lệnh này sẽ thực hiện việc tạo file và các bảng nếu đây là lần đầu chạy.
    await DBHelper.db();

    // Thêm một chút độ trễ để người dùng có thể thấy logo (tùy chọn)
    await Future.delayed(const Duration(seconds: 1));

    // Sau khi hoàn tất, chuyển sang màn hình chính và không cho phép quay lại
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giao diện của màn hình chờ rất đơn giản
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bạn có thể thay bằng logo của mình ở đây
            Icon(Icons.checkroom, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Đang khởi tạo dữ liệu...'),
          ],
        ),
      ),
    );
  }
}