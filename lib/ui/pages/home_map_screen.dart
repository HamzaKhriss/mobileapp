import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../data/mock_data.dart';
import '../../state/theme_provider.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  int _currentIndex = 0;
  String? _selectedListingId;
  Offset? _popupPosition;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return LucideIcons.utensils;
      case 'music':
        return LucideIcons.music;
      case 'cooking':
        return LucideIcons.coffee;
      case 'art':
        return LucideIcons.image;
      case 'entertainment':
        return LucideIcons.play;
      case 'tour':
        return LucideIcons.map;
      default:
        return LucideIcons.calendar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Real interactive map with OpenStreetMap (free!)
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(33.5731, -7.5898), // Casablanca
              initialZoom: 11.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.casa_wonders',
              ),
              MarkerLayer(
                markers: MockData.listings.map((listing) {
                  final isSelected = _selectedListingId == listing.id;
                  return Marker(
                    point: LatLng(listing.latitude, listing.longitude),
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          _selectedListingId = listing.id;
                          _popupPosition = details.globalPosition;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color.fromRGBO(40, 43, 43, 1)
                              : AppColors.kAccentMint,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.kAccentMint, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(listing.category),
                            color: isSelected
                                ? AppColors.kAccentMint
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Search bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor(isDark),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.borderColor(isDark),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: AppColors.textColor(isDark)),
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    prefixIcon: Icon(LucideIcons.search,
                        color: AppColors.textSecondaryColor(isDark)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    hintStyle:
                        TextStyle(color: AppColors.textSecondaryColor(isDark)),
                  ),
                ),
              ),
            ),
          ),
          // Tap to close popup (behind the popup)
          if (_selectedListingId != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedListingId = null;
                  _popupPosition = null;
                });
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          // Popup card for selected listing (on top)
          if (_selectedListingId != null && _popupPosition != null)
            _buildListingPopup(isDark),
          // Custom bottom navigation positioned at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: LucideIcons.house,
                        label: 'Home',
                        index: 0,
                        isSelected: _currentIndex == 0,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: LucideIcons.compass,
                        label: 'Explore',
                        index: 1,
                        isSelected: _currentIndex == 1,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: LucideIcons.heart,
                        label: 'Wishlist',
                        index: 2,
                        isSelected: _currentIndex == 2,
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        icon: LucideIcons.user,
                        label: 'Profile',
                        index: 3,
                        isSelected: _currentIndex == 3,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.goNamed('explore');
              break;
            case 2:
              context.goNamed('wishlist');
              break;
            case 3:
              context.goNamed('profile');
              break;
          }
        },
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

  Widget _buildListingPopup(bool isDark) {
    final selectedListing = MockData.listings.firstWhere(
      (listing) => listing.id == _selectedListingId,
    );

    return Positioned(
      left: _popupPosition!.dx - 150, // Center the popup on the marker
      top: _popupPosition!.dy - 180, // Position above the marker
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => context.pushNamed(
            'listing-detail',
            pathParameters: {'id': selectedListing.id},
          ),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor(isDark),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    selectedListing.imageUrl,
                    width: 300,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedListing.title,
                        style: TextStyle(
                          color: AppColors.textColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedListing.location,
                        style: TextStyle(
                          color: AppColors.textSecondaryColor(isDark),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                selectedListing.rating.toString(),
                                style: TextStyle(
                                  color: AppColors.textColor(isDark),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${selectedListing.price.toInt()} MAD',
                            style: const TextStyle(
                              color: AppColors.kAccentMint,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow pointing down to marker
                Transform.rotate(
                  angle: 0.785398, // 45 degrees in radians
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor(isDark),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
                          blurRadius: 4,
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
    );
  }
}
