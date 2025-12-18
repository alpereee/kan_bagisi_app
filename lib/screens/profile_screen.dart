import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profilim'),
        ),
        body: const Center(
          child: Text('Profili görmek için giriş yapmalısın.'),
        ),
      );
    }

    final userDocStream =
        FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();

    final lastDonationStream = FirebaseFirestore.instance
        .collection('donations')
        .where('donorId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocStream,
        builder: (context, userSnap) {
          final userData =
              userSnap.data?.data() as Map<String, dynamic>? ?? {};

          final displayName = userData['name'] ??
              user.displayName ??
              user.email?.split('@').first ??
              'Kullanıcı';
          final bloodType = userData['bloodType'] ?? 'Bilinmiyor';
          final totalDonations = (userData['totalDonations'] ?? 0) as int;
          final points = (userData['points'] ?? 0) as int;
          final city = userData['city'] ?? 'Belirtilmedi';
          final phone = userData['phone'] ?? 'Belirtilmedi';

          final initial =
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

          return StreamBuilder<QuerySnapshot>(
            stream: lastDonationStream,
            builder: (context, donationSnap) {
              Timestamp? lastTs;
              if (donationSnap.hasData &&
                  donationSnap.data!.docs.isNotEmpty) {
                final data = donationSnap.data!.docs.first.data()
                    as Map<String, dynamic>;
                lastTs = data['date'] as Timestamp?;
              }

              final nextText = _nextDonationText(lastTs);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    // Üst profil kartı
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kan Grubu: $bloodType',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (ctx) => _ProfileEditSheet(
                                  userId: user.uid,
                                  currentName: displayName,
                                  currentBloodType: bloodType,
                                  currentCity: city,
                                  currentPhone: phone,
                                  currentEmail: user.email ?? '',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // İstatistik kartları
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.bloodtype,
                            label: 'Toplam Bağış',
                            value: totalDonations.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.star,
                            label: 'Puan',
                            value: points.toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Sonraki bağış zamanı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            color: Colors.black.withOpacity(.05),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bloodtype_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              nextText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.timer_outlined),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detaylı bilgi kartı
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            color: Colors.black.withOpacity(.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'İletişim Bilgileri',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'E-posta',
                            value: user.email ?? 'Belirtilmedi',
                          ),
                          const Divider(height: 20),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Telefon',
                            value: phone,
                          ),
                          const Divider(height: 20),
                          _InfoRow(
                            icon: Icons.location_city_outlined,
                            label: 'Şehir',
                            value: city,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔴 ÇIKIŞ YAP BUTONU
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          // authStateChanges dinleyen main.dart seni LoginScreen'e döndürecek
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Çıkış Yap'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _nextDonationText(Timestamp? lastTs) {
    if (lastTs == null) {
      return 'Henüz kayıtlı bir bağışınız yok.';
    }
    final last = lastTs.toDate();
    final next = last.add(const Duration(days: 90));
    final diff = next.difference(DateTime.now()).inDays;

    if (diff <= 0) {
      return 'Şu anda tekrar kan bağışı yapabilirsiniz.';
    }
    return '$diff gün sonra tekrar bağış yapabilirsiniz.';
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(.05),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// PROFİL DÜZENLEME ALT SAYFASI (AYARLAR)
class _ProfileEditSheet extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentBloodType;
  final String currentCity;
  final String currentPhone;
  final String currentEmail;

  const _ProfileEditSheet({
    required this.userId,
    required this.currentName,
    required this.currentBloodType,
    required this.currentCity,
    required this.currentPhone,
    required this.currentEmail,
  });

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _bloodController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bloodController = TextEditingController(text: widget.currentBloodType);
    _cityController = TextEditingController(text: widget.currentCity);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': _nameController.text.trim(),
        'bloodType': _bloodController.text.trim(),
        'city': _cityController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedilirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Text(
              'Profil Bilgilerini Düzenle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bloodController,
              decoration: const InputDecoration(
                labelText: 'Kan Grubu (Örn: A+)',
                prefixIcon: Icon(Icons.bloodtype_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Şehir',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta (görünüm için)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
