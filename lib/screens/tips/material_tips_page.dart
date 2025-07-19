// lib/screens/tips/material_tips_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/tip_card.dart';

class _HelpItem {
  final String title;
  final String description;
  final String imagePath;
  const _HelpItem({ required this.title, required this.description, required this.imagePath });
}

class MaterialTipsPage extends StatelessWidget {
  const MaterialTipsPage({super.key});

  // <<< BẮT ĐẦU THAY ĐỔI DỮ LIỆU TẠI ĐÂY >>>
  static const List<_HelpItem> _materialHelpItems = [
    _HelpItem(
      title: "Cotton",
      description: "A soft, breathable natural fiber. Commonly used for t-shirts, jeans, and everyday wear.",
      imagePath: 'assets/images/materials/cotton.webp',
    ),
    _HelpItem(
      title: "Linen",
      description: "A lightweight natural fiber made from the flax plant, known for its coolness in hot weather.",
      imagePath: 'assets/images/materials/linen.webp',
    ),
    _HelpItem(
      title: "Wool",
      description: "A natural fiber from sheep, known for its warmth and insulation. Used for sweaters, coats, and suits.",
      imagePath: 'assets/images/materials/wool.webp',
    ),
    _HelpItem(
      title: "Silk",
      description: "A luxurious natural protein fiber, known for its softness and sheen. Used for blouses, dresses, and scarves.",
      imagePath: 'assets/images/materials/silk.webp',
    ),
    _HelpItem(
      title: "Polyester",
      description: "A durable, wrinkle-resistant synthetic fiber. Often blended with other fibers and used in a wide variety of clothing.",
      imagePath: 'assets/images/materials/polyester.webp',
    ),
    _HelpItem(
      title: "Nylon",
      description: "A strong and elastic synthetic fiber, often used for swimwear, activewear, and hosiery.",
      imagePath: 'assets/images/materials/nylon.webp',
    ),
    _HelpItem(
      title: "Denim",
      description: "A sturdy cotton twill fabric, typically blue, used for jeans, jackets, and skirts.",
      imagePath: 'assets/images/materials/denim.webp',
    ),
    _HelpItem(
      title: "Leather",
      description: "A durable material made from the tanned skin of an animal. Used for jackets, shoes, and bags.",
      imagePath: 'assets/images/materials/leather.webp',
    ),
  ];
  // <<< KẾT THÚC THAY ĐỔI DỮ LIỆU >>>

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(
        title: const Text("Material Guide"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _materialHelpItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _materialHelpItems[index];
          return TipCard(
            title: item.title,
            description: item.description,
            imagePath: item.imagePath,
          );
        },
      ),
    );
  }
}