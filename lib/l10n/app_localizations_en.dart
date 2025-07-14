// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language_english => 'English';

  @override
  String get language_vietnamese => 'Vietnamese';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general_sectionHeader => 'General Settings';

  @override
  String get settings_localization_tile => 'Localization';

  @override
  String get settings_location_tile => 'Location';

  @override
  String get settings_autoDetect_label => 'Auto-detect';

  @override
  String get settings_language_tile => 'Language';

  @override
  String get settings_currency_tile => 'Currency';

  @override
  String get settings_decimalFormat_tile => 'Decimal format';

  @override
  String get settings_notifications_tile => 'Notifications';

  @override
  String get settings_enableAllNotifications_label =>
      'Enable all notifications';

  @override
  String get settings_morningReminder_label => 'Morning reminder (7:00)';

  @override
  String get settings_morningReminder_subtitle =>
      'Get suggestions for your daily outfit plan.';

  @override
  String get settings_eveningReminder_label => 'Evening reminder (20:00)';

  @override
  String get settings_eveningReminder_subtitle =>
      'Remind to update your fashion journal.';

  @override
  String get settings_display_tile => 'Display';

  @override
  String get settings_showWeatherBg_label => 'Show weather background';

  @override
  String get settings_showWeatherBg_subtitle =>
      'Display image based on weather';

  @override
  String get settings_showMascot_label => 'Show Mascot';

  @override
  String get settings_showMascot_subtitle => 'Display the assistant on screen';

  @override
  String get settings_aboutSupport_sectionHeader => 'About & Support';

  @override
  String get settings_aboutLegal_tile => 'About & Legal';

  @override
  String get settings_sendFeedback_tile => 'Send Feedback';

  @override
  String get settings_sendFeedback_subtitle => 'Help us improve MinCloset';

  @override
  String get settings_rateApp_tile => 'Rate on App Store';

  @override
  String get quests_title => 'Achievements';

  @override
  String get quests_yourBadges_sectionHeader => 'Your Badges';

  @override
  String get quests_inProgress_sectionHeader => 'In Progress';

  @override
  String get quests_noActiveQuests_message => 'No active quests.';

  @override
  String get quest_event_topAdded => 'Tops Added';

  @override
  String get quest_event_bottomAdded => 'Bottoms Added';

  @override
  String get quest_event_suggestionReceived => 'AI Suggestion';

  @override
  String get quest_event_outfitCreated => 'Outfit Created';

  @override
  String get quest_event_closetCreated => 'New Closet';

  @override
  String get quest_event_logAdded => 'Item/Outfit Logged';
}
