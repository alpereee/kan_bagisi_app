import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Anasayfadaki "Kan Bağışı Talebi Oluştur" butonunun açtığı bottom sheet.
///
/// Kullanım:
/// `CreateRequestSheet.open(context);`
class CreateRequestSheet {
  static Future<void> open(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return const _CreateRequestSheetBody();
      },
    );
  }
}

class _CreateRequestSheetBody extends StatefulWidget {
  const _CreateRequestSheetBody({Key? key}) : super(key: key);

  @override
  State<_CreateRequestSheetBody> createState() =>
      _CreateRequestSheetBodyState();
}

class _CreateRequestSheetBodyState extends State<_CreateRequestSheetBody> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedBloodGroup = 'A+';
  String _selectedUrgency = 'Orta';
  bool _isSending = false;

  // 81 il listesi – şehir dropdown’unda kullanılıyor
  static const List<String> _cities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talep oluşturmak için önce giriş yapın.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final now = DateTime.now();

      await FirebaseFirestore.instance.collection('donation_requests').add({
        // Güvenlik kuralı için zorunlu alan
        'requesterId': user.uid,

        // İsim soyisim (birkaç farklı key ile kaydediyoruz ki eski kodun
        // hangisini kullandığı önemli olmasın.)
        'name': _nameController.text.trim(),
        'fullName': _nameController.text.trim(),
        'requesterName': _nameController.text.trim(),

        // Kan grubu
        'bloodGroup': _selectedBloodGroup,
        'blood': _selectedBloodGroup,
        'bloodType': _selectedBloodGroup,

        // Aciliyet
        'urgency': _selectedUrgency,
        'priority': _selectedUrgency,

        // Şehir
        'city': _cityController.text.trim(),
        'locationCity': _cityController.text.trim(),

        // Not
        'note': _noteController.text.trim(),
        'description': _noteController.text.trim(),

        // Durum ve zaman
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtLocal': now.toIso8601String(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kan bağışı talebiniz yayınlandı.')),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep oluşturulurken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        // Klavye açıldığında sheet'in yukarı çıkması için
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        // Column, SingleChildScrollView içine alındı.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst bar + başlık
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kan Bağışı Talebi Oluştur',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // İsim Soyisim
              const Text(
                'İsim Soyisim',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Örn. Alperen Yılmaz',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'İsim soyisim zorunludur.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kan grubu & Aciliyet
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kan Grubu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.black12, width: 1.0),
                            color: Colors.grey.shade50,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBloodGroup,
                              icon: const Icon(Icons.expand_more_rounded),
                              items: const [
                                'A+',
                                'A-',
                                'B+',
                                'B-',
                                'AB+',
                                'AB-',
                                '0+',
                                '0-',
                              ]
                                  .map(
                                    (bg) => DropdownMenuItem(
                                      value: bg,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.bloodtype_rounded,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(bg),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => _selectedBloodGroup = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aciliyet',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.black12, width: 1.0),
                            color: Colors.grey.shade50,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedUrgency,
                              icon: const Icon(Icons.expand_more_rounded),
                              items: const [
                                'Düşük',
                                'Orta',
                                'Acil',
                              ]
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Row(
                                        children: [
                                          Icon(
                                            u == 'Acil'
                                                ? Icons.priority_high_rounded
                                                : Icons.schedule_rounded,
                                            size: 20,
                                            color: u == 'Acil'
                                                ? Colors.red
                                                : Colors.orange,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(u),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => _selectedUrgency = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // İl (Dropdown – 81 il)
              const Text(
                'İl',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _cityController.text.isNotEmpty
                    ? _cityController.text
                    : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'İl seçiniz',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                ),
                items: _cities
                    .map(
                      (city) => DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _cityController.text = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'İl bilgisi zorunludur.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Not (opsiyonel)
              const Text(
                'Not (opsiyonel)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.notes_outlined),
                  hintText: 'Örn. Hastane adı, oda numarası, ekstra bilgi...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  filled: true,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Talebi Yayınla butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFE53935),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Talebi Yayınla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                '*Bağış işlemi hastaneye değil, Kızılay bağış noktalarında yapılır.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
