import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../data/services/listings_service.dart';
import '../../data/services/location_service.dart';

class AdvancedFilterDrawer extends ConsumerStatefulWidget {
  final bool isDark;
  final ListingFilters currentFilters;
  final Function(ListingFilters) onApplyFilters;
  final VoidCallback onClearFilters;

  const AdvancedFilterDrawer({
    super.key,
    required this.isDark,
    required this.currentFilters,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  ConsumerState<AdvancedFilterDrawer> createState() =>
      _AdvancedFilterDrawerState();
}

class _AdvancedFilterDrawerState extends ConsumerState<AdvancedFilterDrawer> {
  late ListingFilters _filters;
  LocationData? _userLocation;
  final LocationService _locationService = LocationService();

  // Cache location to avoid repeated requests
  static LocationData? _cachedLocation;
  static DateTime? _lastLocationFetch;
  static const Duration _locationCacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    // Copy the current filters
    _filters = ListingFilters(
      category: widget.currentFilters.category,
      minPrice: widget.currentFilters.minPrice,
      maxPrice: widget.currentFilters.maxPrice,
      minRating: widget.currentFilters.minRating,
      date: widget.currentFilters.date,
      location: widget.currentFilters.location,
    );

    // Get user's current location (with caching)
    _getUserLocationWithCache();
  }

  Future<void> _getUserLocationWithCache({bool forceRefresh = false}) async {
    try {
      // Check if we have a valid cached location
      if (!forceRefresh &&
          _cachedLocation != null &&
          _lastLocationFetch != null &&
          DateTime.now().difference(_lastLocationFetch!) <
              _locationCacheDuration) {
        print(
            '[AdvancedFilterDrawer] 📍 Using cached location: ${_cachedLocation!.latitude}, ${_cachedLocation!.longitude}');

        if (mounted) {
          setState(() {
            _userLocation = _cachedLocation;
          });
          _initializeLocationFilter();
        }
        return;
      }

      print(
          '[AdvancedFilterDrawer] 📍 ${forceRefresh ? "Force refreshing" : "Getting"} user location...');
      final locationData = await _locationService.getUserLocationOrDefault();

      // Cache the location
      _cachedLocation = locationData;
      _lastLocationFetch = DateTime.now();

      if (mounted) {
        setState(() {
          _userLocation = locationData;
        });

        print(
            '[AdvancedFilterDrawer] ✅ Got location: ${locationData.latitude}, ${locationData.longitude} (isUser: ${locationData.isUserLocation})');

        _initializeLocationFilter();
      }
    } catch (e) {
      print('[AdvancedFilterDrawer] ❌ Error getting location: $e');
    }
  }

  void _initializeLocationFilter() {
    // Only auto-initialize location filter if:
    // 1. We don't have one already
    // 2. We have real user location (not default)
    // 3. User hasn't manually set a different location
    if (_filters.location == null &&
        _userLocation != null &&
        _userLocation!.isUserLocation) {
      setState(() {
        _filters = ListingFilters(
          category: _filters.category,
          minPrice: _filters.minPrice,
          maxPrice: _filters.maxPrice,
          minRating: _filters.minRating,
          date: _filters.date,
          location: LocationFilter(
            lat: _userLocation!.latitude,
            lng: _userLocation!.longitude,
            radius: 5.0, // Default 5km radius
          ),
        );
      });
      print(
          '[AdvancedFilterDrawer] 🎯 Auto-initialized location filter with user location');
    }
  }

  // Category definitions matching web version
  final List<CategoryOption> _categories = [
    CategoryOption(
      id: 'restaurant',
      name: 'Restaurants',
      icon: Icons.restaurant,
      description: 'Dining & culinary experiences',
    ),
    CategoryOption(
      id: 'event',
      name: 'Events',
      icon: Icons.celebration,
      description: 'Entertainment & activities',
    ),
    CategoryOption(
      id: 'cultural',
      name: 'Cultural',
      icon: Icons.museum,
      description: 'Heritage & cultural sites',
    ),
  ];

  // Price range options matching web version
  final List<PriceRangeOption> _priceRanges = [
    PriceRangeOption(min: 0, max: 100, label: 'Under 100 MAD'),
    PriceRangeOption(min: 100, max: 200, label: '100-200 MAD'),
    PriceRangeOption(min: 200, max: 300, label: '200-300 MAD'),
    PriceRangeOption(min: 300, max: 500, label: '300-500 MAD'),
    PriceRangeOption(min: 500, max: null, label: 'Over 500 MAD'),
  ];

  // Rating options matching web version
  final List<RatingOption> _ratingOptions = [
    RatingOption(value: 3.0, stars: 3, label: '3+ Stars'),
    RatingOption(value: 4.0, stars: 4, label: '4+ Stars'),
    RatingOption(value: 4.5, stars: 5, label: '4.5+ Stars'),
  ];

  void _handleCategoryChange(String? category) {
    setState(() {
      _filters = ListingFilters(
        category: category,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
        minRating: _filters.minRating,
        date: _filters.date,
        location: _filters.location,
      );
    });
  }

  void _handlePriceRangeChange(double? min, double? max) {
    setState(() {
      _filters = ListingFilters(
        category: _filters.category,
        minPrice: min,
        maxPrice: max,
        minRating: _filters.minRating,
        date: _filters.date,
        location: _filters.location,
      );
    });
  }

  void _handleRatingChange(double? rating) {
    setState(() {
      _filters = ListingFilters(
        category: _filters.category,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
        minRating: rating,
        date: _filters.date,
        location: _filters.location,
      );
    });
  }

  void _handleDateChange(DateTime? date) {
    setState(() {
      _filters = ListingFilters(
        category: _filters.category,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
        minRating: _filters.minRating,
        date: date != null
            ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
            : null,
        location: _filters.location,
      );
    });
  }

  void _handleDistanceChange(double distance) {
    setState(() {
      // Use user's real location if available, otherwise fall back to Casablanca
      final lat = _userLocation?.latitude ?? 33.5731;
      final lng = _userLocation?.longitude ?? -7.5898;

      print(
          '[AdvancedFilterDrawer] 📍 Setting distance filter: ${distance}km from ($lat, $lng)');
      print(
          '[AdvancedFilterDrawer] 📍 Using ${_userLocation?.isUserLocation == true ? "real user location" : "default location"}');

      _filters = ListingFilters(
        category: _filters.category,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
        minRating: _filters.minRating,
        date: _filters.date,
        location: LocationFilter(
          lat: lat,
          lng: lng,
          radius: distance,
        ),
      );
    });
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_filters.category != null) count++;
    if (_filters.minPrice != null || _filters.maxPrice != null) count++;
    if (_filters.minRating != null) count++;
    if (_filters.date != null) count++;
    if (_filters.location != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(widget.isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.textSecondaryColor(widget.isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textColor(widget.isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters = ListingFilters();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kAccentMint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildSectionTitle('Category'),
                  const SizedBox(height: 16),
                  ..._categories
                      .map((category) => _buildCategoryTile(category)),
                  const SizedBox(height: 32),

                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 16),
                  ..._priceRanges.map((range) => _buildPriceRangeTile(range)),
                  const SizedBox(height: 32),

                  // Rating
                  _buildSectionTitle('Minimum Rating'),
                  const SizedBox(height: 16),
                  Row(
                    children: _ratingOptions
                        .map((rating) =>
                            Expanded(child: _buildRatingTile(rating)))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Date
                  _buildSectionTitle('Available Date'),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 32),

                  // Distance
                  _buildSectionTitle('Distance'),
                  const SizedBox(height: 16),
                  _buildDistanceSlider(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor(widget.isDark),
              border: Border(
                top: BorderSide(color: AppColors.borderColor(widget.isDark)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClearFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: AppColors.borderColor(widget.isDark)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textColor(widget.isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApplyFilters(_filters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kAccentMint,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Apply',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_getActiveFiltersCount() > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_getActiveFiltersCount()}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textColor(widget.isDark),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryTile(CategoryOption category) {
    final isSelected = _filters.category == category.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleCategoryChange(isSelected ? null : category.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.kAccentMint
                    : AppColors.borderColor(widget.isDark),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color:
                  isSelected ? AppColors.kAccentMint.withOpacity(0.05) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.kAccentMint.withOpacity(0.1)
                        : AppColors.cardColor(widget.isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: isSelected
                        ? AppColors.kAccentMint
                        : AppColors.textSecondaryColor(widget.isDark),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textColor(widget.isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.kAccentMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeTile(PriceRangeOption range) {
    final isSelected = _filters.minPrice == range.min &&
        (_filters.maxPrice == range.max ||
            (range.max == null && _filters.maxPrice == null));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePriceRangeChange(
            isSelected ? null : range.min,
            isSelected ? null : range.max,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.kAccentMint
                    : AppColors.borderColor(widget.isDark),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected ? AppColors.kAccentMint.withOpacity(0.05) : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: isSelected
                      ? AppColors.kAccentMint
                      : AppColors.textSecondaryColor(widget.isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        range.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textColor(widget.isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${range.min} – ${range.max ?? "+"} MAD',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.kAccentMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingTile(RatingOption rating) {
    final isSelected = _filters.minRating == rating.value;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleRatingChange(isSelected ? null : rating.value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.kAccentMint
                    : AppColors.borderColor(widget.isDark),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected ? AppColors.kAccentMint.withOpacity(0.05) : null,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.stars ? Icons.star : Icons.star_border,
                      color: index < rating.stars ? Colors.amber : Colors.grey,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  rating.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textColor(widget.isDark),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${rating.value}+ stars',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryColor(widget.isDark),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _filters.date != null
                ? DateTime.tryParse(_filters.date!) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            _handleDateChange(date);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor(widget.isDark)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.textSecondaryColor(widget.isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _filters.date ?? 'Select date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _filters.date != null
                        ? AppColors.textColor(widget.isDark)
                        : AppColors.textSecondaryColor(widget.isDark),
                  ),
                ),
              ),
              if (_filters.date != null)
                GestureDetector(
                  onTap: () => _handleDateChange(null),
                  child: Icon(
                    Icons.clear,
                    color: AppColors.textSecondaryColor(widget.isDark),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceSlider() {
    final radius = _filters.location?.radius ?? 5.0;
    final isUsingUserLocation = _userLocation?.isUserLocation == true;

    return Column(
      children: [
        // Location status info
        if (_userLocation != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isUsingUserLocation
                  ? AppColors.kAccentMint.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUsingUserLocation
                    ? AppColors.kAccentMint.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUsingUserLocation ? Icons.my_location : Icons.location_on,
                  size: 16,
                  color: isUsingUserLocation
                      ? AppColors.kAccentMint
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUsingUserLocation
                        ? 'Using your current location'
                        : 'Using default location (Casablanca)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUsingUserLocation
                          ? AppColors.kAccentMint
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Refresh location button
                if (!isUsingUserLocation)
                  GestureDetector(
                    onTap: () async {
                      print('[AdvancedFilterDrawer] 🔄 Refreshing location...');
                      await _getUserLocationWithCache(forceRefresh: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Distance display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Within',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryColor(widget.isDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.kAccentMint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${radius.toInt()} km',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kAccentMint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.kAccentMint,
            inactiveTrackColor: AppColors.borderColor(widget.isDark),
            thumbColor: AppColors.kAccentMint,
            overlayColor: AppColors.kAccentMint.withOpacity(0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: radius,
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: _handleDistanceChange,
          ),
        ),

        // Range labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 km',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryColor(widget.isDark),
                ),
              ),
              Text(
                '25 km',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryColor(widget.isDark),
                ),
              ),
              Text(
                '50 km',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryColor(widget.isDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick distance buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [2, 5, 10, 20].map((distance) {
            final isSelected = radius.toInt() == distance;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleDistanceChange(distance.toDouble()),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.kAccentMint
                              : AppColors.borderColor(widget.isDark),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? AppColors.kAccentMint.withOpacity(0.1)
                            : null,
                      ),
                      child: Text(
                        '$distance km',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.kAccentMint
                              : AppColors.textSecondaryColor(widget.isDark),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Supporting classes
class CategoryOption {
  final String id;
  final String name;
  final IconData icon;
  final String description;

  CategoryOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}

class PriceRangeOption {
  final double min;
  final double? max;
  final String label;

  PriceRangeOption({
    required this.min,
    this.max,
    required this.label,
  });
}

class RatingOption {
  final double value;
  final int stars;
  final String label;

  RatingOption({
    required this.value,
    required this.stars,
    required this.label,
  });
}
