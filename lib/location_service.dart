import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Konum izni ve servis kontrolü
  static Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Mevcut konumu alır (izin verilmişse)
  /// - Crash riskine karşı try/catch
  /// - Sonsuz beklemeye karşı timeLimit
  static Future<Position?> currentPosition() async {
    final ok = await ensurePermission();
    if (!ok) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Konum alınamadıysa sessizce null döner
      return null;
    }
  }
}
