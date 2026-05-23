import 'package:flutter/material.dart';

import 'root_gate.dart';

void main() {
  runApp(const PasswordSafeApp());
}

class PasswordSafeApp extends StatelessWidget {
  const PasswordSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF1F6F78);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Safe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
      ),
      
      home: const RootGate(),
    );
  }
}
