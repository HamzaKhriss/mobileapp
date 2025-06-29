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
import '../../data/models/booking.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/listings_service.dart';

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

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
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

        final isWishlisted = wishlist.value?.contains(listing.id) ?? false;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 60,
                pinned: true,
                backgroundColor: AppColors.backgroundColor(isDark),
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? LucideIcons.heart : LucideIcons.heart,
                        color: isWishlisted
                            ? AppColors.kAccentMint
                            : (isDark ? Colors.white : Colors.black),
                      ),
                      onPressed: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .toggleFavorite(listing.id);
                      },
                    ),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Title and Category
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listing.title,
                                      style: AppTextStyles.h1.copyWith(
                                        color: AppColors.textColor(isDark),
                                        fontSize: 32,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 16,
                                            color: AppColors.textSecondaryColor(
                                                isDark)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            listing.location.address,
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                              color:
                                                  AppColors.textSecondaryColor(
                                                      isDark),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(listing.category),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(listing.category),
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getCategoryLabel(listing.category),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Photo Gallery Section
                    _buildPhotoGallery(listing, isDark),

                    // Main Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Experience by Host Section
                          _buildHostSection(listing, isDark),
                          const SizedBox(height: 32),

                          // What's Included Section
                          _buildWhatsIncludedSection(listing, isDark),
                          const SizedBox(height: 32),

                          // Reviews Section
                          _buildReviewsSection(listing, isDark),
                          const SizedBox(height: 32),

                          // Location Section
                          _buildLocationSection(listing, isDark),
                          const SizedBox(
                              height: 120), // Space for bottom booking
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Floating Booking Card
          bottomNavigationBar: _buildBottomBookingCard(listing, isDark),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundColor(isDark),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kAccentMint),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.backgroundColor(isDark),
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor(isDark),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textColor(isDark)),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
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
                'Listing not found',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textColor(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The listing you\'re looking for doesn\'t exist.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryColor(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(Listing listing, bool isDark) {
    if (listing.images.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            LucideIcons.image,
            size: 64,
            color: AppColors.textSecondaryColor(isDark),
          ),
        ),
      );
    }

    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
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
                return CachedNetworkImage(
                  imageUrl: listing.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.cardColor(isDark),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.kAccentMint),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.cardColor(isDark),
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 32,
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Image Indicators
            if (listing.images.length > 1)
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
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

            // Image Counter
            if (listing.images.length > 1)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${listing.images.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostSection(Listing listing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience by ${listing.host.name}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.users,
                            size: 16,
                            color: AppColors.textSecondaryColor(isDark)),
                        const SizedBox(width: 4),
                        Text('2-8 guests',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondaryColor(isDark))),
                        const SizedBox(width: 16),
                        Icon(LucideIcons.clock,
                            size: 16,
                            color: AppColors.textSecondaryColor(isDark)),
                        const SizedBox(width: 4),
                        Text('2-3 hours',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondaryColor(isDark))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.borderColor(isDark), width: 2),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: listing.host.avatar,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.kAccentMint,
                          child: Icon(LucideIcons.user, color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.kAccentMint,
                          child: Icon(LucideIcons.user, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('4.9',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor(isDark))),
                    ],
                  ),
                  Text('Host',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor(isDark))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            listing.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textColor(isDark),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsIncludedSection(Listing listing, bool isDark) {
    final items = listing.amenities.isNotEmpty
        ? listing.amenities
        : [
            'Professional guide',
            'All materials included',
            'Refreshments',
            'Photos included'
          ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.kAccentMint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.check,
                    size: 20, color: AppColors.kAccentMint),
              ),
              const SizedBox(width: 12),
              Text(
                'What\'s included',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.kAccentMint.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(LucideIcons.check,
                              size: 24, color: AppColors.kAccentMint),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textColor(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Listing listing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${listing.rating.toStringAsFixed(1)}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${listing.reviewCount} Reviews',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryColor(isDark),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showReviewModal(listing, isDark),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.kAccentMint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Write a review',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'From verified guests',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 24),

          // Real Reviews from API
          Consumer(
            builder: (context, ref, child) {
              final reviewsAsync = ref.watch(reviewsProvider(listing.id));

              return reviewsAsync.when(
                data: (reviews) {
                  print(
                      '[ListingDetail] 📝 Reviews loaded: ${reviews.length} reviews');

                  if (reviews.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.star,
                            size: 48,
                            color: AppColors.textSecondaryColor(isDark),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textColor(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to leave a review for this experience!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondaryColor(isDark),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: reviews
                        .take(3)
                        .map((review) => _buildReviewCard(review, isDark))
                        .toList(),
                  );
                },
                loading: () {
                  print('[ListingDetail] ⏳ Loading reviews...');
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.kAccentMint),
                      ),
                    ),
                  );
                },
                error: (error, stack) {
                  print('[ListingDetail] ❌ Reviews error: $error');
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load reviews',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryColor(isDark),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${error.toString()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor(isDark),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            ref.refresh(reviewsProvider(listing.id));
                          },
                          child: Text(
                            'Retry',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.kAccentMint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.kAccentMint,
                  shape: BoxShape.circle,
                ),
                child: review.user?.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: review.user!.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            LucideIcons.user,
                            color: Colors.white,
                            size: 20,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            LucideIcons.user,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : Icon(LucideIcons.user, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.firstName ?? 'Guest',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(review.dateReview),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    LucideIcons.star,
                    size: 16,
                    color: i < review.rating ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.commentText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textColor(isDark),
            ),
          ),

          // Host reply if available
          if (review.partnerReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kAccentMint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 16, color: AppColors.kAccentMint),
                      const SizedBox(width: 8),
                      Text(
                        'Host replied',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.kAccentMint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.partnerReply!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildLocationSection(Listing listing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.kAccentMint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on,
                    size: 20, color: AppColors.kAccentMint),
              ),
              const SizedBox(width: 12),
              Text(
                'Where you\'ll be',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.map,
                      size: 48, color: AppColors.textSecondaryColor(isDark)),
                  const SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            listing.location.address,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Located in the heart of Casablanca, this area is known for its vibrant culture and historical significance.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingCard(Listing listing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        border: Border(top: BorderSide(color: AppColors.borderColor(isDark))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '${listing.price.toInt()}',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textColor(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'MAD per person',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(LucideIcons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.rating.toStringAsFixed(1)} (1 reviews)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GradientButton(
                text: 'Reserve Now',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => BookingModal(
                      listing: listing,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return LucideIcons.landmark;
      case 'event':
        return LucideIcons.calendar;
      case 'restaurant':
        return LucideIcons.utensils;
      default:
        return LucideIcons.star;
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

  void _showReviewModal(Listing listing, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReviewModal(
        listing: listing,
        isDark: isDark,
        onReviewSubmitted: () {
          // Refresh reviews after submission
          ref.refresh(reviewsProvider(listing.id));
        },
      ),
    );
  }
}

class ReviewModal extends ConsumerStatefulWidget {
  final Listing listing;
  final bool isDark;
  final VoidCallback onReviewSubmitted;

  const ReviewModal({
    super.key,
    required this.listing,
    required this.isDark,
    required this.onReviewSubmitted,
  });

  @override
  ConsumerState<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends ConsumerState<ReviewModal> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      NotificationService.showSnackBar(
        context,
        'Please write a comment',
        type: NotificationType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final listingsService = ListingsService();
      await listingsService.leaveReview(
        listingId: int.parse(widget.listing.id),
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      NotificationService.showSnackBar(
        context,
        'Review submitted successfully!',
        type: NotificationType.success,
      );

      widget.onReviewSubmitted();
      Navigator.of(context).pop();
    } catch (e) {
      NotificationService.showSnackBar(
        context,
        'Failed to submit review: ${e.toString()}',
        type: NotificationType.error,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(widget.isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Write a Review',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textColor(widget.isDark),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Listing info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.listing.images.isNotEmpty
                        ? widget.listing.images.first
                        : '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.cardColor(widget.isDark),
                      child: Icon(
                        LucideIcons.image,
                        color: AppColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.cardColor(widget.isDark),
                      child: Icon(
                        LucideIcons.image,
                        color: AppColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textColor(widget.isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.listing.location.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Rating
            Text(
              'Rating',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textColor(widget.isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      LucideIcons.star,
                      size: 32,
                      color: index < _rating ? Colors.amber : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Comment
            Text(
              'Your Review',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textColor(widget.isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: TextStyle(color: AppColors.textColor(widget.isDark)),
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondaryColor(widget.isDark),
                ),
                filled: true,
                fillColor: widget.isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kAccentMint,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Review',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
