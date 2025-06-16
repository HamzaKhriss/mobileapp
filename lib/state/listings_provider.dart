import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';

final listingsProvider = FutureProvider<List<MockListing>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  return MockData.listings;
});

final listingByIdProvider = Provider.family<MockListing?, String>((ref, id) {
  final listingsAsync = ref.watch(listingsProvider);

  return listingsAsync.when(
    data:
        (listings) => listings.firstWhere(
          (listing) => listing.id == id,
          orElse: () => throw Exception('Listing not found'),
        ),
    loading: () => null,
    error: (_, __) => null,
  );
});

final reviewsProvider = FutureProvider<List<MockReview>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockData.reviews;
});

final availabilityProvider = FutureProvider<Map<String, List<DateTime>>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return MockData.availability;
});
