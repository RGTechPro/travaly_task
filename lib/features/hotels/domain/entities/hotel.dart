import 'package:equatable/equatable.dart';

class Hotel extends Equatable {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final String? imageUrl;
  final String? description;
  final double? rating;
  final String? address;
  final int? stars;
  final String? price;

  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    this.imageUrl,
    this.description,
    this.rating,
    this.address,
    this.stars,
    this.price,
  });

  String get fullLocation {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        state,
        country,
        imageUrl,
        description,
        rating,
        address,
        stars,
        price,
      ];
}
