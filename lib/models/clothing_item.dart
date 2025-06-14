// file: lib/models/clothing_item.dart

class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final String closetId; // <-- THUỘC TÍNH MỚI

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    required this.closetId, // <-- THÊM VÀO CONSTRUCTOR
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'closetId': closetId, // <-- THÊM VÀO HÀM
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      imagePath: map['imagePath'],
      closetId: map['closetId'], // <-- THÊM VÀO HÀM
    );
  }
}