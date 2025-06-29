import '../models/listing.dart';
import '../models/booking.dart';
import 'api_client.dart';

class ListingFilters {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? date;
  final LocationFilter? location;

  ListingFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.date,
    this.location,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (category != null) params['category'] = category;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (minRating != null) params['minRating'] = minRating;
    if (date != null) params['date_from'] = date;
    if (location != null) {
      params['lat'] = location!.lat;
      params['lng'] = location!.lng;
      params['radius'] = location!.radius;
    }

    return params;
  }
}

class LocationFilter {
  final double lat;
  final double lng;
  final double radius;

  LocationFilter({
    required this.lat,
    required this.lng,
    required this.radius,
  });
}

class ListingsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<PaginatedResponse<Listing>> getListings({
    ListingFilters? filters,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      print(
          '[ListingsService] 🎯 Getting listings - page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': limit,
        '_t': DateTime.now().millisecondsSinceEpoch, // Cache busting
        ...?filters?.toQueryParameters(),
      };

      print('[ListingsService] 📋 Query params: $queryParams');

      final response = await _apiClient.get(
        '/user/listings',
        queryParameters: queryParams,
      );

      print(
          '[ListingsService] 📦 Raw response data type: ${response.data.runtimeType}');
      print('[ListingsService] 📦 Raw response data: ${response.data}');

      return PaginatedResponse.fromJson(
        response.data,
        (json) => Listing.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stackTrace) {
      print('[ListingsService] ❌ Error getting listings: $e');
      print('[ListingsService] 📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Listing>> searchListings(String keyword) async {
    final response = await _apiClient.get(
      '/user/listings',
      queryParameters: {
        'search': keyword.trim(),
        'page': 1,
        'per_page': 100,
        '_t': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Extract data array from paginated response
    final data = response.data['data'] as List;
    return data.map((json) => Listing.fromJson(json)).toList();
  }

  Future<Listing> getListing(String id) async {
    final response = await _apiClient.get('/user/items/$id');
    return Listing.fromJson(response.data);
  }

  Future<List<Review>> getReviews(String listingId) async {
    try {
      print('[ListingsService] 🔍 Getting reviews for listing: $listingId');
      final response = await _apiClient.get('/user/items/$listingId/reviews');

      print('[ListingsService] 📝 Reviews response: ${response.data}');
      print(
          '[ListingsService] 📝 Reviews response type: ${response.data.runtimeType}');

      final data = response.data as List;
      final reviews = data.map((json) => Review.fromJson(json)).toList();

      print(
          '[ListingsService] ✅ Successfully parsed ${reviews.length} reviews');
      return reviews;
    } catch (e, stackTrace) {
      print('[ListingsService] ❌ Error getting reviews: $e');
      print('[ListingsService] 📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Review> leaveReview({
    required int listingId,
    required double rating,
    required String comment,
  }) async {
    final response = await _apiClient.post(
      '/user/reviews',
      data: {
        'listing_id': listingId,
        'rating': rating,
        'comment_text': comment,
      },
    );

    return Review.fromJson(response.data);
  }

  Future<Booking> createBooking({
    required int listingId,
    required int slotId,
    required String date,
    required String time,
    required int participants,
    String? specialRequests,
  }) async {
    final response = await _apiClient.post(
      '/user/reservations',
      data: {
        'listing_id': listingId,
        'slot_id': slotId,
        'date_time_reservation': '${date}T$time:00Z',
        'number_of_participants': participants,
        'special_requests': specialRequests,
        'payment_token':
            'flutter-demo-${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    return Booking.fromJson(response.data);
  }

  Future<List<Booking>> getBookings() async {
    final response = await _apiClient.get('/user/reservations');

    final data = response.data as List;
    return data.map((json) => Booking.fromJson(json)).toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _apiClient.post('/user/reservations/$bookingId/cancel');
  }

  Future<List<String>> getFavorites() async {
    final response = await _apiClient.get('/user/favorites');

    final data = response.data as List;
    // Map favorites to listing IDs
    return data
        .map((f) =>
            (f['listing_id'] ?? f['listing']?['listing_id'] ?? '').toString())
        .toList();
  }

  Future<void> addFavorite(String listingId) async {
    await _apiClient.post('/user/favorites', data: {
      'listing_id': int.parse(listingId),
    });
  }

  Future<void> removeFavorite(String listingId) async {
    await _apiClient.delete('/user/favorites/$listingId');
  }

  Future<List<Listing>> getFavoriteListings() async {
    final favoriteIds = await getFavorites();

    if (favoriteIds.isEmpty) return [];

    // Fetch each favorite listing, handle errors gracefully
    final listings = <Listing>[];
    for (final id in favoriteIds) {
      try {
        final listing = await getListing(id);
        listings.add(listing);
      } catch (e) {
        // Skip listings that fail to load
        print('Failed to load favorite listing $id: $e');
      }
    }

    return listings;
  }
}
