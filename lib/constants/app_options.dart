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
    'Tops': [
      'T-shirts', 'Long Sleeve', 'Sleeveless', 'Polo Shirts', 'Tanks & Camis',
      'Crop Tops', 'Blouses', 'Shirts', 'Sweatshirts', 'Hoodies', 'Sweaters', 'Other',
    ],
    'Bottoms': [
      'Jeans', 'Trousers', 'Dress Pants', 'Track Pants', 'Leggings', 'Shorts', 'Other',
    ],
    'Dresses/Jumpsuits': [
      'Mini Skirts', 'Midi Skirts', 'Maxi Skirts', 'Day Dresses', 'T-shirt Dresses',
      'Shirt Dresses', 'Sweatshirt Dresses', 'Sweater Dresses', 'Jacket Dresses',
      'Suspender Dresses', 'Jumpsuits', 'Party Dresses', 'Other',
    ],
    'Outerwear': [
      'Coats', 'Trench Coats', 'Fur Coats', 'Shearling Coats', 'Blazers', 'Jackets',
      'Blousons', 'Varsity Jackets', 'Trucker Jackets', 'Biker Jackets', 'Cardigans',
      'Zip-up Hoodies', 'Field Jackets', 'Track Jackets', 'Fleece Jackets',
      'Puffer/Down Jackets', 'Vests', 'Other',
    ],
    'Footwear': [
      'Sneakers', 'Slip-Ons', 'Sports Shoes', 'Hiking Shoes', 'Boots',
      'Combat Boots', 'Ugg Boots', 'Loafers & Mules', 'Boat Shoes',
      'Flat Shoes', 'Heels', 'Sandals', 'Heeled Sandals', 'Slides', 'Other',
    ],
    'Bags': [
      'Tote Bags', 'Shoulder Bags', 'Crossbody Bags', 'Waist Bags', 'Canvas Bags',
      'Backpacks', 'Duffel Bags', 'Clutches', 'Briefcases', 'Drawstring Bags',
      'Suitcases', 'Other',
    ],
    'Hats': [
      'Caps', 'Hats', 'Beanies', 'Berets', 'Fedoras', 'Sun Hats', 'Other',
    ],
    'Other': [],
  };

  static const Map<String, IconData> categoryIcons = {
    'Tops': FontAwesomeIcons.shirt,
    'Bottoms': FontAwesomeIcons.personWalking,
    'Dresses/Jumpsuits': Icons.woman_outlined,
    'Outerwear': FontAwesomeIcons.userTie,
    'Footwear': FontAwesomeIcons.shoePrints,
    'Bags': FontAwesomeIcons.bagShopping,
    'Hats': FontAwesomeIcons.hatCowboy,
    'Other': FontAwesomeIcons.tag,
  };

  static const List<String> seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];

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
    'Everyday', 'Work', 'Date', 'Formal', 'Travel',
    'Home', 'Party', 'Sport', 'Special', 'School', 'Beach', 'Other'
  ];

  static const List<OptionWithImage> materials = [
    OptionWithImage(name: 'Cotton', imagePath: 'assets/images/materials/cotton.webp'),
    OptionWithImage(name: 'Linen', imagePath: 'assets/images/materials/linen.webp'),
    OptionWithImage(name: 'Wool', imagePath: 'assets/images/materials/wool.webp'),
    OptionWithImage(name: 'Silk', imagePath: 'assets/images/materials/silk.webp'),
    OptionWithImage(name: 'Polyester', imagePath: 'assets/images/materials/polyester.webp'),
    OptionWithImage(name: 'Nylon', imagePath: 'assets/images/materials/nylon.webp'),
    OptionWithImage(name: 'Denim', imagePath: 'assets/images/materials/denim.webp'),
    OptionWithImage(name: 'Leather', imagePath: 'assets/images/materials/leather.webp'),
    OptionWithImage(name: 'Other', imagePath: 'assets/images/materials/other.webp'),
  ];

  static const List<OptionWithImage> patterns = [
    OptionWithImage(name: 'Solid', imagePath: 'assets/images/patterns/solid.webp'),
    OptionWithImage(name: 'Striped', imagePath: 'assets/images/patterns/striped.webp'),
    OptionWithImage(name: 'Plaid', imagePath: 'assets/images/patterns/checks.webp'),
    OptionWithImage(name: 'Dotted', imagePath: 'assets/images/patterns/dots.webp'),
    OptionWithImage(name: 'Chevron', imagePath: 'assets/images/patterns/chevron.webp'),
    OptionWithImage(name: 'Animal', imagePath: 'assets/images/patterns/animal.webp'),
    OptionWithImage(name: 'Floral', imagePath: 'assets/images/patterns/floral.webp'),
    OptionWithImage(name: 'Typography', imagePath: 'assets/images/patterns/typography.webp'),
    OptionWithImage(name: 'Other', imagePath: 'assets/images/patterns/other.webp'),
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