import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'vehicles_screen.dart';
import 'check_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  String? _selectedCheckId;

  void _changeTab(int index, {String? checkId}) {
    setState(() {
      _currentIndex = index;
      _selectedCheckId = checkId;
    });
  }

  void _clearSelectedCheckId() {
    setState(() {
      _selectedCheckId = null;
    });
  }

  List<Widget> get _screens => [
        DashboardScreen(
          onNavigateToTab: _changeTab,
          onNavigateToCheck: (checkId) => _changeTab(2, checkId: checkId),
        ),
        const VehiclesScreen(),
        CheckScreen(
          selectedCheckId: _selectedCheckId,
          onCheckClosed: _clearSelectedCheckId,
        ),
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Araçlarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Check',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}

