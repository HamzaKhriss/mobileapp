import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/listing.dart';
import 'listings_provider.dart';

// Re-export favorites provider from listings_provider for consistency
final wishlistProvider = favoritesProvider;

// Wishlist listings provider (favorite listings)
final wishlistListingsProvider = favoriteListingsProvider;

// Helper provider to check if a listing is in wishlist
final isInWishlistProvider = Provider.family<bool, String>((ref, listingId) {
  final favoritesNotifier = ref.watch(favoritesProvider.notifier);
  return favoritesNotifier.isFavorite(listingId);
});

// Toggle wishlist provider
final toggleWishlistProvider = Provider<Future<void> Function(String)>((ref) {
  return (String listingId) async {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    await favoritesNotifier.toggleFavorite(listingId);
  };
});
