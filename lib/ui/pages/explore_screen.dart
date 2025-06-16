import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/listings_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _isMapView = false;
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);
    final wishlist = ref.watch(wishlistProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? LucideIcons.list : LucideIcons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {
              _showFiltersDrawer(context);
            },
          ),
        ],
      ),
      body: listingsAsync.when(
        data: (listings) {
          if (_isMapView) {
            return const Center(
              child: Text(
                'Map View\n(Map implementation here)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(isDark),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.borderColor(isDark),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(color: AppColors.textColor(isDark)),
                    decoration: InputDecoration(
                      hintText: 'Search listings...',
                      hintStyle: TextStyle(
                          color: AppColors.textSecondaryColor(isDark)),
                      prefixIcon: Icon(LucideIcons.search,
                          color: AppColors.textSecondaryColor(isDark)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
              // Listings grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    final isWishlisted =
                        wishlist.any((w) => w.id == listing.id);

                    return GestureDetector(
                      onTap: () => context.pushNamed(
                        'listing-detail',
                        pathParameters: {'id': listing.id},
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardColor(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor(isDark),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(listing.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(wishlistProvider.notifier)
                                            .toggleWishlist(listing);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          LucideIcons.heart,
                                          color: isWishlisted
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Details
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
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      listing.location,
                                      style: AppTextStyles.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          listing.rating.toString(),
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${listing.price.toInt()} MAD',
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
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
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kAccentMint),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading listings',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(isDark),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.borderColor(isDark),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                    // Already on explore
                  },
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

  void _showFiltersDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kBrandDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filters',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 24),
            // Filter options would go here
            Text(
              'Filter options coming soon...',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
