import 'package:flutter_test/flutter_test.dart';

import 'package:password_safe/main.dart';

void main() {
  testWidgets('App shell starts on home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const PasswordSafeApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Lock'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
