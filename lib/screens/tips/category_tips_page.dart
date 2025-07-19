// lib/screens/tips/category_tips_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/l10n_helper.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/tip_card.dart';

// Lớp để chứa dữ liệu cho mỗi mục
class _HelpItem {
  final String titleKey;
  final String description;
  final String imagePath;
  const _HelpItem({ required this.titleKey, required this.description, required this.imagePath });
}

class CategoryTipsPage extends StatefulWidget {
  const CategoryTipsPage({super.key});

  @override
  State<CategoryTipsPage> createState() => _CategoryTipsPageState();
}

class _CategoryTipsPageState extends State<CategoryTipsPage> {
  // Dữ liệu cho các mục hướng dẫn được định nghĩa tại đây
  // Sử dụng Map để nhóm các mục theo danh mục chính
  static const Map<String, List<_HelpItem>> _categoryHelpItems = {
    'category_tops': [
      _HelpItem(titleKey: "category_tops_tshirts", description: "Short-sleeved, casual upper-body garment.", imagePath: "assets/images/category/tops/tshirt.webp"),
      _HelpItem(titleKey: "category_tops_long_sleeve", description: "A top with sleeves that extend to the wrist.", imagePath: "assets/images/category/tops/longsleeve.webp"),
      _HelpItem(titleKey: "category_tops_sleeveless", description: "A top without sleeves.", imagePath: "assets/images/category/tops/sleeveless.webp"),
      _HelpItem(titleKey: "category_tops_polo_shirts", description: "A t-shirt with a collar and a placket neckline with two or three buttons.", imagePath: "assets/images/category/tops/polo.webp"),
      _HelpItem(titleKey: "category_tops_tanks_camis", description: "Sleeveless upper-body garment, often worn as underwear or for warm weather.", imagePath: "assets/images/category/tops/tank.webp"),
      _HelpItem(titleKey: "category_tops_crop_tops", description: "A top where the bottom hem is high enough to expose the waist.", imagePath: "assets/images/category/tops/croptop.webp"),
      _HelpItem(titleKey: "category_tops_blouses", description: "A more formal or decorative shirt, typically for women.", imagePath: "assets/images/category/tops/blouse.webp"),
      _HelpItem(titleKey: "category_tops_shirts", description: "A garment for the upper body with a collar, sleeves, and a front opening.", imagePath: "assets/images/category/tops/shirt.webp"),
      _HelpItem(titleKey: "category_tops_sweatshirts", description: "A loose, warm sweater, typically made of cotton.", imagePath: "assets/images/category/tops/sweatshirt.webp"),
      _HelpItem(titleKey: "category_tops_hoodies", description: "A sweatshirt with a hood.", imagePath: "assets/images/category/tops/hoodie.webp"),
      _HelpItem(titleKey: "category_tops_sweaters", description: "Knitted garment worn on the upper part of the body, providing warmth.", imagePath: "assets/images/category/tops/sweater.webp"),
    ],
    'category_bottoms': [
       _HelpItem(titleKey: "category_bottoms_jeans", description: "Pants made from denim fabric, typically for casual wear.", imagePath: "assets/images/category/bottoms/jeans.webp"),
       _HelpItem(titleKey: "category_bottoms_trousers", description: "A more general term for pants, can be casual or formal.", imagePath: "assets/images/category/bottoms/trousers.webp"),
       _HelpItem(titleKey: "category_bottoms_dress_pants", description: "Formal pants intended for wear with a suit or blazer.", imagePath: "assets/images/category/bottoms/dresspants.webp"),
       _HelpItem(titleKey: "category_bottoms_track_pants", description: "Casual and comfortable pants, typically for athletic purposes.", imagePath: "assets/images/category/bottoms/trackpants.webp"),
       _HelpItem(titleKey: "category_bottoms_leggings", description: "Tight-fitting stretch pants.", imagePath: "assets/images/category/bottoms/leggings.webp"),
       _HelpItem(titleKey: "category_bottoms_shorts", description: "Garment worn over the pelvic area, circling the waist and splitting to cover the upper part of the legs.", imagePath: "assets/images/category/bottoms/shorts.webp"),
    ],
    'category_dresses_jumpsuits': [
      _HelpItem(titleKey: "category_dresses_jumpsuits_mini_skirts", description: "A skirt with a hemline well above the knees.", imagePath: "assets/images/category/dresses/miniskirt.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_midi_skirts", description: "A skirt with a hemline halfway between the knee and the ankle.", imagePath: "assets/images/category/dresses/midiskirt.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_maxi_skirts", description: "A long skirt with a hemline at or near the ankles.", imagePath: "assets/images/category/dresses/maxiskirt.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_day_dresses", description: "A casual dress suitable for daytime wear.", imagePath: "assets/images/category/dresses/daydress.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_tshirt_dresses", description: "A casual dress made of t-shirt fabric.", imagePath: "assets/images/category/dresses/tshirtdress.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_shirt_dresses", description: "A dress that borrows details from a man's shirt.", imagePath: "assets/images/category/dresses/shirtdress.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_jumpsuits", description: "A one-piece garment consisting of a blouse or shirt with attached trousers.", imagePath: "assets/images/category/dresses/jumpsuit.webp"),
      _HelpItem(titleKey: "category_dresses_jumpsuits_party_dresses", description: "An elegant dress for special occasions.", imagePath: "assets/images/category/dresses/partydress.webp"),
    ],
    'category_outerwear': [
      _HelpItem(titleKey: "category_outerwear_coats", description: "A long outer garment worn for warmth or as a fashion item.", imagePath: "assets/images/category/outerwear/coat.webp"),
      _HelpItem(titleKey: "category_outerwear_blazers", description: "A type of jacket resembling a suit jacket, but cut more casually.", imagePath: "assets/images/category/outerwear/blazer.webp"),
      _HelpItem(titleKey: "category_outerwear_jackets", description: "A mid-stomach–length garment for the upper body.", imagePath: "assets/images/category/outerwear/jacket.webp"),
      _HelpItem(titleKey: "category_outerwear_cardigans", description: "A type of knitted sweater that has an open front.", imagePath: "assets/images/category/outerwear/cardigan.webp"),
      _HelpItem(titleKey: "category_outerwear_vests", description: "A sleeveless upper-body garment.", imagePath: "assets/images/category/outerwear/vest.webp"),
    ],
    'category_footwear': [
      _HelpItem(titleKey: "category_footwear_sneakers", description: "Shoes designed for sports or other forms of physical exercise.", imagePath: "assets/images/category/footwear/sneakers.webp"),
      _HelpItem(titleKey: "category_footwear_boots", description: "A sturdy item of footwear covering the foot and ankle.", imagePath: "assets/images/category/footwear/boots.webp"),
      _HelpItem(titleKey: "category_footwear_heels", description: "Footwear that raises the heel of the wearer's foot.", imagePath: "assets/images/category/footwear/heels.webp"),
      _HelpItem(titleKey: "category_footwear_sandals", description: "Open type of footwear consisting of a sole held to the wearer's foot by straps.", imagePath: "assets/images/category/footwear/sandals.webp"),
    ],
    'category_bags': [
      _HelpItem(titleKey: "category_bags_tote_bags", description: "A large and often unfastened bag with parallel handles.", imagePath: "assets/images/category/bags/tote.webp"),
      _HelpItem(titleKey: "category_bags_backpacks", description: "A bag carried on one's back, supported by straps over the shoulders.", imagePath: "assets/images/category/bags/backpack.webp"),
    ],
    'category_hats': [
      _HelpItem(titleKey: "category_hats_caps", description: "A flat head covering, with a visor.", imagePath: "assets/images/category/hats/cap.webp"),
      _HelpItem(titleKey: "category_hats_beanies", description: "A close-fitting, brimless cap.", imagePath: "assets/images/category/hats/beanie.webp"),
    ],
  };

  late String _selectedMainCategory;

  @override
  void initState() {
    super.initState();
    _selectedMainCategory = _categoryHelpItems.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    final subItems = _categoryHelpItems[_selectedMainCategory] ?? [];

    return PageScaffold(
      appBar: AppBar(
        title: const Text("Category Guide"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: _categoryHelpItems.keys.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mainCategoryKey = _categoryHelpItems.keys.elementAt(index);
                final isSelected = mainCategoryKey == _selectedMainCategory;
                return ChoiceChip(
                  label: Text(translateAppOption(mainCategoryKey, l10n)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMainCategory = mainCategoryKey;
                      });
                    }
                  },
                  shape: const StadiumBorder(),
                  side: isSelected ? BorderSide.none : BorderSide(color: theme.colorScheme.outline),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: subItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = subItems[index];
                return TipCard(
                  title: translateAppOption(item.titleKey, l10n),
                  description: item.description,
                  imagePath: item.imagePath,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}