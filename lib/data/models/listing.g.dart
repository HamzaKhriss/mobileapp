// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Listing _$ListingFromJson(Map<String, dynamic> json) => Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      titleFr: json['titleFr'] as String?,
      description: json['description'] as String,
      descriptionFr: json['descriptionFr'] as String?,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      location:
          ListingLocation.fromJson(json['location'] as Map<String, dynamic>),
      availability: (json['availability'] as List<dynamic>)
          .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      amenities:
          (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      host: ListingHost.fromJson(json['host'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ListingToJson(Listing instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleFr': instance.titleFr,
      'description': instance.description,
      'descriptionFr': instance.descriptionFr,
      'category': instance.category,
      'price': instance.price,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'images': instance.images,
      'location': instance.location,
      'availability': instance.availability,
      'amenities': instance.amenities,
      'host': instance.host,
      'createdAt': instance.createdAt,
    };

ListingLocation _$ListingLocationFromJson(Map<String, dynamic> json) =>
    ListingLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      addressFr: json['addressFr'] as String?,
    );

Map<String, dynamic> _$ListingLocationToJson(ListingLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
      'addressFr': instance.addressFr,
    };

ListingHost _$ListingHostFromJson(Map<String, dynamic> json) => ListingHost(
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$ListingHostToJson(ListingHost instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatar': instance.avatar,
      'verified': instance.verified,
    };

AvailabilitySlot _$AvailabilitySlotFromJson(Map<String, dynamic> json) =>
    AvailabilitySlot(
      slotId: (json['slot_id'] as num).toInt(),
      listingId: (json['listing_id'] as num).toInt(),
      dateSlotStart: json['date_slot_start'] as String,
      dateSlotEnd: json['date_slot_end'] as String,
      capacity: (json['capacity'] as num).toInt(),
      bookedCount: (json['booked_count'] as num).toInt(),
      isAvailable: json['is_available'] as bool,
    );

Map<String, dynamic> _$AvailabilitySlotToJson(AvailabilitySlot instance) =>
    <String, dynamic>{
      'slot_id': instance.slotId,
      'listing_id': instance.listingId,
      'date_slot_start': instance.dateSlotStart,
      'date_slot_end': instance.dateSlotEnd,
      'capacity': instance.capacity,
      'booked_count': instance.bookedCount,
      'is_available': instance.isAvailable,
    };

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': instance.data.map(toJsonT).toList(),
      'total': instance.total,
      'page': instance.page,
      'per_page': instance.perPage,
      'has_more': instance.hasMore,
    };
