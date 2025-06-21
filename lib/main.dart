// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/screens/splash_screen.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MinClosetApp()));
}

class MinClosetApp extends ConsumerWidget {
  const MinClosetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'MinCloset',
      theme: appTheme,
      // <<< THÊM CẤU HÌNH ĐA NGÔN NGỮ >>>
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'), // Tiếng Việt
        Locale('en'), // Tiếng Anh
      ],
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}