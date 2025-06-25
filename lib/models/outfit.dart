// lib/models/outfit.dart
import 'package:equatable/equatable.dart';

class Outfit extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final String? thumbnailPath;
  final String itemIds;
  final bool isFixed;
  final DateTime? lastWornDate; // <<< THÊM MỚI

  const Outfit({
    required this.id,
    required this.name,
    required this.imagePath,
    this.thumbnailPath,
    required this.itemIds,
    this.isFixed = false,
    this.lastWornDate, // <<< THÊM MỚI
  });

  Outfit copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? thumbnailPath,
    String? itemIds,
    bool? isFixed,
    DateTime? lastWornDate, // <<< THÊM MỚI
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      itemIds: itemIds ?? this.itemIds,
      isFixed: isFixed ?? this.isFixed,
      lastWornDate: lastWornDate ?? this.lastWornDate, // <<< THÊM MỚI
    );
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      thumbnailPath: map['thumbnailPath'] as String?,
      itemIds: map['itemIds'] as String,
      isFixed: (map['is_fixed'] as int? ?? 0) == 1,
      // <<< THÊM MỚI: Chuyển đổi từ text trong CSDL sang DateTime
      lastWornDate: map['lastWornDate'] != null
          ? DateTime.tryParse(map['lastWornDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'itemIds': itemIds,
      'is_fixed': isFixed ? 1 : 0,
      // <<< THÊM MỚI: Chuyển đổi từ DateTime sang text để lưu vào CSDL
      'lastWornDate': lastWornDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, imagePath, thumbnailPath, itemIds, isFixed, lastWornDate]; // <<< THÊM MỚI
}