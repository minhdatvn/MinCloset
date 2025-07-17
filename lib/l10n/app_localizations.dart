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

  /// No description provided for @banner_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{itemName}\".'**
  String banner_deleteSuccess(Object itemName);

  /// No description provided for @banner_deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete. Please try again.'**
  String get banner_deleteFailed;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get common_seeAll;

  /// No description provided for @category_tops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get category_tops;

  /// No description provided for @category_tops_tshirts.
  ///
  /// In en, this message translates to:
  /// **'T-shirts'**
  String get category_tops_tshirts;

  /// No description provided for @category_tops_long_sleeve.
  ///
  /// In en, this message translates to:
  /// **'Long Sleeve'**
  String get category_tops_long_sleeve;

  /// No description provided for @category_tops_sleeveless.
  ///
  /// In en, this message translates to:
  /// **'Sleeveless'**
  String get category_tops_sleeveless;

  /// No description provided for @category_tops_polo_shirts.
  ///
  /// In en, this message translates to:
  /// **'Polo Shirts'**
  String get category_tops_polo_shirts;

  /// No description provided for @category_tops_tanks_camis.
  ///
  /// In en, this message translates to:
  /// **'Tanks & Camis'**
  String get category_tops_tanks_camis;

  /// No description provided for @category_tops_crop_tops.
  ///
  /// In en, this message translates to:
  /// **'Crop Tops'**
  String get category_tops_crop_tops;

  /// No description provided for @category_tops_blouses.
  ///
  /// In en, this message translates to:
  /// **'Blouses'**
  String get category_tops_blouses;

  /// No description provided for @category_tops_shirts.
  ///
  /// In en, this message translates to:
  /// **'Shirts'**
  String get category_tops_shirts;

  /// No description provided for @category_tops_sweatshirts.
  ///
  /// In en, this message translates to:
  /// **'Sweatshirts'**
  String get category_tops_sweatshirts;

  /// No description provided for @category_tops_hoodies.
  ///
  /// In en, this message translates to:
  /// **'Hoodies'**
  String get category_tops_hoodies;

  /// No description provided for @category_tops_sweaters.
  ///
  /// In en, this message translates to:
  /// **'Sweaters'**
  String get category_tops_sweaters;

  /// No description provided for @category_tops_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_tops_other;

  /// No description provided for @category_bottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get category_bottoms;

  /// No description provided for @category_bottoms_jeans.
  ///
  /// In en, this message translates to:
  /// **'Jeans'**
  String get category_bottoms_jeans;

  /// No description provided for @category_bottoms_trousers.
  ///
  /// In en, this message translates to:
  /// **'Trousers'**
  String get category_bottoms_trousers;

  /// No description provided for @category_bottoms_dress_pants.
  ///
  /// In en, this message translates to:
  /// **'Dress Pants'**
  String get category_bottoms_dress_pants;

  /// No description provided for @category_bottoms_track_pants.
  ///
  /// In en, this message translates to:
  /// **'Track Pants'**
  String get category_bottoms_track_pants;

  /// No description provided for @category_bottoms_leggings.
  ///
  /// In en, this message translates to:
  /// **'Leggings'**
  String get category_bottoms_leggings;

  /// No description provided for @category_bottoms_shorts.
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get category_bottoms_shorts;

  /// No description provided for @category_bottoms_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_bottoms_other;

  /// No description provided for @category_dresses_jumpsuits.
  ///
  /// In en, this message translates to:
  /// **'Dresses/Jumpsuits'**
  String get category_dresses_jumpsuits;

  /// No description provided for @category_dresses_jumpsuits_mini_skirts.
  ///
  /// In en, this message translates to:
  /// **'Mini Skirts'**
  String get category_dresses_jumpsuits_mini_skirts;

  /// No description provided for @category_dresses_jumpsuits_midi_skirts.
  ///
  /// In en, this message translates to:
  /// **'Midi Skirts'**
  String get category_dresses_jumpsuits_midi_skirts;

  /// No description provided for @category_dresses_jumpsuits_maxi_skirts.
  ///
  /// In en, this message translates to:
  /// **'Maxi Skirts'**
  String get category_dresses_jumpsuits_maxi_skirts;

  /// No description provided for @category_dresses_jumpsuits_day_dresses.
  ///
  /// In en, this message translates to:
  /// **'Day Dresses'**
  String get category_dresses_jumpsuits_day_dresses;

  /// No description provided for @category_dresses_jumpsuits_tshirt_dresses.
  ///
  /// In en, this message translates to:
  /// **'T-shirt Dresses'**
  String get category_dresses_jumpsuits_tshirt_dresses;

  /// No description provided for @category_dresses_jumpsuits_shirt_dresses.
  ///
  /// In en, this message translates to:
  /// **'Shirt Dresses'**
  String get category_dresses_jumpsuits_shirt_dresses;

  /// No description provided for @category_dresses_jumpsuits_sweatshirt_dresses.
  ///
  /// In en, this message translates to:
  /// **'Sweatshirt Dresses'**
  String get category_dresses_jumpsuits_sweatshirt_dresses;

  /// No description provided for @category_dresses_jumpsuits_sweater_dresses.
  ///
  /// In en, this message translates to:
  /// **'Sweater Dresses'**
  String get category_dresses_jumpsuits_sweater_dresses;

  /// No description provided for @category_dresses_jumpsuits_jacket_dresses.
  ///
  /// In en, this message translates to:
  /// **'Jacket Dresses'**
  String get category_dresses_jumpsuits_jacket_dresses;

  /// No description provided for @category_dresses_jumpsuits_suspender_dresses.
  ///
  /// In en, this message translates to:
  /// **'Suspender Dresses'**
  String get category_dresses_jumpsuits_suspender_dresses;

  /// No description provided for @category_dresses_jumpsuits_jumpsuits.
  ///
  /// In en, this message translates to:
  /// **'Jumpsuits'**
  String get category_dresses_jumpsuits_jumpsuits;

  /// No description provided for @category_dresses_jumpsuits_party_dresses.
  ///
  /// In en, this message translates to:
  /// **'Party Dresses'**
  String get category_dresses_jumpsuits_party_dresses;

  /// No description provided for @category_dresses_jumpsuits_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_dresses_jumpsuits_other;

  /// No description provided for @category_outerwear.
  ///
  /// In en, this message translates to:
  /// **'Outerwear'**
  String get category_outerwear;

  /// No description provided for @category_outerwear_coats.
  ///
  /// In en, this message translates to:
  /// **'Coats'**
  String get category_outerwear_coats;

  /// No description provided for @category_outerwear_trench_coats.
  ///
  /// In en, this message translates to:
  /// **'Trench Coats'**
  String get category_outerwear_trench_coats;

  /// No description provided for @category_outerwear_fur_coats.
  ///
  /// In en, this message translates to:
  /// **'Fur Coats'**
  String get category_outerwear_fur_coats;

  /// No description provided for @category_outerwear_shearling_coats.
  ///
  /// In en, this message translates to:
  /// **'Shearling Coats'**
  String get category_outerwear_shearling_coats;

  /// No description provided for @category_outerwear_blazers.
  ///
  /// In en, this message translates to:
  /// **'Blazers'**
  String get category_outerwear_blazers;

  /// No description provided for @category_outerwear_jackets.
  ///
  /// In en, this message translates to:
  /// **'Jackets'**
  String get category_outerwear_jackets;

  /// No description provided for @category_outerwear_blousons.
  ///
  /// In en, this message translates to:
  /// **'Blousons'**
  String get category_outerwear_blousons;

  /// No description provided for @category_outerwear_varsity_jackets.
  ///
  /// In en, this message translates to:
  /// **'Varsity Jackets'**
  String get category_outerwear_varsity_jackets;

  /// No description provided for @category_outerwear_trucker_jackets.
  ///
  /// In en, this message translates to:
  /// **'Trucker Jackets'**
  String get category_outerwear_trucker_jackets;

  /// No description provided for @category_outerwear_biker_jackets.
  ///
  /// In en, this message translates to:
  /// **'Biker Jackets'**
  String get category_outerwear_biker_jackets;

  /// No description provided for @category_outerwear_cardigans.
  ///
  /// In en, this message translates to:
  /// **'Cardigans'**
  String get category_outerwear_cardigans;

  /// No description provided for @category_outerwear_zipup_hoodies.
  ///
  /// In en, this message translates to:
  /// **'Zip-up Hoodies'**
  String get category_outerwear_zipup_hoodies;

  /// No description provided for @category_outerwear_field_jackets.
  ///
  /// In en, this message translates to:
  /// **'Field Jackets'**
  String get category_outerwear_field_jackets;

  /// No description provided for @category_outerwear_track_jackets.
  ///
  /// In en, this message translates to:
  /// **'Track Jackets'**
  String get category_outerwear_track_jackets;

  /// No description provided for @category_outerwear_fleece_jackets.
  ///
  /// In en, this message translates to:
  /// **'Fleece Jackets'**
  String get category_outerwear_fleece_jackets;

  /// No description provided for @category_outerwear_puffer_down_jackets.
  ///
  /// In en, this message translates to:
  /// **'Puffer/Down Jackets'**
  String get category_outerwear_puffer_down_jackets;

  /// No description provided for @category_outerwear_vests.
  ///
  /// In en, this message translates to:
  /// **'Vests'**
  String get category_outerwear_vests;

  /// No description provided for @category_outerwear_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_outerwear_other;

  /// No description provided for @category_footwear.
  ///
  /// In en, this message translates to:
  /// **'Footwear'**
  String get category_footwear;

  /// No description provided for @category_footwear_sneakers.
  ///
  /// In en, this message translates to:
  /// **'Sneakers'**
  String get category_footwear_sneakers;

  /// No description provided for @category_footwear_slipons.
  ///
  /// In en, this message translates to:
  /// **'Slip-Ons'**
  String get category_footwear_slipons;

  /// No description provided for @category_footwear_sports_shoes.
  ///
  /// In en, this message translates to:
  /// **'Sports Shoes'**
  String get category_footwear_sports_shoes;

  /// No description provided for @category_footwear_hiking_shoes.
  ///
  /// In en, this message translates to:
  /// **'Hiking Shoes'**
  String get category_footwear_hiking_shoes;

  /// No description provided for @category_footwear_boots.
  ///
  /// In en, this message translates to:
  /// **'Boots'**
  String get category_footwear_boots;

  /// No description provided for @category_footwear_combat_boots.
  ///
  /// In en, this message translates to:
  /// **'Combat Boots'**
  String get category_footwear_combat_boots;

  /// No description provided for @category_footwear_ugg_boots.
  ///
  /// In en, this message translates to:
  /// **'Ugg Boots'**
  String get category_footwear_ugg_boots;

  /// No description provided for @category_footwear_loafers_mules.
  ///
  /// In en, this message translates to:
  /// **'Loafers & Mules'**
  String get category_footwear_loafers_mules;

  /// No description provided for @category_footwear_boat_shoes.
  ///
  /// In en, this message translates to:
  /// **'Boat Shoes'**
  String get category_footwear_boat_shoes;

  /// No description provided for @category_footwear_flat_shoes.
  ///
  /// In en, this message translates to:
  /// **'Flat Shoes'**
  String get category_footwear_flat_shoes;

  /// No description provided for @category_footwear_heels.
  ///
  /// In en, this message translates to:
  /// **'Heels'**
  String get category_footwear_heels;

  /// No description provided for @category_footwear_sandals.
  ///
  /// In en, this message translates to:
  /// **'Sandals'**
  String get category_footwear_sandals;

  /// No description provided for @category_footwear_heeled_sandals.
  ///
  /// In en, this message translates to:
  /// **'Heeled Sandals'**
  String get category_footwear_heeled_sandals;

  /// No description provided for @category_footwear_slides.
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get category_footwear_slides;

  /// No description provided for @category_footwear_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_footwear_other;

  /// No description provided for @category_bags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get category_bags;

  /// No description provided for @category_bags_tote_bags.
  ///
  /// In en, this message translates to:
  /// **'Tote Bags'**
  String get category_bags_tote_bags;

  /// No description provided for @category_bags_shoulder_bags.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Bags'**
  String get category_bags_shoulder_bags;

  /// No description provided for @category_bags_crossbody_bags.
  ///
  /// In en, this message translates to:
  /// **'Crossbody Bags'**
  String get category_bags_crossbody_bags;

  /// No description provided for @category_bags_waist_bags.
  ///
  /// In en, this message translates to:
  /// **'Waist Bags'**
  String get category_bags_waist_bags;

  /// No description provided for @category_bags_canvas_bags.
  ///
  /// In en, this message translates to:
  /// **'Canvas Bags'**
  String get category_bags_canvas_bags;

  /// No description provided for @category_bags_backpacks.
  ///
  /// In en, this message translates to:
  /// **'Backpacks'**
  String get category_bags_backpacks;

  /// No description provided for @category_bags_duffel_bags.
  ///
  /// In en, this message translates to:
  /// **'Duffel Bags'**
  String get category_bags_duffel_bags;

  /// No description provided for @category_bags_clutches.
  ///
  /// In en, this message translates to:
  /// **'Clutches'**
  String get category_bags_clutches;

  /// No description provided for @category_bags_briefcases.
  ///
  /// In en, this message translates to:
  /// **'Briefcases'**
  String get category_bags_briefcases;

  /// No description provided for @category_bags_drawstring_bags.
  ///
  /// In en, this message translates to:
  /// **'Drawstring Bags'**
  String get category_bags_drawstring_bags;

  /// No description provided for @category_bags_suitcases.
  ///
  /// In en, this message translates to:
  /// **'Suitcases'**
  String get category_bags_suitcases;

  /// No description provided for @category_bags_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_bags_other;

  /// No description provided for @category_hats.
  ///
  /// In en, this message translates to:
  /// **'Hats'**
  String get category_hats;

  /// No description provided for @category_hats_caps.
  ///
  /// In en, this message translates to:
  /// **'Caps'**
  String get category_hats_caps;

  /// No description provided for @category_hats_hats.
  ///
  /// In en, this message translates to:
  /// **'Hats'**
  String get category_hats_hats;

  /// No description provided for @category_hats_beanies.
  ///
  /// In en, this message translates to:
  /// **'Beanies'**
  String get category_hats_beanies;

  /// No description provided for @category_hats_berets.
  ///
  /// In en, this message translates to:
  /// **'Berets'**
  String get category_hats_berets;

  /// No description provided for @category_hats_fedoras.
  ///
  /// In en, this message translates to:
  /// **'Fedoras'**
  String get category_hats_fedoras;

  /// No description provided for @category_hats_sun_hats.
  ///
  /// In en, this message translates to:
  /// **'Sun Hats'**
  String get category_hats_sun_hats;

  /// No description provided for @category_hats_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_hats_other;

  /// No description provided for @category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// No description provided for @season_spring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get season_spring;

  /// No description provided for @season_summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get season_summer;

  /// No description provided for @season_autumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get season_autumn;

  /// No description provided for @season_winter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get season_winter;

  /// No description provided for @occasion_everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get occasion_everyday;

  /// No description provided for @occasion_work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get occasion_work;

  /// No description provided for @occasion_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get occasion_date;

  /// No description provided for @occasion_formal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get occasion_formal;

  /// No description provided for @occasion_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get occasion_travel;

  /// No description provided for @occasion_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get occasion_home;

  /// No description provided for @occasion_party.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get occasion_party;

  /// No description provided for @occasion_sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get occasion_sport;

  /// No description provided for @occasion_special.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get occasion_special;

  /// No description provided for @occasion_school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get occasion_school;

  /// No description provided for @occasion_beach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get occasion_beach;

  /// No description provided for @occasion_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get occasion_other;

  /// No description provided for @material_cotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get material_cotton;

  /// No description provided for @material_linen.
  ///
  /// In en, this message translates to:
  /// **'Linen'**
  String get material_linen;

  /// No description provided for @material_wool.
  ///
  /// In en, this message translates to:
  /// **'Wool'**
  String get material_wool;

  /// No description provided for @material_silk.
  ///
  /// In en, this message translates to:
  /// **'Silk'**
  String get material_silk;

  /// No description provided for @material_polyester.
  ///
  /// In en, this message translates to:
  /// **'Polyester'**
  String get material_polyester;

  /// No description provided for @material_nylon.
  ///
  /// In en, this message translates to:
  /// **'Nylon'**
  String get material_nylon;

  /// No description provided for @material_denim.
  ///
  /// In en, this message translates to:
  /// **'Denim'**
  String get material_denim;

  /// No description provided for @material_leather.
  ///
  /// In en, this message translates to:
  /// **'Leather'**
  String get material_leather;

  /// No description provided for @material_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get material_other;

  /// No description provided for @pattern_solid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get pattern_solid;

  /// No description provided for @pattern_striped.
  ///
  /// In en, this message translates to:
  /// **'Striped'**
  String get pattern_striped;

  /// No description provided for @pattern_plaid.
  ///
  /// In en, this message translates to:
  /// **'Plaid'**
  String get pattern_plaid;

  /// No description provided for @pattern_dotted.
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get pattern_dotted;

  /// No description provided for @pattern_chevron.
  ///
  /// In en, this message translates to:
  /// **'Chevron'**
  String get pattern_chevron;

  /// No description provided for @pattern_animal.
  ///
  /// In en, this message translates to:
  /// **'Animal'**
  String get pattern_animal;

  /// No description provided for @pattern_floral.
  ///
  /// In en, this message translates to:
  /// **'Floral'**
  String get pattern_floral;

  /// No description provided for @pattern_typography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get pattern_typography;

  /// No description provided for @pattern_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pattern_other;

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

  /// No description provided for @settings_dailyReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive a daily reminder to log your outfit.'**
  String get settings_dailyReminderDescription;

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

  /// No description provided for @citySelection_title.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get citySelection_title;

  /// No description provided for @citySelection_autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect'**
  String get citySelection_autoDetect;

  /// No description provided for @citySelection_autoDetect_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your current location'**
  String get citySelection_autoDetect_subtitle;

  /// No description provided for @citySelection_manual.
  ///
  /// In en, this message translates to:
  /// **'Manually'**
  String get citySelection_manual;

  /// No description provided for @citySelection_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city/location…'**
  String get citySelection_searchHint;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About & Legal'**
  String get about_title;

  /// No description provided for @about_privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get about_privacy_title;

  /// No description provided for @about_privacy_subtitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data.'**
  String get about_privacy_subtitle;

  /// No description provided for @about_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get about_terms_title;

  /// No description provided for @about_terms_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules for using the app.'**
  String get about_terms_subtitle;

  /// No description provided for @about_loadingVersion.
  ///
  /// In en, this message translates to:
  /// **'Loading version...'**
  String get about_loadingVersion;

  /// No description provided for @about_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({buildNumber})'**
  String about_version(Object buildNumber, Object version);

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

  /// No description provided for @achievementDialog_title.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT UNLOCKED!'**
  String get achievementDialog_title;

  /// No description provided for @achievementDialog_button.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get achievementDialog_button;

  /// No description provided for @badgeDetail_completedQuests.
  ///
  /// In en, this message translates to:
  /// **'Completed Quests'**
  String get badgeDetail_completedQuests;

  /// No description provided for @badgeDetail_noQuests.
  ///
  /// In en, this message translates to:
  /// **'No quests found for this badge.'**
  String get badgeDetail_noQuests;

  /// No description provided for @mascot_newQuest.
  ///
  /// In en, this message translates to:
  /// **'New Quest!'**
  String get mascot_newQuest;

  /// No description provided for @mascot_questCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quest Completed!'**
  String get mascot_questCompleted;

  /// No description provided for @stats_label_item.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Item} other{Items}}'**
  String stats_label_item(num count);

  /// No description provided for @stats_label_closet.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Closet} other{Closets}}'**
  String stats_label_closet(num count);

  /// No description provided for @stats_label_outfit.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Outfit} other{Outfits}}'**
  String stats_label_outfit(num count);

  /// No description provided for @insights_title.
  ///
  /// In en, this message translates to:
  /// **'Closet Insights'**
  String get insights_title;

  /// No description provided for @insights_exclusive.
  ///
  /// In en, this message translates to:
  /// **'MINCLOSET EXCLUSIVE'**
  String get insights_exclusive;

  /// No description provided for @insights_journeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Inside {userName}\'s Style Journey'**
  String insights_journeyTitle(Object userName);

  /// No description provided for @insights_mostLoved.
  ///
  /// In en, this message translates to:
  /// **'The Most-Loved Pieces'**
  String get insights_mostLoved;

  /// No description provided for @insights_smartestInvestments.
  ///
  /// In en, this message translates to:
  /// **'Smartest Investments'**
  String get insights_smartestInvestments;

  /// No description provided for @insights_rediscoverCloset.
  ///
  /// In en, this message translates to:
  /// **'Rediscover Your Closet'**
  String get insights_rediscoverCloset;

  /// No description provided for @insights_investmentFocus.
  ///
  /// In en, this message translates to:
  /// **'Investment Focus'**
  String get insights_investmentFocus;

  /// No description provided for @insights_noData.
  ///
  /// In en, this message translates to:
  /// **'No insights available.'**
  String get insights_noData;

  /// No description provided for @insights_error_noLogs.
  ///
  /// In en, this message translates to:
  /// **'Please add items or outfits to Style journal first!'**
  String get insights_error_noLogs;

  /// No description provided for @insights_goToJournal.
  ///
  /// In en, this message translates to:
  /// **'Go to Style Journal'**
  String get insights_goToJournal;

  /// No description provided for @insights_mostWorn_noData.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t logged any worn items yet. Start your style journal today!'**
  String get insights_mostWorn_noData;

  /// No description provided for @insights_bestValue_noData.
  ///
  /// In en, this message translates to:
  /// **'Wear items you\'ve added a price to and your smartest investments will appear here!'**
  String get insights_bestValue_noData;

  /// No description provided for @insights_addPrices.
  ///
  /// In en, this message translates to:
  /// **'Add Prices to Items'**
  String get insights_addPrices;

  /// No description provided for @insights_wears.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 wear} other{{count} wears}}'**
  String insights_wears(num count);

  /// No description provided for @insights_costPerWear.
  ///
  /// In en, this message translates to:
  /// **'{price}/wear'**
  String insights_costPerWear(Object price);

  /// No description provided for @insights_forgottenItem_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Not worn yet. Give it a try!'**
  String get insights_forgottenItem_subtitle;

  /// No description provided for @insights_wearToday.
  ///
  /// In en, this message translates to:
  /// **'Wear Today'**
  String get insights_wearToday;

  /// No description provided for @insights_wearToday_success.
  ///
  /// In en, this message translates to:
  /// **'Added \"{itemName}\" to today\'s journal!'**
  String insights_wearToday_success(Object itemName);

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

  /// No description provided for @outfitDetail_fixedOutfit_title.
  ///
  /// In en, this message translates to:
  /// **'Fixed outfit'**
  String get outfitDetail_fixedOutfit_title;

  /// No description provided for @outfitDetail_fixedOutfit_description.
  ///
  /// In en, this message translates to:
  /// **'Items in this outfit are always worn together. Each item can only belong to one fixed outfit.'**
  String get outfitDetail_fixedOutfit_description;

  /// No description provided for @outfitMenu_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get outfitMenu_rename;

  /// No description provided for @outfitMenu_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get outfitMenu_share;

  /// No description provided for @outfitMenu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get outfitMenu_delete;

  /// No description provided for @outfitMenu_rename_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename outfit'**
  String get outfitMenu_rename_dialogTitle;

  /// No description provided for @outfitMenu_rename_dialogLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get outfitMenu_rename_dialogLabel;

  /// No description provided for @outfitMenu_rename_success.
  ///
  /// In en, this message translates to:
  /// **'Outfit name updated.'**
  String get outfitMenu_rename_success;

  /// No description provided for @outfitMenu_share_error.
  ///
  /// In en, this message translates to:
  /// **'Could not share: {error}'**
  String outfitMenu_share_error(Object error);

  /// No description provided for @outfitMenu_delete_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get outfitMenu_delete_dialogTitle;

  /// No description provided for @outfitMenu_delete_dialogContent.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete outfit \"{outfitName}\"?'**
  String outfitMenu_delete_dialogContent(Object outfitName);

  /// No description provided for @outfitMenu_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Deleted outfit \"{outfitName}\".'**
  String outfitMenu_delete_success(Object outfitName);

  /// No description provided for @outfitMenu_delete_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete outfit. Please try again.'**
  String get outfitMenu_delete_error;

  /// No description provided for @closets_title.
  ///
  /// In en, this message translates to:
  /// **'Your Closet'**
  String get closets_title;

  /// No description provided for @closets_itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 selected} other{{count} selected}}'**
  String closets_itemsSelected(num count);

  /// No description provided for @closets_tabAllItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get closets_tabAllItems;

  /// No description provided for @closets_tabByCloset.
  ///
  /// In en, this message translates to:
  /// **'By Closet'**
  String get closets_tabByCloset;

  /// No description provided for @closetDetail_itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 selected} other{{count} selected}}'**
  String closetDetail_itemsSelected(num count);

  /// No description provided for @closetDetail_itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 item} other{{count} items}}'**
  String closetDetail_itemCount(num count);

  /// No description provided for @closetDetail_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in this closet...'**
  String get closetDetail_searchHint;

  /// No description provided for @closetDetail_noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get closetDetail_noItemsFound;

  /// No description provided for @closetDetail_emptyCloset.
  ///
  /// In en, this message translates to:
  /// **'This closet is empty.'**
  String get closetDetail_emptyCloset;

  /// No description provided for @closetDetail_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get closetDetail_delete;

  /// No description provided for @closetDetail_move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get closetDetail_move;

  /// No description provided for @closetDetail_createOutfit.
  ///
  /// In en, this message translates to:
  /// **'Create Outfit'**
  String get closetDetail_createOutfit;

  /// No description provided for @closetDetail_confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get closetDetail_confirmDeleteTitle;

  /// No description provided for @closetDetail_confirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete {count,plural, =1{1 selected item} other{{count} selected items}}?'**
  String closetDetail_confirmDeleteContent(num count);

  /// No description provided for @closetDetail_moveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Move {count,plural, =1{1 item} other{{count} items}} to...'**
  String closetDetail_moveDialogTitle(num count);

  /// No description provided for @closetDetail_moveErrorNoClosets.
  ///
  /// In en, this message translates to:
  /// **'No other closets available to move to.'**
  String get closetDetail_moveErrorNoClosets;

  /// No description provided for @closetDetail_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get closetDetail_cancel;

  /// No description provided for @closetDialog_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit closet name'**
  String get closetDialog_editTitle;

  /// No description provided for @closetDialog_createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new closet'**
  String get closetDialog_createTitle;

  /// No description provided for @closetDialog_editLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get closetDialog_editLabel;

  /// No description provided for @closetDialog_createLabel.
  ///
  /// In en, this message translates to:
  /// **'Closet name'**
  String get closetDialog_createLabel;

  /// No description provided for @closet_error_emptyName.
  ///
  /// In en, this message translates to:
  /// **'Closet name cannot be empty.'**
  String get closet_error_emptyName;

  /// No description provided for @closet_error_maxLength.
  ///
  /// In en, this message translates to:
  /// **'Closet name cannot exceed 30 characters.'**
  String get closet_error_maxLength;

  /// No description provided for @closet_error_limitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of closets (10) reached.'**
  String get closet_error_limitReached;

  /// No description provided for @closet_error_duplicateName.
  ///
  /// In en, this message translates to:
  /// **'A closet with this name already exists.'**
  String get closet_error_duplicateName;

  /// No description provided for @closet_error_notEmptyOnDelete.
  ///
  /// In en, this message translates to:
  /// **'Closet is not empty. Move or delete items first.'**
  String get closet_error_notEmptyOnDelete;

  /// No description provided for @closet_success_created.
  ///
  /// In en, this message translates to:
  /// **'Successfully created \"{closetName}\" closet.'**
  String closet_success_created(Object closetName);

  /// No description provided for @closet_success_updated.
  ///
  /// In en, this message translates to:
  /// **'Closet updated successfully.'**
  String get closet_success_updated;

  /// No description provided for @closet_success_deleted.
  ///
  /// In en, this message translates to:
  /// **'Closet deleted successfully.'**
  String get closet_success_deleted;

  /// No description provided for @closet_moveErrorNoClosets.
  ///
  /// In en, this message translates to:
  /// **'No other closets available to move to.'**
  String get closet_moveErrorNoClosets;

  /// No description provided for @allItems_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get allItems_searchHint;

  /// No description provided for @allItems_filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get allItems_filterTooltip;

  /// No description provided for @allItems_emptyCloset.
  ///
  /// In en, this message translates to:
  /// **'Your closet is empty.'**
  String get allItems_emptyCloset;

  /// No description provided for @allItems_noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found for your search or filter.'**
  String get allItems_noItemsFound;

  /// No description provided for @allItems_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get allItems_delete;

  /// No description provided for @allItems_createOutfit.
  ///
  /// In en, this message translates to:
  /// **'Create Outfit'**
  String get allItems_createOutfit;

  /// No description provided for @allItems_deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get allItems_deleteDialogTitle;

  /// No description provided for @allItems_deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Are you sure you want to permanently delete 1 selected item?} other{Are you sure you want to permanently delete {count} selected items?}}'**
  String allItems_deleteDialogContent(int count);

  /// No description provided for @byCloset_addClosetHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a New Closet'**
  String get byCloset_addClosetHintTitle;

  /// No description provided for @byCloset_addClosetHintDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap here to create a new closet, helping you organize your clothes for different purposes like \'Work\' or \'Gym\'.'**
  String get byCloset_addClosetHintDescription;

  /// No description provided for @byCloset_addNewCloset.
  ///
  /// In en, this message translates to:
  /// **'Add new closet'**
  String get byCloset_addNewCloset;

  /// No description provided for @byCloset_itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{0 items} =1{1 item} other{{count} items}}'**
  String byCloset_itemCount(int count);

  /// No description provided for @byCloset_itemCountError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get byCloset_itemCountError;

  /// No description provided for @byCloset_itemCountLoading.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get byCloset_itemCountLoading;

  /// No description provided for @byCloset_deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get byCloset_deleteDialogTitle;

  /// No description provided for @byCloset_deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the \"{closetName}\" closet?'**
  String byCloset_deleteDialogContent(String closetName);

  /// No description provided for @byCloset_limitReached.
  ///
  /// In en, this message translates to:
  /// **'Closet limit (10) reached.'**
  String get byCloset_limitReached;

  /// No description provided for @closetForm_titleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Closet'**
  String get closetForm_titleEdit;

  /// No description provided for @closetForm_titleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add New Closet'**
  String get closetForm_titleAdd;

  /// No description provided for @closetForm_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get closetForm_saveButton;

  /// No description provided for @closetForm_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Closet Name'**
  String get closetForm_nameLabel;

  /// No description provided for @closetForm_iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get closetForm_iconLabel;

  /// No description provided for @closetForm_colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose Card Color'**
  String get closetForm_colorLabel;

  /// No description provided for @calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Style Journal'**
  String get calendar_title;

  /// No description provided for @calendar_addLogButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get calendar_addLogButton;

  /// No description provided for @calendar_logWearHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Your Wear'**
  String get calendar_logWearHintTitle;

  /// No description provided for @calendar_logWearHintDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a day and tap here to log what you wore.'**
  String get calendar_logWearHintDescription;

  /// No description provided for @calendar_selectOutfits.
  ///
  /// In en, this message translates to:
  /// **'Select Outfits'**
  String get calendar_selectOutfits;

  /// No description provided for @calendar_selectItems.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get calendar_selectItems;

  /// No description provided for @calendar_deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get calendar_deleteDialogTitle;

  /// No description provided for @calendar_deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {count,plural, =1{1 selection} other{{count} selections}} from this day?'**
  String calendar_deleteDialogContent(int count);

  /// No description provided for @calendar_deleteDialogContentOutfit.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the outfit \'{outfitName}\' from this day\'s journal?'**
  String calendar_deleteDialogContentOutfit(String outfitName);

  /// No description provided for @calendar_deleteDialogContentItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the item \'{itemName}\' from this day\'s journal?'**
  String calendar_deleteDialogContentItem(String itemName);

  /// No description provided for @calendar_noItemsLogged.
  ///
  /// In en, this message translates to:
  /// **'No items logged for this day.'**
  String get calendar_noItemsLogged;

  /// No description provided for @calendar_outfitLabel.
  ///
  /// In en, this message translates to:
  /// **'Outfit'**
  String get calendar_outfitLabel;

  /// No description provided for @calendar_formatMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendar_formatMonth;

  /// No description provided for @calendar_formatTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get calendar_formatTwoWeeks;

  /// No description provided for @calendar_formatWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendar_formatWeek;

  /// No description provided for @logWear_title_items.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get logWear_title_items;

  /// No description provided for @logWear_title_outfits.
  ///
  /// In en, this message translates to:
  /// **'Select Outfits'**
  String get logWear_title_outfits;

  /// No description provided for @logWear_noData_items.
  ///
  /// In en, this message translates to:
  /// **'No items to select.'**
  String get logWear_noData_items;

  /// No description provided for @logWear_noData_outfits.
  ///
  /// In en, this message translates to:
  /// **'No outfits to select.'**
  String get logWear_noData_outfits;

  /// No description provided for @logWear_label_outfit.
  ///
  /// In en, this message translates to:
  /// **'Outfit'**
  String get logWear_label_outfit;

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get home_greeting;

  /// No description provided for @home_userNameDefault.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get home_userNameDefault;

  /// No description provided for @home_actionAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add\nItem'**
  String get home_actionAddItem;

  /// No description provided for @home_actionCreateCloset.
  ///
  /// In en, this message translates to:
  /// **'Create Closet'**
  String get home_actionCreateCloset;

  /// No description provided for @home_actionCreateOutfits.
  ///
  /// In en, this message translates to:
  /// **'Create Outfits'**
  String get home_actionCreateOutfits;

  /// No description provided for @home_actionSavedOutfits.
  ///
  /// In en, this message translates to:
  /// **'Saved Outfits'**
  String get home_actionSavedOutfits;

  /// No description provided for @home_weeklyJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Week\'s Journal'**
  String get home_weeklyJournalTitle;

  /// No description provided for @home_weeklyJournalViewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get home_weeklyJournalViewMore;

  /// No description provided for @home_suggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Outfit suggestion'**
  String get home_suggestionTitle;

  /// No description provided for @home_suggestion_showcase_description.
  ///
  /// In en, this message translates to:
  /// **'Describe your purpose for the day (e.g., \"coffee with friends\", \"work meeting\") and tap the send button to get a personalized outfit suggestion!'**
  String get home_suggestion_showcase_description;

  /// No description provided for @mainScreen_bottomNav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainScreen_bottomNav_home;

  /// No description provided for @mainScreen_bottomNav_closets.
  ///
  /// In en, this message translates to:
  /// **'Closets'**
  String get mainScreen_bottomNav_closets;

  /// No description provided for @mainScreen_bottomNav_addItems.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get mainScreen_bottomNav_addItems;

  /// No description provided for @mainScreen_bottomNav_outfits.
  ///
  /// In en, this message translates to:
  /// **'Outfits'**
  String get mainScreen_bottomNav_outfits;

  /// No description provided for @mainScreen_bottomNav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get mainScreen_bottomNav_profile;

  /// No description provided for @mainScreen_addItem_takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get mainScreen_addItem_takePhoto;

  /// No description provided for @mainScreen_addItem_fromAlbum.
  ///
  /// In en, this message translates to:
  /// **'From album (up to 10)'**
  String get mainScreen_addItem_fromAlbum;

  /// No description provided for @mainScreen_tutorial_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MinCloset! I\'m your personal fashion assistant.'**
  String get mainScreen_tutorial_welcome;

  /// No description provided for @mainScreen_tutorial_introduce.
  ///
  /// In en, this message translates to:
  /// **'Let me introduce you to the first and most important feature!'**
  String get mainScreen_tutorial_introduce;

  /// No description provided for @mainScreen_tutorial_showAddItem.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start by adding your first item to the closet!'**
  String get mainScreen_tutorial_showAddItem;

  /// No description provided for @mainScreen_hint_addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get mainScreen_hint_addItem;

  /// No description provided for @mainScreen_hint_addItem_description.
  ///
  /// In en, this message translates to:
  /// **'Tap here to digitize your clothes by taking a photo or choosing from your library.'**
  String get mainScreen_hint_addItem_description;

  /// No description provided for @suggestion_purposeHint.
  ///
  /// In en, this message translates to:
  /// **'Purpose? (e.g. coffee, date night...)'**
  String get suggestion_purposeHint;

  /// No description provided for @suggestion_purposeLength.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max}'**
  String suggestion_purposeLength(int current, int max);

  /// No description provided for @suggestion_editAndSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Edit & Save'**
  String get suggestion_editAndSaveButton;

  /// No description provided for @suggestion_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Describe your purpose and tap the send button to get suggestions!'**
  String get suggestion_placeholder;

  /// No description provided for @suggestion_weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather data unavailable. This is a general suggestion.'**
  String get suggestion_weatherUnavailable;

  /// No description provided for @suggestion_lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {datetime}'**
  String suggestion_lastUpdated(String datetime);

  /// No description provided for @getOutfitSuggestion_errorManualLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Your manually selected location data is missing. Please select your city again in the settings.'**
  String get getOutfitSuggestion_errorManualLocationMissing;

  /// No description provided for @getOutfitSuggestion_errorLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable it in your device settings.'**
  String get getOutfitSuggestion_errorLocationServicesDisabled;

  /// No description provided for @getOutfitSuggestion_errorLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied. Please enable it for MinCloset in your device settings.'**
  String get getOutfitSuggestion_errorLocationPermissionDenied;

  /// No description provided for @getOutfitSuggestion_errorLocationUndetermined.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location to get weather data. Please check your device settings or select a location manually.'**
  String get getOutfitSuggestion_errorLocationUndetermined;

  /// No description provided for @getOutfitSuggestion_errorNotEnoughItems.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 3 tops and 3 bottoms/skirts to your closet to receive suggestions.'**
  String get getOutfitSuggestion_errorNotEnoughItems;

  /// No description provided for @getOutfitSuggestion_defaultSelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get getOutfitSuggestion_defaultSelectedLocation;

  /// No description provided for @getOutfitSuggestion_defaultCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get getOutfitSuggestion_defaultCurrentLocation;

  /// No description provided for @getOutfitSuggestion_defaultNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get getOutfitSuggestion_defaultNotSpecified;

  /// No description provided for @getOutfitSuggestion_defaultAnyStyle.
  ///
  /// In en, this message translates to:
  /// **'Any style'**
  String get getOutfitSuggestion_defaultAnyStyle;

  /// No description provided for @getOutfitSuggestion_defaultAnyColor.
  ///
  /// In en, this message translates to:
  /// **'Any color'**
  String get getOutfitSuggestion_defaultAnyColor;

  /// No description provided for @itemDetail_titleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get itemDetail_titleEdit;

  /// No description provided for @itemDetail_titleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get itemDetail_titleAdd;

  /// No description provided for @itemDetail_favoriteTooltip_add.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get itemDetail_favoriteTooltip_add;

  /// No description provided for @itemDetail_favoriteTooltip_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get itemDetail_favoriteTooltip_remove;

  /// No description provided for @itemDetail_deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get itemDetail_deleteTooltip;

  /// No description provided for @itemDetail_deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get itemDetail_deleteDialogTitle;

  /// No description provided for @itemDetail_deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to permanently delete item \"{itemName}\"?'**
  String itemDetail_deleteDialogContent(String itemName);

  /// No description provided for @itemDetail_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get itemDetail_saveButton;

  /// No description provided for @itemDetail_form_imageError.
  ///
  /// In en, this message translates to:
  /// **'Please add a photo for the item.'**
  String get itemDetail_form_imageError;

  /// No description provided for @itemDetail_form_editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get itemDetail_form_editButton;

  /// No description provided for @itemDetail_form_removeBgButton.
  ///
  /// In en, this message translates to:
  /// **'Remove BG'**
  String get itemDetail_form_removeBgButton;

  /// No description provided for @itemDetail_form_removeBgDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Image May Have Been Processed'**
  String get itemDetail_form_removeBgDialogTitle;

  /// No description provided for @itemDetail_form_removeBgDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This image might already have a transparent background. Proceeding again may cause errors. Do you want to continue?'**
  String get itemDetail_form_removeBgDialogContent;

  /// No description provided for @itemDetail_form_removeBgDialogContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get itemDetail_form_removeBgDialogContinue;

  /// No description provided for @itemDetail_form_errorReadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error reading image format.'**
  String get itemDetail_form_errorReadingImage;

  /// No description provided for @itemDetail_form_timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Operation timed out after 45 seconds.'**
  String get itemDetail_form_timeoutError;

  /// No description provided for @itemDetail_form_unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String itemDetail_form_unexpectedError(String error);

  /// No description provided for @itemDetail_form_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name *'**
  String get itemDetail_form_nameLabel;

  /// No description provided for @itemDetail_form_closetLabel.
  ///
  /// In en, this message translates to:
  /// **'Select closet *'**
  String get itemDetail_form_closetLabel;

  /// No description provided for @itemDetail_form_categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get itemDetail_form_categoryLabel;

  /// No description provided for @itemDetail_form_categoryNoneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get itemDetail_form_categoryNoneSelected;

  /// No description provided for @itemDetail_form_colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get itemDetail_form_colorLabel;

  /// No description provided for @itemDetail_form_colorNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get itemDetail_form_colorNotYet;

  /// No description provided for @itemDetail_form_seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get itemDetail_form_seasonLabel;

  /// No description provided for @itemDetail_form_occasionLabel.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get itemDetail_form_occasionLabel;

  /// No description provided for @itemDetail_form_materialLabel.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get itemDetail_form_materialLabel;

  /// No description provided for @itemDetail_form_patternLabel.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get itemDetail_form_patternLabel;

  /// No description provided for @itemDetail_form_priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get itemDetail_form_priceLabel;

  /// No description provided for @itemDetail_form_notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemDetail_form_notesLabel;

  /// No description provided for @itemBrowser_noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get itemBrowser_noItemsFound;

  /// No description provided for @itemBrowser_empty.
  ///
  /// In en, this message translates to:
  /// **'Your closet is empty.'**
  String get itemBrowser_empty;

  /// No description provided for @itemNotifier_analysis_error.
  ///
  /// In en, this message translates to:
  /// **'Pre-filling information failed.\\nReason: {error}'**
  String itemNotifier_analysis_error(Object error);

  /// No description provided for @itemNotifier_error_noPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add a photo for the item.'**
  String get itemNotifier_error_noPhoto;

  /// No description provided for @itemNotifier_error_createThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Error creating thumbnail: {error}'**
  String itemNotifier_error_createThumbnail(Object error);

  /// No description provided for @itemNotifier_save_success_updated.
  ///
  /// In en, this message translates to:
  /// **'Item successfully updated.'**
  String get itemNotifier_save_success_updated;

  /// No description provided for @itemNotifier_save_success_created.
  ///
  /// In en, this message translates to:
  /// **'Item successfully saved.'**
  String get itemNotifier_save_success_created;

  /// No description provided for @itemNotifier_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted item \"{itemName}\".'**
  String itemNotifier_delete_success(Object itemName);

  /// No description provided for @itemNotifier_error_updateImage.
  ///
  /// In en, this message translates to:
  /// **'Could not update image: {error}'**
  String itemNotifier_error_updateImage(Object error);

  /// No description provided for @validation_nameTakenSingle.
  ///
  /// In en, this message translates to:
  /// **'\"{itemName}\" is already taken. Please use a different name. You can add numbers to distinguish items (e.g., Shirt 1, Shirt 2...).'**
  String validation_nameTakenSingle(Object itemName);

  /// No description provided for @filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter_title;

  /// No description provided for @filter_closet.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get filter_closet;

  /// No description provided for @filter_allClosets.
  ///
  /// In en, this message translates to:
  /// **'All closets'**
  String get filter_allClosets;

  /// No description provided for @filter_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filter_category;

  /// No description provided for @filter_allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get filter_allCategories;

  /// No description provided for @filter_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get filter_color;

  /// No description provided for @filter_season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get filter_season;

  /// No description provided for @filter_occasion.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get filter_occasion;

  /// No description provided for @filter_material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get filter_material;

  /// No description provided for @filter_pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get filter_pattern;

  /// No description provided for @filter_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filter_clear;

  /// No description provided for @filter_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filter_apply;

  /// No description provided for @batchAdd_title_page.
  ///
  /// In en, this message translates to:
  /// **'Add item ({current}/{total})'**
  String batchAdd_title_page(Object current, Object total);

  /// No description provided for @batchAdd_button_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get batchAdd_button_previous;

  /// No description provided for @batchAdd_button_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get batchAdd_button_next;

  /// No description provided for @batchAdd_button_saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all'**
  String get batchAdd_button_saveAll;

  /// No description provided for @batchAdd_empty.
  ///
  /// In en, this message translates to:
  /// **'No photos to display.'**
  String get batchAdd_empty;

  /// No description provided for @batchNotifier_analysis_error.
  ///
  /// In en, this message translates to:
  /// **'Pre-filling information failed for one or more items.\\nReason: {error}'**
  String batchNotifier_analysis_error(Object error);

  /// No description provided for @batchNotifier_validation_nameTaken.
  ///
  /// In en, this message translates to:
  /// **'\"{itemName}\" for item {itemNumber} is already taken. Please use a different name.'**
  String batchNotifier_validation_nameTaken(Object itemName, Object itemNumber);

  /// No description provided for @batchNotifier_validation_nameConflict.
  ///
  /// In en, this message translates to:
  /// **'\"{itemName}\" for item {itemNumber} is already used by item {conflictNumber}. Please use a different name.'**
  String batchNotifier_validation_nameConflict(
      Object conflictNumber, Object itemName, Object itemNumber);

  /// No description provided for @analysis_preparingImages.
  ///
  /// In en, this message translates to:
  /// **'Preparing images...'**
  String get analysis_preparingImages;

  /// No description provided for @analysis_prefillingInfo.
  ///
  /// In en, this message translates to:
  /// **'Pre-filling information...\nThis may take a moment to complete.'**
  String get analysis_prefillingInfo;

  /// No description provided for @analysis_maxPhotosWarning.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 10 photos selected. Extra photos were skipped.'**
  String get analysis_maxPhotosWarning;

  /// No description provided for @analysis_error_pickImage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while picking images. Please try again.'**
  String get analysis_error_pickImage;

  /// No description provided for @onboarding_page1_title.
  ///
  /// In en, this message translates to:
  /// **'A closet full of clothes...'**
  String get onboarding_page1_title;

  /// No description provided for @onboarding_page1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'...but nothing to wear?'**
  String get onboarding_page1_subtitle;

  /// No description provided for @onboarding_page1_description.
  ///
  /// In en, this message translates to:
  /// **'Do you often spend time wondering what to wear? Do you forget what amazing items you already own?'**
  String get onboarding_page1_description;

  /// No description provided for @onboarding_page2_title.
  ///
  /// In en, this message translates to:
  /// **'MinCloset\nYour Smart Closet Assistant'**
  String get onboarding_page2_title;

  /// No description provided for @onboarding_page2_feature1_title.
  ///
  /// In en, this message translates to:
  /// **'Digitize Your Closet'**
  String get onboarding_page2_feature1_title;

  /// No description provided for @onboarding_page2_feature1_desc.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo and let AI automatically categorize your clothes.'**
  String get onboarding_page2_feature1_desc;

  /// No description provided for @onboarding_page2_feature2_title.
  ///
  /// In en, this message translates to:
  /// **'AI Outfit Suggestions'**
  String get onboarding_page2_feature2_title;

  /// No description provided for @onboarding_page2_feature2_desc.
  ///
  /// In en, this message translates to:
  /// **'Get personalized outfit ideas based on your items and the weather.'**
  String get onboarding_page2_feature2_desc;

  /// No description provided for @onboarding_page2_feature3_title.
  ///
  /// In en, this message translates to:
  /// **'Creative Outfit Studio'**
  String get onboarding_page2_feature3_title;

  /// No description provided for @onboarding_page2_feature3_desc.
  ///
  /// In en, this message translates to:
  /// **'Freely mix and match items to create unique looks.'**
  String get onboarding_page2_feature3_desc;

  /// No description provided for @onboarding_page2_feature4_title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Style Journey'**
  String get onboarding_page2_feature4_title;

  /// No description provided for @onboarding_page2_feature4_desc.
  ///
  /// In en, this message translates to:
  /// **'Log what you wear and discover your habits.'**
  String get onboarding_page2_feature4_desc;

  /// No description provided for @onboarding_page3_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know each other!'**
  String get onboarding_page3_title;

  /// No description provided for @onboarding_page3_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us your name so we can get more personal.'**
  String get onboarding_page3_subtitle;

  /// No description provided for @onboarding_page3_nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name...'**
  String get onboarding_page3_nameHint;

  /// No description provided for @onboarding_page3_nameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please tell me your name'**
  String get onboarding_page3_nameValidator;

  /// No description provided for @permissions_title.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get permissions_title;

  /// No description provided for @permissions_description.
  ///
  /// In en, this message translates to:
  /// **'MinCloset needs some permissions to provide the best experience, including:'**
  String get permissions_description;

  /// No description provided for @permissions_notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissions_notifications_title;

  /// No description provided for @permissions_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'To remind you what to wear every day.'**
  String get permissions_notifications_desc;

  /// No description provided for @permissions_camera_title.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissions_camera_title;

  /// No description provided for @permissions_camera_desc.
  ///
  /// In en, this message translates to:
  /// **'To take photos and add new items to your closet.'**
  String get permissions_camera_desc;

  /// No description provided for @permissions_location_title.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permissions_location_title;

  /// No description provided for @permissions_location_desc.
  ///
  /// In en, this message translates to:
  /// **'To provide outfit suggestions that match the weather.'**
  String get permissions_location_desc;

  /// No description provided for @permissions_continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permissions_continue_button;

  /// No description provided for @validation_error_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter item name'**
  String get validation_error_name_required;

  /// No description provided for @validation_error_closet_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a closet'**
  String get validation_error_closet_required;

  /// No description provided for @validation_error_category_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get validation_error_category_required;

  /// No description provided for @validation_error_batch_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for Item {itemNumber}'**
  String validation_error_batch_name_required(Object itemNumber);

  /// No description provided for @validation_error_batch_closet_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a closet for Item {itemNumber}'**
  String validation_error_batch_closet_required(Object itemNumber);

  /// No description provided for @validation_error_batch_category_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a category for Item {itemNumber}'**
  String validation_error_batch_category_required(Object itemNumber);

  /// No description provided for @removeBg_title.
  ///
  /// In en, this message translates to:
  /// **'Remove Background'**
  String get removeBg_title;

  /// No description provided for @removeBg_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing, please wait...'**
  String get removeBg_processing;

  /// No description provided for @removeBg_error_process.
  ///
  /// In en, this message translates to:
  /// **'Could not process image.'**
  String get removeBg_error_process;

  /// No description provided for @removeBg_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Error processing image: {error}'**
  String removeBg_error_generic(Object error);
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
