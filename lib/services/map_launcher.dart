import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  /// Cihazda Google/Apple Haritalar ile rota açar.
  static Future<void> openDirections({
    required double destLat, // Hedef (hastane) enlemi
    required double destLng, // Hedef (hastane) boylamı
    double? originLat,      // Başlangıç (kullanıcı) enlemi
    double? originLng,      // Başlangıç (kullanıcı) boylamı
  }) async {
    
    // 1. Hedef ve Başlangıç Konumlarını Metin Olarak Hazırlama
    final destination = '$destLat,$destLng';
    
    // 2. Başlangıç noktası (Kullanıcının mevcut konumu veya otomatik bulma)
    String origin; 
    if (originLat != null && originLng != null) {
      origin = '$originLat,$originLng';
    } else {
      // Konum yoksa, haritanın otomatik bulması için boş bırakılır.
      origin = ''; 
    }
    
    // 3. Google Haritalar query parametrelerini oluşturma
    // Bu parametreler (origin, destination) Haritalar uygulaması tarafından okunur.
    final Map<String, dynamic> queryParameters = {
      'api': '1', // Google Maps API versiyonu (genellikle rota başlatmak için kullanılır)
      'origin': origin,
      'destination': destination,
      'travelmode': 'driving',
      'dir_action': 'navigate',
    };

    // 4. URL'yi Uri.https ile güvenli şekilde oluşturma (Hata yapmayı engeller)
    final uri = Uri.https(
      'www.google.com', 
      '/maps/dir/', 
      queryParameters,
    );

    try {
      // launchUrl çağrısında canLaunchUrl kontrolünü atlayıp, launchUrl'ın 
      // kendi hata yakalama mekanizmasını kullanıyoruz (daha temiz bir Flutter yapısıdır).
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      } else {
        throw 'Haritalar uygulaması açılamadı veya URL geçersiz.';
      }
    } catch (e) {
        // Hata yönetimi
        rethrow; 
    }
  }
}