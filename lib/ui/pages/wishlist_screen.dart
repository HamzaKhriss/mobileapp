import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist', style: AppTextStyles.h3),
        actions: [
          if (wishlist.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(wishlistProvider.notifier).clearWishlist();
              },
              child: Text(
                'Clear All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kAlertRed,
                ),
              ),
            ),
        ],
      ),
      body: wishlist.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final listing = wishlist[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderColor(isDark),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => context.pushNamed(
                      'listing-detail',
                      pathParameters: {'id': listing.id},
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(listing.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Details
                          Expanded(
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
                                ),
                                const SizedBox(height: 8),
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
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.kAccentMint,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Remove button
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(wishlistProvider.notifier)
                                  .toggleWishlist(listing);
                            },
                            icon: const Icon(
                              LucideIcons.heart,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
                    context.goNamed('explore');
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
                    // Already on wishlist
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.heart,
            size: 80,
            color: AppColors.textSecondaryColor(isDark),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved listings yet',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start exploring and save places you love!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pushNamed('explore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kAccentMint,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: Text(
              'Start Exploring',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }
}
