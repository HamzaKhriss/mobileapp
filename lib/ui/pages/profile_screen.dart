import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/auth_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/listings_provider.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';
import '../widgets/animated_bubble_background.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 3;
  String _selectedLanguage = 'English';

  // Tab controller for profile tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final bookingsAsync = ref.watch(bookingsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Hero Profile Header
            SliverAppBar(
              expandedHeight: 450,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.kAccentMint,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroHeader(
                    authState, bookingsAsync, favoritesAsync, isDark),
                collapseMode: CollapseMode.parallax,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppColors.kAccentMint,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.person_outline), text: 'Overview'),
                      Tab(icon: Icon(Icons.calendar_today), text: 'Bookings'),
                      Tab(icon: Icon(Icons.settings), text: 'Settings'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(authState, bookingsAsync, favoritesAsync, isDark),
            _buildBookingsTab(bookingsAsync, isDark),
            _buildSettingsTab(authState, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(isDark),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderColor(isDark),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kAccentMint.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.kAccentMint,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondaryColor(isDark),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor(isDark),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.kAccentMint.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.kAccentMint,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.kAccentMint,
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(bool isDark) {
    final languages = ['English', 'French', 'Arabic', 'Spanish'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 24),
            ...languages.map((language) => ListTile(
                  title: Text(
                    language,
                    style: AppTextStyles.bodyMedium,
                  ),
                  trailing: _selectedLanguage == language
                      ? const Icon(LucideIcons.check,
                          color: AppColors.kAccentMint)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // New methods for the enhanced profile structure
  Widget _buildHeroHeader(AuthState authState, AsyncValue bookingsAsync,
      AsyncValue favoritesAsync, bool isDark) {
    return AnimatedBubbleBackground(
      isDark: false, // Always use light bubbles on mint background
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.kAccentMint.withOpacity(0.7),
              AppColors.kAccentMint.withOpacity(0.5)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile Avatar and Info
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: authState.user?.profilePictureUrl != null
                            ? CachedNetworkImage(
                                imageUrl: authState.user!.profilePictureUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.kAccentMint,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.kAccentMint,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.kAccentMint,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            authState.user != null
                                ? '${authState.user!.firstName} ${authState.user!.lastName}'
                                    .trim()
                                : 'Guest User',
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authState.user?.email ?? 'guest@casawonders.com',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // User Level Badge
                          _buildUserLevelBadge(bookingsAsync),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Quick Stats Grid (2x2)
                Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard(
                            'Bookings',
                            bookingsAsync.maybeWhen(
                              data: (bookings) => bookings.length,
                              orElse: () => 0,
                            ),
                            Icons.calendar_today),
                        const SizedBox(width: 12),
                        _buildStatCard(
                            'Favorites',
                            favoritesAsync.maybeWhen(
                              data: (favorites) => favorites.length,
                              orElse: () => 0,
                            ),
                            Icons.favorite),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatCard('Places Visited',
                            _getPlacesVisitedCount(bookingsAsync), Icons.place),
                        const SizedBox(width: 12),
                        _buildStatCard('Total Spent',
                            _getTotalSpent(bookingsAsync), Icons.trending_up),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getPlacesVisitedCount(AsyncValue bookingsAsync) {
    return bookingsAsync.maybeWhen(
      data: (bookings) {
        // Count unique listing IDs from confirmed bookings
        final confirmedBookings =
            bookings.where((b) => b.status == 'confirmed');
        final uniqueListings = confirmedBookings
            .map((b) => b.listing?.listingId)
            .where((id) => id != null)
            .toSet();
        return uniqueListings.length;
      },
      orElse: () => 0,
    );
  }

  Map<String, dynamic> _getUserLevel(AsyncValue bookingsAsync) {
    final confirmedCount = bookingsAsync.maybeWhen(
      data: (bookings) => bookings.where((b) => b.status == 'confirmed').length,
      orElse: () => 0,
    );

    if (confirmedCount >= 10) {
      return {
        'level': 'Explorer Elite',
        'color': Colors.purple,
        'icon': Icons.emoji_events,
      };
    } else if (confirmedCount >= 5) {
      return {
        'level': 'Adventure Seeker',
        'color': Colors.blue,
        'icon': Icons.star,
      };
    } else {
      return {
        'level': 'Casa Wanderer',
        'color': AppColors.kAccentMint,
        'icon': Icons.auto_awesome,
      };
    }
  }

  double _getTotalSpent(AsyncValue bookingsAsync) {
    return bookingsAsync.maybeWhen(
      data: (bookings) {
        final confirmedBookings =
            bookings.where((b) => b.status == 'confirmed');
        return confirmedBookings.fold(
            0.0, (sum, booking) => sum + booking.totalPrice);
      },
      orElse: () => 0.0,
    );
  }

  Widget _buildUserLevelBadge(AsyncValue bookingsAsync) {
    final userLevel = _getUserLevel(bookingsAsync);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            userLevel['icon'] as IconData,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            userLevel['level'] as String,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, dynamic value, IconData icon) {
    String displayValue;
    if (value is double) {
      // For Total Spent, add currency
      if (label == 'Total Spent') {
        displayValue = '${value.toStringAsFixed(0)}';
      } else {
        displayValue = value.toStringAsFixed(0);
      }
    } else {
      displayValue = value.toString();
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          // Use solid white background for better contrast
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          // Add subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use mint color for icons to maintain theme consistency
            Icon(icon, color: AppColors.kAccentMint, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                displayValue,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.kTextLight, // Dark text on white background
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (label == 'Total Spent')
              Text(
                'MAD',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kAccentMint,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.kTextSecondaryLight, // Muted dark text
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountLevelCard(AsyncValue bookingsAsync, bool isDark) {
    final userLevel = _getUserLevel(bookingsAsync);
    final Color levelColor = userLevel['color'] as Color;
    final IconData levelIcon = userLevel['icon'] as IconData;
    final String levelName = userLevel['level'] as String;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor.withOpacity(0.1), levelColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  levelIcon,
                  color: levelColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelName,
                      style: AppTextStyles.h3.copyWith(color: levelColor),
                    ),
                    Text(
                      'Your adventure level',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getLevelDescription(levelName),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'Explorer Elite':
        return 'Wow! You are a true Casa Wonders explorer. You\'ve discovered 10+ amazing places!';
      case 'Adventure Seeker':
        return 'Great job! You\'re building an impressive collection of Casablanca experiences.';
      case 'Casa Wanderer':
        return 'Welcome to Casa Wonders! Keep exploring to unlock new levels and exclusive rewards.';
      default:
        return 'Keep exploring to unlock new levels and exclusive rewards!';
    }
  }

  Widget _buildOverviewTab(AuthState authState, AsyncValue bookingsAsync,
      AsyncValue favoritesAsync, bool isDark) {
    final bookingsCount = bookingsAsync.maybeWhen(
        data: (bookings) => bookings.length, orElse: () => 0);
    final favoritesCount = favoritesAsync.maybeWhen(
        data: (favorites) => favorites.length, orElse: () => 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${authState.user?.firstName ?? 'User'}!',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for your next Casablanca adventure?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        'Total Bookings',
                        bookingsCount.toString(),
                        Icons.calendar_today,
                        Colors.blue,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStatCard(
                        'Saved Places',
                        favoritesCount.toString(),
                        Icons.favorite,
                        Colors.red,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Actions', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Explore Places',
                  'Discover new experiences',
                  Icons.explore,
                  AppColors.kAccentMint,
                  isDark,
                  () => context.goNamed('explore'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'My Wishlist',
                  'View saved favorites',
                  Icons.favorite_border,
                  Colors.red,
                  isDark,
                  () => context.goNamed('wishlist'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Level
          _buildAccountLevelCard(bookingsAsync, isDark),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor(isDark)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab(AsyncValue bookingsAsync, bool isDark) {
    return bookingsAsync.when(
      data: (bookings) => bookings.isEmpty
          ? const Center(child: Text('No bookings yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(booking.listingName),
                    subtitle:
                        Text('${booking.date} • ${booking.formattedPrice}'),
                    trailing: Chip(label: Text(booking.status ?? 'Unknown')),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Unable to load bookings'),
            const SizedBox(height: 8),
            Text('Error: $error',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(AuthState authState, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Section
          if (authState.user != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor(isDark)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.kAccentMint,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Profile Settings',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.kAccentMint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    subtitle: 'Update your profile information',
                    isDark: isDark,
                    onTap: () =>
                        _showEditProfileDialog(authState.user!, isDark),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    isDark: isDark,
                    onTap: () => _showChangePasswordDialog(isDark),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.camera_alt,
                    title: 'Update Avatar',
                    subtitle: 'Change your profile picture',
                    isDark: isDark,
                    onTap: () => _showAvatarUploadDialog(isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          // App Settings
          _buildMenuItem(
            icon: Icons.palette,
            title: 'Dark Mode',
            subtitle: 'Toggle theme',
            isDark: isDark,
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            isDark: isDark,
            onTap: () => _showLanguageSelector(isDark),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.goNamed('welcome');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: AppColors.borderColor(isDark)),
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
                icon: Icons.home,
                label: 'Home',
                index: 0,
                isSelected: _currentIndex == 0,
                isDark: isDark,
                onTap: () {
                  setState(() => _currentIndex = 0);
                  context.goNamed('home');
                },
              ),
              _buildNavItem(
                icon: Icons.explore,
                label: 'Explore',
                index: 1,
                isSelected: _currentIndex == 1,
                isDark: isDark,
                onTap: () {
                  setState(() => _currentIndex = 1);
                  context.goNamed('explore');
                },
              ),
              _buildNavItem(
                icon: Icons.favorite,
                label: 'Wishlist',
                index: 2,
                isSelected: _currentIndex == 2,
                isDark: isDark,
                onTap: () {
                  setState(() => _currentIndex = 2);
                  context.goNamed('wishlist');
                },
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profile',
                index: 3,
                isSelected: _currentIndex == 3,
                isDark: isDark,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarUploadDialog(bool isDark) {
    final imagePicker = ImagePicker();
    File? selectedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Update Avatar',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textColor(isDark),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current/Preview Avatar
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.kAccentMint,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : ref.watch(authProvider).user?.profilePictureUrl !=
                                  null
                              ? CachedNetworkImage(
                                  imageUrl: ref
                                      .watch(authProvider)
                                      .user!
                                      .profilePictureUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.borderColor(isDark),
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.kAccentMint,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.borderColor(isDark),
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.kAccentMint,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.borderColor(isDark),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.kAccentMint,
                                  ),
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Upload Options
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final XFile? image = await imagePicker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                            maxWidth: 500,
                            maxHeight: 500,
                          );
                          if (image != null) {
                            setState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.kAccentMint),
                          foregroundColor: AppColors.kAccentMint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final XFile? image = await imagePicker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                            maxWidth: 500,
                            maxHeight: 500,
                          );
                          if (image != null) {
                            setState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.kAccentMint),
                          foregroundColor: AppColors.kAccentMint,
                        ),
                      ),
                    ),
                  ],
                ),

                if (selectedImage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.kAccentMint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.kAccentMint.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.kAccentMint,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                              'New image selected! Click "Upload" to save.'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedImage == null || isUploading
                  ? null
                  : () async {
                      setState(() => isUploading = true);

                      try {
                        final authService = AuthService();
                        final updatedUser =
                            await authService.uploadAvatar(selectedImage!);

                        // Update the user state immediately
                        await ref.read(authProvider.notifier).refreshUser();

                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avatar updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update avatar: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isUploading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kAccentMint,
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Upload',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(User user, bool isDark) {
    // Combine first and last name like web frontend does
    final fullName = '${user.firstName} ${user.lastName ?? ''}'.trim();
    final nameController = TextEditingController(text: fullName);
    final emailController = TextEditingController(text: user.email);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Edit Profile',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textColor(isDark),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      setState(() => isUpdating = true);

                      try {
                        // Update profile - split name like web frontend
                        final nameParts = nameController.text.trim().split(' ');
                        final firstName =
                            nameParts.isNotEmpty ? nameParts.first : '';
                        final lastName = nameParts.length > 1
                            ? nameParts.skip(1).join(' ')
                            : '';

                        final success =
                            await ref.read(authProvider.notifier).updateProfile(
                                  firstName: firstName,
                                  lastName: lastName.isEmpty ? null : lastName,
                                  email: emailController.text.trim(),
                                );

                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update profile: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isUpdating = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kAccentMint,
              ),
              child: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(bool isDark) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authService = AuthService();
    bool isChanging = false;
    bool showOldPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Change Password',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textColor(isDark),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: !showOldPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => showOldPassword = !showOldPassword),
                      icon: Icon(
                        showOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => showNewPassword = !showNewPassword),
                      icon: Icon(
                        showNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                          () => showConfirmPassword = !showConfirmPassword),
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isChanging
                  ? null
                  : () async {
                      // Validate passwords
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Password must be at least 8 characters long'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isChanging = true);

                      try {
                        await authService.changePassword(
                          oldPasswordController.text,
                          newPasswordController.text,
                        );

                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to change password: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isChanging = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kAccentMint,
              ),
              child: isChanging
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
