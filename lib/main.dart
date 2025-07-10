import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/locale_provider.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/widgets/global_ui_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SentryFlutter.init(
    (options) {
      // Giữ lại DSN để gửi lỗi
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      // Bỏ các tùy chọn tracesSampleRate và profilesSampleRate để tắt performance
    },
    // Chỉ cần bọc ứng dụng trong ProviderScope là đủ
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
      // Khi provider đã tải xong dữ liệu (từ trạng thái loading chuyển sang có data)
      if (next is AsyncData<WeatherImageService>) {
        // Gọi hàm để tải trước tất cả các ảnh vào cache
        next.value.precacheWeatherImages(context);
      }
    });
    final locale = ref.watch(localeProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);

    // Bỏ SentryAssetBundle và SentryNavigatorObserver
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MinCloset',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.onGenerateRoute,
      builder: (context, child) {
        // Bọc child bằng cả hai widget theo đúng thứ tự
        return SafeArea(
          top: false,   // Vẫn giữ nguyên logic cho phép tràn viền trên
          bottom: true,  // Vẫn giữ nguyên logic ngăn tràn viền dưới
          // GlobalUiScope sẽ là con của SafeArea
          child: GlobalUiScope(
            child: child!, 
          ),
        );
      },
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