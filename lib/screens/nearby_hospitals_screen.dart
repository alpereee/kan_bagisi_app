import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 81 il için bağış noktası modeli
class DonationPoint {
  final String id;
  final String city;
  final String name;
  final double lat;
  final double lng;

  const DonationPoint({
    required this.id,
    required this.city,
    required this.name,
    required this.lat,
    required this.lng,
  });
}

/// 81 il için örnek Kızılay bağış noktaları
const List<DonationPoint> kDonationPoints = [
  DonationPoint(
    id: 'adana',
    city: 'Adana',
    name: 'Adana Kızılay Kan Bağış Merkezi',
    lat: 37.0000,
    lng: 35.3213,
  ),
  DonationPoint(
    id: 'adiyaman',
    city: 'Adıyaman',
    name: 'Adıyaman Kızılay Kan Bağış Merkezi',
    lat: 37.7648,
    lng: 38.2786,
  ),
  DonationPoint(
    id: 'afyonkarahisar',
    city: 'Afyonkarahisar',
    name: 'Afyonkarahisar Kızılay Kan Bağış Merkezi',
    lat: 38.7569,
    lng: 30.5433,
  ),
  DonationPoint(
    id: 'agri',
    city: 'Ağrı',
    name: 'Ağrı Kızılay Kan Bağış Merkezi',
    lat: 39.7191,
    lng: 43.0503,
  ),
  DonationPoint(
    id: 'amasya',
    city: 'Amasya',
    name: 'Amasya Kızılay Kan Bağış Merkezi',
    lat: 40.6539,
    lng: 35.8331,
  ),
  DonationPoint(
    id: 'ankara',
    city: 'Ankara',
    name: 'Ankara Kızılay Kan Bağış Merkezi',
    lat: 39.9208,
    lng: 32.8541,
  ),
  DonationPoint(
    id: 'antalya',
    city: 'Antalya',
    name: 'Antalya Kızılay Kan Bağış Merkezi',
    lat: 36.8969,
    lng: 30.7133,
  ),
  DonationPoint(
    id: 'artvin',
    city: 'Artvin',
    name: 'Artvin Kızılay Kan Bağış Merkezi',
    lat: 41.1828,
    lng: 41.8228,
  ),
  DonationPoint(
    id: 'aydin',
    city: 'Aydın',
    name: 'Aydın Kızılay Kan Bağış Merkezi',
    lat: 37.8450,
    lng: 27.8396,
  ),
  DonationPoint(
    id: 'balikesir',
    city: 'Balıkesir',
    name: 'Balıkesir Kızılay Kan Bağış Merkezi',
    lat: 39.6484,
    lng: 27.8826,
  ),
  DonationPoint(
    id: 'bilecik',
    city: 'Bilecik',
    name: 'Bilecik Kızılay Kan Bağış Merkezi',
    lat: 40.1500,
    lng: 29.9833,
  ),
  DonationPoint(
    id: 'bingol',
    city: 'Bingöl',
    name: 'Bingöl Kızılay Kan Bağış Merkezi',
    lat: 38.8853,
    lng: 40.4983,
  ),
  DonationPoint(
    id: 'bitlis',
    city: 'Bitlis',
    name: 'Bitlis Kızılay Kan Bağış Merkezi',
    lat: 38.4011,
    lng: 42.1075,
  ),
  DonationPoint(
    id: 'bolu',
    city: 'Bolu',
    name: 'Bolu Kızılay Kan Bağış Merkezi',
    lat: 40.7316,
    lng: 31.5898,
  ),
  DonationPoint(
    id: 'burdur',
    city: 'Burdur',
    name: 'Burdur Kızılay Kan Bağış Merkezi',
    lat: 37.7203,
    lng: 30.2908,
  ),
  DonationPoint(
    id: 'bursa',
    city: 'Bursa',
    name: 'Bursa Kızılay Kan Bağış Merkezi',
    lat: 40.1950,
    lng: 29.0600,
  ),
  DonationPoint(
    id: 'canakkale',
    city: 'Çanakkale',
    name: 'Çanakkale Kızılay Kan Bağış Merkezi',
    lat: 40.1553,
    lng: 26.4142,
  ),
  DonationPoint(
    id: 'cankiri',
    city: 'Çankırı',
    name: 'Çankırı Kızılay Kan Bağış Merkezi',
    lat: 40.6070,
    lng: 33.6210,
  ),
  DonationPoint(
    id: 'corum',
    city: 'Çorum',
    name: 'Çorum Kızılay Kan Bağış Merkezi',
    lat: 40.5506,
    lng: 34.9556,
  ),
  DonationPoint(
    id: 'denizli',
    city: 'Denizli',
    name: 'Denizli Kızılay Kan Bağış Merkezi',
    lat: 37.7833,
    lng: 29.0963,
  ),
  DonationPoint(
    id: 'diyarbakir',
    city: 'Diyarbakır',
    name: 'Diyarbakır Kızılay Kan Bağış Merkezi',
    lat: 37.9144,
    lng: 40.2306,
  ),
  DonationPoint(
    id: 'edirne',
    city: 'Edirne',
    name: 'Edirne Kızılay Kan Bağış Merkezi',
    lat: 41.6772,
    lng: 26.5556,
  ),
  DonationPoint(
    id: 'elazig',
    city: 'Elazığ',
    name: 'Elazığ Kızılay Kan Bağış Merkezi',
    lat: 38.6742,
    lng: 39.2220,
  ),
  DonationPoint(
    id: 'erzincan',
    city: 'Erzincan',
    name: 'Erzincan Kızılay Kan Bağış Merkezi',
    lat: 39.7500,
    lng: 39.5000,
  ),
  DonationPoint(
    id: 'erzurum',
    city: 'Erzurum',
    name: 'Erzurum Kızılay Kan Bağış Merkezi',
    lat: 39.9056,
    lng: 41.2769,
  ),
  DonationPoint(
    id: 'eskisehir',
    city: 'Eskişehir',
    name: 'Eskişehir Kızılay Kan Bağış Merkezi',
    lat: 39.7767,
    lng: 30.5206,
  ),
  DonationPoint(
    id: 'gaziantep',
    city: 'Gaziantep',
    name: 'Gaziantep Kızılay Kan Bağış Merkezi',
    lat: 37.0662,
    lng: 37.3833,
  ),
  DonationPoint(
    id: 'giresun',
    city: 'Giresun',
    name: 'Giresun Kızılay Kan Bağış Merkezi',
    lat: 40.9175,
    lng: 38.3927,
  ),
  DonationPoint(
    id: 'gumushane',
    city: 'Gümüşhane',
    name: 'Gümüşhane Kızılay Kan Bağış Merkezi',
    lat: 40.4600,
    lng: 39.4800,
  ),
  DonationPoint(
    id: 'hakkari',
    city: 'Hakkâri',
    name: 'Hakkâri Kızılay Kan Bağış Merkezi',
    lat: 37.5744,
    lng: 43.7408,
  ),
  DonationPoint(
    id: 'hatay',
    city: 'Hatay',
    name: 'Hatay Kızılay Kan Bağış Merkezi',
    lat: 36.2028,
    lng: 36.1600,
  ),
  DonationPoint(
    id: 'isparta',
    city: 'Isparta',
    name: 'Isparta Kızılay Kan Bağış Merkezi',
    lat: 37.7648,
    lng: 30.5566,
  ),
  DonationPoint(
    id: 'mersin',
    city: 'Mersin',
    name: 'Mersin Kızılay Kan Bağış Merkezi',
    lat: 36.8000,
    lng: 34.6333,
  ),
  DonationPoint(
    id: 'istanbul',
    city: 'İstanbul',
    name: 'İstanbul Kızılay Kan Bağış Merkezi',
    lat: 41.0082,
    lng: 28.9784,
  ),
  DonationPoint(
    id: 'izmir',
    city: 'İzmir',
    name: 'İzmir Kızılay Kan Bağış Merkezi',
    lat: 38.4237,
    lng: 27.1428,
  ),
  DonationPoint(
    id: 'kars',
    city: 'Kars',
    name: 'Kars Kızılay Kan Bağış Merkezi',
    lat: 40.6085,
    lng: 43.0975,
  ),
  DonationPoint(
    id: 'kastamonu',
    city: 'Kastamonu',
    name: 'Kastamonu Kızılay Kan Bağış Merkezi',
    lat: 41.3890,
    lng: 33.7827,
  ),
  DonationPoint(
    id: 'kayseri',
    city: 'Kayseri',
    name: 'Kayseri Kızılay Kan Bağış Merkezi',
    lat: 38.7333,
    lng: 35.4833,
  ),
  DonationPoint(
    id: 'kirklareli',
    city: 'Kırklareli',
    name: 'Kırklareli Kızılay Kan Bağış Merkezi',
    lat: 41.7333,
    lng: 27.2167,
  ),
  DonationPoint(
    id: 'kirsehir',
    city: 'Kırşehir',
    name: 'Kırşehir Kızılay Kan Bağış Merkezi',
    lat: 39.1458,
    lng: 34.1639,
  ),
  DonationPoint(
    id: 'kocaeli',
    city: 'Kocaeli',
    name: 'Kocaeli Kızılay Kan Bağış Merkezi',
    lat: 40.8533,
    lng: 29.8815,
  ),
  DonationPoint(
    id: 'konya',
    city: 'Konya',
    name: 'Konya Kızılay Kan Bağış Merkezi',
    lat: 37.8667,
    lng: 32.4833,
  ),
  DonationPoint(
    id: 'kutahya',
    city: 'Kütahya',
    name: 'Kütahya Kızılay Kan Bağış Merkezi',
    lat: 39.4167,
    lng: 29.9833,
  ),
  DonationPoint(
    id: 'malatya',
    city: 'Malatya',
    name: 'Malatya Kızılay Kan Bağış Merkezi',
    lat: 38.3552,
    lng: 38.3095,
  ),
  DonationPoint(
    id: 'manisa',
    city: 'Manisa',
    name: 'Manisa Kızılay Kan Bağış Merkezi',
    lat: 38.6191,
    lng: 27.4289,
  ),
  DonationPoint(
    id: 'kahramanmaras',
    city: 'Kahramanmaraş',
    name: 'Kahramanmaraş Kızılay Kan Bağış Merkezi',
    lat: 37.5858,
    lng: 36.9371,
  ),
  DonationPoint(
    id: 'mardin',
    city: 'Mardin',
    name: 'Mardin Kızılay Kan Bağış Merkezi',
    lat: 37.3212,
    lng: 40.7245,
  ),
  DonationPoint(
    id: 'mugla',
    city: 'Muğla',
    name: 'Muğla Kızılay Kan Bağış Merkezi',
    lat: 37.2153,
    lng: 28.3636,
  ),
  DonationPoint(
    id: 'mus',
    city: 'Muş',
    name: 'Muş Kızılay Kan Bağış Merkezi',
    lat: 38.7433,
    lng: 41.5069,
  ),
  DonationPoint(
    id: 'nevsehir',
    city: 'Nevşehir',
    name: 'Nevşehir Kızılay Kan Bağış Merkezi',
    lat: 38.6247,
    lng: 34.7142,
  ),
  DonationPoint(
    id: 'nigde',
    city: 'Niğde',
    name: 'Niğde Kızılay Kan Bağış Merkezi',
    lat: 37.9667,
    lng: 34.6833,
  ),
  DonationPoint(
    id: 'ordu',
    city: 'Ordu',
    name: 'Ordu Kızılay Kan Bağış Merkezi',
    lat: 40.9839,
    lng: 37.8764,
  ),
  DonationPoint(
    id: 'rize',
    city: 'Rize',
    name: 'Rize Kızılay Kan Bağış Merkezi',
    lat: 41.0201,
    lng: 40.5234,
  ),
  DonationPoint(
    id: 'sakarya',
    city: 'Sakarya',
    name: 'Sakarya Kızılay Kan Bağış Merkezi',
    lat: 40.7569,
    lng: 30.3781,
  ),
  DonationPoint(
    id: 'samsun',
    city: 'Samsun',
    name: 'Samsun Kızılay Kan Bağış Merkezi',
    lat: 41.2867,
    lng: 36.3300,
  ),
  DonationPoint(
    id: 'siirt',
    city: 'Siirt',
    name: 'Siirt Kızılay Kan Bağış Merkezi',
    lat: 37.9333,
    lng: 41.9500,
  ),
  DonationPoint(
    id: 'sinop',
    city: 'Sinop',
    name: 'Sinop Kızılay Kan Bağış Merkezi',
    lat: 42.0231,
    lng: 35.1531,
  ),
  DonationPoint(
    id: 'sivas',
    city: 'Sivas',
    name: 'Sivas Kızılay Kan Bağış Merkezi',
    lat: 39.7477,
    lng: 37.0179,
  ),
  DonationPoint(
    id: 'tekirdag',
    city: 'Tekirdağ',
    name: 'Tekirdağ Kızılay Kan Bağış Merkezi',
    lat: 40.9780,
    lng: 27.5110,
  ),
  DonationPoint(
    id: 'tokat',
    city: 'Tokat',
    name: 'Tokat Kızılay Kan Bağış Merkezi',
    lat: 40.3167,
    lng: 36.5500,
  ),
  DonationPoint(
    id: 'trabzon',
    city: 'Trabzon',
    name: 'Trabzon Kızılay Kan Bağış Merkezi',
    lat: 41.0050,
    lng: 39.7267,
  ),
  DonationPoint(
    id: 'tunceli',
    city: 'Tunceli',
    name: 'Tunceli Kızılay Kan Bağış Merkezi',
    lat: 39.1060,
    lng: 39.5489,
  ),
  DonationPoint(
    id: 'sanliurfa',
    city: 'Şanlıurfa',
    name: 'Şanlıurfa Kızılay Kan Bağış Merkezi',
    lat: 37.1583,
    lng: 38.7910,
  ),
  DonationPoint(
    id: 'usak',
    city: 'Uşak',
    name: 'Uşak Kızılay Kan Bağış Merkezi',
    lat: 38.6823,
    lng: 29.4082,
  ),
  DonationPoint(
    id: 'van',
    city: 'Van',
    name: 'Van Kızılay Kan Bağış Merkezi',
    lat: 38.4942,
    lng: 43.3800,
  ),
  DonationPoint(
    id: 'yozgat',
    city: 'Yozgat',
    name: 'Yozgat Kızılay Kan Bağış Merkezi',
    lat: 39.8200,
    lng: 34.8044,
  ),
  DonationPoint(
    id: 'zonguldak',
    city: 'Zonguldak',
    name: 'Zonguldak Kızılay Kan Bağış Merkezi',
    lat: 41.4564,
    lng: 31.7987,
  ),
  DonationPoint(
    id: 'aksaray',
    city: 'Aksaray',
    name: 'Aksaray Kızılay Kan Bağış Merkezi',
    lat: 38.3687,
    lng: 34.0360,
  ),
  DonationPoint(
    id: 'bayburt',
    city: 'Bayburt',
    name: 'Bayburt Kızılay Kan Bağış Merkezi',
    lat: 40.2552,
    lng: 40.2249,
  ),
  DonationPoint(
    id: 'karaman',
    city: 'Karaman',
    name: 'Karaman Kızılay Kan Bağış Merkezi',
    lat: 37.1811,
    lng: 33.2150,
  ),
  DonationPoint(
    id: 'kirikkale',
    city: 'Kırıkkale',
    name: 'Kırıkkale Kızılay Kan Bağış Merkezi',
    lat: 39.8468,
    lng: 33.5153,
  ),
  DonationPoint(
    id: 'batman',
    city: 'Batman',
    name: 'Batman Kızılay Kan Bağış Merkezi',
    lat: 37.8812,
    lng: 41.1351,
  ),
  DonationPoint(
    id: 'sirnak',
    city: 'Şırnak',
    name: 'Şırnak Kızılay Kan Bağış Merkezi',
    lat: 37.5164,
    lng: 42.4610,
  ),
  DonationPoint(
    id: 'bartin',
    city: 'Bartın',
    name: 'Bartın Kızılay Kan Bağış Merkezi',
    lat: 41.6344,
    lng: 32.3375,
  ),
  DonationPoint(
    id: 'ardahan',
    city: 'Ardahan',
    name: 'Ardahan Kızılay Kan Bağış Merkezi',
    lat: 41.1105,
    lng: 42.7022,
  ),
  DonationPoint(
    id: 'igdir',
    city: 'Iğdır',
    name: 'Iğdır Kızılay Kan Bağış Merkezi',
    lat: 39.9237,
    lng: 44.0450,
  ),
  DonationPoint(
    id: 'yalova',
    city: 'Yalova',
    name: 'Yalova Kızılay Kan Bağış Merkezi',
    lat: 40.6550,
    lng: 29.2769,
  ),
  DonationPoint(
    id: 'karabuk',
    city: 'Karabük',
    name: 'Karabük Kızılay Kan Bağış Merkezi',
    lat: 41.2049,
    lng: 32.6277,
  ),
  DonationPoint(
    id: 'kilis',
    city: 'Kilis',
    name: 'Kilis Kızılay Kan Bağış Merkezi',
    lat: 36.7161,
    lng: 37.1147,
  ),
  DonationPoint(
    id: 'osmaniye',
    city: 'Osmaniye',
    name: 'Osmaniye Kızılay Kan Bağış Merkezi',
    lat: 37.0742,
    lng: 36.2478,
  ),
  DonationPoint(
    id: 'duzce',
    city: 'Düzce',
    name: 'Düzce Kızılay Kan Bağış Merkezi',
    lat: 40.8438,
    lng: 31.1565,
  ),
];

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchCtrl = TextEditingController();

  late List<DonationPoint> _filtered;
  DonationPoint? _selected;

  @override
  void initState() {
    super.initState();
    _filtered = kDonationPoints;
    if (_filtered.isNotEmpty) {
      _selected = _filtered.first;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = kDonationPoints;
      } else {
        _filtered = kDonationPoints
            .where(
              (p) =>
                  p.city.toLowerCase().contains(query) ||
                  p.name.toLowerCase().contains(query),
            )
            .toList();
      }

      if (_filtered.isNotEmpty) {
        _selected = _filtered.first;
        _moveCamera(_selected!);
      } else {
        _selected = null;
      }
    });
  }

  void _moveCamera(DonationPoint point) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(point.lat, point.lng),
          zoom: 11,
        ),
      ),
    );
  }

  Future<void> _openDirections(DonationPoint point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${point.lat},${point.lng}&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita açılamadı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        _selected != null ? _selected! : kDonationPoints.first;

    final markers = _filtered
        .map(
          (p) => Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.lat, p.lng),
            infoWindow: InfoWindow(title: p.city, snippet: p.name),
            onTap: () {
              setState(() => _selected = p);
            },
          ),
        )
        .toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bağış Noktaları',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Arama kutusu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(.05),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Bağış noktası ara',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Harita + alt bilgi paneli
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(initial.lat, initial.lng),
                      zoom: 6.5,
                    ),
                    markers: markers,
                    onMapCreated: (c) => _mapController = c,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),

                  // Konumum butonu (istersen burada Geolocator ile gerçek konumu bağlarız)
                  Positioned(
                    top: 70,
                    right: 20,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text('Konumum'),
                      onPressed: () {
                        _moveCamera(initial);
                      },
                    ),
                  ),

                  // Seçili bağış noktası kartı + Yol tarifi aç
                  if (_selected != null)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selected!.city,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selected!.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _openDirections(_selected!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Yol tarifi aç',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
