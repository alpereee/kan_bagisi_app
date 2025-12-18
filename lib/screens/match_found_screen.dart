import 'package:flutter/material.dart';

class MatchFoundScreen extends StatelessWidget {
  static const route = '/match-found';

  final String donorName;
  final String donorPhone;
  final String donorBloodType;
  final double distanceKm;

  const MatchFoundScreen({
    super.key,
    this.donorName = '-',
    this.donorPhone = '-',
    this.donorBloodType = '-',
    this.distanceKm = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eşleşme Bulundu')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text("Kan Bağışçısı Bulundu!",
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Text("👤 Ad Soyad: $donorName", style: const TextStyle(fontSize: 18)),
                Text("🩸 Kan Grubu: $donorBloodType", style: const TextStyle(fontSize: 18)),
                Text("📞 Telefon: $donorPhone", style: const TextStyle(fontSize: 18)),
                Text("📍 Uzaklık: ${distanceKm.toStringAsFixed(1)} km",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text("Tamam"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
