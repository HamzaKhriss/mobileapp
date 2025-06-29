import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart'; // Invalid import - removed
import 'package:geolocator/geolocator.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/listings_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';
import '../../data/models/listing.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/listings_service.dart';
import '../../data/services/location_service.dart';
import '../widgets/advanced_filter_drawer.dart';
import 'listing_detail_screen.dart';
import 'dart:async';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  bool _isGridView = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _itemsPerPage = 50;
  int _currentIndex = 1; // For bottom navigation

  // Simple filters matching frontend exactly
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;
  DateTime? _selectedDate;
  double? _proximityRadius; // in km
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _getUserLocation(),
      _loadListings(reset: true),
    ]);
  }

  Future<void> _getUserLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _userLocation = position;
        });
      }
    } catch (e) {
      print('Failed to get user location: $e');
    }
  }

  Future<void> _loadListings({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final listingsService = ref.read(listingsServiceProvider);

      if (_searchQuery.trim().isNotEmpty) {
        // Search path - simple search, no pagination
        final newListings =
            await listingsService.searchListings(_searchQuery.trim());
        if (mounted) {
          setState(() {
            _allListings = newListings;
            _filteredListings = newListings;
            _hasMore = false;
          });
        }
      } else {
        // Filter path - build filters object matching frontend
        final filters = ListingFilters(
          category: _selectedCategory,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minRating: _minRating,
          date: _selectedDate?.toIso8601String().split('T')[0],
          location: (_proximityRadius != null && _userLocation != null)
              ? LocationFilter(
                  lat: _userLocation!.latitude,
                  lng: _userLocation!.longitude,
                  radius: _proximityRadius!,
                )
              : null,
        );

        final response = await listingsService.getListings(
          filters: filters,
          page: _currentPage,
          limit: _itemsPerPage,
        );

        if (mounted) {
          setState(() {
            if (reset) {
              _allListings = response.data;
              _filteredListings = response.data;
            } else {
              _allListings.addAll(response.data);
              _filteredListings.addAll(response.data);
              _currentPage++;
            }
            _hasMore = response.hasMore;
          });
        }
      }
    } catch (e) {
      print('Error loading listings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load listings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _loadListings(reset: true);
  }

  void _applyFilters({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    DateTime? date,
    double? proximityRadius,
  }) {
    setState(() {
      _selectedCategory = category;
      _minPrice = minPrice;
      _maxPrice = maxPrice;
      _minRating = minRating;
      _selectedDate = date;
      _proximityRadius = proximityRadius;
    });

    _loadListings(reset: true);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _minRating = null;
      _selectedDate = null;
      _proximityRadius = null;
      _searchQuery = '';
      _searchController.clear();
    });

    _loadListings(reset: true);
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_minRating != null) count++;
    if (_selectedDate != null) count++;
    if (_proximityRadius != null) count++;
    return count;
  }

  void _showFilterModal() {
    final isDark = ref.read(themeProvider.notifier).isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        selectedCategory: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
        selectedDate: _selectedDate,
        proximityRadius: _proximityRadius,
        userLocation: _userLocation,
        onApply: _applyFilters,
        onClear: _clearAllFilters,
        isDark: isDark,
      ),
    );
  }

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
            expandedHeight: 180,
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
                    _isGridView ? Icons.grid_view : LucideIcons.list,
                    color: AppColors.textColor(isDark),
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
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
                  icon: Stack(
                    children: [
                      Icon(
                        LucideIcons.filter,
                        color: AppColors.textColor(isDark),
                      ),
                      if (_activeFiltersCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.kAccentMint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              _activeFiltersCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => _showFilterModal(),
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
                        onChanged: _onSearchChanged,
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
                                    _applyFilters();
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
                    const SizedBox(height: 16),
                    // Removed old category filter buttons - we now have the filter modal
                  ],
                ),
              ),
            ),
          ),

          // Content - Simple unified approach
          listingsAsync.when(
            data: (listings) {
              // Apply both search and category filters
              List<Listing> filteredListings = listings;

              // Apply search filter
              if (_searchQuery.trim().isNotEmpty) {
                filteredListings = filteredListings.where((listing) {
                  final query = _searchQuery.toLowerCase();
                  return listing.title.toLowerCase().contains(query) ||
                      listing.description.toLowerCase().contains(query) ||
                      listing.location.address.toLowerCase().contains(query) ||
                      listing.category.toLowerCase().contains(query);
                }).toList();
              }

              // Apply category filter
              if (_selectedCategory != null) {
                filteredListings = filteredListings.where((listing) {
                  return listing.category.toLowerCase() ==
                      _selectedCategory!.toLowerCase();
                }).toList();
              }

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
                              ? 'Try different search terms'
                              : 'Check back later for new experiences',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryColor(isDark),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedCategory != null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = null;
                              });
                              _applyFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kAccentMint,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _isGridView
                    ? SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final listing = filteredListings[index];
                            final isWishlisted =
                                wishlist.value?.contains(listing.id) ?? false;
                            return _buildModernListingCard(
                                listing, isWishlisted, isDark);
                          },
                          childCount: filteredListings.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final listing = filteredListings[index];
                            final isWishlisted =
                                wishlist.value?.contains(listing.id) ?? false;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildListViewCard(
                                  listing, isWishlisted, isDark),
                            );
                          },
                          childCount: filteredListings.length,
                        ),
                      ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.kAccentMint),
                ),
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.search,
                      size: 64,
                      color: AppColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load listings',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your internet connection',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(listingsProvider.notifier).refreshListings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kAccentMint,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
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
                                    LucideIcons.search,
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
                                  LucideIcons.search,
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
                                  LucideIcons.search,
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
                                LucideIcons.search,
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

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              index: 0,
              isSelected: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                context.goNamed('home');
              },
              isDark: isDark,
            ),
            _buildNavItem(
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore,
              label: 'Explore',
              index: 1,
              isSelected: _currentIndex == 1,
              onTap: () =>
                  setState(() => _currentIndex = 1), // Already on explore
              isDark: isDark,
            ),
            _buildNavItem(
              icon: Icons.favorite_outline,
              selectedIcon: Icons.favorite,
              label: 'Wishlist',
              index: 2,
              isSelected: _currentIndex == 2,
              onTap: () {
                setState(() => _currentIndex = 2);
                context.goNamed('wishlist');
              },
              isDark: isDark,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              index: 3,
              isSelected: _currentIndex == 3,
              onTap: () {
                setState(() => _currentIndex = 3);
                context.goNamed('profile');
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected
                ? AppColors.kAccentMint
                : AppColors.textColor(isDark).withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? AppColors.kAccentMint
                  : AppColors.textColor(isDark).withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
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

  // Remove the old category button methods since we're using the filter modal now
  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters(category: category);
  }
}

