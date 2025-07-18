// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/providers/flow_providers.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mincloset/screens/onboarding_screen.dart';
import 'package:mincloset/screens/permissions_screen.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/src/services/local_notification_service.dart';
import 'package:mincloset/services/secure_storage_service.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:mincloset/widgets/global_ui_scope.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
  ]);

  await LocalNotificationService().init();
  
  await DatabaseHelper.instance.database;
  final prefs = await SharedPreferences.getInstance();

  // Tạo một ProviderContainer tạm thời chỉ để chạy logic khởi tạo
  // Điều này cho phép các service truy cập các provider khác như SharedPreferences
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  
  // Kích hoạt việc lấy key chạy trong nền. Chúng ta không "await" ở đây.
  // Đây là hành động "fire-and-forget".
  container.read(remoteConfigServiceProvider).initializeAndFetchKeys();

  // Đọc trạng thái từ SharedPreferences
  final bool hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
  final bool hasSeenPermissionsScreen = prefs.getBool('has_seen_permissions_screen') ?? false;

  // Logic tạo tủ đồ mặc định (giữ nguyên)
  if (!hasCompletedOnboarding) {
    final defaultCloset = Closet(id: const Uuid().v4(), name: 'My first closet');
    await DatabaseHelper.instance.insertCloset(defaultCloset.toMap());
  }
  
  // Quyết định màn hình đầu tiên (giữ nguyên)
  final Widget initialScreen;
  if (!hasCompletedOnboarding) {
    initialScreen = const OnboardingScreen();
  } else if (!hasSeenPermissionsScreen) {
    initialScreen = const PermissionsScreen();
  } else {
    initialScreen = const MainScreen();
  }

  // Đọc Sentry DSN từ Secure Storage trước khi khởi tạo Sentry
  final secureStorage = SecureStorageService();
  final sentryDsn = await secureStorage.read(SecureStorageKeys.sentryDsn);

  await SentryFlutter.init(
    (options) {
      // Sử dụng DSN đã đọc được
      options.dsn = sentryDsn ?? '';
    },
    // --- KẾT THÚC THAY ĐỔI ---
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          initialScreenProvider.overrideWithValue(initialScreen),
          onboardingCompletedProvider.overrideWith((ref) => StateController(hasCompletedOnboarding)),
          permissionsSeenProvider.overrideWith((ref) => StateController(hasSeenPermissionsScreen)),
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
      home: const FullAppNavigator(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
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

class FullAppNavigator extends ConsumerWidget {
  const FullAppNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic của widget này không thay đổi, chỉ đổi tên
    final nestedNavigatorKey = ref.watch(nestedNavigatorKeyProvider);
    final initialScreen = ref.watch(initialScreenProvider);

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
            AppFlowController(
              child: Navigator(
                key: nestedNavigatorKey,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [
                    MaterialPageRoute(builder: (context) => initialScreen)
                  ];
                },
                onGenerateRoute: RouteGenerator.onGenerateRoute,
              ),
            ),
            const GlobalUiScope(),
          ],
        ),
      ),
    );
  }
}

class AppFlowController extends ConsumerWidget {
  final Widget child;
  const AppFlowController({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nestedNavigatorKey = ref.watch(nestedNavigatorKeyProvider);

    // Lắng nghe trạng thái onboarding
    ref.listen<bool>(onboardingCompletedProvider, (previous, next) {
      // Khi trạng thái thay đổi từ false -> true
      if (next == true && previous == false) {
        // Chuyển tới màn hình xin quyền
        nestedNavigatorKey.currentState?.pushReplacementNamed(AppRoutes.permissions);
      }
    });

    // Lắng nghe trạng thái xin quyền
    ref.listen<bool>(permissionsSeenProvider, (previous, next) {
      // Khi trạng thái thay đổi từ false -> true
      if (next == true && previous == false) {
        // Chuyển tới màn hình chính
        nestedNavigatorKey.currentState?.pushReplacementNamed(AppRoutes.main);
      }
    });

    return child;
  }
}