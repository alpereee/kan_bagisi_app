import 'dart:math';

class GeoUtils {
  static double distanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    double dLat = _deg(lat2 - lat1), dLon = _deg(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg(lat1)) * cos(_deg(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _deg(double d) => d * pi / 180.0;
}
