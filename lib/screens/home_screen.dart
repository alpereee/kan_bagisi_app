import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/create_request_sheet.dart';
import '../widgets/primary_button.dart';
import 'nearby_hospitals_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // OVERFLOW HATASI BURADAYDI → Text'i Expanded ile sardık
        title: Row(
          children: [
            const Icon(Icons.volunteer_activism, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Birbirimize kandan bağlıyız',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ÜST CTA (Kan bağışı talebi oluştur)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PrimaryButton(
              onPressed: () => CreateRequestSheet.open(context),
              child: const Text('Kan Bağışı Talebi Oluştur'),
            ),
          ),

          // Küçük bilgilendirme kartı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Acil durumlarda en yakın bağış noktasına yönlendirme yapılır.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // TALEP LİSTESİ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donation_requests')
                  .where('status', isEqualTo: 'open')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasError) {
                  return _ErrorState(error: snapshot.error.toString());
                }

                final docs = snapshot.data?.docs ?? [];

                // Empty
                if (docs.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _RequestCard(
                      requestId: doc.id,
                      data: data,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
///  TEK TALEP KARTI
/// ------------------------------
class _RequestCard extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  const _RequestCard({
    required this.requestId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final bloodType = data['bloodType'] ?? '-';
    final city = data['city'] ?? '';
    final urgency = (data['urgency'] ?? 'orta').toString();
    final createdAt = data['createdAt'] as Timestamp?;

    // İSİM & NOT → senin isterlerine göre
    final receiverName = data['receiverName'] ??
        data['name'] ??
        data['fullName'] ??
        'İsim belirtilmemiş';

    final note = (data['note'] ?? '').toString().trim();

    final createdText = _timeAgo(createdAt);
    final urgencyColor = _urgencyColor(context, urgency);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST SATIR (KAN GRUBU + ACİLİYET)
            Row(
              children: [
                // Kan grubu
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bloodtype, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        bloodType,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Aciliyet
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgency.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: urgencyColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // İSİM
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    receiverName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ŞEHİR
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    city,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),

            // NOT (varsa)
            if (note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 6),

            // TARİH
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 6),
                Text(
                  createdText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ALT BUTONLAR
            Column(
              children: [
                // BAĞIŞ NOKTALARINI GÖR
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: const Text(
                      'Bağış Noktalarını Gör',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NearbyHospitalsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // BAĞIŞ YAPILDI
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Bağış Yapıldı',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => _handleDonationCompleted(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _urgencyColor(BuildContext context, String urgency) {
    switch (urgency.toLowerCase()) {
      case 'acil':
        return Colors.red;
      case 'düşük':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return 'Bilinmiyor';

    final diff = DateTime.now().difference(ts.toDate());

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }

  Future<void> _handleDonationCompleted(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağışı kaydetmek için giriş yapmalısın.')),
      );
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // 1) Talebi güncelle (tamamlandı)
      final reqRef =
          firestore.collection('donation_requests').doc(requestId);

      batch.update(reqRef, {
        'status': 'done',
        'helpedBy': user.uid,
        'helpedAt': FieldValue.serverTimestamp(),
      });

      // 2) Bağış kaydı oluştur
      final donationRef = firestore.collection('donations').doc();

      final receiverName = data['receiverName'] ??
          data['name'] ??
          data['fullName'] ??
          'Bilinmiyor';
      final bloodType = data['bloodType'] ?? '-';
      final city = data['city'] ?? '';

      batch.set(donationRef, {
        'donorId': user.uid,
        'requestId': requestId,
        'receiverName': receiverName,
        'bloodType': bloodType,
        'city': city,
        'date': FieldValue.serverTimestamp(),
      });

      // 3) Kullanıcı puanı / toplam bağış
      final userRef = firestore.collection('users').doc(user.uid);

      batch.set(
        userRef,
        {
          'totalDonations': FieldValue.increment(1),
          'points': FieldValue.increment(10),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bağış kaydedildi. Toplam puanına +10 eklendi.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağış kaydedilirken bir hata oluştu: $e'),
        ),
      );
    }
  }
}

/// ------------------------------
///  BOŞ LİSTE DURUMU
/// ------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz aktif bir kan bağışı talebi yok',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'İlk talebi sen oluşturabilirsin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------
///  HATA DURUMU
/// ------------------------------
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
