// lib/routing/route_generator.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/log_wear_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/about_legal_page.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/analysis_loading_screen.dart';
import 'package:mincloset/screens/background_remover_page.dart';
import 'package:mincloset/screens/batch_add_item_screen.dart';
import 'package:mincloset/screens/calendar_page.dart';
import 'package:mincloset/screens/city_selection_screen.dart';
import 'package:mincloset/screens/closet_insights_screen.dart';
import 'package:mincloset/screens/edit_profile_screen.dart';
import 'package:mincloset/screens/image_editor_screen.dart';
import 'package:mincloset/screens/language_selection_screen.dart';
import 'package:mincloset/screens/log_wear_screen.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mincloset/screens/outfit_detail_page.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/screens/settings_page.dart';
import 'package:mincloset/screens/splash_screen.dart';
import 'package:mincloset/screens/webview_page.dart';

class RouteGenerator {
  static const Widget _mainScreen = MainScreen();
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.main:
        return FadeRoute(page: _mainScreen, settings: settings);

      case AppRoutes.analysisLoading:
          // Logic mới: màn hình loading giờ đây có thể nhận một danh sách ảnh
          // (cho trường hợp camera) hoặc không nhận gì cả (cho trường hợp album)
          final images = args as List<XFile>?; // args có thể là null
          return PageRouteBuilder(
            opaque: false,
            // Truyền `images` vào, có thể là null
            pageBuilder: (_, __, ___) => AnalysisLoadingScreen(images: images),
            settings: settings,
          );

      case AppRoutes.addItem:
        final itemArgs = args as ItemNotifierArgs?;
        return FadeRoute<bool>(
          page: AddItemScreen(
            itemToEdit: itemArgs?.itemToEdit,
            preAnalyzedState: itemArgs?.preAnalyzedState,
          ),
          settings: settings,
        );

      case AppRoutes.batchAddItem:
        return FadeRoute<bool>(page: const BatchAddItemScreen(), settings: settings);

      case AppRoutes.outfitBuilder:
        // Chấp nhận cả việc không có args (tạo mới) và có args (sửa từ gợi ý)
        final suggestionResult = args as SuggestionResult?;
        return FadeRoute(
          page: OutfitBuilderPage(
            suggestionResult: suggestionResult,
          ),
          settings: settings,
        );

      case AppRoutes.outfitDetail:
        if (args is Outfit) {
          // Màn hình này cũng có thể trả về giá trị bool
          return FadeRoute<bool>(page: OutfitDetailPage(outfit: args), settings: settings);
        }
        return _errorRoute();

      case AppRoutes.closetDetail:
        if (args is Closet) {
          return FadeRoute(page: ClosetDetailPage(closet: args), settings: settings);
        }
        return _errorRoute();
      
      case AppRoutes.editProfile:
        return FadeRoute(page: const EditProfileScreen(), settings: settings);

      case AppRoutes.settings:
        return FadeRoute(page: const SettingsPage(), settings: settings);

      case AppRoutes.citySelection:
        return FadeRoute(page: const CitySelectionScreen(), settings: settings);

      case AppRoutes.aboutLegal:
        return FadeRoute(page: const AboutLegalPage(), settings: settings);
      
      case AppRoutes.webview:
        if (args is WebViewPageArgs) {
          return FadeRoute(page: WebViewPage(args: args));
        }
        return _errorRoute();
      
      case AppRoutes.calendar:
        // Lấy ngày được truyền qua arguments (có thể là null)
        final initialDate = args as DateTime?;
        return FadeRoute(
          page: CalendarPage(initialDate: initialDate),
        );

      case AppRoutes.logWearSelection:
        if (args is LogWearNotifierArgs) {
          // Màn hình này sẽ trả về một Set<String>
          return FadeRoute<Set<String>>(
            page: LogWearScreen(args: args),
          );
        }
        return _errorRoute();
      
      case AppRoutes.languageSelection:
        return FadeRoute(page: const LanguageSelectionScreen());
      
      case AppRoutes.closetInsights:
        return FadeRoute(page: const ClosetInsightsScreen());

      case AppRoutes.backgroundRemover:
        if (args is Uint8List) {
          return FadeRoute<Uint8List?>(
            page: BackgroundRemoverPage(imageBytes: args),
            settings: settings,
          );
        }
        return _errorRoute();
      
      case AppRoutes.imageEditor:
        if (args is Uint8List) {
          // Route này sẽ nhận dữ liệu ảnh và trả về ảnh đã chỉnh sửa
          return FadeRoute<Uint8List?>(
            page: ImageEditorScreen(imageBytes: args),
            settings: settings,
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Error: Route not found!'),
        ),
      ),
    );
  }
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page, super.settings})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) => FadeTransition(
              opacity: animation,
              child: child,
            ),
          transitionDuration: const Duration(milliseconds: 300), 
        );
}