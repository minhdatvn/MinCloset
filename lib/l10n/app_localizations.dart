import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// The word for English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// The word for Vietnamese language
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get language_vietnamese;

  /// SCREEN: Settings. The title in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_general_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settings_general_sectionHeader;

  /// No description provided for @settings_localization_tile.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get settings_localization_tile;

  /// No description provided for @settings_location_tile.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settings_location_tile;

  /// No description provided for @settings_autoDetect_label.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect'**
  String get settings_autoDetect_label;

  /// No description provided for @settings_language_tile.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language_tile;

  /// No description provided for @settings_currency_tile.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency_tile;

  /// No description provided for @settings_decimalFormat_tile.
  ///
  /// In en, this message translates to:
  /// **'Decimal format'**
  String get settings_decimalFormat_tile;

  /// No description provided for @settings_notifications_tile.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications_tile;

  /// No description provided for @settings_enableAllNotifications_label.
  ///
  /// In en, this message translates to:
  /// **'Enable all notifications'**
  String get settings_enableAllNotifications_label;

  /// No description provided for @settings_morningReminder_label.
  ///
  /// In en, this message translates to:
  /// **'Morning reminder (7:00)'**
  String get settings_morningReminder_label;

  /// No description provided for @settings_morningReminder_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get suggestions for your daily outfit plan.'**
  String get settings_morningReminder_subtitle;

  /// No description provided for @settings_eveningReminder_label.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder (20:00)'**
  String get settings_eveningReminder_label;

  /// No description provided for @settings_eveningReminder_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Remind to update your fashion journal.'**
  String get settings_eveningReminder_subtitle;

  /// No description provided for @settings_display_tile.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settings_display_tile;

  /// No description provided for @settings_showWeatherBg_label.
  ///
  /// In en, this message translates to:
  /// **'Show weather background'**
  String get settings_showWeatherBg_label;

  /// No description provided for @settings_showWeatherBg_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Display image based on weather'**
  String get settings_showWeatherBg_subtitle;

  /// No description provided for @settings_showMascot_label.
  ///
  /// In en, this message translates to:
  /// **'Show Mascot'**
  String get settings_showMascot_label;

  /// No description provided for @settings_showMascot_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Display the assistant on screen'**
  String get settings_showMascot_subtitle;

  /// No description provided for @settings_aboutSupport_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'About & Support'**
  String get settings_aboutSupport_sectionHeader;

  /// No description provided for @settings_aboutLegal_tile.
  ///
  /// In en, this message translates to:
  /// **'About & Legal'**
  String get settings_aboutLegal_tile;

  /// No description provided for @settings_sendFeedback_tile.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settings_sendFeedback_tile;

  /// No description provided for @settings_sendFeedback_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve MinCloset'**
  String get settings_sendFeedback_subtitle;

  /// No description provided for @settings_rateApp_tile.
  ///
  /// In en, this message translates to:
  /// **'Rate on App Store'**
  String get settings_rateApp_tile;

  /// No description provided for @quests_title.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get quests_title;

  /// No description provided for @quests_yourBadges_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Your Badges'**
  String get quests_yourBadges_sectionHeader;

  /// No description provided for @quests_inProgress_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get quests_inProgress_sectionHeader;

  /// No description provided for @quests_noActiveQuests_message.
  ///
  /// In en, this message translates to:
  /// **'No active quests.'**
  String get quests_noActiveQuests_message;

  /// No description provided for @quest_event_topAdded.
  ///
  /// In en, this message translates to:
  /// **'Tops Added'**
  String get quest_event_topAdded;

  /// No description provided for @quest_event_bottomAdded.
  ///
  /// In en, this message translates to:
  /// **'Bottoms Added'**
  String get quest_event_bottomAdded;

  /// No description provided for @quest_event_suggestionReceived.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion'**
  String get quest_event_suggestionReceived;

  /// No description provided for @quest_event_outfitCreated.
  ///
  /// In en, this message translates to:
  /// **'Outfit Created'**
  String get quest_event_outfitCreated;

  /// No description provided for @quest_event_closetCreated.
  ///
  /// In en, this message translates to:
  /// **'New Closet'**
  String get quest_event_closetCreated;

  /// No description provided for @quest_event_logAdded.
  ///
  /// In en, this message translates to:
  /// **'Item/Outfit Logged'**
  String get quest_event_logAdded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
