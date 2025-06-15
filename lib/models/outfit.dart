// file: lib/models/outfit.dart

class Outfit {
  final String id;
  final String name;
  final String imagePath; // Đường dẫn tới ảnh screenshot của bộ đồ
  final String itemIds;   // Chuỗi các ID của clothing_item, ngăn cách bởi dấu phẩy

  Outfit({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.itemIds,
  });

  // Chuyển đổi từ Map (đọc từ CSDL) sang đối tượng Outfit
  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      itemIds: map['itemIds'] as String,
    );
  }

  // Chuyển đổi từ đối tượng Outfit sang Map (để ghi vào CSDL)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'itemIds': itemIds,
    };
  }
}