// lib/models/clothing_item.dart

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
    this.season,
    this.occasion,
    this.material,
    this.pattern,
  });

  // <<< THÊM TOÀN BỘ PHƯƠNG THỨC NÀY VÀO LỚP CỦA BẠN
  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    String? imagePath,
    String? closetId,
    String? season,
    String? occasion,
    String? material,
    String? pattern,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      closetId: closetId ?? this.closetId,
      season: season ?? this.season,
      occasion: occasion ?? this.occasion,
      material: material ?? this.material,
      pattern: pattern ?? this.pattern,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'closetId': closetId,
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
      season: map['season'],
      occasion: map['occasion'],
      material: map['material'],
      pattern: map['pattern'],
    );
  }
}