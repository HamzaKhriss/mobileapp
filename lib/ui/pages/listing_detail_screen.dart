import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/listings_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../state/theme_provider.dart';
import '../../data/mock_data.dart';
import '../widgets/gradient_button.dart';
import '../widgets/booking_modal.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);
    final wishlist = ref.watch(wishlistProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return listingsAsync.when(
      data: (listings) {
        final listing = listings.firstWhere(
          (l) => l.id == widget.listingId,
          orElse: () => throw Exception('Listing not found'),
        );

        final isWishlisted = wishlist.any((w) => w.id == listing.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar with image carousel
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.backgroundColor(isDark),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.heart,
                        color: isWishlisted ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .toggleWishlist(listing);
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemCount: listing.images.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            listing.images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      // Image indicators
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            listing.images.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textColor(isDark),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${listing.rating} (${listing.reviewCount})',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textColor(isDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.location,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hosted by ${listing.host}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.kAccentMint,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${listing.price.toInt()} MAD',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.kAccentMint,
                              ),
                            ),
                            TextSpan(
                              text: listing.category == 'restaurant'
                                  ? ' per person'
                                  : ' per ticket',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textColor(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tabs
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.kAccentMint,
                        unselectedLabelColor:
                            AppColors.textSecondaryColor(isDark),
                        indicatorColor: AppColors.kAccentMint,
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Amenities'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tab content
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Overview
                            SingleChildScrollView(
                              child: Text(
                                listing.description,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textColor(isDark),
                                ),
                              ),
                            ),
                            // Amenities
                            SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: listing.amenities.map((amenity) {
                                  return Chip(
                                    label: Text(
                                      amenity,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textColor(isDark),
                                      ),
                                    ),
                                    backgroundColor:
                                        AppColors.cardColor(isDark),
                                    side: BorderSide(
                                      color: AppColors.borderColor(isDark),
                                      width: 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            // Reviews
                            ListView.builder(
                              itemCount: MockData.reviews.length,
                              itemBuilder: (context, index) {
                                final review = MockData.reviews[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor(isDark),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.borderColor(isDark),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                AssetImage(review.userAvatar),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review.userName,
                                                  style: AppTextStyles
                                                      .bodyMedium
                                                      .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textColor(
                                                        isDark),
                                                  ),
                                                ),
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (i) => Icon(
                                                      LucideIcons.star,
                                                      size: 14,
                                                      color: i < review.rating
                                                          ? Colors.amber
                                                          : AppColors
                                                              .textSecondaryColor(
                                                                  isDark),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        review.comment,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textColor(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor(isDark),
              border: Border(
                top: BorderSide(color: AppColors.borderColor(isDark)),
              ),
            ),
            child: SafeArea(
              child: GradientButton(
                text: 'Book Now',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => BookingModal(listing: listing),
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kAccentMint),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            'Error loading listing',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textColor(isDark),
            ),
          ),
        ),
      ),
    );
  }
}
