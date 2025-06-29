// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      reservationId: (json['reservation_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      listing: json['listing'] == null
          ? null
          : BookingListing.fromJson(json['listing'] as Map<String, dynamic>),
      dateTimeReservation: json['date_time_reservation'] as String?,
      numberOfParticipants: (json['number_of_participants'] as num?)?.toInt(),
      status: json['status'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      specialRequests: json['special_requests'] as String?,
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'reservation_id': instance.reservationId,
      'user_id': instance.userId,
      'listing': instance.listing,
      'date_time_reservation': instance.dateTimeReservation,
      'number_of_participants': instance.numberOfParticipants,
      'status': instance.status,
      'total_price': instance.totalPrice,
      'special_requests': instance.specialRequests,
    };

BookingListing _$BookingListingFromJson(Map<String, dynamic> json) =>
    BookingListing(
      listingId: (json['listing_id'] as num).toInt(),
      partnerId: (json['partner_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      addressId: (json['address_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool?,
      creationDate: json['creation_date'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BookingListingToJson(BookingListing instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'partner_id': instance.partnerId,
      'category_id': instance.categoryId,
      'address_id': instance.addressId,
      'name': instance.name,
      'description': instance.description,
      'base_price': instance.basePrice,
      'is_active': instance.isActive,
      'creation_date': instance.creationDate,
      'average_rating': instance.averageRating,
      'reviews_count': instance.reviewsCount,
      'images': instance.images,
    };

BookingRequest _$BookingRequestFromJson(Map<String, dynamic> json) =>
    BookingRequest(
      listingId: (json['listing_id'] as num).toInt(),
      slotId: (json['slot_id'] as num).toInt(),
      date: json['date'] as String,
      time: json['time'] as String,
      participants: (json['participants'] as num).toInt(),
      specialRequests: json['special_requests'] as String?,
      paymentToken: json['payment_token'] as String,
    );

Map<String, dynamic> _$BookingRequestToJson(BookingRequest instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'slot_id': instance.slotId,
      'date': instance.date,
      'time': instance.time,
      'participants': instance.participants,
      'special_requests': instance.specialRequests,
      'payment_token': instance.paymentToken,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      reviewId: (json['review_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      listingId: (json['listing_id'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      commentText: json['comment_text'] as String,
      dateReview: json['date_review'] as String,
      partnerReply: json['partner_reply'] as String?,
      partnerReplyDate: json['partner_reply_date'] as String?,
      user: json['user'] == null
          ? null
          : ReviewUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'review_id': instance.reviewId,
      'user_id': instance.userId,
      'listing_id': instance.listingId,
      'rating': instance.rating,
      'comment_text': instance.commentText,
      'date_review': instance.dateReview,
      'partner_reply': instance.partnerReply,
      'partner_reply_date': instance.partnerReplyDate,
      'user': instance.user,
    };

ReviewUser _$ReviewUserFromJson(Map<String, dynamic> json) => ReviewUser(
      firstName: json['first_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$ReviewUserToJson(ReviewUser instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'avatar_url': instance.avatarUrl,
    };

ReviewRequest _$ReviewRequestFromJson(Map<String, dynamic> json) =>
    ReviewRequest(
      listingId: (json['listing_id'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      commentText: json['comment_text'] as String,
    );

Map<String, dynamic> _$ReviewRequestToJson(ReviewRequest instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'rating': instance.rating,
      'comment_text': instance.commentText,
    };
