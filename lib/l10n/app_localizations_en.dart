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
  String banner_deleteSuccess(Object itemName) {
    return 'Deleted \"$itemName\".';
  }

  @override
  String get banner_deleteFailed => 'Failed to delete. Please try again.';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_settings_tooltip => 'Settings';

  @override
  String get profile_editProfile_label => 'Edit profile';

  @override
  String get profile_unnamed_label => 'Unnamed';

  @override
  String get profile_achievements_label => 'Achievements';

  @override
  String get profile_closetsOverview_sectionHeader => 'Closets overview';

  @override
  String get profile_insights_button => 'Insights';

  @override
  String get profile_statistics_sectionHeader => 'Statistics';

  @override
  String get profile_noData_message => 'No data for statistics';

  @override
  String get profile_statPage_category => 'Category';

  @override
  String get profile_statPage_color => 'Color';

  @override
  String get profile_statPage_season => 'Season';

  @override
  String get profile_statPage_occasion => 'Occasion';

  @override
  String get profile_statPage_material => 'Material';

  @override
  String get profile_statPage_pattern => 'Pattern';

  @override
  String get profile_takePhoto_label => 'Take Photo';

  @override
  String get profile_fromAlbum_label => 'From Album';

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
  String get settings_units_tile => 'Units';

  @override
  String get settings_height_label => 'Height';

  @override
  String get settings_weight_label => 'Weight';

  @override
  String get settings_temp_label => 'Temperature';

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
  String get editProfile_title => 'Edit profile';

  @override
  String get editProfile_saveButton => 'Save';

  @override
  String get editProfile_basicInfo_sectionHeader => 'Basic info';

  @override
  String get editProfile_fullName_label => 'Full name';

  @override
  String get editProfile_gender_label => 'Gender';

  @override
  String get editProfile_birthday_label => 'Birthday';

  @override
  String get editProfile_notSelected_label => 'Not selected';

  @override
  String get editProfile_height_cm_label => 'Height (cm)';

  @override
  String get editProfile_height_ft_in_label => 'Height';

  @override
  String get editProfile_weight_label => 'Weight';

  @override
  String get editProfile_interests_sectionHeader => 'Interests & Style';

  @override
  String get editProfile_personalStyle_label => 'Personal style';

  @override
  String get editProfile_favoriteColors_label => 'Favorite colors';

  @override
  String get gender_male => 'Male';

  @override
  String get gender_female => 'Female';

  @override
  String get gender_other => 'Other';

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

  @override
  String get quest_firstSteps_title => 'First Steps into Your Digital Closet';

  @override
  String get quest_firstSteps_description =>
      'Add your first 3 tops and 3 bottoms (pants, skirts, etc.) to start receiving personalized suggestions.';

  @override
  String get quest_firstSuggestion_title => 'Your First AI-Powered Suggestion';

  @override
  String get quest_firstSuggestion_description =>
      'Let\'s see what the AI has in store for you. Get your first outfit suggestion!';

  @override
  String get quest_firstOutfit_title => 'Your First Creation';

  @override
  String get quest_firstOutfit_description =>
      'Use the Outfit Builder to create and save your first custom outfit.';

  @override
  String get quest_organizeCloset_title => 'Get Organized';

  @override
  String get quest_organizeCloset_description =>
      'Create a new closet to better organize your clothing items (e.g., for work, for sports).';

  @override
  String get quest_firstLog_title => 'Track Your Style Journey';

  @override
  String get quest_firstLog_description =>
      'Log an item or an outfit to your Journey to keep track of what you wear.';

  @override
  String get outfitsHub_title => 'Your Outfits';

  @override
  String outfitsHub_lastWorn(Object date) {
    return 'Last worn: $date';
  }

  @override
  String get outfitsHub_lastWorn_never => 'Never';

  @override
  String get outfitsHub_rename_label => 'Rename';

  @override
  String get outfitsHub_share_label => 'Share';

  @override
  String get outfitsHub_viewDetails_label => 'View full details';

  @override
  String get outfitsHub_delete_label => 'Delete';

  @override
  String get outfitsHub_rename_dialogTitle => 'Rename outfit';

  @override
  String get outfitsHub_newName_label => 'New name';

  @override
  String get outfitsHub_cancel_button => 'Cancel';

  @override
  String get outfitsHub_save_button => 'Save';

  @override
  String get outfitsHub_delete_dialogTitle => 'Confirm deletion';

  @override
  String outfitsHub_delete_dialogContent(Object outfitName) {
    return 'Permanently delete outfit \"$outfitName\"?';
  }

  @override
  String get outfitsHub_create_cardLabel => 'Create outfits';

  @override
  String get outfitsHub_create_hintTitle => 'Outfit Builder';

  @override
  String get outfitsHub_create_hintDescription =>
      'Tap here to manually mix and match your items and create your own perfect outfits.';

  @override
  String get outfitBuilder_title => 'Outfit studio';

  @override
  String get outfitBuilder_changeBg_button => 'Change background';

  @override
  String get outfitBuilder_undo_tooltip => 'Undo';

  @override
  String get outfitBuilder_redo_tooltip => 'Redo';

  @override
  String get outfitBuilder_save_dialogTitle => 'Save outfit';

  @override
  String get outfitBuilder_save_nameHint => 'Example: Weekend coffee meet-up';

  @override
  String get outfitBuilder_save_nameValidator => 'Please enter an outfit name';

  @override
  String get outfitBuilder_save_isFixedLabel => 'Fixed outfit';

  @override
  String get outfitBuilder_save_isFixedSubtitle =>
      'Items in this outfit are always worn together. Each item can only belong to one fixed outfit.';

  @override
  String get outfitBuilder_stickers_placeholder =>
      'Stickers will be available soon.';
}
