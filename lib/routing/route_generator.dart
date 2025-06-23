// lib/routing/route_generator.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
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

class RouteGenerator {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      // SỬA LỖI Ở ĐÂY: Thêm <bool>
      case AppRoutes.analysisLoading:
        if (args is List<XFile>) {
          return MaterialPageRoute<bool>(
              builder: (_) => AnalysisLoadingScreen(images: args));
        }
        return _errorRoute();

      // SỬA LỖI Ở ĐÂY: Thêm <bool>
      case AppRoutes.addItem:
        final itemArgs = args as ItemNotifierArgs?;
        return MaterialPageRoute<bool>(
            builder: (_) => AddItemScreen(
                  itemToEdit: itemArgs?.itemToEdit,
                  newImage: itemArgs?.newImage,
                  preAnalyzedState: itemArgs?.preAnalyzedState,
                ));

      // SỬA LỖI Ở ĐÂY: Thêm <bool>
      case AppRoutes.batchAddItem:
        return MaterialPageRoute<bool>(builder: (_) => const BatchAddItemScreen());

      // SỬA LỖI Ở ĐÂY: Thêm <bool>
      case AppRoutes.outfitBuilder:
        return MaterialPageRoute<bool>(builder: (_) => const OutfitBuilderPage());

      // SỬA LỖI Ở ĐÂY: Thêm <bool>
      case AppRoutes.outfitDetail:
        if (args is Outfit) {
          return MaterialPageRoute<bool>(
              builder: (_) => OutfitDetailPage(outfit: args));
        }
        return _errorRoute();

      // SỬA LỖI Ở ĐÂY: Thêm <bool>
      case AppRoutes.closetDetail:
        if (args is Closet) {
          return MaterialPageRoute<bool>(
              builder: (_) => ClosetDetailPage(closet: args));
        }
        return _errorRoute();
      
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case AppRoutes.citySelection:
        return MaterialPageRoute(builder: (_) => const CitySelectionScreen());

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