import 'package:flutter/material.dart';

import 'root_gate.dart';
import "theme_controller.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.initialize();

  runApp(PasswordSafeApp(themeController: themeController));
}

class PasswordSafeApp extends StatefulWidget {
  const PasswordSafeApp({
    super.key, 
    required this.themeController
  });

  final ThemeController themeController;

  @override
  State<PasswordSafeApp> createState() => _PasswordSafeAppState();
}

class _PasswordSafeAppState extends State<PasswordSafeApp> {

  @override
  void dispose() {
    widget.themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData buildTheme(Brightness brightness) {
      const seedColor = Color(0xFF1F6F78);

      final colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      );

      return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF101416)
            : const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
      );
    }

    return AnimatedBuilder(
      animation: widget.themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Password Safe',
          themeMode: widget.themeController.themeMode,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: RootGate(themeController: widget.themeController),
        );
      },
    );
  }
}
