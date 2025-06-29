import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/listings_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';
import '../../data/models/listing.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/listings_service.dart';
import '../widgets/advanced_filter_drawer.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _isMapView = false;
  bool _isListView = false;
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);
    final wishlist = ref.watch(wishlistProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(isDark),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            title: Text(
              'Explore Casablanca',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor(isDark)),
                ),
                child: IconButton(
                  icon: Icon(
                    _isListView ? Icons.grid_view : LucideIcons.list,
                    color: AppColors.textColor(isDark),
                  ),
                  onPressed: () {
                    setState(() {
                      _isListView = !_isListView;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor(isDark)),
                ),
                child: IconButton(
                  icon: Icon(
                    LucideIcons.filter,
                    color: AppColors.textColor(isDark),
                  ),
                  onPressed: () => _showFiltersDrawer(context, isDark),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Search Bar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor(isDark),
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: AppColors.borderColor(isDark)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        style: TextStyle(color: AppColors.textColor(isDark)),
                        decoration: InputDecoration(
                          hintText:
                              'Search experiences, restaurants, events...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondaryColor(isDark),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: AppColors.textSecondaryColor(isDark),
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondaryColor(isDark),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          listingsAsync.when(
            data: (listings) {
              // Filter listings based on search query
              final filteredListings = _searchQuery.isEmpty
                  ? listings
                  : listings.where((listing) {
                      return listing.title
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          listing.description
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          listing.location.address
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          listing.category.toLowerCase().contains(_searchQuery);
                    }).toList();

              if (filteredListings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? LucideIcons.search
                              : LucideIcons.compass,
                          size: 64,
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No results found'
                              : 'No listings available',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try adjusting your search'
                              : 'Check back later for new experiences',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _isListView
                  ? _buildListView(filteredListings, wishlist, isDark)
                  : _buildGridView(filteredListings, wishlist, isDark);
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.kAccentMint),
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading listings',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildGridView(
      List<Listing> listings, AsyncValue<List<String>> wishlist, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final listing = listings[index];
            final isWishlisted = wishlist.value?.contains(listing.id) ?? false;
            return _buildModernListingCard(listing, isWishlisted, isDark);
          },
          childCount: listings.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
      ),
    );
  }

  Widget _buildListView(
      List<Listing> listings, AsyncValue<List<String>> wishlist, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final listing = listings[index];
            final isWishlisted = wishlist.value?.contains(listing.id) ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildListViewCard(listing, isWishlisted, isDark),
            );
          },
          childCount: listings.length,
        ),
      ),
    );
  }

  Widget _buildModernListingCard(
      Listing listing, bool isWishlisted, bool isDark) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'listing-detail',
        pathParameters: {'id': listing.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay elements
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: listing.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: listing.images[0],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.cardColor(isDark),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.kAccentMint),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: AppColors.textSecondaryColor(isDark),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  LucideIcons.image,
                                  size: 32,
                                  color: AppColors.textSecondaryColor(isDark),
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Category Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(listing.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryLabel(listing.category),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  // Wishlist Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        final wasWishlisted = isWishlisted;
                        try {
                          await ref
                              .read(wishlistProvider.notifier)
                              .toggleFavorite(listing.id);

                          // Show notification based on action
                          if (!wasWishlisted) {
                            NotificationService.showSnackBar(
                              context,
                              'Added "${listing.title}" to wishlist',
                              type: NotificationType.success,
                              actionLabel: 'View',
                              onActionPressed: () {
                                context.pushNamed('wishlist');
                              },
                            );
                          } else {
                            NotificationService.showSnackBar(
                              context,
                              'Removed "${listing.title}" from wishlist',
                              type: NotificationType.info,
                            );
                          }
                        } catch (e) {
                          NotificationService.showSnackBar(
                            context,
                            'Failed to update wishlist',
                            type: NotificationType.error,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey[600],
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(isDark),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.location.address,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor(isDark),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textColor(isDark),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          ' (${listing.reviewCount})',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${listing.price.toInt()}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.kAccentMint,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' MAD',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor(isDark),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListViewCard(Listing listing, bool isWishlisted, bool isDark) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'listing-detail',
        pathParameters: {'id': listing.id},
      ),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Container(
                    width: 120,
                    height: double.infinity,
                    child: listing.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: listing.images[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.cardColor(isDark),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.kAccentMint),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 24,
                                  color: AppColors.textSecondaryColor(isDark),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 24,
                                color: AppColors.textSecondaryColor(isDark),
                              ),
                            ),
                          ),
                  ),
                ),

                // Category Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(listing.category),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryLabel(listing.category),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor(isDark),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final wasWishlisted = isWishlisted;
                            try {
                              await ref
                                  .read(wishlistProvider.notifier)
                                  .toggleFavorite(listing.id);

                              // Show notification based on action
                              if (!wasWishlisted) {
                                NotificationService.showSnackBar(
                                  context,
                                  'Added "${listing.title}" to wishlist',
                                  type: NotificationType.success,
                                  actionLabel: 'View',
                                  onActionPressed: () {
                                    context.pushNamed('wishlist');
                                  },
                                );
                              } else {
                                NotificationService.showSnackBar(
                                  context,
                                  'Removed "${listing.title}" from wishlist',
                                  type: NotificationType.info,
                                );
                              }
                            } catch (e) {
                              NotificationService.showSnackBar(
                                context,
                                'Failed to update wishlist',
                                type: NotificationType.error,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted
                                  ? Colors.red
                                  : AppColors.textSecondaryColor(isDark),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location.address,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.rating.toStringAsFixed(1)} (${listing.reviewCount})',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textColor(isDark),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${listing.price.toInt()} MAD',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.kAccentMint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: AppColors.borderColor(isDark), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: LucideIcons.house,
                label: 'Home',
                index: 0,
                isSelected: _currentIndex == 0,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  context.goNamed('home');
                },
              ),
              _buildNavItem(
                icon: LucideIcons.compass,
                label: 'Explore',
                index: 1,
                isSelected: _currentIndex == 1,
                isDark: isDark,
                onTap: () {},
              ),
              _buildNavItem(
                icon: LucideIcons.heart,
                label: 'Wishlist',
                index: 2,
                isSelected: _currentIndex == 2,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                  context.goNamed('wishlist');
                },
              ),
              _buildNavItem(
                icon: LucideIcons.user,
                label: 'Profile',
                index: 3,
                isSelected: _currentIndex == 3,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                  context.goNamed('profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.kAccentMint.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.kAccentMint
                    : AppColors.textSecondaryColor(isDark),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.kAccentMint
                      : AppColors.textSecondaryColor(isDark),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFiltersDrawer(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AdvancedFilterDrawer(
        isDark: isDark,
        currentFilters: ref.read(listingsProvider.notifier).currentFilters ??
            ListingFilters(),
        onApplyFilters: (filters) {
          ref.read(listingsProvider.notifier).applyFilters(filters);
          Navigator.pop(context);
        },
        onClearFilters: () {
          ref.read(listingsProvider.notifier).clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  // Helper methods for category styling
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return Colors.purple;
      case 'event':
        return Colors.orange;
      case 'restaurant':
        return Colors.green;
      default:
        return AppColors.kAccentMint;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return 'Cultural';
      case 'event':
        return 'Event';
      case 'restaurant':
        return 'Restaurant';
      default:
        return category;
    }
  }
}
