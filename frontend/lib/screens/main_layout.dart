import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.directions_car_outlined),
            selectedIcon: const Icon(Icons.directions_car),
            label: AppLocalizations.of(context)!.myVehiclesNav,
          ),
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt),
            label: AppLocalizations.of(context)!.checksNav,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}

