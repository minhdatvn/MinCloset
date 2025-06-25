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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    // <<< THAY ĐỔI QUAN TRỌNG Ở ĐÂY >>>
    // appRunner giờ sẽ bọc ứng dụng của bạn trong các widget cần thiết của Sentry
    appRunner: () => runApp(
      DefaultAssetBundle(
        // Cách dùng SentryAssetBundle mới
        bundle: SentryAssetBundle(),
        // SentryUserInteractionWidget giúp ghi lại các tương tác của người dùng
        child: SentryUserInteractionWidget(
          child: const ProviderScope(
            child: MinClosetApp(),
          ),
        ),
      ),
    ),
  );
}

class MinClosetApp extends ConsumerWidget {
  const MinClosetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MinCloset',
      theme: appTheme,
      // SentryNavigatorObserver vẫn được giữ nguyên ở đây
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.onGenerateRoute,
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