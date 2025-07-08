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
import 'package:mincloset/screens/avatar_cropper_screen.dart';

class RouteGenerator {
  static const Widget _mainScreen = MainScreen();
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => _mainScreen, settings: settings);

      case AppRoutes.analysisLoading:
          final images = args as List<XFile>?;
          return PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => AnalysisLoadingScreen(images: images),
            settings: settings,
          );

      case AppRoutes.addItem:
        final itemArgs = args as ItemNotifierArgs?;
        return MaterialPageRoute<bool>(
          builder: (_) => AddItemScreen(
            itemToEdit: itemArgs?.itemToEdit,
            preAnalyzedState: itemArgs?.preAnalyzedState,
          ),
          settings: settings,
        );

      case AppRoutes.batchAddItem:
        return MaterialPageRoute<bool>(builder: (_) => const BatchAddItemScreen(), settings: settings);

      case AppRoutes.outfitBuilder:
        final suggestionResult = args as SuggestionResult?;
        return MaterialPageRoute(
          builder: (_) => OutfitBuilderPage(
            suggestionResult: suggestionResult,
          ),
          settings: settings,
        );

      case AppRoutes.outfitDetail:
        if (args is Outfit) {
          return MaterialPageRoute<bool>(builder: (_) => OutfitDetailPage(outfit: args), settings: settings);
        }
        return _errorRoute();

      case AppRoutes.closetDetail:
        if (args is Closet) {
          return MaterialPageRoute(builder: (_) => ClosetDetailPage(closet: args), settings: settings);
        }
        return _errorRoute();
      
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen(), settings: settings);

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage(), settings: settings);

      case AppRoutes.citySelection:
        return MaterialPageRoute(builder: (_) => const CitySelectionScreen(), settings: settings);

      case AppRoutes.aboutLegal:
        return MaterialPageRoute(builder: (_) => const AboutLegalPage(), settings: settings);
      
      case AppRoutes.webview:
        if (args is WebViewPageArgs) {
          return MaterialPageRoute(builder: (_) => WebViewPage(args: args));
        }
        return _errorRoute();
      
      case AppRoutes.calendar:
        final initialDate = args as DateTime?;
        return MaterialPageRoute(
          builder: (_) => CalendarPage(initialDate: initialDate),
        );

      case AppRoutes.logWearSelection:
        if (args is LogWearNotifierArgs) {
          return MaterialPageRoute<Set<String>>(
            builder: (_) => LogWearScreen(args: args),
          );
        }
        return _errorRoute();
      
      case AppRoutes.languageSelection:
        return MaterialPageRoute(builder: (_) => const LanguageSelectionScreen());
      
      case AppRoutes.closetInsights:
        return MaterialPageRoute(builder: (_) => const ClosetInsightsScreen());

      case AppRoutes.backgroundRemover:
        if (args is Uint8List) {
          return MaterialPageRoute<Uint8List?>(
            builder: (_) => BackgroundRemoverPage(imageBytes: args),
            settings: settings,
          );
        }
        return _errorRoute();
      
      case AppRoutes.imageEditor:
        if (args is Uint8List) {
          return MaterialPageRoute<Uint8List?>(
            builder: (_) => ImageEditorScreen(imageBytes: args),
            settings: settings,
          );
        }
        return _errorRoute();

      case AppRoutes.avatarCropper:
        if (settings.arguments is Uint8List) {
          return MaterialPageRoute<Uint8List?>(
            builder: (_) => AvatarCropperScreen(
              imageBytes: settings.arguments as Uint8List,
            ),
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