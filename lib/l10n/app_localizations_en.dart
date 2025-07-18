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
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_done => 'Done';

  @override
  String get common_today => 'Today';

  @override
  String get common_seeAll => 'See all';

  @override
  String get itemDetail_titleEdit => 'Edit item';

  @override
  String get itemDetail_titleAdd => 'Add item';

  @override
  String get itemDetail_favoriteTooltip_add => 'Add to favorites';

  @override
  String get itemDetail_favoriteTooltip_remove => 'Remove from favorites';

  @override
  String get itemDetail_deleteTooltip => 'Delete item';

  @override
  String get itemDetail_deleteDialogTitle => 'Confirm deletion';

  @override
  String itemDetail_deleteDialogContent(String itemName) {
    return 'Are you sure to permanently delete item \"$itemName\"?';
  }

  @override
  String get itemDetail_saveButton => 'Save';

  @override
  String get itemDetail_form_imageError => 'Please add a photo for the item.';

  @override
  String get itemDetail_form_editButton => 'Edit';

  @override
  String get itemDetail_form_removeBgButton => 'Remove BG';

  @override
  String get itemDetail_form_removeBgDialogTitle =>
      'Image May Have Been Processed';

  @override
  String get itemDetail_form_removeBgDialogContent =>
      'This image might already have a transparent background. Proceeding again may cause errors. Do you want to continue?';

  @override
  String get itemDetail_form_removeBgDialogContinue => 'Continue';

  @override
  String get itemDetail_form_errorReadingImage => 'Error reading image format.';

  @override
  String get itemDetail_form_timeoutError =>
      'Operation timed out after 45 seconds.';

  @override
  String itemDetail_form_unexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get itemDetail_form_nameLabel => 'Item name *';

  @override
  String get itemDetail_form_closetLabel => 'Select closet *';

  @override
  String get itemDetail_form_categoryLabel => 'Category *';

  @override
  String get itemDetail_form_categoryNoneSelected => 'None selected';

  @override
  String get itemDetail_form_colorLabel => 'Color';

  @override
  String get itemDetail_form_colorNotYet => 'Not yet';

  @override
  String get itemDetail_form_seasonLabel => 'Season';

  @override
  String get itemDetail_form_occasionLabel => 'Occasion';

  @override
  String get itemDetail_form_materialLabel => 'Material';

  @override
  String get itemDetail_form_patternLabel => 'Pattern';

  @override
  String get itemDetail_form_priceLabel => 'Price';

  @override
  String get itemDetail_form_notesLabel => 'Notes';

  @override
  String get itemBrowser_noItemsFound => 'No items found.';

  @override
  String get itemBrowser_empty => 'Your closet is empty.';

  @override
  String itemNotifier_analysis_error(Object error) {
    return 'Pre-filling information failed.\\nReason: $error';
  }

  @override
  String get itemNotifier_error_noPhoto => 'Please add a photo for the item.';

  @override
  String itemNotifier_error_createThumbnail(Object error) {
    return 'Error creating thumbnail: $error';
  }

  @override
  String get itemNotifier_save_success_updated => 'Item successfully updated.';

  @override
  String get itemNotifier_save_success_created => 'Item successfully saved.';

  @override
  String itemNotifier_delete_success(Object itemName) {
    return 'Successfully deleted item \"$itemName\".';
  }

  @override
  String itemNotifier_error_updateImage(Object error) {
    return 'Could not update image: $error';
  }

  @override
  String validation_nameTakenSingle(Object itemName) {
    return '\"$itemName\" is already taken. Please use a different name. You can add numbers to distinguish items (e.g., Shirt 1, Shirt 2...).';
  }

  @override
  String get filter_title => 'Filter';

  @override
  String get filter_closet => 'Closet';

  @override
  String get filter_allClosets => 'All closets';

  @override
  String get filter_category => 'Category';

  @override
  String get filter_allCategories => 'All categories';

  @override
  String get filter_color => 'Color';

  @override
  String get filter_season => 'Season';

  @override
  String get filter_occasion => 'Occasion';

  @override
  String get filter_material => 'Material';

  @override
  String get filter_pattern => 'Pattern';

  @override
  String get filter_clear => 'Clear filters';

  @override
  String get filter_apply => 'Apply';

  @override
  String batchAdd_title_page(Object current, Object total) {
    return 'Add item ($current/$total)';
  }

  @override
  String get batchAdd_button_previous => 'Previous';

  @override
  String get batchAdd_button_next => 'Next';

  @override
  String get batchAdd_button_saveAll => 'Save all';

  @override
  String get batchAdd_empty => 'No photos to display.';

  @override
  String batchNotifier_analysis_error(Object error) {
    return 'Pre-filling information failed for one or more items.\\nReason: $error';
  }

  @override
  String batchNotifier_validation_nameTaken(
      Object itemName, Object itemNumber) {
    return '\"$itemName\" for item $itemNumber is already taken. Please use a different name.';
  }

  @override
  String batchNotifier_validation_nameConflict(
      Object conflictNumber, Object itemName, Object itemNumber) {
    return '\"$itemName\" for item $itemNumber is already used by item $conflictNumber. Please use a different name.';
  }

  @override
  String get analysis_preparingImages => 'Preparing images...';

  @override
  String get analysis_prefillingInfo =>
      'Pre-filling information...\nThis may take a moment to complete.';

  @override
  String get analysis_maxPhotosWarning =>
      'Maximum of 10 photos selected. Extra photos were skipped.';

  @override
  String get analysis_error_pickImage =>
      'An error occurred while picking images. Please try again.';

  @override
  String get onboarding_page1_title => 'A closet full of clothes...';

  @override
  String get onboarding_page1_subtitle => '...but nothing to wear?';

  @override
  String get onboarding_page1_description =>
      'Do you often spend time wondering what to wear? Do you forget what amazing items you already own?';

  @override
  String get onboarding_page2_title => 'MinCloset\nYour Smart Closet Assistant';

  @override
  String get onboarding_page2_feature1_title => 'Digitize Your Closet';

  @override
  String get onboarding_page2_feature1_desc =>
      'Snap a photo and let AI automatically categorize your clothes.';

  @override
  String get onboarding_page2_feature2_title => 'AI Outfit Suggestions';

  @override
  String get onboarding_page2_feature2_desc =>
      'Get personalized outfit ideas based on your items and the weather.';

  @override
  String get onboarding_page2_feature3_title => 'Creative Outfit Studio';

  @override
  String get onboarding_page2_feature3_desc =>
      'Freely mix and match items to create unique looks.';

  @override
  String get onboarding_page2_feature4_title => 'Track Your Style Journey';

  @override
  String get onboarding_page2_feature4_desc =>
      'Log what you wear and discover your habits.';

  @override
  String get onboarding_page3_title => 'Let\'s get to know each other!';

  @override
  String get onboarding_page3_subtitle =>
      'Tell us your name so we can get more personal.';

  @override
  String get onboarding_page3_nameHint => 'Enter your name...';

  @override
  String get onboarding_page3_nameValidator => 'Please tell me your name';

  @override
  String get permissions_title => 'Allow Access';

  @override
  String get permissions_description =>
      'MinCloset needs some permissions to provide the best experience, including:';

  @override
  String get permissions_notifications_title => 'Notifications';

  @override
  String get permissions_notifications_desc =>
      'To remind you what to wear every day.';

  @override
  String get permissions_camera_title => 'Camera';

  @override
  String get permissions_camera_desc =>
      'To take photos and add new items to your closet.';

  @override
  String get permissions_location_title => 'Location';

  @override
  String get permissions_location_desc =>
      'To provide outfit suggestions that match the weather.';

  @override
  String get permissions_continue_button => 'Continue';

  @override
  String get validation_error_name_required => 'Please enter item name';

  @override
  String get validation_error_closet_required => 'Please select a closet';

  @override
  String get validation_error_category_required => 'Please select a category';

  @override
  String validation_error_batch_name_required(Object itemNumber) {
    return 'Please enter a name for Item $itemNumber';
  }

  @override
  String validation_error_batch_closet_required(Object itemNumber) {
    return 'Please select a closet for Item $itemNumber';
  }

  @override
  String validation_error_batch_category_required(Object itemNumber) {
    return 'Please select a category for Item $itemNumber';
  }

  @override
  String get closets_title => 'Your Closet';

  @override
  String closets_itemsSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get closets_tabAllItems => 'All Items';

  @override
  String get closets_tabByCloset => 'By Closet';

  @override
  String closetDetail_itemsSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String closetDetail_itemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get closetDetail_searchHint => 'Search in this closet...';

  @override
  String get closetDetail_noItemsFound => 'No items found.';

  @override
  String get closetDetail_emptyCloset => 'This closet is empty.';

  @override
  String get closetDetail_delete => 'Delete';

  @override
  String get closetDetail_move => 'Move';

  @override
  String get closetDetail_createOutfit => 'Create Outfit';

  @override
  String get closetDetail_confirmDeleteTitle => 'Confirm Deletion';

  @override
  String closetDetail_confirmDeleteContent(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected items',
      one: '1 selected item',
    );
    return 'Are you sure you want to permanently delete $_temp0?';
  }

  @override
  String closetDetail_moveDialogTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return 'Move $_temp0 to...';
  }

  @override
  String get closetDetail_moveErrorNoClosets =>
      'No other closets available to move to.';

  @override
  String get closetDetail_cancel => 'Cancel';

  @override
  String get closetDialog_editTitle => 'Edit closet name';

  @override
  String get closetDialog_createTitle => 'Create new closet';

  @override
  String get closetDialog_editLabel => 'New name';

  @override
  String get closetDialog_createLabel => 'Closet name';

  @override
  String get closet_error_emptyName => 'Closet name cannot be empty.';

  @override
  String get closet_error_maxLength =>
      'Closet name cannot exceed 30 characters.';

  @override
  String get closet_error_limitReached =>
      'Maximum number of closets (10) reached.';

  @override
  String get closet_error_duplicateName =>
      'A closet with this name already exists.';

  @override
  String get closet_error_notEmptyOnDelete =>
      'Closet is not empty. Move or delete items first.';

  @override
  String closet_success_created(Object closetName) {
    return 'Successfully created \"$closetName\" closet.';
  }

  @override
  String get closet_success_updated => 'Closet updated successfully.';

  @override
  String get closet_success_deleted => 'Closet deleted successfully.';

  @override
  String get closet_moveErrorNoClosets =>
      'No other closets available to move to.';

  @override
  String get allItems_searchHint => 'Search items...';

  @override
  String get allItems_filterTooltip => 'Filter';

  @override
  String get allItems_emptyCloset => 'Your closet is empty.';

  @override
  String get allItems_noItemsFound =>
      'No items found for your search or filter.';

  @override
  String get allItems_delete => 'Delete';

  @override
  String get allItems_createOutfit => 'Create Outfit';

  @override
  String get allItems_deleteDialogTitle => 'Confirm Deletion';

  @override
  String allItems_deleteDialogContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Are you sure you want to permanently delete $count selected items?',
      one: 'Are you sure you want to permanently delete 1 selected item?',
    );
    return '$_temp0';
  }

  @override
  String get byCloset_addClosetHintTitle => 'Create a New Closet';

  @override
  String get byCloset_addClosetHintDescription =>
      'Tap here to create a new closet, helping you organize your clothes for different purposes like \'Work\' or \'Gym\'.';

  @override
  String get byCloset_addNewCloset => 'Add new closet';

  @override
  String byCloset_itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: '0 items',
    );
    return '$_temp0';
  }

  @override
  String get byCloset_itemCountError => 'Error';

  @override
  String get byCloset_itemCountLoading => '...';

  @override
  String get byCloset_deleteDialogTitle => 'Confirm Deletion';

  @override
  String byCloset_deleteDialogContent(String closetName) {
    return 'Are you sure you want to delete the \"$closetName\" closet?';
  }

  @override
  String get byCloset_limitReached => 'Closet limit (10) reached.';

  @override
  String get closetForm_titleEdit => 'Edit Closet';

  @override
  String get closetForm_titleAdd => 'Add New Closet';

  @override
  String get closetForm_saveButton => 'Save';

  @override
  String get closetForm_nameLabel => 'Closet Name';

  @override
  String get closetForm_iconLabel => 'Choose Icon';

  @override
  String get closetForm_colorLabel => 'Choose Card Color';

  @override
  String get calendar_title => 'Style Journal';

  @override
  String get calendar_addLogButton => 'Add';

  @override
  String get calendar_logWearHintTitle => 'Log Your Wear';

  @override
  String get calendar_logWearHintDescription =>
      'Select a day and tap here to log what you wore.';

  @override
  String get calendar_selectOutfits => 'Select Outfits';

  @override
  String get calendar_selectItems => 'Select Items';

  @override
  String get calendar_deleteDialogTitle => 'Confirm Deletion';

  @override
  String calendar_deleteDialogContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selections',
      one: '1 selection',
    );
    return 'Are you sure you want to remove $_temp0 from this day?';
  }

  @override
  String calendar_deleteDialogContentOutfit(String outfitName) {
    return 'Are you sure you want to remove the outfit \'$outfitName\' from this day\'s journal?';
  }

  @override
  String calendar_deleteDialogContentItem(String itemName) {
    return 'Are you sure you want to remove the item \'$itemName\' from this day\'s journal?';
  }

  @override
  String get calendar_noItemsLogged => 'No items logged for this day.';

  @override
  String get calendar_outfitLabel => 'Outfit';

  @override
  String get calendar_formatMonth => 'Month';

  @override
  String get calendar_formatTwoWeeks => '2 Weeks';

  @override
  String get calendar_formatWeek => 'Week';

  @override
  String get logWear_title_items => 'Select Items';

  @override
  String get logWear_title_outfits => 'Select Outfits';

  @override
  String get logWear_noData_items => 'No items to select.';

  @override
  String get logWear_noData_outfits => 'No outfits to select.';

  @override
  String get logWear_label_outfit => 'Outfit';

  @override
  String get home_greeting => 'Hello,';

  @override
  String get home_userNameDefault => 'User';

  @override
  String get home_actionAddItem => 'Add\nItem';

  @override
  String get home_actionCreateCloset => 'Create Closet';

  @override
  String get home_actionCreateOutfits => 'Create Outfits';

  @override
  String get home_actionSavedOutfits => 'Saved Outfits';

  @override
  String get home_weeklyJournalTitle => 'Week\'s Journal';

  @override
  String get home_weeklyJournalViewMore => 'View more';

  @override
  String get home_suggestionTitle => 'Outfit suggestion';

  @override
  String get home_suggestion_showcase_description =>
      'Describe your purpose for the day (e.g., \"coffee with friends\", \"work meeting\") and tap the send button to get a personalized outfit suggestion!';

  @override
  String get home_weather_noNetwork =>
      'Weather unavailable. No network connection';

  @override
  String get mainScreen_bottomNav_home => 'Home';

  @override
  String get mainScreen_bottomNav_closets => 'Closets';

  @override
  String get mainScreen_bottomNav_addItems => 'Add items';

  @override
  String get mainScreen_bottomNav_outfits => 'Outfits';

  @override
  String get mainScreen_bottomNav_profile => 'Profile';

  @override
  String get mainScreen_addItem_takePhoto => 'Take photo';

  @override
  String get mainScreen_addItem_fromAlbum => 'From album (up to 10)';

  @override
  String get mainScreen_tutorial_welcome =>
      'Welcome to MinCloset! I\'m your personal fashion assistant.';

  @override
  String get mainScreen_tutorial_introduce =>
      'Let me introduce you to the first and most important feature!';

  @override
  String get mainScreen_tutorial_showAddItem =>
      'Let\'s start by adding your first item to the closet!';

  @override
  String get mainScreen_hint_addItem => 'Add Items';

  @override
  String get mainScreen_hint_addItem_description =>
      'Tap here to digitize your clothes by taking a photo or choosing from your library.';

  @override
  String get suggestion_purposeHint => 'Purpose? (e.g. coffee, date night...)';

  @override
  String suggestion_purposeLength(int current, int max) {
    return '$current/$max';
  }

  @override
  String get suggestion_editAndSaveButton => 'Edit & Save';

  @override
  String get suggestion_placeholder =>
      'Describe your purpose and tap the send button to get suggestions!';

  @override
  String get suggestion_weatherUnavailable =>
      'Weather data unavailable. This is a general suggestion.';

  @override
  String suggestion_lastUpdated(String datetime) {
    return 'Last updated: $datetime';
  }

  @override
  String get getOutfitSuggestion_errorManualLocationMissing =>
      'Your manually selected location data is missing. Please select your city again in the settings.';

  @override
  String get getOutfitSuggestion_errorLocationServicesDisabled =>
      'Location services are disabled. Please enable it in your device settings.';

  @override
  String get getOutfitSuggestion_errorLocationPermissionDenied =>
      'Location permissions are denied. Please enable it for MinCloset in your device settings.';

  @override
  String get getOutfitSuggestion_errorLocationUndetermined =>
      'Could not determine your location to get weather data. Please check your device settings or select a location manually.';

  @override
  String get getOutfitSuggestion_errorNotEnoughItems =>
      'Please add at least 3 tops and 3 bottoms/skirts to your closet to receive suggestions.';

  @override
  String get getOutfitSuggestion_defaultSelectedLocation => 'Selected Location';

  @override
  String get getOutfitSuggestion_defaultCurrentLocation => 'Current Location';

  @override
  String get getOutfitSuggestion_defaultNotSpecified => 'Not specified';

  @override
  String get getOutfitSuggestion_defaultAnyStyle => 'Any style';

  @override
  String get getOutfitSuggestion_defaultAnyColor => 'Any color';

  @override
  String get category_tops => 'Tops';

  @override
  String get category_tops_tshirts => 'T-shirts';

  @override
  String get category_tops_long_sleeve => 'Long Sleeve';

  @override
  String get category_tops_sleeveless => 'Sleeveless';

  @override
  String get category_tops_polo_shirts => 'Polo Shirts';

  @override
  String get category_tops_tanks_camis => 'Tanks & Camis';

  @override
  String get category_tops_crop_tops => 'Crop Tops';

  @override
  String get category_tops_blouses => 'Blouses';

  @override
  String get category_tops_shirts => 'Shirts';

  @override
  String get category_tops_sweatshirts => 'Sweatshirts';

  @override
  String get category_tops_hoodies => 'Hoodies';

  @override
  String get category_tops_sweaters => 'Sweaters';

  @override
  String get category_tops_other => 'Other';

  @override
  String get category_bottoms => 'Bottoms';

  @override
  String get category_bottoms_jeans => 'Jeans';

  @override
  String get category_bottoms_trousers => 'Trousers';

  @override
  String get category_bottoms_dress_pants => 'Dress Pants';

  @override
  String get category_bottoms_track_pants => 'Track Pants';

  @override
  String get category_bottoms_leggings => 'Leggings';

  @override
  String get category_bottoms_shorts => 'Shorts';

  @override
  String get category_bottoms_other => 'Other';

  @override
  String get category_dresses_jumpsuits => 'Dresses/Jumpsuits';

  @override
  String get category_dresses_jumpsuits_mini_skirts => 'Mini Skirts';

  @override
  String get category_dresses_jumpsuits_midi_skirts => 'Midi Skirts';

  @override
  String get category_dresses_jumpsuits_maxi_skirts => 'Maxi Skirts';

  @override
  String get category_dresses_jumpsuits_day_dresses => 'Day Dresses';

  @override
  String get category_dresses_jumpsuits_tshirt_dresses => 'T-shirt Dresses';

  @override
  String get category_dresses_jumpsuits_shirt_dresses => 'Shirt Dresses';

  @override
  String get category_dresses_jumpsuits_sweatshirt_dresses =>
      'Sweatshirt Dresses';

  @override
  String get category_dresses_jumpsuits_sweater_dresses => 'Sweater Dresses';

  @override
  String get category_dresses_jumpsuits_jacket_dresses => 'Jacket Dresses';

  @override
  String get category_dresses_jumpsuits_suspender_dresses =>
      'Suspender Dresses';

  @override
  String get category_dresses_jumpsuits_jumpsuits => 'Jumpsuits';

  @override
  String get category_dresses_jumpsuits_party_dresses => 'Party Dresses';

  @override
  String get category_dresses_jumpsuits_other => 'Other';

  @override
  String get category_outerwear => 'Outerwear';

  @override
  String get category_outerwear_coats => 'Coats';

  @override
  String get category_outerwear_trench_coats => 'Trench Coats';

  @override
  String get category_outerwear_fur_coats => 'Fur Coats';

  @override
  String get category_outerwear_shearling_coats => 'Shearling Coats';

  @override
  String get category_outerwear_blazers => 'Blazers';

  @override
  String get category_outerwear_jackets => 'Jackets';

  @override
  String get category_outerwear_blousons => 'Blousons';

  @override
  String get category_outerwear_varsity_jackets => 'Varsity Jackets';

  @override
  String get category_outerwear_trucker_jackets => 'Trucker Jackets';

  @override
  String get category_outerwear_biker_jackets => 'Biker Jackets';

  @override
  String get category_outerwear_cardigans => 'Cardigans';

  @override
  String get category_outerwear_zipup_hoodies => 'Zip-up Hoodies';

  @override
  String get category_outerwear_field_jackets => 'Field Jackets';

  @override
  String get category_outerwear_track_jackets => 'Track Jackets';

  @override
  String get category_outerwear_fleece_jackets => 'Fleece Jackets';

  @override
  String get category_outerwear_puffer_down_jackets => 'Puffer/Down Jackets';

  @override
  String get category_outerwear_vests => 'Vests';

  @override
  String get category_outerwear_other => 'Other';

  @override
  String get category_footwear => 'Footwear';

  @override
  String get category_footwear_sneakers => 'Sneakers';

  @override
  String get category_footwear_slipons => 'Slip-Ons';

  @override
  String get category_footwear_sports_shoes => 'Sports Shoes';

  @override
  String get category_footwear_hiking_shoes => 'Hiking Shoes';

  @override
  String get category_footwear_boots => 'Boots';

  @override
  String get category_footwear_combat_boots => 'Combat Boots';

  @override
  String get category_footwear_ugg_boots => 'Ugg Boots';

  @override
  String get category_footwear_loafers_mules => 'Loafers & Mules';

  @override
  String get category_footwear_boat_shoes => 'Boat Shoes';

  @override
  String get category_footwear_flat_shoes => 'Flat Shoes';

  @override
  String get category_footwear_heels => 'Heels';

  @override
  String get category_footwear_sandals => 'Sandals';

  @override
  String get category_footwear_heeled_sandals => 'Heeled Sandals';

  @override
  String get category_footwear_slides => 'Slides';

  @override
  String get category_footwear_other => 'Other';

  @override
  String get category_bags => 'Bags';

  @override
  String get category_bags_tote_bags => 'Tote Bags';

  @override
  String get category_bags_shoulder_bags => 'Shoulder Bags';

  @override
  String get category_bags_crossbody_bags => 'Crossbody Bags';

  @override
  String get category_bags_waist_bags => 'Waist Bags';

  @override
  String get category_bags_canvas_bags => 'Canvas Bags';

  @override
  String get category_bags_backpacks => 'Backpacks';

  @override
  String get category_bags_duffel_bags => 'Duffel Bags';

  @override
  String get category_bags_clutches => 'Clutches';

  @override
  String get category_bags_briefcases => 'Briefcases';

  @override
  String get category_bags_drawstring_bags => 'Drawstring Bags';

  @override
  String get category_bags_suitcases => 'Suitcases';

  @override
  String get category_bags_other => 'Other';

  @override
  String get category_hats => 'Hats';

  @override
  String get category_hats_caps => 'Caps';

  @override
  String get category_hats_hats => 'Hats';

  @override
  String get category_hats_beanies => 'Beanies';

  @override
  String get category_hats_berets => 'Berets';

  @override
  String get category_hats_fedoras => 'Fedoras';

  @override
  String get category_hats_sun_hats => 'Sun Hats';

  @override
  String get category_hats_other => 'Other';

  @override
  String get category_other => 'Other';

  @override
  String get season_spring => 'Spring';

  @override
  String get season_summer => 'Summer';

  @override
  String get season_autumn => 'Autumn';

  @override
  String get season_winter => 'Winter';

  @override
  String get occasion_everyday => 'Everyday';

  @override
  String get occasion_work => 'Work';

  @override
  String get occasion_date => 'Date';

  @override
  String get occasion_formal => 'Formal';

  @override
  String get occasion_travel => 'Travel';

  @override
  String get occasion_home => 'Home';

  @override
  String get occasion_party => 'Party';

  @override
  String get occasion_sport => 'Sport';

  @override
  String get occasion_special => 'Special';

  @override
  String get occasion_school => 'School';

  @override
  String get occasion_beach => 'Beach';

  @override
  String get occasion_other => 'Other';

  @override
  String get material_cotton => 'Cotton';

  @override
  String get material_linen => 'Linen';

  @override
  String get material_wool => 'Wool';

  @override
  String get material_silk => 'Silk';

  @override
  String get material_polyester => 'Polyester';

  @override
  String get material_nylon => 'Nylon';

  @override
  String get material_denim => 'Denim';

  @override
  String get material_leather => 'Leather';

  @override
  String get material_other => 'Other';

  @override
  String get pattern_solid => 'Solid';

  @override
  String get pattern_striped => 'Striped';

  @override
  String get pattern_plaid => 'Plaid';

  @override
  String get pattern_dotted => 'Dotted';

  @override
  String get pattern_chevron => 'Chevron';

  @override
  String get pattern_animal => 'Animal';

  @override
  String get pattern_floral => 'Floral';

  @override
  String get pattern_typography => 'Typography';

  @override
  String get pattern_other => 'Other';

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

  @override
  String get outfitBuilder_save_success => 'Outfit saved successfully!';

  @override
  String get outfitDetail_fixedOutfit_title => 'Fixed outfit';

  @override
  String get outfitDetail_fixedOutfit_description =>
      'Items in this outfit are always worn together. Each item can only belong to one fixed outfit.';

  @override
  String get outfitMenu_rename => 'Rename';

  @override
  String get outfitMenu_share => 'Share';

  @override
  String get outfitMenu_delete => 'Delete';

  @override
  String get outfitMenu_rename_dialogTitle => 'Rename outfit';

  @override
  String get outfitMenu_rename_dialogLabel => 'New name';

  @override
  String get outfitMenu_rename_success => 'Outfit name updated.';

  @override
  String outfitMenu_share_error(Object error) {
    return 'Could not share: $error';
  }

  @override
  String get outfitMenu_delete_dialogTitle => 'Confirm deletion';

  @override
  String outfitMenu_delete_dialogContent(Object outfitName) {
    return 'Permanently delete outfit \"$outfitName\"?';
  }

  @override
  String outfitMenu_delete_success(Object outfitName) {
    return 'Deleted outfit \"$outfitName\".';
  }

  @override
  String get outfitMenu_delete_error =>
      'Failed to delete outfit. Please try again.';

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
  String get settings_dailyReminderDescription =>
      'Receive a daily reminder to log your outfit.';

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
  String get citySelection_title => 'Select Location';

  @override
  String get citySelection_autoDetect => 'Auto-detect';

  @override
  String get citySelection_autoDetect_subtitle => 'Use your current location';

  @override
  String get citySelection_manual => 'Manually';

  @override
  String get citySelection_searchHint => 'Search city/location…';

  @override
  String get about_title => 'About & Legal';

  @override
  String get about_privacy_title => 'Privacy Policy';

  @override
  String get about_privacy_subtitle => 'How we handle your data.';

  @override
  String get about_terms_title => 'Terms of Use';

  @override
  String get about_terms_subtitle => 'Rules for using the app.';

  @override
  String get about_loadingVersion => 'Loading version...';

  @override
  String about_version(Object buildNumber, Object version) {
    return 'Version $version ($buildNumber)';
  }

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
  String get achievementDialog_title => 'ACHIEVEMENT UNLOCKED!';

  @override
  String get achievementDialog_button => 'Awesome!';

  @override
  String get badgeDetail_completedQuests => 'Completed Quests';

  @override
  String get badgeDetail_noQuests => 'No quests found for this badge.';

  @override
  String get mascot_newQuest => 'New Quest!';

  @override
  String get mascot_questCompleted => 'Quest Completed!';

  @override
  String stats_label_item(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Items',
      one: 'Item',
    );
    return '$_temp0';
  }

  @override
  String stats_label_closet(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Closets',
      one: 'Closet',
    );
    return '$_temp0';
  }

  @override
  String stats_label_outfit(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Outfits',
      one: 'Outfit',
    );
    return '$_temp0';
  }

  @override
  String get insights_title => 'Closet Insights';

  @override
  String get insights_exclusive => 'MINCLOSET EXCLUSIVE';

  @override
  String insights_journeyTitle(Object userName) {
    return 'Inside $userName\'s Style Journey';
  }

  @override
  String get insights_mostLoved => 'The Most-Loved Pieces';

  @override
  String get insights_smartestInvestments => 'Smartest Investments';

  @override
  String get insights_rediscoverCloset => 'Rediscover Your Closet';

  @override
  String get insights_investmentFocus => 'Investment Focus';

  @override
  String get insights_noData => 'No insights available.';

  @override
  String get insights_error_noLogs =>
      'Please add items or outfits to Style journal first!';

  @override
  String get insights_goToJournal => 'Go to Style Journal';

  @override
  String get insights_mostWorn_noData =>
      'You haven\'t logged any worn items yet. Start your style journal today!';

  @override
  String get insights_bestValue_noData =>
      'Wear items you\'ve added a price to and your smartest investments will appear here!';

  @override
  String get insights_addPrices => 'Add Prices to Items';

  @override
  String insights_wears(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wears',
      one: '1 wear',
    );
    return '$_temp0';
  }

  @override
  String insights_costPerWear(Object price) {
    return '$price/wear';
  }

  @override
  String get insights_forgottenItem_subtitle => 'Not worn yet. Give it a try!';

  @override
  String get insights_wearToday => 'Wear Today';

  @override
  String insights_wearToday_success(Object itemName) {
    return 'Added \"$itemName\" to today\'s journal!';
  }

  @override
  String get removeBg_title => 'Remove Background';

  @override
  String get removeBg_processing => 'Processing, please wait...';

  @override
  String get removeBg_error_process => 'Could not process image.';

  @override
  String removeBg_error_generic(Object error) {
    return 'Error processing image: $error';
  }

  @override
  String get proImageEditor_common_done => 'Done';

  @override
  String get proImageEditor_common_back => 'Back';

  @override
  String get proImageEditor_common_cancel => 'Cancel';

  @override
  String get proImageEditor_common_undo => 'Undo';

  @override
  String get proImageEditor_common_redo => 'Redo';

  @override
  String get proImageEditor_common_remove => 'Remove';

  @override
  String get proImageEditor_common_edit => 'Edit';

  @override
  String get proImageEditor_common_rotateScale => 'Rotate and Scale';

  @override
  String get proImageEditor_common_more => 'More';

  @override
  String get proImageEditor_crop_title => 'Crop/ Rotate';

  @override
  String get proImageEditor_crop_rotate => 'Rotate';

  @override
  String get proImageEditor_crop_flip => 'Flip';

  @override
  String get proImageEditor_crop_ratio => 'Ratio';

  @override
  String get proImageEditor_crop_reset => 'Reset';

  @override
  String get proImageEditor_filter_title => 'Filter';

  @override
  String get proImageEditor_filter_noFilter => 'No Filter';

  @override
  String get proImageEditor_tune_title => 'Tune';

  @override
  String get proImageEditor_tune_brightness => 'Brightness';

  @override
  String get proImageEditor_tune_contrast => 'Contrast';

  @override
  String get proImageEditor_tune_saturation => 'Saturation';

  @override
  String get proImageEditor_tune_exposure => 'Exposure';

  @override
  String get proImageEditor_tune_hue => 'Hue';

  @override
  String get proImageEditor_tune_temperature => 'Temperature';

  @override
  String get proImageEditor_tune_sharpness => 'Sharpness';

  @override
  String get proImageEditor_tune_fade => 'Fade';

  @override
  String get proImageEditor_tune_luminance => 'Luminance';

  @override
  String get proImageEditor_blur_title => 'Blur';

  @override
  String get proImageEditor_sticker_title => 'Stickers';

  @override
  String get proImageEditor_paint_title => 'Paint';

  @override
  String get proImageEditor_text_title => 'Text';

  @override
  String get proImageEditor_text_hint => 'Enter text';

  @override
  String get proImageEditor_emoji_title => 'Emoji';
}
