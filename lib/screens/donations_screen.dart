// lib/screens/donations_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: user == null
          ? const _NotLoggedIn()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .where('donorId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return _ErrorState(error: snap.error.toString());
                }

                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const _EmptyState();
                }

                final docs = snap.data!.docs;

                return SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    children: [
                      _HeaderCard(total: docs.length),
                      const SizedBox(height: 20),
                      _DonationChart(docs: docs),
                      const SizedBox(height: 20),
                      _NextDonationCard(docs: docs),
                      const SizedBox(height: 24),
                      ...docs.map(
                        (d) => _DonationItem(
                          data: d.data() as Map<String, dynamic>,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HEADER                                                                    */
/* -------------------------------------------------------------------------- */

class _HeaderCard extends StatelessWidget {
  final int total;
  const _HeaderCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bloodtype, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam Bağış',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                total.toString(),
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* CHART                                                                     */
/* -------------------------------------------------------------------------- */

class _DonationChart extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _DonationChart({required this.docs});

  @override
  Widget build(BuildContext context) {
    // Ay bazlı bağış sayısı (sadece ay numarası ile)
    final Map<int, int> monthCounts = {}; // key: 1-12

    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final ts = data['date'] as Timestamp?;
      if (ts == null) continue;
      final dt = ts.toDate();
      final key = DateTime(dt.year, dt.month).month;
      monthCounts[key] = (monthCounts[key] ?? 0) + 1;
    }

    if (monthCounts.isEmpty) {
      return _ChartContainer(
        child: Center(
          child: Text(
            'Henüz grafik için yeterli veri yok.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    // Son 6 ay
    final now = DateTime.now();
    final List<int> lastMonths = [];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i).month;
      lastMonths.add(m);
    }

    const monthNames = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];

    final maxVal = monthCounts.values.isEmpty
        ? 1
        : monthCounts.values.reduce((a, b) => a > b ? a : b);

    return _ChartContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bağış Geçmişi',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: lastMonths.map((m) {
                final count = monthCounts[m] ?? 0;

                final double h;
                if (count == 0) {
                  h = 8.0;
                } else {
                  const double base = 18.0;
                  const double extra = 36.0; // max ~54 px bar
                  h = base + (count / maxVal) * extra;
                }

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        height: h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: count == 0
                              ? Colors.grey.shade200
                              : const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthNames[m - 1],
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final Widget child;
  const _ChartContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

/* -------------------------------------------------------------------------- */
/* NEXT DONATION CARD                                                         */
/* -------------------------------------------------------------------------- */

class _NextDonationCard extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _NextDonationCard({required this.docs});

  @override
  Widget build(BuildContext context) {
    Timestamp? lastTs;

    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final ts = data['date'] as Timestamp?;
      if (ts == null) continue;
      if (lastTs == null || ts.toDate().isAfter(lastTs.toDate())) {
        lastTs = ts;
      }
    }

    String text;
    Color color;
    IconData icon;

    if (lastTs == null) {
      text = 'Henüz bağış yapmadın. İlk bağışınla bir hayat kurtarabilirsin.';
      color = Colors.orange;
      icon = Icons.info_outline;
    } else {
      final lastDate = lastTs.toDate();
      final next = lastDate.add(const Duration(days: 90));
      final diff = next.difference(DateTime.now()).inDays;

      if (diff <= 0) {
        text = 'Şu anda tekrar kan bağışı yapabilirsin.';
        color = Colors.green;
        icon = Icons.check_circle_outline;
      } else {
        text = '$diff gün sonra tekrar kan bağışı yapabilirsin.';
        color = Colors.redAccent;
        icon = Icons.hourglass_bottom;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* DONATION ITEM CARD                                                         */
/* -------------------------------------------------------------------------- */

class _DonationItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DonationItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final blood = data['bloodType'] ?? '-';
    final receiver = data['receiverName'] ?? 'Bilinmiyor';
    final city = data['city'] ?? '';
    final pointName = data['pointName'] ?? '';
    final Timestamp? ts = data['date'];
    final dateStr = _format(ts);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // üst satır: kan grubu + tarih
          Row(
            children: [
              _pill(context, blood),
              const Spacer(),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            receiver,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          if (city.isNotEmpty || pointName.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [city, pointName].where((e) => e.isNotEmpty).join(' • '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  String _format(Timestamp? ts) {
    if (ts == null) return 'Tarih bilinmiyor';
    final d = ts.toDate();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

/* -------------------------------------------------------------------------- */
/* STATES                                                                     */
/* -------------------------------------------------------------------------- */

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
              Icons.bloodtype_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz bağış yapmadın',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'İlk bağışınla bir hayat kurtarabilirsin.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bağışlarını görmek için önce giriş yapmalısın.'),
    );
  }
}

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
