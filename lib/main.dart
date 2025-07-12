// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/widgets/global_ui_scope.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mincloset/src/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalNotificationService().init();

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
class MainAppWrapper extends ConsumerWidget {
  const MainAppWrapper({super.key});

  @override
  // Thêm WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) { 
    // THAY ĐỔI 2: Đọc key từ provider
    final nestedNavigatorKey = ref.watch(nestedNavigatorKeyProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // Nếu hành động pop chưa được hệ thống xử lý
        if (didPop) return;

        // Lấy trạng thái của navigator lồng nhau
        final navigator = nestedNavigatorKey.currentState;
        
        // Nếu navigator lồng nhau có thể pop (tức là đang ở trang con)
        if (navigator != null && navigator.canPop()) {
          // Thì thực hiện pop trên navigator lồng nhau
          navigator.pop();
        } 
        // Nếu không, nghĩa là đang ở các trang chính, không làm gì cả
        // để người dùng có thể thoát app bằng nút back 2 lần như bình thường.
      },
      child: Scaffold(
        body: Stack(
          children: [
            Navigator(
              key: nestedNavigatorKey,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: RouteGenerator.onGenerateRoute,
            ),
            const GlobalUiScope(),
          ],
        ),
      ),
    );
  }
}