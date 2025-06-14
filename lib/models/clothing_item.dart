// file: lib/models/clothing_item.dart

class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final String closetId;
  final String? season;
  final String? occasion;
  final String? material;
  final String? pattern;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    required this.closetId,
    // Thêm vào constructor
    this.season,
    this.occasion,
    this.material,
    this.pattern,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'closetId': closetId,
      // Thêm vào hàm
      'season': season,
      'occasion': occasion,
      'material': material,
      'pattern': pattern,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      imagePath: map['imagePath'],
      closetId: map['closetId'],
      // Thêm vào hàm
      season: map['season'],
      occasion: map['occasion'],
      material: map['material'],
      pattern: map['pattern'],
    );
  }
}