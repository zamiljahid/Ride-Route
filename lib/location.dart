import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  Timer? _locationTimer;
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  Future<void> sendLocationToBackend(Position position, String id, String authToken) async {
    final response = await http.post(
      Uri.parse('https://rasdalmodon-backend.onrender.com/api/driver/update-location/'),
      body: {
        'driver_id': id,
        'latitude': position.latitude.toString(), // Double to String conversion
        'longitude': position.longitude.toString(), // Double to String conversion
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Location updated successfully");
    } else {
      print("Failed to update location");
    }
  }
  void startLocationUpdates(String driverId, String authToken) {
    if (_locationTimer != null) {
      print("Location updates already running.");
      return;
    }
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        final position = await getCurrentLocation();
        await sendLocationToBackend(position, driverId, authToken);
      } catch (e) {
        print("Error updating location: $e");
      }
    });
  }
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    print("Location updates stopped.");
  }
}
