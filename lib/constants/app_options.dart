// lib/constants/app_options.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionWithImage {
  final String name;
  final String imagePath;

  const OptionWithImage({required this.name, required this.imagePath});
}

class AppOptions {
  static const Map<String, List<String>> categories = {
    'category_tops': [
      'category_tops_tshirts', 'category_tops_long_sleeve', 'category_tops_sleeveless', 'category_tops_polo_shirts', 'category_tops_tanks_camis',
      'category_tops_crop_tops', 'category_tops_blouses', 'category_tops_shirts', 'category_tops_sweatshirts', 'category_tops_hoodies', 'category_tops_sweaters', 'category_tops_other', 
    ],
    'category_bottoms': [
      'category_bottoms_jeans', 'category_bottoms_trousers', 'category_bottoms_dress_pants', 'category_bottoms_track_pants', 'category_bottoms_leggings', 'category_bottoms_shorts', 'category_bottoms_other', 
    ],
    'category_dresses_jumpsuits': [
      'category_dresses_jumpsuits_mini_skirts', 'category_dresses_jumpsuits_midi_skirts', 'category_dresses_jumpsuits_maxi_skirts', 'category_dresses_jumpsuits_day_dresses', 'category_dresses_jumpsuits_tshirt_dresses',
      'category_dresses_jumpsuits_shirt_dresses', 'category_dresses_jumpsuits_sweatshirt_dresses', 'category_dresses_jumpsuits_sweater_dresses', 'category_dresses_jumpsuits_jacket_dresses',
      'category_dresses_jumpsuits_suspender_dresses', 'category_dresses_jumpsuits_jumpsuits', 'category_dresses_jumpsuits_party_dresses', 'category_dresses_jumpsuits_other', 
    ],
    'category_outerwear': [
      'category_outerwear_coats', 'category_outerwear_trench_coats', 'category_outerwear_fur_coats', 'category_outerwear_shearling_coats', 'category_outerwear_blazers', 'category_outerwear_jackets',
      'category_outerwear_blousons', 'category_outerwear_varsity_jackets', 'category_outerwear_trucker_jackets', 'category_outerwear_biker_jackets', 'category_outerwear_cardigans',
      'category_outerwear_zipup_hoodies', 'category_outerwear_field_jackets', 'category_outerwear_track_jackets', 'category_outerwear_fleece_jackets', 'category_outerwear_puffer_down_jackets', 'category_outerwear_vests', 'category_outerwear_other',
    ],
    'category_footwear': [
      'category_footwear_sneakers', 'category_footwear_slipons', 'category_footwear_sports_shoes', 'category_footwear_hiking_shoes', 'category_footwear_boots',
      'category_footwear_combat_boots', 'category_footwear_ugg_boots', 'category_footwear_loafers_mules', 'category_footwear_boat_shoes',
      'category_footwear_flat_shoes', 'category_footwear_heels', 'category_footwear_sandals', 'category_footwear_heeled_sandals', 'category_footwear_slides', 'category_footwear_other',
    ],
    'category_bags': [
      'category_bags_tote_bags', 'category_bags_shoulder_bags', 'category_bags_crossbody_bags', 'category_bags_waist_bags', 'category_bags_canvas_bags',
      'category_bags_backpacks', 'category_bags_duffel_bags', 'category_bags_clutches', 'category_bags_briefcases', 'category_bags_drawstring_bags', 'category_bags_suitcases', 'category_bags_other', 
    ],
    'category_hats': [
      'category_hats_caps', 'category_hats_hats', 'category_hats_beanies', 'category_hats_berets', 'category_hats_fedoras', 'category_hats_sun_hats', 'category_hats_other',
    ],
    'category_other': [],
  };

  static const Map<String, IconData> categoryIcons = {
    'category_tops': FontAwesomeIcons.shirt,
    'category_bottoms': FontAwesomeIcons.personWalking,
    'category_dresses_jumpsuits': Icons.woman_outlined,
    'category_outerwear': FontAwesomeIcons.userTie,
    'category_footwear': FontAwesomeIcons.shoePrints,
    'category_bags': FontAwesomeIcons.bagShopping,
    'category_hats': FontAwesomeIcons.hatCowboy,
    'category_other': FontAwesomeIcons.tag,
  };

  static const List<String> seasons = [
    'season_spring', 
    'season_summer', 
    'season_autumn', 
    'season_winter'
  ];

