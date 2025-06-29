import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

import '../../state/theme_provider.dart';
import '../../state/listings_provider.dart';
import '../../data/models/listing.dart';
import '../../data/services/location_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/listings_service.dart';
import '../widgets/advanced_filter_drawer.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  int _currentIndex = 0;
  String? _selectedListingId;
  Offset? _popupPosition;

  // Map controller for programmatic map control
  late final MapController _mapController;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Listing> _filteredListings = [];

  // User location state
  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  bool _hasLocationPermission = false;

  // Location service
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();

    // Initialize search functionality
    _searchController.addListener(() {
      // This listener is already handled in the onChanged callback
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Initialize user location
  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      print('[HomeMapScreen] 🎯 Initializing location...');
      final locationData = await _locationService.getUserLocationOrDefault();

      setState(() {
        _userLocation = LatLng(locationData.latitude, locationData.longitude);
        _hasLocationPermission = locationData.isUserLocation;
        _isLoadingLocation = false;
      });

      if (!locationData.isUserLocation) {
        // Show instructions for emulator setup
        _locationService.printEmulatorInstructions();

        // Show helpful message to user
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            NotificationService.showSnackBar(
              context,
              'Using default location. Tap the location button to set your position.',
              type: NotificationType.info,
              duration: const Duration(seconds: 5),
            );
          }
        });
      }
    } catch (e) {
      print('[HomeMapScreen] ❌ Error initializing location: $e');
      setState(() {
        _userLocation = const LatLng(33.5731, -7.5898); // Casablanca default
        _hasLocationPermission = false;
        _isLoadingLocation = false;
      });

      // Show error to user
      if (mounted) {
        NotificationService.showSnackBar(
          context,
          'Location unavailable. Using default map view.',
          type: NotificationType.warning,
        );
      }
    }
  }

  // Center map on user location
  void _centerOnUserLocation() async {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
      NotificationService.showSnackBar(
        context,
        'Centered on your location',
        type: NotificationType.info,
      );
    } else {
      // Request permission and get location
      await _requestLocationPermission();
    }
  }

  // Center map on listing
  void _centerOnListing(Listing listing) {
    final listingPos = LatLng(listing.location.lat, listing.location.lng);
    _mapController.move(listingPos, 16.0);
  }

  // Handle search functionality
  void _handleSearch(String query, List<Listing> allListings) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredListings = allListings;
      } else {
        _filteredListings = allListings.where((listing) {
          return listing.title.toLowerCase().contains(_searchQuery) ||
              listing.description.toLowerCase().contains(_searchQuery) ||
              listing.location.address.toLowerCase().contains(_searchQuery) ||
              listing.category.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });

    // If there are search results, fit the map to show all results
    if (_filteredListings.isNotEmpty && _searchQuery.isNotEmpty) {
      _fitMapToListings(_filteredListings);
    }
  }

  // Fit map to show all filtered listings
  void _fitMapToListings(List<Listing> listings) {
    if (listings.isEmpty) {
      print('[HomeMapScreen] ⚠️ No listings to fit map to');
      return;
    }

    try {
      // Validate coordinates and filter out invalid ones
      final validListings = listings.where((listing) {
        final lat = listing.location.lat;
        final lng = listing.location.lng;
        return lat.isFinite &&
            lng.isFinite &&
            lat != 0.0 &&
            lng != 0.0 && // Exclude 0,0 coordinates
            lat >= -90 &&
            lat <= 90 &&
            lng >= -180 &&
            lng <= 180;
      }).toList();

      if (validListings.isEmpty) {
        print('[HomeMapScreen] ⚠️ No valid coordinates found in listings');
        return;
      }

      double minLat = validListings.first.location.lat;
      double maxLat = validListings.first.location.lat;
      double minLng = validListings.first.location.lng;
      double maxLng = validListings.first.location.lng;

      for (final listing in validListings) {
        final lat = listing.location.lat;
        final lng = listing.location.lng;

        minLat = math.min(minLat, lat);
        maxLat = math.max(maxLat, lat);
        minLng = math.min(minLng, lng);
        maxLng = math.max(maxLng, lng);
      }

      // Ensure we have valid bounds
      if (!minLat.isFinite ||
          !maxLat.isFinite ||
          !minLng.isFinite ||
          !maxLng.isFinite) {
        print('[HomeMapScreen] ❌ Invalid bounds calculated');
        return;
      }

      // Add padding, but ensure minimum padding for single point
      double latPadding = (maxLat - minLat) * 0.1;
      double lngPadding = (maxLng - minLng) * 0.1;

      // Minimum padding for single point or very close points
      const minPadding = 0.01; // ~1km
      latPadding = math.max(latPadding, minPadding);
      lngPadding = math.max(lngPadding, minPadding);

      final southWest = LatLng(minLat - latPadding, minLng - lngPadding);
      final northEast = LatLng(maxLat + latPadding, maxLng + lngPadding);

      // Validate final bounds
      if (!southWest.latitude.isFinite ||
          !southWest.longitude.isFinite ||
          !northEast.latitude.isFinite ||
          !northEast.longitude.isFinite) {
        print('[HomeMapScreen] ❌ Invalid final bounds');
        return;
      }

      final bounds = LatLngBounds(southWest, northEast);

      print(
          '[HomeMapScreen] 📍 Fitting map to ${validListings.length} listings');
      print(
          '[HomeMapScreen] 📍 Bounds: SW(${southWest.latitude}, ${southWest.longitude}) NE(${northEast.latitude}, ${northEast.longitude})');

      _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    } catch (e, stackTrace) {
      print('[HomeMapScreen] ❌ Error fitting map to listings: $e');
      print('[HomeMapScreen] 📍 Stack trace: $stackTrace');

      // Fallback: just center on Casablanca
      _mapController.move(const LatLng(33.5731, -7.5898), 12.0);
    }
  }

  // Enhanced location permission handling
  Future<void> _requestLocationPermission() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      print('[HomeMapScreen] 🔑 Requesting location permission...');

      final hasPermission = await _locationService.hasLocationPermission();
      if (hasPermission) {
        print('[HomeMapScreen] ✅ Already has permission');
        await _initializeLocation();
        return;
      }

      // Show permission explanation dialog
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission'),
          content: const Text(
            'This app needs location access to show your position on the map and provide better recommendations based on your location.\n\nIf you\'re using an emulator, make sure location is set in the emulator settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        print('[HomeMapScreen] 🔑 User agreed to permission request');
        final granted = await _locationService.requestLocationPermission();

        if (granted) {
          print('[HomeMapScreen] ✅ Permission granted, initializing location');
          await _initializeLocation();

          NotificationService.showSnackBar(
            context,
            'Location permission granted!',
            type: NotificationType.success,
          );
        } else {
          print('[HomeMapScreen] ❌ Permission denied');
          // Show settings dialog
          _showLocationSettingsDialog();
        }
      } else {
        print('[HomeMapScreen] ❌ User declined permission request');
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('[HomeMapScreen] ❌ Error requesting location permission: $e');
      setState(() {
        _isLoadingLocation = false;
      });

      NotificationService.showSnackBar(
        context,
        'Error requesting location permission. Check console for emulator setup instructions.',
        type: NotificationType.error,
        duration: const Duration(seconds: 6),
      );

      // Print instructions for user
      _locationService.printEmulatorInstructions();
    }
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Setup Required'),
        content: const Text(
          'Location permission is required to show your position on the map.\n\n'
          'For Android Emulator:\n'
          '1. Click "..." in emulator\n'
          '2. Go to Location tab\n'
          '3. Set a location\n'
          '4. Restart the app\n\n'
          'For real devices:\n'
          'Open app settings to enable location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _locationService.printEmulatorInstructions();
            },
            child: const Text('Show Instructions'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _locationService.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

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
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ??
                  const LatLng(33.5731, -7.5898), // User location or Casablanca
              initialZoom: _userLocation != null ? 15.0 : 11.0,
              onTap: (tapPosition, point) {
                // Close popup when tapping on map
                setState(() {
                  _selectedListingId = null;
                  _popupPosition = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.casa_wonders',
              ),
              // User location accuracy circle
              if (_userLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _userLocation!,
                      color: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue.withOpacity(0.4),
                      borderStrokeWidth: 2,
                      radius: 50, // meters
                    ),
                  ],
                ),

              // User location marker layer
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Listings markers layer
              Consumer(
                builder: (context, ref, child) {
                  final listingsAsync = ref.watch(listingsProvider);

                  return listingsAsync.when(
                    data: (listings) {
                      // Initialize filtered listings if not set
                      if (_filteredListings.isEmpty && _searchQuery.isEmpty) {
                        _filteredListings = listings;
                      }

                      // Use filtered listings or all listings
                      final displayListings = _searchQuery.isNotEmpty
                          ? _filteredListings
                          : listings;

                      return MarkerLayer(
                        markers: displayListings.map((listing) {
                          final isSelected = _selectedListingId == listing.id;
                          return Marker(
                            point: LatLng(
                                listing.location.lat, listing.location.lng),
                            child: GestureDetector(
                              onTapDown: (details) {
                                setState(() {
                                  _selectedListingId = listing.id;
                                  _popupPosition = details.globalPosition;
                                });
                                // Center map on selected listing
                                _centerOnListing(listing);
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
                                          color: AppColors.kAccentMint,
                                          width: 2)
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
                      );
                    },
                    loading: () => MarkerLayer(markers: []),
                    error: (error, stack) => MarkerLayer(markers: []),
                  );
                },
              ),
            ],
          ),
          // Search bar and Filter button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
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
                        controller: _searchController,
                        style: TextStyle(color: AppColors.textColor(isDark)),
                        onChanged: (value) {
                          final listingsAsync = ref.read(listingsProvider);
                          listingsAsync.whenData((listings) {
                            _handleSearch(value, listings);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search destinations...',
                          prefixIcon: Icon(LucideIcons.search,
                              color: AppColors.textSecondaryColor(isDark)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color:
                                          AppColors.textSecondaryColor(isDark)),
                                  onPressed: () {
                                    _searchController.clear();
                                    final listingsAsync =
                                        ref.read(listingsProvider);
                                    listingsAsync.whenData((listings) {
                                      _handleSearch('', listings);
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          hintStyle: TextStyle(
                              color: AppColors.textSecondaryColor(isDark)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Filter button
                  Container(
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
                    child: Consumer(
                      builder: (context, ref, child) {
                        final currentFilters =
                            ref.watch(listingsProvider.notifier).currentFilters;
                        final activeFiltersCount =
                            _getActiveFiltersCount(currentFilters);

                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                LucideIcons.filter,
                                color: AppColors.textColor(isDark),
                              ),
                              onPressed: () =>
                                  _showFiltersDrawer(context, isDark),
                            ),
                            // Active filters badge
                            if (activeFiltersCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.kAccentMint,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$activeFiltersCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
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

          // Floating action button to center on user location
          Positioned(
            top: 140,
            right: 16,
            child: FloatingActionButton(
              heroTag: "centerLocation",
              mini: true,
              backgroundColor: AppColors.cardColor(isDark),
              foregroundColor: AppColors.textColor(isDark),
              elevation: 4,
              onPressed: _isLoadingLocation ? null : _centerOnUserLocation,
              child: _isLoadingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.kAccentMint,
                        ),
                      ),
                    )
                  : Icon(
                      _hasLocationPermission
                          ? LucideIcons.crosshair
                          : Icons.location_on,
                      size: 20,
                    ),
            ),
          ),
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
    return Consumer(
      builder: (context, ref, child) {
        final listingsAsync = ref.watch(listingsProvider);

        return listingsAsync.when(
          data: (listings) {
            try {
              final selectedListing = listings.firstWhere(
                (listing) => listing.id == _selectedListingId,
              );
              return _buildPopupContent(selectedListing, isDark);
            } catch (e) {
              // If listing not found, close popup
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedListingId = null;
                  _popupPosition = null;
                });
              });
              return const SizedBox.shrink();
            }
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildPopupContent(Listing selectedListing, bool isDark) {
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
                  child: CachedNetworkImage(
                    imageUrl: selectedListing.images.isNotEmpty
                        ? selectedListing.images[0]
                        : 'https://via.placeholder.com/300x120?text=No+Image',
                    width: 300,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 300,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 300,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
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
                        selectedListing.location.address,
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

  // Helper method to count active filters
  int _getActiveFiltersCount(ListingFilters? filters) {
    if (filters == null) return 0;

    int count = 0;
    if (filters.category != null) count++;
    if (filters.minPrice != null || filters.maxPrice != null) count++;
    if (filters.minRating != null) count++;
    if (filters.date != null) count++;
    if (filters.location != null) count++;
    return count;
  }

  // Show filters drawer
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

          // Show feedback to user
          NotificationService.showSnackBar(
            context,
            'Filters applied successfully!',
            type: NotificationType.success,
          );
        },
        onClearFilters: () {
          ref.read(listingsProvider.notifier).clearFilters();
          Navigator.pop(context);

          // Show feedback to user
          NotificationService.showSnackBar(
            context,
            'All filters cleared',
            type: NotificationType.info,
          );
        },
      ),
    );
  }
}
