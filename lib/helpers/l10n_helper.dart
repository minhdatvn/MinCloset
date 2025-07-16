// lib/helpers/l10n_helper.dart
import 'package:mincloset/l10n/app_localizations.dart';

// Hàm này nhận vào một khóa và đối tượng l10n, trả về chuỗi đã dịch
String translateAppOption(String key, AppLocalizations l10n) {
  switch (key) {
    case 'category_tops': return l10n.category_tops;
    case 'category_tops_tshirts': return l10n.category_tops_tshirts;
    case 'category_tops_long_sleeve': return l10n.category_tops_long_sleeve;
    case 'category_tops_sleeveless': return l10n.category_tops_sleeveless;
    case 'category_tops_polo_shirts': return l10n.category_tops_polo_shirts;
    case 'category_tops_tanks_camis': return l10n.category_tops_tanks_camis;
    case 'category_tops_crop_tops': return l10n.category_tops_crop_tops;
    case 'category_tops_blouses': return l10n.category_tops_blouses;
    case 'category_tops_shirts': return l10n.category_tops_shirts;
    case 'category_tops_sweatshirts': return l10n.category_tops_sweatshirts;
    case 'category_tops_hoodies': return l10n.category_tops_hoodies;
    case 'category_tops_sweaters': return l10n.category_tops_sweaters;
    case 'category_tops_other': return l10n.category_tops_other;
    case 'category_bottoms': return l10n.category_bottoms;
    case 'category_bottoms_jeans': return l10n.category_bottoms_jeans;
    case 'category_bottoms_trousers': return l10n.category_bottoms_trousers;
    case 'category_bottoms_dress_pants': return l10n.category_bottoms_dress_pants;
    case 'category_bottoms_track_pants': return l10n.category_bottoms_track_pants;
    case 'category_bottoms_leggings': return l10n.category_bottoms_leggings;
    case 'category_bottoms_shorts': return l10n.category_bottoms_shorts;
    case 'category_bottoms_other': return l10n.category_bottoms_other;
    case 'category_dresses_jumpsuits': return l10n.category_dresses_jumpsuits;
    case 'category_dresses_jumpsuits_mini_skirts': return l10n.category_dresses_jumpsuits_mini_skirts;
    case 'category_dresses_jumpsuits_midi_skirts': return l10n.category_dresses_jumpsuits_midi_skirts;
    case 'category_dresses_jumpsuits_maxi_skirts': return l10n.category_dresses_jumpsuits_maxi_skirts;
    case 'category_dresses_jumpsuits_day_dresses': return l10n.category_dresses_jumpsuits_day_dresses;
    case 'category_dresses_jumpsuits_tshirt_dresses': return l10n.category_dresses_jumpsuits_tshirt_dresses;
    case 'category_dresses_jumpsuits_shirt_dresses': return l10n.category_dresses_jumpsuits_shirt_dresses;
    case 'category_dresses_jumpsuits_sweatshirt_dresses': return l10n.category_dresses_jumpsuits_sweatshirt_dresses;
    case 'category_dresses_jumpsuits_sweater_dresses': return l10n.category_dresses_jumpsuits_sweater_dresses;
    case 'category_dresses_jumpsuits_jacket_dresses': return l10n.category_dresses_jumpsuits_jacket_dresses;
    case 'category_dresses_jumpsuits_suspender_dresses': return l10n.category_dresses_jumpsuits_suspender_dresses;
    case 'category_dresses_jumpsuits_jumpsuits': return l10n.category_dresses_jumpsuits_jumpsuits;
    case 'category_dresses_jumpsuits_party_dresses': return l10n.category_dresses_jumpsuits_party_dresses;
    case 'category_dresses_jumpsuits_other': return l10n.category_dresses_jumpsuits_other;
    case 'category_outerwear': return l10n.category_outerwear;
    case 'category_outerwear_coats': return l10n.category_outerwear_coats;
    case 'category_outerwear_trench_coats': return l10n.category_outerwear_trench_coats;
    case 'category_outerwear_fur_coats': return l10n.category_outerwear_fur_coats;
    case 'category_outerwear_shearling_coats': return l10n.category_outerwear_shearling_coats;
    case 'category_outerwear_blazers': return l10n.category_outerwear_blazers;
    case 'category_outerwear_jackets': return l10n.category_outerwear_jackets;
    case 'category_outerwear_blousons': return l10n.category_outerwear_blousons;
    case 'category_outerwear_varsity_jackets': return l10n.category_outerwear_varsity_jackets;
    case 'category_outerwear_trucker_jackets': return l10n.category_outerwear_trucker_jackets;
    case 'category_outerwear_biker_jackets': return l10n.category_outerwear_biker_jackets;
    case 'category_outerwear_cardigans': return l10n.category_outerwear_cardigans;
    case 'category_outerwear_zipup_hoodies': return l10n.category_outerwear_zipup_hoodies;
    case 'category_outerwear_field_jackets': return l10n.category_outerwear_field_jackets;
    case 'category_outerwear_track_jackets': return l10n.category_outerwear_track_jackets;
    case 'category_outerwear_fleece_jackets': return l10n.category_outerwear_fleece_jackets;
    case 'category_outerwear_puffer_down_jackets': return l10n.category_outerwear_puffer_down_jackets;
    case 'category_outerwear_vests': return l10n.category_outerwear_vests;
    case 'category_outerwear_other': return l10n.category_outerwear_other;
    case 'category_footwear': return l10n.category_footwear;
    case 'category_footwear_sneakers': return l10n.category_footwear_sneakers;
    case 'category_footwear_slipons': return l10n.category_footwear_slipons;
    case 'category_footwear_sports_shoes': return l10n.category_footwear_sports_shoes;
    case 'category_footwear_hiking_shoes': return l10n.category_footwear_hiking_shoes;
    case 'category_footwear_boots': return l10n.category_footwear_boots;
    case 'category_footwear_combat_boots': return l10n.category_footwear_combat_boots;
    case 'category_footwear_ugg_boots': return l10n.category_footwear_ugg_boots;
    case 'category_footwear_loafers_mules': return l10n.category_footwear_loafers_mules;
    case 'category_footwear_boat_shoes': return l10n.category_footwear_boat_shoes;
    case 'category_footwear_flat_shoes': return l10n.category_footwear_flat_shoes;
    case 'category_footwear_heels': return l10n.category_footwear_heels;
    case 'category_footwear_sandals': return l10n.category_footwear_sandals;
    case 'category_footwear_heeled_sandals': return l10n.category_footwear_heeled_sandals;
    case 'category_footwear_slides': return l10n.category_footwear_slides;
    case 'category_footwear_other': return l10n.category_footwear_other;
    case 'category_bags': return l10n.category_bags;
    case 'category_bags_tote_bags': return l10n.category_bags_tote_bags;
    case 'category_bags_shoulder_bags': return l10n.category_bags_shoulder_bags;
    case 'category_bags_crossbody_bags': return l10n.category_bags_crossbody_bags;
    case 'category_bags_waist_bags': return l10n.category_bags_waist_bags;
    case 'category_bags_canvas_bags': return l10n.category_bags_canvas_bags;
    case 'category_bags_backpacks': return l10n.category_bags_backpacks;
    case 'category_bags_duffel_bags': return l10n.category_bags_duffel_bags;
    case 'category_bags_clutches': return l10n.category_bags_clutches;
    case 'category_bags_briefcases': return l10n.category_bags_briefcases;
    case 'category_bags_drawstring_bags': return l10n.category_bags_drawstring_bags;
    case 'category_bags_suitcases': return l10n.category_bags_suitcases;
    case 'category_bags_other': return l10n.category_bags_other;
    case 'category_hats': return l10n.category_hats;
    case 'category_hats_caps': return l10n.category_hats_caps;
    case 'category_hats_hats': return l10n.category_hats_hats;
    case 'category_hats_beanies': return l10n.category_hats_beanies;
    case 'category_hats_berets': return l10n.category_hats_berets;
    case 'category_hats_fedoras': return l10n.category_hats_fedoras;
    case 'category_hats_sun_hats': return l10n.category_hats_sun_hats;
    case 'category_hats_other': return l10n.category_hats_other;
    case 'category_other': return l10n.category_other;
    
    // Seasons
    case 'season_spring':
      return l10n.season_spring;
    case 'season_summer':
      return l10n.season_summer;
    case 'season_autumn':
      return l10n.season_autumn;
    case 'season_winter':
      return l10n.season_winter;
    
    case 'occasion_everyday':
      return l10n.occasion_everyday;
    case 'occasion_work':
      return l10n.occasion_work;
    case 'occasion_date':
      return l10n.occasion_date;
    case 'occasion_formal':
      return l10n.occasion_formal;
    case 'occasion_travel':
      return l10n.occasion_travel;
    case 'occasion_home':
      return l10n.occasion_home;
    case 'occasion_party':
      return l10n.occasion_party;
    case 'occasion_sport':
      return l10n.occasion_sport;
    case 'occasion_special':
      return l10n.occasion_special;
    case 'occasion_school':
      return l10n.occasion_school;
    case 'occasion_beach':
      return l10n.occasion_beach;
    case 'occasion_other':
      return l10n.occasion_other;
    
    case 'material_cotton':
      return l10n.material_cotton;
    case 'material_linen':
      return l10n.material_linen;
    case 'material_wool':
      return l10n.material_wool;
    case 'material_silk':
      return l10n.material_silk;
    case 'material_polyester':
      return l10n.material_polyester;
    case 'material_nylon':
      return l10n.material_nylon;
    case 'material_denim':
      return l10n.material_denim;
    case 'material_leather':
      return l10n.material_leather;
    case 'material_other':
      return l10n.material_other;

    case 'pattern_solid':
      return l10n.pattern_solid;
    case 'pattern_striped':
      return l10n.pattern_striped;
    case 'pattern_plaid':
      return l10n.pattern_plaid;
    case 'pattern_dotted':
      return l10n.pattern_dotted;
    case 'pattern_chevron':
      return l10n.pattern_chevron;
    case 'pattern_animal':
      return l10n.pattern_animal;
    case 'pattern_floral':
      return l10n.pattern_floral;
    case 'pattern_typography':
      return l10n.pattern_typography;
    case 'pattern_other':
      return l10n.pattern_other;
    
    // Trả về chính khóa đó nếu không tìm thấy bản dịch
    default:
      return key;
  }
}