// lib/routing/route_generator.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/notifiers/log_wear_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/about_legal_page.dart';
import 'package:mincloset/screens/analysis_loading_screen.dart';
import 'package:mincloset/screens/avatar_cropper_screen.dart';
import 'package:mincloset/screens/background_remover_page.dart';
import 'package:mincloset/screens/badge_detail_page.dart';
import 'package:mincloset/screens/batch_add_item_screen.dart';
import 'package:mincloset/screens/calendar_page.dart';
import 'package:mincloset/screens/city_selection_screen.dart';
import 'package:mincloset/screens/closet_form_screen.dart';
import 'package:mincloset/screens/closet_insights_screen.dart';
import 'package:mincloset/screens/edit_profile_screen.dart';
import 'package:mincloset/screens/image_editor_screen.dart';
import 'package:mincloset/screens/item_detail_screen.dart';
import 'package:mincloset/screens/language_selection_screen.dart';
import 'package:mincloset/screens/log_wear_screen.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mincloset/screens/onboarding_screen.dart';
import 'package:mincloset/screens/outfit_detail_page.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/screens/permissions_screen.dart';
import 'package:mincloset/screens/quests_page.dart';
import 'package:mincloset/screens/settings_page.dart';
import 'package:mincloset/screens/webview_page.dart';
import 'package:showcaseview/showcaseview.dart';

class CalendarPageArgs {
  final bool showHint;
  const CalendarPageArgs({this.showHint = false});
}

class RouteGenerator {
  static const Widget _mainScreen = MainScreen();
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => _mainScreen, settings: settings);

      case AppRoutes.analysisLoading:
          // Bây giờ `args` sẽ là ImageSource
          final source = args as ImageSource;
          return PageRouteBuilder(
            opaque: false,
            // Truyền `source` vào constructor của màn hình
            pageBuilder: (_, __, ___) => AnalysisLoadingScreen(source: source),
            settings: settings,
          );

      case AppRoutes.addItem:
        final itemArgs = args as ItemDetailNotifierArgs?;
        return AnimatePageRoute<bool>( // Sử dụng lớp mới
          page: ItemDetailScreen(
            itemToEdit: itemArgs?.itemToEdit,
            preAnalyzedState: itemArgs?.preAnalyzedState,
          ),
          settings: settings,
        );

      case AppRoutes.batchAddItem:
        return MaterialPageRoute<bool>(builder: (_) => const BatchItemDetailScreen(), settings: settings);

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
          return AnimatePageRoute<bool>(page: OutfitDetailPage(outfit: args), settings: settings);
        }
        return _errorRoute();

      case AppRoutes.closetDetail:
        if (args is Closet) {
          return AnimatePageRoute(page: ClosetDetailPage(closet: args), settings: settings);
        }
        return _errorRoute();
      
      case AppRoutes.editProfile:
        return AnimatePageRoute(page: const EditProfileScreen(), settings: settings);

      case AppRoutes.settings:
        return AnimatePageRoute(page: const SettingsPage(), settings: settings);

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
        final calendarArgs = args is CalendarPageArgs ? args : const CalendarPageArgs();
        return AnimatePageRoute(
          page: ShowCaseWidget(
              builder: (context) => CalendarPage(
                initialDate: null, // hoặc logic lấy ngày của bạn
                showHintOnLoad: calendarArgs.showHint, // Truyền tín hiệu vào
              ),
            ),
          settings: settings,
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
      
      case AppRoutes.quests:
        return MaterialPageRoute(builder: (_) => const QuestsPage());

      case AppRoutes.badgeDetail:
        if (args is BadgeDetailPageArgs) {
          return AnimatePageRoute(page: BadgeDetailPage(args: args));
        }
        return _errorRoute();

      case AppRoutes.editCloset:
        // Chấp nhận `args` có thể là null hoặc Closet
        final closetToEdit = args as Closet?; 
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ClosetFormScreen(closetToEdit: closetToEdit),
        );
      
      case AppRoutes.permissions:
        return MaterialPageRoute(builder: (_) => const PermissionsScreen());

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

class AnimatePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AnimatePageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Sử dụng Animate như một widget và điều khiển nó bằng animation của route
            return Animate(
              effects: [
                // Hiệu ứng trượt ngang
                SlideEffect(
                  begin: const Offset(-1.0, 0.0), // Bắt đầu từ bên trái
                  end: Offset.zero,
                  curve: Curves.easeOutCubic,
                ),
                // Hiệu ứng mờ dần
                FadeEffect(
                  begin: 0.0,
                  end: 1.0,
                  curve: Curves.easeOutCubic,
                )
              ],
              // Điều khiển hiệu ứng bằng giá trị của animation do PageRouteBuilder cung cấp
              value: animation.value, 
              // Không để Animate tự động chạy
              autoPlay: false, 
              // Hiệu ứng khi đóng (pop) trang
              onComplete: (controller) {
                // Khi trang đóng, controller sẽ chạy ngược lại
                if (animation.status == AnimationStatus.reverse) {
                  controller.reverse();
                }
              },
              child: child,
            );
          },
        );
}
