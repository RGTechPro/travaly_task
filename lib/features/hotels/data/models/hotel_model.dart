import '../../domain/entities/hotel.dart';

class HotelModel extends Hotel {
  const HotelModel({
    required super.id,
    required super.name,
    required super.city,
    required super.state,
    required super.country,
    super.imageUrl,
    super.description,
    super.rating,
    super.address,
    super.stars,
    super.price,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final propertyAddress = json['propertyAddress'] ?? json['address'] ?? {};

    return HotelModel(
      id: json['propertyCode']?.toString() ??
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['propertyName']?.toString() ??
          json['name']?.toString() ??
          'Unknown Hotel',
      city:
          propertyAddress['city']?.toString() ?? json['city']?.toString() ?? '',
      state: propertyAddress['state']?.toString() ??
          json['state']?.toString() ??
          '',
      country: propertyAddress['country']?.toString() ??
          json['country']?.toString() ??
          '',
      imageUrl: json['propertyImage'] is String
          ? json['propertyImage']
          : json['propertyImage']?['fullUrl']?.toString() ??
              json['image_url']?.toString() ??
              json['image']?.toString(),
      description: json['description']?.toString(),
      rating: _parseRating(json),
      address:
          propertyAddress['street']?.toString() ?? json['address']?.toString(),
      stars: json['propertyStar'] ?? json['stars'],
      price: _parsePrice(json),
    );
  }

  static double? _parseRating(Map<String, dynamic> json) {
    if (json['rating'] != null) {
      return double.tryParse(json['rating'].toString());
    }
    if (json['googleReview']?['reviewPresent'] == true) {
      final rating = json['googleReview']?['data']?['overallRating'];
      return rating != null ? double.tryParse(rating.toString()) : null;
    }
    return null;
  }

  static String? _parsePrice(Map<String, dynamic> json) {
    if (json['staticPrice'] != null) {
      return json['staticPrice']['displayAmount']?.toString();
    }
    if (json['propertyMinPrice'] != null) {
      return json['propertyMinPrice']['displayAmount']?.toString();
    }
    return null;
  }

  Hotel toEntity() {
    return Hotel(
      id: id,
      name: name,
      city: city,
      state: state,
      country: country,
      imageUrl: imageUrl,
      description: description,
      rating: rating,
      address: address,
      stars: stars,
      price: price,
    );
  }
}
