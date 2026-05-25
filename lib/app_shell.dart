import 'package:flutter/material.dart';

import "theme_controller.dart";

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

import "auth/auth_controller.dart";

class AppShell extends StatefulWidget {
  const AppShell({
      super.key,
      required this.authController,
      required this.themeController,
    });

  final AuthController authController;
  final ThemeController themeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  static const double _navigationBarHeight = 64;

  List<Widget> get _pages {
    return [
      HomeScreen(authController: widget.authController),
      SettingsScreen(
        authController: widget.authController,
        themeController: widget.themeController,
      ),
    ];
  }

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: '',
    ),
  ];

  void _selectTab(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  Widget _buildAnimatedPage(Widget page) {
    return KeyedSubtree(
      key: ValueKey(_selectedIndex),
      child: page,
    );
  }

  Widget _pageTransition(Widget child, Animation<double> animation) {
    final pageIndex = (child.key as ValueKey<int>).value;
    final isIncomingPage = pageIndex == _selectedIndex;
    final isForwardTransition = _selectedIndex > _previousIndex;
    final beginOffset = isIncomingPage
        ? Offset(isForwardTransition ? 0.08 : -0.08, 0)
        : Offset(isForwardTransition ? -0.08 : 0.08, 0);

    final offsetAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: _pageTransition,
            child: _buildAnimatedPage(_pages[_selectedIndex]),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: _navigationBarHeight,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: _destinations,
      ),
    );
  }
}