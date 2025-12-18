class BloodUtils {
  
  // Tam kan / eritrosit bağışı için uyumluluk matrisi
  static const Map<String, List<String>> _donorCompatibility = {
    'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'], 
    'O+': ['O+', 'A+', 'B+', 'AB+'],
    'A-': ['A-', 'A+', 'AB-', 'AB+'],
    'A+': ['A+', 'AB+'],
    'B-': ['B-', 'B+', 'AB-', 'AB+'],
    'B+': ['B+', 'AB+'],
    'AB-': ['AB-', 'AB+'],
    'AB+': ['AB+'],
  };

  /// 🔥 [NİHAİ DÜZELTME] Kan Grubu Uygunluk Kontrolü
  static bool isCompatible({required String donor, required String recipient}) {
    // 1. Agresif Temizlik ve Standartlaştırma
    // Tüm boşlukları, özel karakterleri kaldırır ve sadece izin verilen formatı bırakır.
    final cleanDonor = _sanitizeBloodGroup(donor);
    final cleanRecipient = _sanitizeBloodGroup(recipient);

    // 2. KRİTİK KONTROL: Kan Grupları aynıysa mutlak uyumluluk vardır.
    if (cleanDonor == cleanRecipient) {
      return true;
    }
    
    // 3. Matris Kontrolü
    final recipientsList = _donorCompatibility[cleanDonor];
    
    if (recipientsList == null) {
      return false; 
    }

    // Donörün verebileceği alıcılar listesinde, bizim alıcımız var mı?
    return recipientsList.contains(cleanRecipient);
  }
  
  /// Gelen kan grubunu karşılaştırma için temizler ve standartlaştırır.
  static String _sanitizeBloodGroup(String blood) {
      // Sadece A, B, O, AB, +, - karakterlerini tutar. Diğer her şeyi siler.
      // Bu, gizli boşlukları ve karakterleri yok etmenin en garantili yoludur.
      return blood.toUpperCase()   
                  .replaceAll(RegExp(r'[^A-Z0-9+-]'), '') // Geçerli olmayan tüm karakterleri sil
                  .replaceAll('RH', ''); // RH yazıyorsa onu da siler.
  }
  
}