// Filter Modal Widget
class _FilterModal extends StatefulWidget {
  final String? selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final DateTime? selectedDate;
  final double? proximityRadius;
  final Position? userLocation;
  final Function({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    DateTime? date,
    double? proximityRadius,
  }) onApply;
  final VoidCallback onClear;
  final bool isDark;

  const _FilterModal({
    this.selectedCategory,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.selectedDate,
    this.proximityRadius,
    this.userLocation,
    required this.onApply,
    required this.onClear,
    required this.isDark,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late String? _selectedCategory;
  late double? _minPrice;
  late double? _maxPrice;
  late double? _minRating;
  late DateTime? _selectedDate;
  late double? _proximityRadius;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _minRating = widget.minRating;
    _selectedDate = widget.selectedDate;
    _proximityRadius =
        widget.proximityRadius ?? (widget.userLocation != null ? 5.0 : null);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.cardColor(true) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: widget.isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        widget.onClear();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppColors.textColor(widget.isDark),
                        ),
                      ),
                    ),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(widget.isDark),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onApply(
                          category: _selectedCategory,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          minRating: _minRating,
                          date: _selectedDate,
                          proximityRadius: _proximityRadius,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: AppColors.kAccentMint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Section
                      _buildSectionTitle('Category'),
                      const SizedBox(height: 12),
                      _buildCategorySelector(),
                      const SizedBox(height: 24),

                      // Price Range Section
                      _buildSectionTitle('Price Range'),
                      const SizedBox(height: 12),
                      _buildPriceRangeSelector(),
                      const SizedBox(height: 24),

                      // Rating Section
                      _buildSectionTitle('Minimum Rating'),
                      const SizedBox(height: 12),
                      _buildRatingSelector(),
                      const SizedBox(height: 24),

                      // Distance Section (if location available)
                      if (widget.userLocation != null) ...[
                        _buildSectionTitle('Distance'),
                        const SizedBox(height: 12),
                        _buildDistanceSlider(),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textColor(widget.isDark),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'id': 'restaurant', 'name': 'Restaurants', 'icon': Icons.restaurant},
      {'id': 'event', 'name': 'Events', 'icon': Icons.event},
      {'id': 'cultural', 'name': 'Cultural', 'icon': Icons.museum},
    ];

    return Wrap(
      spacing: 12,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category['id'];
        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category['id'] as String : null;
            });
          },
          label: Text(
            category['name'] as String,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.textColor(widget.isDark),
            ),
          ),
          avatar: Icon(
            category['icon'] as IconData,
            size: 16,
            color:
                isSelected ? Colors.white : AppColors.textColor(widget.isDark),
          ),
          backgroundColor:
              widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          selectedColor: AppColors.kAccentMint,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSelector() {
    final priceRanges = [
      {'min': 0.0, 'max': 100.0, 'label': 'Under 100 MAD'},
      {'min': 100.0, 'max': 200.0, 'label': '100-200 MAD'},
      {'min': 200.0, 'max': 300.0, 'label': '200-300 MAD'},
      {'min': 300.0, 'max': 500.0, 'label': '300-500 MAD'},
      {'min': 500.0, 'max': null, 'label': 'Over 500 MAD'},
    ];

    return Wrap(
      spacing: 12,
      children: priceRanges.map((range) {
        final isSelected =
            _minPrice == range['min'] && _maxPrice == range['max'];
        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _minPrice = range['min'] as double;
                _maxPrice = range['max'] as double?;
              } else {
                _minPrice = null;
                _maxPrice = null;
              }
            });
          },
          label: Text(
            range['label'] as String,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.textColor(widget.isDark),
            ),
          ),
          backgroundColor:
              widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          selectedColor: AppColors.kAccentMint,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector() {
    final ratings = [4.5, 4.0, 3.5, 3.0];

    return Wrap(
      spacing: 12,
      children: ratings.map((rating) {
        final isSelected = _minRating == rating;
        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _minRating = selected ? rating : null;
            });
          },
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${rating}+',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textColor(widget.isDark),
                ),
              ),
            ],
          ),
          backgroundColor:
              widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          selectedColor: AppColors.kAccentMint,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Within ${_proximityRadius?.toInt() ?? 5} km',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryColor(widget.isDark),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.kAccentMint,
            inactiveTrackColor:
                widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            thumbColor: AppColors.kAccentMint,
            overlayColor: AppColors.kAccentMint.withOpacity(0.2),
          ),
          child: Slider(
            value: _proximityRadius ?? 5.0,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _proximityRadius = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
