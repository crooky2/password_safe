import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:password_safe/l10n/app_localizations.dart";
import "package:password_safe/screens/lock_screen.dart";

Widget _buildLockScreen({
  required bool autoPromptFingerprint,
  required Future<bool> Function({required String promptTitle})
  onUnlockWithFingerprint,
}) {
  return MaterialApp(
    locale: const Locale("en"),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LockScreen(
      onUnlock: (_) async => false,
      onUnlockWithPin: (_) async => false,
      onUnlockWithFingerprint: onUnlockWithFingerprint,
      isPinUnlockEnabled: () async => false,
      isFingerprintUnlockEnabled: () async => true,
      refreshUnlockBlock: () async {},
      autoPromptFingerprint: autoPromptFingerprint,
    ),
  );
}

Future<void> _finishQuickUnlockLoad(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets("does not auto prompt fingerprint when auto prompt is disabled", (
    tester,
  ) async {
    var fingerprintPrompts = 0;

    await tester.pumpWidget(
      _buildLockScreen(
        autoPromptFingerprint: false,
        onUnlockWithFingerprint: ({required String promptTitle}) async {
          fingerprintPrompts += 1;
          return false;
        },
      ),
    );

    await _finishQuickUnlockLoad(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(fingerprintPrompts, 0);
  });

  testWidgets("fingerprint prompt can be retried after a cancelled attempt", (
    tester,
  ) async {
    var fingerprintPrompts = 0;

    await tester.pumpWidget(
      _buildLockScreen(
        autoPromptFingerprint: true,
        onUnlockWithFingerprint: ({required String promptTitle}) async {
          fingerprintPrompts += 1;
          return false;
        },
      ),
    );

    await _finishQuickUnlockLoad(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(fingerprintPrompts, 1);

    await tester.tap(find.widgetWithText(FilledButton, "Unlock"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(fingerprintPrompts, 2);
  });
}
