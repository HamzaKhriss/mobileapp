import 'package:json_annotation/json_annotation.dart';

part 'listing.g.dart';

@JsonSerializable()
class Listing {
  final String id;
  final String title;
  final String? titleFr;
  final String description;
  final String? descriptionFr;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final ListingLocation location;
  final List<AvailabilitySlot> availability;
  final List<String> amenities;
  final ListingHost host;
  final String createdAt;

  Listing({
    required this.id,
    required this.title,
    this.titleFr,
    required this.description,
    this.descriptionFr,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.location,
    required this.availability,
    required this.amenities,
    required this.host,
    required this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Custom mapping based on actual backend response (like web frontend)
    print(
        '[Listing] 🔍 Parsing listing: ${json['listing_id']} - ${json['name']}');

    // Extract coordinates from address field
    final address = json['address'] as Map<String, dynamic>?;
    final lat = (address?['latitude'] as num?)?.toDouble() ?? 33.5731;
    final lng = (address?['longitude'] as num?)?.toDouble() ?? -7.5898;
    final streetAddress =
        address?['street_address'] as String? ?? 'Casablanca, Morocco';

    print('[Listing] 📍 Location: lat=$lat, lng=$lng, address=$streetAddress');

    // Map category from object to string
    String categoryName = 'restaurant';
    final categoryObj = json['category'];
    if (categoryObj is Map<String, dynamic>) {
      final catName = categoryObj['category_name'] as String? ?? '';
      switch (catName.toLowerCase()) {
        case 'event':
        case 'entertainment':
          categoryName = 'event';
          break;
        case 'cultural':
        case 'cultural experience':
          categoryName = 'cultural';
          break;
        case 'culinary':
        case 'culinary experience':
        case 'restaurant':
          categoryName = 'restaurant';
          break;
      }
    }
    print('[Listing] 🏷️ Category: $categoryName (from ${categoryObj})');

    // Extract images array
    final images = (json['images'] as List?)?.cast<String>() ?? <String>[];
    print('[Listing] 📷 Images count: ${images.length}');

    // Extract availability slots
    final availabilityList = json['availability_slots'] as List? ?? [];
    final availability = availabilityList
        .map((slot) => AvailabilitySlot.fromJson(slot as Map<String, dynamic>))
        .toList();

    return Listing(
      id: (json['listing_id'] as num).toString(),
      title: json['name'] as String? ?? '',
      titleFr: json['title_fr'] as String?,
      description: json['description'] as String? ?? '',
      descriptionFr: json['description_fr'] as String?,
      category: categoryName,
      price: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      images: images,
      location: ListingLocation(
        lat: lat,
        lng: lng,
        address: streetAddress,
        addressFr: streetAddress,
      ),
      availability: availability,
      amenities: const [], // TODO: Extract from restaurant data if needed
      host: ListingHost(
        name: 'Casa Wonders Host', // TODO: Extract from partner data
        avatar: '/placeholder-avatar.jpg',
        verified: false,
      ),
      createdAt: json['creation_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$ListingToJson(this);
}

@JsonSerializable()
class ListingLocation {
  final double lat;
  final double lng;
  final String address;
  @JsonKey(name: 'addressFr')
  final String? addressFr;

  ListingLocation({
    required this.lat,
    required this.lng,
    required this.address,
    this.addressFr,
  });

  factory ListingLocation.fromJson(Map<String, dynamic> json) =>
      _$ListingLocationFromJson(json);
  Map<String, dynamic> toJson() => _$ListingLocationToJson(this);
}

@JsonSerializable()
class ListingHost {
  final String name;
  final String avatar;
  final bool verified;

  ListingHost({
    required this.name,
    required this.avatar,
    required this.verified,
  });

  factory ListingHost.fromJson(Map<String, dynamic> json) =>
      _$ListingHostFromJson(json);
  Map<String, dynamic> toJson() => _$ListingHostToJson(this);
}

@JsonSerializable()
class AvailabilitySlot {
  @JsonKey(name: 'slot_id')
  final int slotId;
  @JsonKey(name: 'listing_id')
  final int listingId;
  @JsonKey(name: 'date_slot_start')
  final String dateSlotStart;
  @JsonKey(name: 'date_slot_end')
  final String dateSlotEnd;
  final int capacity;
  @JsonKey(name: 'booked_count')
  final int bookedCount;
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  AvailabilitySlot({
    required this.slotId,
    required this.listingId,
    required this.dateSlotStart,
    required this.dateSlotEnd,
    required this.capacity,
    required this.bookedCount,
    required this.isAvailable,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilitySlotToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
 