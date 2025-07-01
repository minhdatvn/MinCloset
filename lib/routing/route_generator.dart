// lib/routing/route_generator.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/about_legal_page.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/analysis_loading_screen.dart';
import 'package:mincloset/screens/batch_add_item_screen.dart';
import 'package:mincloset/screens/city_selection_screen.dart';
import 'package:mincloset/screens/edit_profile_screen.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/screens/outfit_detail_page.dart';
import 'package:mincloset/screens/settings_page.dart';
import 'package:mincloset/screens/splash_screen.dart';
import 'package:mincloset/screens/webview_page.dart';
import 'package:mincloset/screens/calendar_page.dart';

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
        // <<< SỬA LỖI Ở ĐÂY: Dùng MaterialPageRoute<bool> >>>
        return MaterialPageRoute<bool>(
          builder: (_) => AddItemScreen(
            itemToEdit: itemArgs?.itemToEdit,
            newImage: itemArgs?.newImage,
            preAnalyzedState: itemArgs?.preAnalyzedState,
          ),
          settings: settings,
        );

      case AppRoutes.batchAddItem:
         return MaterialPageRoute<bool>(builder: (_) => const BatchAddItemScreen(), settings: settings);

      case AppRoutes.outfitBuilder:
        // Chấp nhận cả việc không có args (tạo mới) và có args (sửa từ gợi ý)
        final suggestionResult = args as SuggestionResult?;
        return FadeRoute(
          page: OutfitBuilderPage(
            // Truyền suggestionResult vào constructor
            suggestionResult: suggestionResult,
          ),
          settings: settings,
        );

      case AppRoutes.outfitDetail:
        if (args is Outfit) {
          // Màn hình này cũng có thể trả về giá trị bool
          return MaterialPageRoute<bool>(builder: (_) => OutfitDetailPage(outfit: args), settings: settings);
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
          return MaterialPageRoute(builder: (_) => WebViewPage(args: args));
        }
        return _errorRoute();
      
      case AppRoutes.calendar:
        // Lấy ngày được truyền qua arguments (có thể là null)
        final initialDate = args as DateTime?;
        return MaterialPageRoute(
          builder: (_) => CalendarPage(initialDate: initialDate),
        );
        
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