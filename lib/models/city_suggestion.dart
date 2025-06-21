// lib/models/city_suggestion.dart

import 'package:equatable/equatable.dart';

class CitySuggestion extends Equatable {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final String? state; // Một số thành phố có bang (state)

  const CitySuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    this.state,
  });

  // Hiển thị tên đầy đủ để phân biệt, ví dụ "London, GB" hoặc "Portland, Oregon, US"
  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }

  factory CitySuggestion.fromMap(Map<String, dynamic> map) {
    return CitySuggestion(
      name: map['name'] as String? ?? 'N/A',
      country: map['country'] as String? ?? 'N/A',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (map['lon'] as num?)?.toDouble() ?? 0.0,
      state: map['state'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, country, lat, lon, state];
}