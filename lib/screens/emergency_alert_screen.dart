import 'dart:convert' as convert;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Flask sunucu adresin
const String kNotifyEndpoint = 'http://127.0.0.1:5001/notify';

class EmergencyAlertScreen extends StatefulWidget {
  static const route = '/emergency';
  const EmergencyAlertScreen({super.key});

  @override
  State<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends State<EmergencyAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _bloodType = 'A Rh+';
  String _urgency = 'Yüksek';
  bool _sending = false;

  GeoPoint? _myLocation;
  String? _myCity, _myDistrict;

  List<_MatchCandidate> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadSelf();
  }

  @override
  void dispose() {
    _hospitalCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSelf() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final me = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final d = me.data();
    if (!mounted) return;
    setState(() {
      _myLocation = d?['location'];
      _myCity = d?['city'];
      _myDistrict = d?['district'];
    });
  }

  List<String> _compatibleDonors(String needed) {
    switch (needed) {
      case '0 Rh-': return ['0 Rh-'];
      case '0 Rh+': return ['0 Rh-', '0 Rh+'];
      case 'A Rh-': return ['0 Rh-', 'A Rh-'];
      case 'A Rh+': return ['0 Rh-', '0 Rh+', 'A Rh-', 'A Rh+'];
      case 'B Rh-': return ['0 Rh-', 'B Rh-'];
      case 'B Rh+': return ['0 Rh-', '0 Rh+', 'B Rh-', 'B Rh+'];
      case 'AB Rh-': return ['0 Rh-', 'A Rh-', 'B Rh-', 'AB Rh-'];
      case 'AB Rh+':
      default:
        return ['0 Rh-', '0 Rh+', 'A Rh-', 'A Rh+', 'B Rh-', 'B Rh+', 'AB Rh-', 'AB Rh+'];
    }
  }

  double _haversineKm(GeoPoint a, GeoPoint b) {
    const R = 6371.0;
    double dLat = _deg2rad(b.latitude - a.latitude);
    double dLon = _deg2rad(b.longitude - a.longitude);
    double lat1 = _deg2rad(a.latitude);
    double lat2 = _deg2rad(b.latitude);
    double h = (sin(dLat/2) * sin(dLat/2)) +
        cos(lat1) * cos(lat2) * (sin(dLon/2) * sin(dLon/2));
    return 2 * R * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg2rad(double d) => d * pi / 180.0;

  Future<void> _createAnnouncementAndMatch() async {
    if (!_formKey.currentState!.validate()) return;

    final myLoc = _myLocation;
    if (myLoc == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konum bulunamadı. Lütfen izinleri kontrol edin.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 1) Talebi kaydet
      final annRef = await FirebaseFirestore.instance.collection('announcements').add({
        'requesterId': uid,
        'hospitalName': _hospitalCtrl.text.trim(),
        'bloodTypeNeeded': _bloodType,
        'urgency': _urgency,
        'note': _noteCtrl.text.trim(),
        'location': myLoc,
        'city': _myCity,
        'district': _myDistrict,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2) Donörleri çek
      final donors = _compatibleDonors(_bloodType);
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('isAvailable', isEqualTo: true)
          .where('bloodType', whereIn: donors)
          .get();

      // 3) Mesafe hesapla
      final List<_MatchCandidate> candidates = [];
      for (final doc in q.docs) {
        final data = doc.data();
        if (doc.id == uid) continue;
        final GeoPoint? loc = data['location'];
        if (loc == null) continue;
        final dist = _haversineKm(myLoc, loc);
        candidates.add(_MatchCandidate(
          uid: doc.id,
          fullName: data['fullName'] ?? '-',
          phone: data['phoneNumber'] ?? '-',
          bloodType: data['bloodType'] ?? '-',
          fcmToken: data['fcmToken'],
          distanceKm: dist,
        ));
      }
      candidates.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      if (!mounted) return;
      setState(() => _matches = candidates.take(10).toList());

      // 4) Sonuç diyaloğu
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Eşleşen Bağışçılar'),
          content: _matches.isEmpty
              ? const Text('Uygun bağışçı bulunamadı.')
              : SizedBox(
                  width: 420,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _matches.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final m = _matches[i];
                      return ListTile(
                        leading: const Icon(Icons.bloodtype),
                        title: Text('${m.fullName} • ${m.bloodType}'),
                        subtitle:
                            Text('~${m.distanceKm.toStringAsFixed(1)} km • ${m.phone}'),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
            if (_matches.any((m) => (m.fcmToken ?? '').isNotEmpty))
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _sendFcmToMatches(announcementId: annRef.id);
                },
                child: const Text('Bildirim Gönder'),
              ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendFcmToMatches({required String announcementId}) async {
    final tokens = _matches
        .map((m) => m.fcmToken)
        .where((t) => t != null && t.isNotEmpty)
        .cast<String>()
        .toList();

    if (tokens.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli FCM token bulunamadı.')),
      );
      return;
    }

    try {
      final me = FirebaseAuth.instance.currentUser;
      final requesterDoc =
          await FirebaseFirestore.instance.collection('users').doc(me!.uid).get();
      final requesterName = requesterDoc.data()?['fullName'] ?? 'Bağış Talebi';

      final payload = {
        'title': 'Acil Kan İhtiyacı: $_bloodType',
        'body': '$requesterName için ${_hospitalCtrl.text.trim()}',
        'tokens': tokens,
        'data': {
          'type': 'blood_request',
          'bloodType': _bloodType,
          'urgency': _urgency,
          'hospital': _hospitalCtrl.text.trim(),
          'announcementId': announcementId,
        }
      };

      final res = await http.post(
        Uri.parse(kNotifyEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirimler gönderildi ✅')),
        );
      } else {
        throw 'Sunucu yanıtı: ${res.statusCode}';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim gönderilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloodTypes = ['0 Rh-','0 Rh+','A Rh-','A Rh+','B Rh-','B Rh+','AB Rh-','AB Rh+'];
    final urgencies = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];

    return Scaffold(
      appBar: AppBar(title: const Text('Acil Kan İsteği')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Talep Bilgileri', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _hospitalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hastane Adı',
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _bloodType,
                      decoration: const InputDecoration(
                        labelText: 'İstenen Kan Grubu',
                        border: OutlineInputBorder(),
                      ),
                      items: bloodTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _bloodType = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _urgency,
                      decoration: const InputDecoration(
                        labelText: 'Aciliyet',
                        border: OutlineInputBorder(),
                      ),
                      items: urgencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _urgency = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Not (opsiyonel)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    if (_myCity != null || _myDistrict != null)
                      Text('Konum: ${_myCity ?? '-'} / ${_myDistrict ?? '-'}',
                          style: const TextStyle(color: Colors.grey)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _sending ? null : _createAnnouncementAndMatch,
                icon: _sending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bloodtype),
                label: Text(_sending ? 'İşleniyor...' : 'Talep Oluştur ve Eşleştir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchCandidate {
  final String uid;
  final String fullName;
  final String phone;
  final String bloodType;
  final String? fcmToken;
  final double distanceKm;

  _MatchCandidate({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.bloodType,
    required this.fcmToken,
    required this.distanceKm,
  });
}
