// lib/models/outfit.dart
import 'package:equatable/equatable.dart';

class Outfit extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final String itemIds;
  final bool isFixed; // <<< THÊM MỚI: Thuộc tính để xác định bộ đồ cố định

  const Outfit({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.itemIds,
    this.isFixed = false, // <<< THÊM MỚI: Giá trị mặc định là false
  });

  Outfit copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? itemIds,
    bool? isFixed, // <<< THÊM MỚI
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      itemIds: itemIds ?? this.itemIds,
      isFixed: isFixed ?? this.isFixed, // <<< THÊM MỚI
    );
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      itemIds: map['itemIds'] as String,
      // <<< THÊM MỚI: Đọc giá trị is_fixed từ CSDL >>>
      // Chuyển đổi từ INTEGER (0 hoặc 1) sang bool (false hoặc true)
      // `?? 0` để tương thích với các dòng dữ liệu cũ chưa có cột này
      isFixed: (map['is_fixed'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'itemIds': itemIds,
      // <<< THÊM MỚI: Lưu giá trị isFixed vào CSDL >>>
      // Chuyển đổi từ bool sang INTEGER
      'is_fixed': isFixed ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, name, imagePath, itemIds, isFixed]; // <<< THÊM MỚI
}