  static const Map<String, Color> colors = {
    // Neutral Tones
    'White': Color(0xFFFFFFFF),
    'Ivory': Color(0xFFFFFFF0),
    'Light Gray': Color(0xFFD3D3D3),
    'Dark Gray': Color(0xFFA9A9A9),
    'Black': Color(0xFF000000),

    // Yellow & Orange Tones
    'Light Yellow': Color(0xFFFFFFE0),
    'Yellow': Color(0xFFFFF176),
    'Mustard': Color(0xFFFFC107),
    'Orange': Color(0xFFFFA726),
    
    // Red & Pink Tones
    'Coral': Color(0xFFFF7F50),
    'Light Pink': Color(0xFFF06292),
    'Hot Pink': Color(0xFFEC407A),
    'Red': Color.fromARGB(255, 255, 4, 0),
    'Maroon': Color(0xFF880E4F),

    // Green Tones
    'Lime Green': Color(0xFF9CCC65),
    'Green': Color(0xFF66BB6A),
    'Olive': Color(0xFF808000),
    'Khaki': Color(0xFFC3B091),

    // Blue Tones
    'Teal': Color(0xFF26A69A),
    'Cyan': Color(0xFF26C6DA),
    'Sky Blue': Color(0xFF42A5F5),
    'Navy Blue': Color(0xFF1A237E),

    // Purple Tones
    'Lavender': Color(0xFFE6E6FA),
    'Purple': Color(0xFFAB47BC),
    'Magenta': Color(0xFFD81B60),

    // Brown Tones
    'Tan': Color(0xFFC19A6B),
    'Light Brown': Color(0xFF8D6E63),
    'Dark Brown': Color(0xFF5D4037),
  };

  static const List<String> occasions = [
    'occasion_everyday', 'occasion_work', 'occasion_date', 'occasion_formal', 'occasion_travel',
    'occasion_home', 'occasion_party', 'occasion_sport', 'occasion_special', 'occasion_school', 'occasion_beach', 'occasion_other'
  ];

  static const List<OptionWithImage> materials = [
    OptionWithImage(name: 'material_cotton', imagePath: 'assets/images/materials/cotton.webp'),
    OptionWithImage(name: 'material_linen', imagePath: 'assets/images/materials/linen.webp'),
    OptionWithImage(name: 'material_wool', imagePath: 'assets/images/materials/wool.webp'),
    OptionWithImage(name: 'material_silk', imagePath: 'assets/images/materials/silk.webp'),
    OptionWithImage(name: 'material_polyester', imagePath: 'assets/images/materials/polyester.webp'),
    OptionWithImage(name: 'material_nylon', imagePath: 'assets/images/materials/nylon.webp'),
    OptionWithImage(name: 'material_denim', imagePath: 'assets/images/materials/denim.webp'),
    OptionWithImage(name: 'material_leather', imagePath: 'assets/images/materials/leather.webp'),
    OptionWithImage(name: 'material_other', imagePath: 'assets/images/materials/other.webp'),
  ];

  static const List<OptionWithImage> patterns = [
    OptionWithImage(name: 'pattern_solid', imagePath: 'assets/images/patterns/solid.webp'),
    OptionWithImage(name: 'pattern_striped', imagePath: 'assets/images/patterns/striped.webp'),
    OptionWithImage(name: 'pattern_plaid', imagePath: 'assets/images/patterns/checks.webp'),
    OptionWithImage(name: 'pattern_dotted', imagePath: 'assets/images/patterns/dots.webp'),
    OptionWithImage(name: 'pattern_chevron', imagePath: 'assets/images/patterns/chevron.webp'),
    OptionWithImage(name: 'pattern_animal', imagePath: 'assets/images/patterns/animal.webp'),
    OptionWithImage(name: 'pattern_floral', imagePath: 'assets/images/patterns/floral.webp'),
    OptionWithImage(name: 'pattern_typography', imagePath: 'assets/images/patterns/typography.webp'),
    OptionWithImage(name: 'pattern_other', imagePath: 'assets/images/patterns/other.webp'),
  ];

  static const List<String> personalStyles = [
    'Minimalist',
    'Classic',
    'Sporty',
    'Streetwear',
    'Business',
    'Romantic',
    'Bohemian',
    'Edgy',
    'Other',
  ];
}