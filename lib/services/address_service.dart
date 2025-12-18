import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressService {
  static Stream<String> watchDistrictCity() async* {
    // izin ve servis kontrolü çağıran tarafta yapıldı varsayıyoruz.
    final ctrl = StreamController<String>();
    Position? last;
    Future<void> _resolve(Position p) async {
      try {
        final placemarks = await placemarkFromCoordinates(p.latitude, p.longitude);
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;
          final district = (pm.subAdministrativeArea?.isNotEmpty ?? false)
              ? pm.subAdministrativeArea!
              : (pm.locality ?? '');
          final city = pm.administrativeArea ?? '';
          ctrl.add('$district / $city');
        }
      } catch (_) {}
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 50),
    ).listen((p) {
      if (last == null ||
          Geolocator.distanceBetween(last!.latitude, last!.longitude, p.latitude, p.longitude) > 30) {
        last = p;
        _resolve(p);
      }
    });

    // ilk değer
    try {
      final p = await Geolocator.getCurrentPosition();
      await _resolve(p);
    } catch (_) {}

    yield* ctrl.stream;
  }
}
