import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/big_header.dart';
import '../widgets/primary_button.dart';
import '../widgets/settings_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  static const route = '/notification-settings';
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool emergencyEnabled = true;
  bool nearbyEnabled = true;
  double radiusKm = 10;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final m =
          (doc.data()?['notificationSettings'] ?? {}) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        emergencyEnabled = (m['emergencyEnabled'] ?? true) as bool;
        nearbyEnabled = (m['nearbyEnabled'] ?? true) as bool;
        radiusKm = ((m['nearbyRadiusKm'] ?? 10) as num).toDouble();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar yüklenemedi')),
      );
    }
  }

  Future<void> _save() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationSettings': {
          'emergencyEnabled': emergencyEnabled,
          'nearbyEnabled': nearbyEnabled,
          'nearbyRadiusKm': nearbyEnabled ? radiusKm.round() : 0,
        }
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedildi ✅')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          const BigHeader(
            icon: Icons.notifications_active,
            title: 'Bildirim Ayarları',
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Acil durum bildirimleri
                SettingsCard(
                  header: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Acil durum bildirimleri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: emergencyEnabled,
                        onChanged: (v) =>
                            setState(() => emergencyEnabled = v),
                      ),
                    ],
                  ),
                  showDivider: true,
                  children: const [
                    SizedBox(height: 4),
                    Text(
                      'Acil kan talepleri için bildirim al',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Yakındaki kan arayanlar
                SettingsCard(
                  header: Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Yakındaki kan arayanlar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: nearbyEnabled,
                        onChanged: (v) =>
                            setState(() => nearbyEnabled = v),
                      ),
                    ],
                  ),
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Mesafe',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const Spacer(),
                        Text(
                          '${radiusKm.round()} km',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Slider(
                      min: 1,
                      max: 50,
                      divisions: 49,
                      value: radiusKm,
                      label: '${radiusKm.round()} km',
                      onChanged: nearbyEnabled
                          ? (v) => setState(() => radiusKm = v)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seçilen mesafe içindeki talepler için bildirim al',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: _save,
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
