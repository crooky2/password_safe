import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

import "auth/auth_controller.dart";

class AppShell extends StatefulWidget {
  const AppShell({
      super.key,
      required this.authController,
    });

  final AuthController authController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    return [
      const HomeScreen(),
      // const InfoScreen(),
      SettingsScreen(authController: widget.authController,),
    ];
  }

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: _destinations,
      ),
    );
  }
}