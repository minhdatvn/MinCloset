// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/screens/splash_screen.dart';
import 'package:mincloset/theme/app_theme.dart'; // <<< THÊM IMPORT NÀY

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MinClosetApp()));
}

class MinClosetApp extends StatelessWidget {
  const MinClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MinCloset',
      // <<< SỬA ĐỔI Ở ĐÂY >>>
      theme: appTheme, // Áp dụng theme bạn vừa tạo
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}