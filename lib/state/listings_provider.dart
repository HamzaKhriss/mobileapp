import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/listing.dart';
import '../data/models/booking.dart';
import '../data/services/listings_service.dart';
import '../data/services/location_service.dart';

// Services
final listingsServiceProvider = Provider<ListingsService>((ref) {
  return ListingsService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Location state
final userLocationProvider = FutureProvider<LocationData>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getUserLocationOrDefault();
});

// Listings state with filters
class ListingsNotifier extends StateNotifier<AsyncValue<List<Listing>>> {
  final ListingsService _listingsService;
  ListingFilters? _currentFilters;
  int _currentPage = 1;
  bool _hasMore = true;
  List<Listing> _allListings = [];

  ListingsNotifier(this._listingsService) : super(const AsyncValue.loading()) {
    loadListings();
  }

  Future<void> loadListings({
    ListingFilters? filters,
    bool refresh = false,
  }) async {
    print(
        '[ListingsNotifier] 🚀 Loading listings - refresh: $refresh, filters: $filters');

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _allListings = [];
      state = const AsyncValue.loading();
    }

    if (filters != null) {
      _currentFilters = filters;
      _currentPage = 1;
      _hasMore = true;
      _allListings = [];
      state = const AsyncValue.loading();
    }

    if (!_hasMore && !refresh && filters == null) {
      print('[ListingsNotifier] ⏹️ Not loading more - hasMore: $_hasMore');
      return;
    }

    try {
      print('[ListingsNotifier] 📞 Calling listings service...');
      final response = await _listingsService.getListings(
        filters: _currentFilters,
        page: _currentPage,
        limit: 100,
      );

      print(
          '[ListingsNotifier] ✅ Got response - data count: ${response.data.length}, hasMore: ${response.hasMore}');

      if (_currentPage == 1) {
        _allListings = response.data;
      } else {
        _allListings.addAll(response.data);
      }

      _hasMore = response.hasMore;
      _currentPage++;

      state = AsyncValue.data(_allListings);
      print(
          '[ListingsNotifier] 🎯 Updated state with ${_allListings.length} listings');
    } catch (error, stackTrace) {
      print('[ListingsNotifier] ❌ Error loading listings: $error');
      print('[ListingsNotifier] 📍 Stack trace: $stackTrace');

      if (_currentPage == 1) {
        state = AsyncValue.error(error, stackTrace);
      }
      // If loading more pages fails, keep current data
    }
  }

  Future<void> loadMoreListings() async {
    if (!_hasMore) return;
    await loadListings();
  }

  Future<void> refreshListings() async {
    await loadListings(refresh: true);
  }

  void applyFilters(ListingFilters filters) {
    loadListings(filters: filters);
  }

  void clearFilters() {
    loadListings(filters: ListingFilters());
  }

  bool get hasMore => _hasMore;
  ListingFilters? get currentFilters => _currentFilters;
}

final listingsProvider =
    StateNotifierProvider<ListingsNotifier, AsyncValue<List<Listing>>>((ref) {
  final service = ref.read(listingsServiceProvider);
  return ListingsNotifier(service);
});

// Individual listing provider
final listingByIdProvider =
    FutureProvider.family<Listing, String>((ref, id) async {
  final service = ref.read(listingsServiceProvider);
  return await service.getListing(id);
});

// Search provider
final searchListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];

  final service = ref.read(listingsServiceProvider);
  return await service.searchListings(query);
});

// Reviews provider
final reviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, listingId) async {
  final service = ref.read(listingsServiceProvider);
  return await service.getReviews(listingId);
});

// Bookings provider
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(listingsServiceProvider);
  return await service.getBookings();
});

// Favorites provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<String>>>((ref) {
  final service = ref.read(listingsServiceProvider);
  return FavoritesNotifier(service);
});

class FavoritesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final ListingsService _listingsService;

  FavoritesNotifier(this._listingsService) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await _listingsService.getFavorites();
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(String listingId) async {
    final currentFavorites = state.value ?? [];
    final isFavorite = currentFavorites.contains(listingId);

    try {
      if (isFavorite) {
        await _listingsService.removeFavorite(listingId);
        state = AsyncValue.data(
          currentFavorites.where((id) => id != listingId).toList(),
        );
      } else {
        await _listingsService.addFavorite(listingId);
        state = AsyncValue.data([...currentFavorites, listingId]);
      }
    } catch (error, stackTrace) {
      // Revert state on error
      state = AsyncValue.data(currentFavorites);
      rethrow;
    }
  }

  bool isFavorite(String listingId) {
    return state.value?.contains(listingId) ?? false;
  }
}

// Favorite listings provider - watches favorites to auto-refresh
final favoriteListingsProvider = FutureProvider<List<Listing>>((ref) async {
  // Watch favorites to trigger rebuild when favorites change
  final favoritesAsync = ref.watch(favoritesProvider);
  final service = ref.read(listingsServiceProvider);

  // Wait for favorites to load
  final favoriteIds = await favoritesAsync.when(
    data: (ids) => ids,
    loading: () => throw Exception('Loading favorites...'),
    error: (error, stack) => throw error,
  );

  if (favoriteIds.isEmpty) return [];

  // Fetch each favorite listing, handle errors gracefully
  final listings = <Listing>[];
  for (final id in favoriteIds) {
    try {
      final listing = await service.getListing(id);
      listings.add(listing);
    } catch (e) {
      // Skip listings that fail to load
      print('Failed to load favorite listing $id: $e');
    }
  }

  return listings;
});

// Create booking provider
final createBookingProvider =
    FutureProvider.family<Booking, BookingRequest>((ref, request) async {
  final service = ref.read(listingsServiceProvider);
  return await service.createBooking(
    listingId: request.listingId,
    slotId: request.slotId,
    date: request.date,
    time: request.time,
    participants: request.participants,
    specialRequests: request.specialRequests,
  );
});

// Submit review provider
final submitReviewProvider =
    FutureProvider.family<Review, ReviewRequest>((ref, request) async {
  final service = ref.read(listingsServiceProvider);
  return await service.leaveReview(
    listingId: request.listingId,
    rating: request.rating,
    comment: request.comment,
  );
});

// Review request class for the provider
class ReviewRequest {
  final int listingId;
  final double rating;
  final String comment;

  ReviewRequest({
    required this.listingId,
    required this.rating,
    required this.comment,
  });
}

// Map-specific provider that loads all listings (no pagination limit)
final mapListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final service = ref.read(listingsServiceProvider);

  try {
    print('[MapListingsProvider] 🗺️ Loading all listings for map...');

    // Load a reasonable number of listings for the map
    final response = await service.getListings(
      filters: ListingFilters(), // No filters for map - show everything
      page: 1,
      limit: 100, // Reduced from 1000 to avoid backend issues
    );

    print(
        '[MapListingsProvider] ✅ Loaded ${response.data.length} listings for map');
    return response.data;
  } catch (error, stackTrace) {
    print('[MapListingsProvider] ❌ Error loading map listings: $error');
    rethrow;
  }
});
