// lib/models/outfit.dart
import 'package:equatable/equatable.dart';

class Outfit extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final String? thumbnailPath; // <<< THÊM MỚI
  final String itemIds;
  final bool isFixed;

  const Outfit({
    required this.id,
    required this.name,
    required this.imagePath,
    this.thumbnailPath, // <<< THÊM MỚI
    required this.itemIds,
    this.isFixed = false,
  });

  Outfit copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? thumbnailPath, // <<< THÊM MỚI
    String? itemIds,
    bool? isFixed,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath, // <<< THÊM MỚI
      itemIds: itemIds ?? this.itemIds,
      isFixed: isFixed ?? this.isFixed,
    );
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      thumbnailPath: map['thumbnailPath'] as String?, // <<< THÊM MỚI
      itemIds: map['itemIds'] as String,
      isFixed: (map['is_fixed'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath, // <<< THÊM MỚI
      'itemIds': itemIds,
      'is_fixed': isFixed ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, name, imagePath, thumbnailPath, itemIds, isFixed]; // <<< THÊM MỚI
}