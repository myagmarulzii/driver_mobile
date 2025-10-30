import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driving_session.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;
  final List<Location> _routePoints = [];

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  List<Location> get routePoints => _routePoints;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check permissions
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions permanently denied');
        return null;
      }

      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Get position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      notifyListeners();
      return _currentPosition;
    } catch (e) {
      debugPrint('Get current position error: $e');
      return null;
    }
  }

  // Start tracking location
  Future<bool> startTracking({
    required Function(Location) onLocationUpdate,
  }) async {
    try {
      if (_isTracking) {
        debugPrint('Already tracking location');
        return false;
      }

      // Get initial position
      final position = await getCurrentPosition();
      if (position == null) {
        return false;
      }

      _isTracking = true;
      _routePoints.clear();

      // Add initial point
      final initialLocation = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
      _routePoints.add(initialLocation);

      // Start listening to position updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 5), // Update every 5 seconds max
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;

          final location = Location(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
          );

          _routePoints.add(location);
          onLocationUpdate(location);
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Position stream error: $error');
          stopTracking();
        },
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Start tracking error: $e');
      return false;
    }
  }

  // Stop tracking location
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  // Calculate total distance of route
  double calculateRouteDistance() {
    if (_routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;

    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        _routePoints[i],
        _routePoints[i + 1],
      );
    }

    return totalDistance;
  }

  // Calculate distance between two locations using Haversine formula
  double _calculateDistance(Location start, Location end) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    final lat1 = start.latitude * (3.14159265359 / 180.0);
    final lon1 = start.longitude * (3.14159265359 / 180.0);
    final lat2 = end.latitude * (3.14159265359 / 180.0);
    final lon2 = end.longitude * (3.14159265359 / 180.0);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();

    final c = 2 * (a.sqrt()).asin();
    return earthRadius * c;
  }

  // Get distance between two positions
  double getDistanceBetween(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  // Clear route points
  void clearRoute() {
    _routePoints.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
