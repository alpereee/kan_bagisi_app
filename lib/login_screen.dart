// lib/login_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widgets/primary_button.dart';

enum _AuthMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _birthDateCtrl = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _loading = false;

  final _bloodTypes = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  String _blood = 'A+';

  final _genders = const [
    'Kadın',
    'Erkek',
    'Diğer',
  ];
  String _gender = 'Kadın';

  DateTime? _birthDate;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _city.dispose();
    _phone.dispose();
    _birthDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;

      if (_mode == _AuthMode.login) {
        // 🔐 GİRİŞ
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } else {
        // 📝 KAYIT
        final cred = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        final uid = cred.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          // 🔹 ProfileScreen ile UYUMLU field isimleri
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'city': _city.text.trim(),
          'bloodType': _blood,
          'gender': _gender,
          'birthDate':
              _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,

          'totalDonations': 0,
          'points': 0,
          'lastDonationAt': null,
          'createdAt': FieldValue.serverTimestamp(),

          // Eski isimler de dursun, başka yer kullanıyorsa bozulmasın
          'fullName': _name.text.trim(),
          'phoneNumber': _phone.text.trim(),
          'donationCount': 0,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mode == _AuthMode.login
                ? 'Giriş başarılı'
                : 'Kayıt başarılı, hoş geldiniz!',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Bir hata oluştu')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kan Bağışı Uygulaması',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? 'Devam etmek için giriş yap'
                        : 'Bir hesap oluştur ve bize katıl',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 📧 Email
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'E-posta zorunlu';
                      }
                      if (!v.contains('@')) return 'Geçerli bir e-posta gir';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 🔑 Şifre
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.trim().length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),

                  if (!isLogin) ...[
                    const SizedBox(height: 12),

                    // 👤 Ad Soyad
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Ad soyad zorunlu' : null,
                    ),
                    const SizedBox(height: 12),

                    // 📱 Telefon
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // 📍 Şehir
                    TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(
                        labelText: 'Şehir',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🩸 Kan Grubu
                    DropdownButtonFormField<String>(
                      value: _blood,
                      decoration: const InputDecoration(
                        labelText: 'Kan Grubu',
                        prefixIcon: Icon(Icons.bloodtype_outlined),
                      ),
                      items: _bloodTypes
                          .map(
                            (b) =>
                                DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _blood = v ?? _blood),
                    ),
                    const SizedBox(height: 12),

                    // ⚧ Cinsiyet
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Cinsiyet',
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      items: _genders
                          .map(
                            (g) =>
                                DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _gender = v ?? _gender),
                    ),
                    const SizedBox(height: 12),

                    // 📅 Doğum Tarihi
                    TextFormField(
                      controller: _birthDateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      onTap: _pickBirthDate,
                      validator: (v) {
                        if (isLogin) return null;
                        if (_birthDate == null) {
                          return 'Doğum tarihi seçmelisin';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Ana buton
                  PrimaryButton(
                    onPressed: _loading ? null : _submit,
                    isLoading: _loading,
                    child: Text(isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                  ),
                  const SizedBox(height: 12),

                  // Mod değiştirme
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _mode =
                                  isLogin ? _AuthMode.register : _AuthMode.login;
                            });
                          },
                    child: Text(
                      isLogin
                          ? 'Hesabın yok mu? Kayıt ol'
                          : 'Zaten hesabın var mı? Giriş yap',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
