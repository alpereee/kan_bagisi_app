import 'package:flutter/material.dart';

// SAYFALAR (lib/screens klasöründen)
import 'screens/home_screen.dart';
import 'screens/donations_screen.dart';
import 'screens/nearby_hospitals_screen.dart';
import 'screens/profile_screen.dart';

class MainNav extends StatefulWidget {
  static const route = '/nav';

  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  // Alt menüde gösterilecek sayfalar
  final List<Widget> _pages = const [
    HomeScreen(),
    DonationsScreen(),
    NearbyHospitalsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (newIndex) {
          setState(() => _index = newIndex);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Bağışlarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital),
            label: 'Bağış Noktaları',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}
