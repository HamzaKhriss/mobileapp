import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';

class WishlistNotifier extends StateNotifier<List<MockListing>> {
  WishlistNotifier() : super([]);

  void toggleWishlist(MockListing listing) {
    if (state.any((item) => item.id == listing.id)) {
      state = state.where((item) => item.id != listing.id).toList();
    } else {
      state = [...state, listing];
    }
  }

  bool isInWishlist(String listingId) {
    return state.any((item) => item.id == listingId);
  }

  void clearWishlist() {
    state = [];
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<MockListing>>((ref) {
      return WishlistNotifier();
    });
