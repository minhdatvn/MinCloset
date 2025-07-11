// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/widgets/global_ui_scope.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: MinClosetApp(),
      ),
    ),
  );
}

class MinClosetApp extends ConsumerWidget {
  const MinClosetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<WeatherImageService>>(weatherImageServiceProvider, (previous, next) {
      if (next is AsyncData<WeatherImageService>) {
        next.value.precacheWeatherImages(context);
      }
    });

    final locale = ref.watch(localeProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MinCloset',
      theme: appTheme,
      // THAY ĐỔI 1: Không dùng onGenerateRoute ở đây nữa
      // THAY ĐỔI 2: Dùng home thay cho initialRoute
      home: const MainAppWrapper(), // <--- SỬ DỤNG WIDGET BỌC MỚI
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

// THAY ĐỔI 3: Tạo một widget mới để chứa Stack
class MainAppWrapper extends StatelessWidget {
  const MainAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Bọc trong Scaffold để có nền trắng và các thuộc tính cơ bản
      body: Stack(
        children: [
          // Lớp dưới cùng: Navigator để quản lý các trang
          Navigator(
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.onGenerateRoute,
          ),
          // Lớp trên cùng: Lớp UI toàn cục của chúng ta
          const GlobalUiScope(),
        ],
      ),
    );
  }
}