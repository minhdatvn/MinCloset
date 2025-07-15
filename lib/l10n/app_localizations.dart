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

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_settings_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings_tooltip;

  /// No description provided for @profile_editProfile_label.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_editProfile_label;

  /// No description provided for @profile_unnamed_label.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get profile_unnamed_label;

  /// No description provided for @profile_achievements_label.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profile_achievements_label;

  /// No description provided for @profile_closetsOverview_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Closets overview'**
  String get profile_closetsOverview_sectionHeader;

  /// No description provided for @profile_insights_button.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get profile_insights_button;

  /// No description provided for @profile_statistics_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profile_statistics_sectionHeader;

  /// No description provided for @profile_noData_message.
  ///
  /// In en, this message translates to:
  /// **'No data for statistics'**
  String get profile_noData_message;

  /// No description provided for @profile_statPage_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get profile_statPage_category;

  /// No description provided for @profile_statPage_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get profile_statPage_color;

  /// No description provided for @profile_statPage_season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get profile_statPage_season;

  /// No description provided for @profile_statPage_occasion.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get profile_statPage_occasion;

  /// No description provided for @profile_statPage_material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get profile_statPage_material;

  /// No description provided for @profile_statPage_pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get profile_statPage_pattern;

  /// No description provided for @profile_takePhoto_label.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get profile_takePhoto_label;

  /// No description provided for @profile_fromAlbum_label.
  ///
  /// In en, this message translates to:
  /// **'From Album'**
  String get profile_fromAlbum_label;

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

  /// No description provided for @settings_units_tile.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settings_units_tile;

  /// No description provided for @settings_height_label.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get settings_height_label;

  /// No description provided for @settings_weight_label.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get settings_weight_label;

  /// No description provided for @settings_temp_label.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get settings_temp_label;

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

  /// No description provided for @editProfile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile_title;

  /// No description provided for @editProfile_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfile_saveButton;

  /// No description provided for @editProfile_basicInfo_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get editProfile_basicInfo_sectionHeader;

  /// No description provided for @editProfile_fullName_label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfile_fullName_label;

  /// No description provided for @editProfile_gender_label.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editProfile_gender_label;

  /// No description provided for @editProfile_birthday_label.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get editProfile_birthday_label;

  /// No description provided for @editProfile_notSelected_label.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get editProfile_notSelected_label;

  /// No description provided for @editProfile_height_cm_label.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get editProfile_height_cm_label;

  /// No description provided for @editProfile_height_ft_in_label.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get editProfile_height_ft_in_label;

  /// No description provided for @editProfile_weight_label.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get editProfile_weight_label;

  /// No description provided for @editProfile_interests_sectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Interests & Style'**
  String get editProfile_interests_sectionHeader;

  /// No description provided for @editProfile_personalStyle_label.
  ///
  /// In en, this message translates to:
  /// **'Personal style'**
  String get editProfile_personalStyle_label;

  /// No description provided for @editProfile_favoriteColors_label.
  ///
  /// In en, this message translates to:
  /// **'Favorite colors'**
  String get editProfile_favoriteColors_label;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @gender_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gender_other;

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

  /// No description provided for @quest_firstSteps_title.
  ///
  /// In en, this message translates to:
  /// **'First Steps into Your Digital Closet'**
  String get quest_firstSteps_title;

  /// No description provided for @quest_firstSteps_description.
  ///
  /// In en, this message translates to:
  /// **'Add your first 3 tops and 3 bottoms (pants, skirts, etc.) to start receiving personalized suggestions.'**
  String get quest_firstSteps_description;

  /// No description provided for @quest_firstSuggestion_title.
  ///
  /// In en, this message translates to:
  /// **'Your First AI-Powered Suggestion'**
  String get quest_firstSuggestion_title;

  /// No description provided for @quest_firstSuggestion_description.
  ///
  /// In en, this message translates to:
  /// **'Let\'s see what the AI has in store for you. Get your first outfit suggestion!'**
  String get quest_firstSuggestion_description;

  /// No description provided for @quest_firstOutfit_title.
  ///
  /// In en, this message translates to:
  /// **'Your First Creation'**
  String get quest_firstOutfit_title;

  /// No description provided for @quest_firstOutfit_description.
  ///
  /// In en, this message translates to:
  /// **'Use the Outfit Builder to create and save your first custom outfit.'**
  String get quest_firstOutfit_description;

  /// No description provided for @quest_organizeCloset_title.
  ///
  /// In en, this message translates to:
  /// **'Get Organized'**
  String get quest_organizeCloset_title;

  /// No description provided for @quest_organizeCloset_description.
  ///
  /// In en, this message translates to:
  /// **'Create a new closet to better organize your clothing items (e.g., for work, for sports).'**
  String get quest_organizeCloset_description;

  /// No description provided for @quest_firstLog_title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Style Journey'**
  String get quest_firstLog_title;

  /// No description provided for @quest_firstLog_description.
  ///
  /// In en, this message translates to:
  /// **'Log an item or an outfit to your Journey to keep track of what you wear.'**
  String get quest_firstLog_description;

  /// No description provided for @outfitsHub_title.
  ///
  /// In en, this message translates to:
  /// **'Your Outfits'**
  String get outfitsHub_title;

  /// No description provided for @outfitsHub_lastWorn.
  ///
  /// In en, this message translates to:
  /// **'Last worn: {date}'**
  String outfitsHub_lastWorn(Object date);

  /// No description provided for @outfitsHub_lastWorn_never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get outfitsHub_lastWorn_never;

  /// No description provided for @outfitsHub_rename_label.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get outfitsHub_rename_label;

  /// No description provided for @outfitsHub_share_label.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get outfitsHub_share_label;

  /// No description provided for @outfitsHub_viewDetails_label.
  ///
  /// In en, this message translates to:
  /// **'View full details'**
  String get outfitsHub_viewDetails_label;

  /// No description provided for @outfitsHub_delete_label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get outfitsHub_delete_label;

  /// No description provided for @outfitsHub_rename_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename outfit'**
  String get outfitsHub_rename_dialogTitle;

  /// No description provided for @outfitsHub_newName_label.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get outfitsHub_newName_label;

  /// No description provided for @outfitsHub_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get outfitsHub_cancel_button;

  /// No description provided for @outfitsHub_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get outfitsHub_save_button;

  /// No description provided for @outfitsHub_delete_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get outfitsHub_delete_dialogTitle;

  /// No description provided for @outfitsHub_delete_dialogContent.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete outfit \"{outfitName}\"?'**
  String outfitsHub_delete_dialogContent(Object outfitName);

  /// No description provided for @outfitsHub_create_cardLabel.
  ///
  /// In en, this message translates to:
  /// **'Create outfits'**
  String get outfitsHub_create_cardLabel;

  /// No description provided for @outfitsHub_create_hintTitle.
  ///
  /// In en, this message translates to:
  /// **'Outfit Builder'**
  String get outfitsHub_create_hintTitle;

  /// No description provided for @outfitsHub_create_hintDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap here to manually mix and match your items and create your own perfect outfits.'**
  String get outfitsHub_create_hintDescription;

  /// No description provided for @outfitBuilder_title.
  ///
  /// In en, this message translates to:
  /// **'Outfit studio'**
  String get outfitBuilder_title;

  /// No description provided for @outfitBuilder_changeBg_button.
  ///
  /// In en, this message translates to:
  /// **'Change background'**
  String get outfitBuilder_changeBg_button;

  /// No description provided for @outfitBuilder_undo_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get outfitBuilder_undo_tooltip;

  /// No description provided for @outfitBuilder_redo_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get outfitBuilder_redo_tooltip;

  /// No description provided for @outfitBuilder_save_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save outfit'**
  String get outfitBuilder_save_dialogTitle;

  /// No description provided for @outfitBuilder_save_nameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Weekend coffee meet-up'**
  String get outfitBuilder_save_nameHint;

  /// No description provided for @outfitBuilder_save_nameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter an outfit name'**
  String get outfitBuilder_save_nameValidator;

  /// No description provided for @outfitBuilder_save_isFixedLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed outfit'**
  String get outfitBuilder_save_isFixedLabel;

  /// No description provided for @outfitBuilder_save_isFixedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items in this outfit are always worn together. Each item can only belong to one fixed outfit.'**
  String get outfitBuilder_save_isFixedSubtitle;

  /// No description provided for @outfitBuilder_stickers_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Stickers will be available soon.'**
  String get outfitBuilder_stickers_placeholder;
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
