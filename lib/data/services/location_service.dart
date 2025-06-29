import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class LocationService {
  static const double casablancaLat = 33.5731;
  static const double casablancaLng = -7.5898;

  Future<Position?> getCurrentPosition() async {
    try {
      print('[LocationService] 🚀 Starting location request...');

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('[LocationService] 📍 Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        print('[LocationService] ❌ Location services are disabled');
        return null;
      }

      // For Android 13+, we need to request permissions using permission_handler
      // for better compatibility with the new permission model
      if (Platform.isAndroid) {
        final hasPermission = await _requestAndroidLocationPermissions();
        if (!hasPermission) {
          print(
              '[LocationService] ❌ Could not get Android location permissions');
          return null;
        }
      } else {
        // iOS - use geolocator's built-in permission handling
        LocationPermission permission = await Geolocator.checkPermission();
        print('[LocationService] 🔐 Current permission: $permission');

        if (permission == LocationPermission.denied) {
          print('[LocationService] 🔑 Requesting location permission...');
          permission = await Geolocator.requestPermission();
          print('[LocationService] 🔑 Permission after request: $permission');

          if (permission == LocationPermission.denied) {
            print('[LocationService] ❌ Location permissions denied by user');
            return null;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print('[LocationService] ❌ Location permissions permanently denied');
          return null;
        }
      }

      print(
          '[LocationService] 📡 Getting current position with mobile-data-friendly settings...');

      // Try multiple strategies for getting location, especially on mobile data
      Position? position = await _getLocationWithFallback();

      if (position != null) {
        print(
            '[LocationService] ✅ Got position: ${position.latitude}, ${position.longitude}');
        return position;
      } else {
        print('[LocationService] ❌ Could not get location with any strategy');
        return null;
      }
    } catch (e, stackTrace) {
      print('[LocationService] ❌ Error getting location: $e');
      print('[LocationService] 📍 Stack trace: $stackTrace');
      return null;
    }
  }

  // Mobile-data-friendly location fetching with fallback strategies
  Future<Position?> _getLocationWithFallback() async {
    try {
      // First, try to get last known location (fastest)
      print('[LocationService] 🔍 Trying last known location first...');
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          // Check if it's recent (within 5 minutes)
          final age = DateTime.now().difference(lastKnown.timestamp);
          if (age.inMinutes < 5) {
            print(
                '[LocationService] ⚡ Using recent last known location (${age.inMinutes}m old)');
            return lastKnown;
          }
        }
      } catch (e) {
        print('[LocationService] ⚠️ Last known location not available: $e');
      }

      // Strategy 1: Try medium accuracy first (good for mobile data)
      print(
          '[LocationService] 🎯 Trying medium accuracy (mobile-data friendly)...');
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium, // More mobile-data friendly
          timeLimit:
              const Duration(seconds: 20), // Longer timeout for mobile data
        ).timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw Exception('Medium accuracy timeout'),
        );

        print('[LocationService] ✅ Got location with medium accuracy');
        return position;
      } catch (e) {
        print('[LocationService] ⚠️ Medium accuracy failed: $e');
      }

      // Strategy 2: Try low accuracy (fastest on mobile data)
      print(
          '[LocationService] 🎯 Trying low accuracy (fastest on mobile data)...');
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy:
              LocationAccuracy.low, // Network-based, works well on mobile data
          timeLimit: const Duration(seconds: 30), // Even longer timeout
        ).timeout(
          const Duration(seconds: 35),
          onTimeout: () => throw Exception('Low accuracy timeout'),
        );

        print('[LocationService] ✅ Got location with low accuracy');
        return position;
      } catch (e) {
        print('[LocationService] ⚠️ Low accuracy failed: $e');
      }

      // Strategy 3: Try high accuracy as last resort (best on WiFi)
      print(
          '[LocationService] 🎯 Trying high accuracy (GPS-based, may be slow on mobile data)...');
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 45), // Very long timeout for GPS
        ).timeout(
          const Duration(seconds: 50),
          onTimeout: () => throw Exception('High accuracy timeout'),
        );

        print('[LocationService] ✅ Got location with high accuracy');
        return position;
      } catch (e) {
        print('[LocationService] ⚠️ High accuracy failed: $e');
      }

      // Strategy 4: Use any cached location if available
      print('[LocationService] 🔍 Trying any cached location as fallback...');
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          final age = DateTime.now().difference(lastKnown.timestamp);
          print(
              '[LocationService] ⚡ Using cached location (${age.inMinutes}m old)');
          return lastKnown;
        }
      } catch (e) {
        print('[LocationService] ⚠️ No cached location available: $e');
      }

      print('[LocationService] ❌ All location strategies failed');
      return null;
    } catch (e) {
      print('[LocationService] ❌ Error in location fallback: $e');
      return null;
    }
  }

  // Android 13+ specific permission handling
  Future<bool> _requestAndroidLocationPermissions() async {
    try {
      print('[LocationService] 🤖 Requesting Android location permissions...');

      // Check current permission status
      var fineLocationStatus = await Permission.location.status;
      var coarseLocationStatus = await Permission.locationWhenInUse.status;

      print('[LocationService] 🔐 Fine location status: $fineLocationStatus');
      print(
          '[LocationService] 🔐 Coarse location status: $coarseLocationStatus');

      // For Android 12+ (API 31+), we need to request both permissions together
      if (fineLocationStatus.isDenied || coarseLocationStatus.isDenied) {
        print('[LocationService] 🔑 Requesting location permissions...');

        // Request both fine and coarse location together for Android 12+
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location,
          Permission.locationWhenInUse,
        ].request();

        fineLocationStatus =
            statuses[Permission.location] ?? PermissionStatus.denied;
        coarseLocationStatus =
            statuses[Permission.locationWhenInUse] ?? PermissionStatus.denied;

        print(
            '[LocationService] 🔑 Fine location after request: $fineLocationStatus');
        print(
            '[LocationService] 🔑 Coarse location after request: $coarseLocationStatus');
      }

      // Check if we got at least one location permission
      final hasLocationPermission = fineLocationStatus.isGranted ||
          coarseLocationStatus.isGranted ||
          fineLocationStatus.isLimited ||
          coarseLocationStatus.isLimited;

      if (!hasLocationPermission) {
        print('[LocationService] ❌ No location permissions granted');
        return false;
      }

      print('[LocationService] ✅ Location permissions granted');
      return true;
    } catch (e) {
      print('[LocationService] ❌ Error requesting Android permissions: $e');
      return false;
    }
  }

  // Helper method to detect if running on emulator
  Future<bool> _isRunningOnEmulator() async {
    try {
      // Simple heuristic: assume emulator if we can't get location easily
      // In a real app, you might use device_info_plus for better detection
      if (Platform.isAndroid) {
        // Check if we can get location quickly (real devices usually can)
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 2),
          );

          // If we get a position very quickly, likely a real device
          // If lat/lng are exactly 0,0 or default emulator coords, likely emulator
          if (position.latitude == 0.0 && position.longitude == 0.0) {
            return true;
          }

          return false; // Got real coordinates quickly
        } catch (e) {
          // If we can't get location quickly, might be emulator
          return true;
        }
      }
      return false;
    } catch (e) {
      print('[LocationService] Could not determine emulator status: $e');
      return true; // Assume emulator if we can't determine (safer approach)
    }
  }

  // Provide emulator setup instructions
  void printEmulatorInstructions() {
    print('');
    print('🖥️ ===== EMULATOR LOCATION SETUP =====');
    print('💡 If you\'re using Android Emulator:');
    print('💡 1. Open Android Studio');
    print('💡 2. In emulator, click "..." (more) button');
    print('💡 3. Go to "Location" tab');
    print('💡 4. Set location to:');
    print('💡    - Google HQ: 37.422, -122.084');
    print('💡    - Or search for a city');
    print('💡    - Or use custom coordinates');
    print('💡 5. Click "Send Location"');
    print('💡 6. Restart the app');
    print('🖥️ =====================================');
    print('');
  }

  Future<LocationData> getUserLocationOrDefault() async {
    try {
      print('[LocationService] 🎯 Getting user location or default...');

      // Print helpful debug info for mobile data issues
      _printLocationTroubleshootingInfo();

      final position = await getCurrentPosition();

      if (position != null) {
        print('[LocationService] ✅ Using real user location');
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          isUserLocation: true,
        );
      } else {
        print('[LocationService] 📍 Using default location (Casablanca)');
        _printLocationFailureHelp();

        // Return Casablanca as default
        return LocationData(
          latitude: casablancaLat,
          longitude: casablancaLng,
          isUserLocation: false,
        );
      }
    } catch (e) {
      print('[LocationService] ❌ Error in getUserLocationOrDefault: $e');
      return LocationData(
        latitude: casablancaLat,
        longitude: casablancaLng,
        isUserLocation: false,
      );
    }
  }

  // Helper method to print troubleshooting info
  void _printLocationTroubleshootingInfo() {
    print('');
    print('📍 ===== LOCATION TROUBLESHOOTING =====');
    print('💡 If location is not working:');
    print('💡 📶 WiFi vs Mobile Data:');
    print('💡   • WiFi: Usually faster, uses network-assisted GPS');
    print('💡   • 4G/5G: Slower, relies more on GPS satellites');
    print('💡   • Make sure location services are enabled in Settings');
    print('💡 🔧 Android Settings to check:');
    print('💡   • Settings > Location > App permissions');
    print('💡   • Settings > Location > Location accuracy (High accuracy)');
    print('💡   • Settings > Location > Google Location Services');
    print('💡 ⏱️ Mobile data location can take 30-60 seconds');
    print('💡 🏢 Try going outside or near a window for better GPS signal');
    print('📍 =====================================');
    print('');
  }

  // Helper method to print failure help
  void _printLocationFailureHelp() {
    print('');
    print('❌ ===== LOCATION FAILED - TROUBLESHOOTING =====');
    print('💡 Common issues and solutions:');
    print('💡 📶 Mobile Data Issues:');
    print('💡   • GPS takes longer on mobile data (30-60 seconds)');
    print('💡   • Try moving outside or near a window');
    print('💡   • Check if mobile data is working properly');
    print('💡 🔒 Permission Issues:');
    print('💡   • Go to Settings > Apps > CasaWonders > Permissions');
    print('💡   • Enable Location permission');
    print('💡   • Choose "While using the app" or "All the time"');
    print('💡 ⚙️ Location Services:');
    print('💡   • Settings > Location > Turn ON');
    print('💡   • Settings > Location > Mode > High accuracy');
    print('💡 🌐 Network Issues:');
    print('💡   • Try switching between WiFi and mobile data');
    print('💡   • Restart the app after switching networks');
    print('❌ =============================================');
    print('');
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  Future<bool> hasLocationPermission() async {
    try {
      print('[LocationService] 🔐 Checking location permission...');

      if (Platform.isAndroid) {
        // Use permission_handler for Android 13+ compatibility
        final fineLocationStatus = await Permission.location.status;
        final coarseLocationStatus = await Permission.locationWhenInUse.status;

        print('[LocationService] 🔐 Fine location status: $fineLocationStatus');
        print(
            '[LocationService] 🔐 Coarse location status: $coarseLocationStatus');

        final hasPermission = fineLocationStatus.isGranted ||
            coarseLocationStatus.isGranted ||
            fineLocationStatus.isLimited ||
            coarseLocationStatus.isLimited;

        print('[LocationService] 🔐 Has permission: $hasPermission');
        return hasPermission;
      } else {
        // iOS - use geolocator
        final permission = await Geolocator.checkPermission();
        print('[LocationService] 🔐 Current permission: $permission');

        final hasPermission = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;

        print('[LocationService] 🔐 Has permission: $hasPermission');
        return hasPermission;
      }
    } catch (e) {
      print('[LocationService] ❌ Error checking permission: $e');
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      print('[LocationService] 🔑 Requesting location permission...');

      // First check if services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[LocationService] ❌ Location services not enabled');
        return false;
      }

      if (Platform.isAndroid) {
        // Use Android 13+ compatible permission request
        return await _requestAndroidLocationPermissions();
      } else {
        // iOS - use geolocator
        final permission = await Geolocator.requestPermission();
        print('[LocationService] 🔑 Permission result: $permission');

        final granted = permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;

        print('[LocationService] 🔑 Permission granted: $granted');
        return granted;
      }
    } catch (e) {
      print('[LocationService] ❌ Error requesting permission: $e');
      return false;
    }
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final bool isUserLocation;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.isUserLocation,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, isUser: $isUserLocation)';
  }
}
