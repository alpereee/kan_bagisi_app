import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'main_nav.dart';
import 'theme.dart';

// Diğer ekranlar
import 'screens/notification_settings_screen.dart';
import 'screens/emergency_alert_screen.dart';
import 'screens/match_found_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': user.uid,
    'title': message.notification?.title ?? 'Bildirim',
    'body': message.notification?.body ?? '',
    'data': message.data,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(const KanBagisiApp());
}

class KanBagisiApp extends StatefulWidget {
  const KanBagisiApp({super.key});

  @override
  State<KanBagisiApp> createState() => _KanBagisiAppState();
}

class _KanBagisiAppState extends State<KanBagisiApp> {
  @override
  void initState() {
    super.initState();
    _setupMessaging();
  }

  Future<void> _setupMessaging() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((m) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': user.uid,
          'title': m.notification?.title ?? 'Bildirim',
          'body': m.notification?.body ?? '',
          'data': m.data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      if (m.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 ${m.notification!.title ?? ''}\n${m.notification!.body ?? ''}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kan Bağışı Uygulaması',
      theme: appTheme(),

      // 🔥 LOGIN / AUTH FLOW
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const MainNav();
          }

          return const LoginScreen();
        },
      ),

      routes: {
        NotificationSettingsScreen.route: (_) =>
            const NotificationSettingsScreen(),
        EmergencyAlertScreen.route: (_) => const EmergencyAlertScreen(),
        MatchFoundScreen.route: (_) => const MatchFoundScreen(),
      },
    );
  }
}
