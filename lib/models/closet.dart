// file: lib/models/closet.dart

class Closet {
  final String id;
  final String name;

  Closet({
    required this.id,
    required this.name,
  });

  Closet copyWith({
    String? id,
    String? name,
  }) {
    return Closet(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Closet.fromMap(Map<String, dynamic> map) {
    return Closet(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}