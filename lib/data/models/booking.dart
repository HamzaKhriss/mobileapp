import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  @JsonKey(name: 'reservation_id')
  final int reservationId;
  @JsonKey(name: 'user_id')
  final int userId;

  // Handle nested listing object
  final BookingListing? listing;

  @JsonKey(name: 'date_time_reservation')
  final String? dateTimeReservation;
  @JsonKey(name: 'number_of_participants')
  final int? numberOfParticipants;
  final String? status;
  @JsonKey(name: 'total_price')
  final double? totalPrice;
  @JsonKey(name: 'special_requests')
  final String? specialRequests;

  Booking({
    required this.reservationId,
    required this.userId,
    this.listing,
    this.dateTimeReservation,
    this.numberOfParticipants,
    this.status,
    this.totalPrice,
    this.specialRequests,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    print('[Booking.fromJson] Raw JSON: $json');
    try {
      return _$BookingFromJson(json);
    } catch (e) {
      print('[Booking.fromJson] Error: $e');
      // Provide fallback values for required fields
      return Booking(
        reservationId: json['reservation_id'] ?? 0,
        userId: json['user_id'] ?? 0,
        listing: json['listing'] != null
            ? BookingListing.fromJson(json['listing'])
            : null,
        dateTimeReservation: json['date_time_reservation']?.toString(),
        numberOfParticipants: json['number_of_participants'],
        status: json['status']?.toString() ?? 'unknown',
        totalPrice: (json['total_price'] as num?)?.toDouble(),
        specialRequests: json['special_requests']?.toString(),
      );
    }
  }

  Map<String, dynamic> toJson() => _$BookingToJson(this);

  String get id => reservationId.toString();
  int get listingId => listing?.listingId ?? 0;
  String get listingName => listing?.name ?? 'Unknown Listing';
  String? get listingNameFr => listing?.name;
  DateTime? get dateTime => dateTimeReservation != null
      ? DateTime.tryParse(dateTimeReservation!)
      : null;
  String get formattedPrice =>
      totalPrice != null ? '${totalPrice!.toStringAsFixed(0)} MAD' : '0 MAD';
  String get date => dateTime?.toIso8601String().split('T')[0] ?? '';
  String get time =>
      dateTime?.toIso8601String().split('T')[1].split(':').take(2).join(':') ??
      '';
  int get participants => numberOfParticipants ?? 1;
}

@JsonSerializable()
class BookingListing {
  @JsonKey(name: 'listing_id')
  final int listingId;
  @JsonKey(name: 'partner_id')
  final int? partnerId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'address_id')
  final int? addressId;
  final String? name;
  final String? description;
  @JsonKey(name: 'base_price')
  final double? basePrice;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'creation_date')
  final String? creationDate;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'reviews_count')
  final int? reviewsCount;
  final List<String>? images;

  BookingListing({
    required this.listingId,
    this.partnerId,
    this.categoryId,
    this.addressId,
    this.name,
    this.description,
    this.basePrice,
    this.isActive,
    this.creationDate,
    this.averageRating,
    this.reviewsCount,
    this.images,
  });

  factory BookingListing.fromJson(Map<String, dynamic> json) =>
      _$BookingListingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingListingToJson(this);
}

@JsonSerializable()
class BookingRequest {
  @JsonKey(name: 'listing_id')
  final int listingId;
  @JsonKey(name: 'slot_id')
  final int slotId;
  final String date;
  final String time;
  final int participants;
  @JsonKey(name: 'special_requests')
  final String? specialRequests;
  @JsonKey(name: 'payment_token')
  final String paymentToken;

  BookingRequest({
    required this.listingId,
    required this.slotId,
    required this.date,
    required this.time,
    required this.participants,
    this.specialRequests,
    required this.paymentToken,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookingRequestToJson(this);
}

@JsonSerializable()
class Review {
  @JsonKey(name: 'review_id')
  final int reviewId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'listing_id')
  final int listingId;
  final double rating;
  @JsonKey(name: 'comment_text')
  final String commentText;
  @JsonKey(name: 'date_review')
  final String dateReview;
  @JsonKey(name: 'partner_reply')
  final String? partnerReply;
  @JsonKey(name: 'partner_reply_date')
  final String? partnerReplyDate;
  final ReviewUser? user;

  Review({
    required this.reviewId,
    required this.userId,
    required this.listingId,
    required this.rating,
    required this.commentText,
    required this.dateReview,
    this.partnerReply,
    this.partnerReplyDate,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    print('[Review.fromJson] Raw JSON: $json');

    try {
      // Handle different response formats
      return Review(
        reviewId: json['review_id'] ?? 0,
        userId: json['user_id'] ?? 0,
        listingId: json['listing_id'] ?? json['listing']?['listing_id'] ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        commentText: json['comment_text']?.toString() ?? '',
        dateReview:
            json['date_review']?.toString() ?? DateTime.now().toIso8601String(),
        partnerReply: json['partner_reply']?.toString(),
        partnerReplyDate: json['partner_reply_date']?.toString(),
        user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
      );
    } catch (e) {
      print('[Review.fromJson] Error parsing review: $e');
      // Return a default review to prevent crashes
      return Review(
        reviewId: json['review_id'] ?? 0,
        userId: json['user_id'] ?? 0,
        listingId: 0,
        rating: 0.0,
        commentText: 'Error loading review',
        dateReview: DateTime.now().toIso8601String(),
      );
    }
  }

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  DateTime get reviewDate => DateTime.parse(dateReview);
  String get userName => user?.firstName ?? 'Anonymous';
  String get userAvatar => user?.avatarUrl ?? '';
}

@JsonSerializable()
class ReviewUser {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  ReviewUser({
    required this.firstName,
    this.avatarUrl,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) =>
      _$ReviewUserFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewUserToJson(this);
}

@JsonSerializable()
class ReviewRequest {
  @JsonKey(name: 'listing_id')
  final int listingId;
  final double rating;
  @JsonKey(name: 'comment_text')
  final String commentText;

  ReviewRequest({
    required this.listingId,
    required this.rating,
    required this.commentText,
  });

  factory ReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewRequestToJson(this);
}
