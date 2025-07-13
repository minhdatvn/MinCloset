// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart'; // Thêm import
import 'package:mincloset/models/closet.dart'; // Thêm import
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/screens/main_screen.dart'; // Thêm import
import 'package:mincloset/screens/onboarding_screen.dart'; // Thêm import
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/src/services/local_notification_service.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/widgets/global_ui_scope.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import
import 'package:uuid/uuid.dart'; // Thêm import

// BƯỚC 1: Chuyển hàm main thành async
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalNotificationService().init();

  // BƯỚC 2: Di chuyển toàn bộ logic từ SplashScreen vào đây
  await DatabaseHelper.instance.database;
  final prefs = await SharedPreferences.getInstance();
  final bool hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  // Logic tạo tủ đồ mặc định khi onboarding chưa hoàn thành
  if (!hasCompletedOnboarding) {
      final defaultCloset = Closet(
        id: const Uuid().v4(),
        name: 'My first closet',
      );
      await DatabaseHelper.instance.insertCloset(defaultCloset.toMap());
  }
  
  // BƯỚC 3: Quyết định màn hình đầu tiên sẽ là gì
  final Widget initialScreen = hasCompletedOnboarding
      ? const MainScreen()
      : const OnboardingScreen();

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
    },
    appRunner: () => runApp(
      ProviderScope(
        // BƯỚC 4: Ghi đè provider để truyền màn hình đầu tiên vào trong
        overrides: [
          initialScreenProvider.overrideWithValue(initialScreen),
        ],
        child: const MinClosetApp(),
      ),
    ),
  );
}

// Provider mới để chứa widget màn hình đầu tiên
final initialScreenProvider = Provider<Widget>((ref) {
  // Giá trị mặc định này sẽ không bao giờ được sử dụng vì đã bị override
  throw UnimplementedError();
});


// MinClosetApp không thay đổi nhiều
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
      home: const MainAppWrapper(), // Giữ nguyên
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


// BƯỚC 5: Cập nhật MainAppWrapper để đọc màn hình đầu tiên từ provider
class MainAppWrapper extends ConsumerWidget {
  const MainAppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nestedNavigatorKey = ref.watch(nestedNavigatorKeyProvider);
    final initialScreen = ref.watch(initialScreenProvider); // Đọc màn hình đầu tiên

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        final navigator = nestedNavigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Navigator(
              key: nestedNavigatorKey,
              // BƯỚC 6: Thay vì route, dùng onGenerateInitialRoutes
              // Điều này cho phép chúng ta đặt một trang tùy chỉnh làm trang đầu tiên
              // mà không cần route name.
              onGenerateInitialRoutes: (navigator, initialRoute) {
                return [
                  MaterialPageRoute(builder: (context) => initialScreen)
                ];
              },
              onGenerateRoute: RouteGenerator.onGenerateRoute,
            ),
            const GlobalUiScope(),
          ],
        ),
      ),
    );
  }
}