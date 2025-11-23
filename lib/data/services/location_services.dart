import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationService {
  /// Request Permission
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Ambil lokasi pengguna
  Future<Position?> getCurrentLocation() async {
    final allowed = await requestPermission();
    if (!allowed) return null;

    return Geolocator.getCurrentPosition();
  }

  /// Hitung jarak antar titik (meter)
  double distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // radius bumi

    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * pi / 180;
}
