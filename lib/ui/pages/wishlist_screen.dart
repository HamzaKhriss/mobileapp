import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/listings_provider.dart';
import '../../data/models/listing.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2;
  bool _isGridView = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(favoriteListingsProvider);
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
              'My Wishlist',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // View toggle button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor(isDark)),
                ),
                child: IconButton(
                  icon: Icon(
                    _isGridView ? LucideIcons.list : Icons.grid_view,
                    color: AppColors.textColor(isDark),
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
              ),
              // Clear all button (shown only when there are items)
              wishlistAsync.when(
                data: (listings) => listings.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.borderColor(isDark)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.clear_all,
                            color: Colors.red[400],
                          ),
                          onPressed: () =>
                              _showClearAllDialog(context, listings, isDark),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Stats row
                    wishlistAsync.when(
                      data: (listings) => _buildStatsRow(listings, isDark),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          wishlistAsync.when(
            data: (listings) {
              if (listings.isEmpty) {
                return SliverFillRemaining(
                  child: _buildModernEmptyState(isDark),
                );
              }

              return _isGridView
                  ? _buildGridView(listings, isDark)
                  : _buildListView(listings, isDark);
            },
            loading: () => SliverFillRemaining(
              child: _buildLoadingState(isDark),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: _buildErrorState(error, isDark),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildStatsRow(List<Listing> listings, bool isDark) {
    if (listings.isEmpty) return const SizedBox.shrink();

    final avgPrice = listings.isNotEmpty
        ? listings.map((l) => l.price).reduce((a, b) => a + b) / listings.length
        : 0.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${listings.length} ${listings.length == 1 ? 'favorite' : 'favorites'}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.trending_up,
              color: AppColors.kAccentMint,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Avg ${avgPrice.toInt()} MAD',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<Listing> listings, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final listing = listings[index];
            return _buildModernListingCard(listing, isDark, index);
          },
          childCount: listings.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  Widget _buildListView(List<Listing> listings, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final listing = listings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildListViewCard(listing, isDark, index),
            );
          },
          childCount: listings.length,
        ),
      ),
    );
  }

  Widget _buildModernListingCard(Listing listing, bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => context.pushNamed(
              'listing-detail',
              pathParameters: {'id': listing.id},
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.borderColor(isDark), width: 0.5),
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
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.kAccentMint),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 32,
                                          color: AppColors.textSecondaryColor(
                                              isDark),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        LucideIcons.image,
                                        size: 32,
                                        color: AppColors.textSecondaryColor(
                                            isDark),
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

                        // Remove Button with Animation
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeFromWishlist(listing.id),
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
                                Icons.favorite,
                                color: Colors.red[400],
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
          ),
        );
      },
    );
  }

  Widget _buildListViewCard(Listing listing, bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Dismissible(
              key: Key(listing.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => _removeFromWishlist(listing.id),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remove',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              child: GestureDetector(
                onTap: () => context.pushNamed(
                  'listing-detail',
                  pathParameters: {'id': listing.id},
                ),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.borderColor(isDark), width: 0.5),
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
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16)),
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.kAccentMint),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 24,
                                            color: AppColors.textSecondaryColor(
                                                isDark),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      child: Center(
                                        child: Icon(
                                          LucideIcons.image,
                                          size: 24,
                                          color: AppColors.textSecondaryColor(
                                              isDark),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                                    onTap: () =>
                                        _removeFromWishlist(listing.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.red[400],
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
                                        color: AppColors.textSecondaryColor(
                                            isDark),
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernEmptyState(bool isDark) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.kAccentMint.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 60,
                      color: AppColors.kAccentMint,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Your wishlist is empty',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Discover amazing experiences in Casablanca and save your favorites here',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryColor(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kAccentMint.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => context.pushNamed('explore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kAccentMint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.compass, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Start Exploring',
                      style: AppTextStyles.buttonText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kAccentMint),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your favorites...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error, bool isDark) {
    return Center(
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
            'Error loading wishlist',
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(favoriteListingsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kAccentMint,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
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
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  context.goNamed('explore');
                },
              ),
              _buildNavItem(
                icon: LucideIcons.heart,
                label: 'Wishlist',
                index: 2,
                isSelected: _currentIndex == 2,
                isDark: isDark,
                onTap: () {},
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

  void _removeFromWishlist(String listingId) {
    ref.read(wishlistProvider.notifier).toggleFavorite(listingId);

    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed from wishlist',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor:
            AppColors.textColor(ref.read(themeProvider) == ThemeMode.dark),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.kAccentMint,
          onPressed: () {
            ref.read(wishlistProvider.notifier).toggleFavorite(listingId);
          },
        ),
      ),
    );
  }

  void _showClearAllDialog(
      BuildContext context, List<Listing> listings, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear All Favorites?',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textColor(isDark),
          ),
        ),
        content: Text(
          'This will remove all ${listings.length} items from your wishlist. This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryColor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              for (final listing in listings) {
                await ref
                    .read(wishlistProvider.notifier)
                    .toggleFavorite(listing.id);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cleared all favorites',
                    style:
                        AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.textColor(isDark),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear All'),
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
}
