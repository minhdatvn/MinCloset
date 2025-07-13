// lib/models/closet.dart

import 'package:equatable/equatable.dart'; // Thêm Equatable để so sánh object

class Closet extends Equatable {
  final String id;
  final String name;
  final String? iconName; // Tên của icon, ví dụ: 'work', 'gym'
  final String? colorHex; // Mã màu hex, ví dụ: '#FF5733'

  const Closet({
    required this.id,
    required this.name,
    this.iconName, // Thêm vào constructor
    this.colorHex, // Thêm vào constructor
  });

  Closet copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
  }) {
    return Closet(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      // --- THÊM 2 DÒNG MỚI ---
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }

  factory Closet.fromMap(Map<String, dynamic> map) {
    return Closet(
      id: map['id'] as String,
      name: map['name'] as String,
      // --- THÊM 2 DÒNG MỚI ---
      iconName: map['iconName'] as String?,
      colorHex: map['colorHex'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, iconName, colorHex];
}