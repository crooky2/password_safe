import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:password_safe/app_shell.dart';
import 'package:password_safe/auth/auth_controller.dart';
import 'package:password_safe/theme_controller.dart';

void main() {
  testWidgets('App shell animates between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          authController: AuthController(),
          themeController: ThemeController(),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
  });
}
