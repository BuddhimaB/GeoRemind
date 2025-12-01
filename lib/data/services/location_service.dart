import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';

class LocationService {
  static final LocationService instance = LocationService._init();
  LocationService._init();
  
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;
    
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
  
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.distanceFilter.toInt(),
      ),
    );
  }
  
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }
  
  bool isWithinRadius(
    double currentLat,
    double currentLng,
    double targetLat,
    double targetLng,
    double radius,
  ) {
    final distance = calculateDistance(
      currentLat,
      currentLng,
      targetLat,
      targetLng,
    );
    return distance <= radius;
  }
}
