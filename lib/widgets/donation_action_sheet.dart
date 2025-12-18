import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Kan bağışı için yol tarifi + "Bağış yapıldı" alt sheet'i.
/// Her bağışta:
///  - donations koleksiyonuna kayıt ekler
///  - users/{uid}.points alanına +10 puan ekler
///  - users/{uid}.totalDonations alanına +1 ekler
class DonationActionSheet extends StatefulWidget {
  final Map<String, dynamic>? requestData;

  /// Seçilen bağış noktası bilgileri
  final String? pointId;
  final String? pointName;
  final String? city;
  final double? lat;
  final double? lng;

  const DonationActionSheet({
    super.key,
    this.requestData,
    this.pointId,
    this.pointName,
    this.city,
    this.lat,
    this.lng,
  });

  /// Eski / yeni tüm çağrılarla uyumlu olsun diye
  /// tüm parametreleri opsiyonel yaptım.
  ///
  /// Örn:
  /// DonationActionSheet.open(
  ///   context,
  ///   data: data,
  ///   pointId: 'ankara_kizilay',
  ///   pointName: 'Kızılay Ankara Şubesi',
  ///   city: 'Ankara',
  ///   lat: 39.92,
  ///   lng: 32.85,
  /// );
  static Future<void> open(
    BuildContext context, {
    Map<String, dynamic>? data,
    String? pointId,
    String? pointName,
    String? city,
    double? lat,
    double? lng,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DonationActionSheet(
        requestData: data,
        pointId: pointId,
        pointName: pointName,
        city: city,
        lat: lat,
        lng: lng,
      ),
    );
  }

  @override
  State<DonationActionSheet> createState() => _DonationActionSheetState();
}

class _DonationActionSheetState extends State<DonationActionSheet> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final request = widget.requestData ?? {};
    final requesterName = request['requesterName'] as String? ?? 'Bilinmiyor';
    final bloodType = request['bloodType'] as String? ?? '-';
    final requestCity =
        request['city'] as String? ?? widget.city ?? 'Şehir bilgisi yok';

    final pointName = widget.pointName ?? 'Seçili bağış noktası';
    final pointCity = widget.city ?? requestCity;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bağış Detayı',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),

                // İhtiyaç sahibi
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      child: Text(
                        (requesterName.isNotEmpty
                                ? requesterName[0]
                                : '?')
                            .toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requesterName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Kan Grubu: $bloodType',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bağış noktası
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pointName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pointCity,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Yol tarifi butonu
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text(
                      'Yol Tarifi Aç',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: _openMaps,
                  ),
                ),

                const SizedBox(height: 12),

                // Bağış yapıldı butonu (+10 puan)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      _saving ? 'Kaydediliyor...' : 'Bağış Yapıldı (+10 puan)',
                    ),
                    onPressed: _saving ? null : _onDonationDone,
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  'Bağışı kaydettiğinizde, bağış geçmişinize eklenir ve profil puanınıza +10 puan yazılır.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMaps() async {
    final lat = widget.lat;
    final lng = widget.lng;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum bilgisi bulunamadı.')),
      );
      return;
    }

    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng'
        '&travelmode=driving');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita açılamadı.')),
      );
    }
  }

  /// Bağış kaydı + kullanıcıya puan ekleme
  Future<void> _onDonationDone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devam etmek için giriş yapmalısın.')),
      );
      return;
    }

    setState(() => _saving = true);

    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(user.uid);
    final donationsRef = db.collection('donations').doc();

    final request = widget.requestData ?? {};

    final donationData = <String, dynamic>{
      'donorId': user.uid,
      'receiverName': request['requesterName'] ?? 'Bilinmiyor',
      'bloodType': request['bloodType'] ?? '-',
      'city': request['city'] ?? widget.city,
      'pointId': widget.pointId,
      'pointName': widget.pointName,
      'lat': widget.lat,
      'lng': widget.lng,
      'date': FieldValue.serverTimestamp(),
    };

    try {
      await db.runTransaction((tx) async {
        // Bağış kaydı
        tx.set(donationsRef, donationData);

        // Kullanıcıya +10 puan ve +1 toplam bağış
        final userSnap = await tx.get(userRef);
        final data = (userSnap.data() as Map<String, dynamic>?) ?? {};
        final currentPoints = (data['points'] as int?) ?? 0;
        final currentTotal = (data['totalDonations'] as int?) ?? 0;

        tx.set(
          userRef,
          {
            'points': currentPoints + 10,
            'totalDonations': currentTotal + 1,
          },
          SetOptions(merge: true),
        );

        // İstersen bağış isteğini kapatma (id varsa)
        final reqId = request['id'] as String?;
        if (reqId != null && reqId.isNotEmpty) {
          final reqRef =
              db.collection('donation_requests').doc(reqId);
          tx.set(
            reqRef,
            {
              'status': 'done',
              'helpedBy': user.uid,
              'helpedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      });

      if (!mounted) return;
      Navigator.of(context).pop(); // Sheet kapat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağış kaydedildi, +10 puan eklendi 🎉')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
