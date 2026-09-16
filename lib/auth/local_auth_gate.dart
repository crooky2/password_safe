import "package:flutter/widgets.dart";
import "package:local_auth/local_auth.dart";
import "package:local_auth_android/local_auth_android.dart";
import "package:local_auth_darwin/local_auth_darwin.dart";

import "../l10n/app_localizations.dart";

class LocalAuthGate {
  LocalAuthGate({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> canUseFingerprint() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();

      return biometrics.contains(BiometricType.fingerprint) ||
          biometrics.contains(BiometricType.strong);
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateFingerprint({
    required String reason,
    String localeName = "en",
  }) async {
    try {
      final requestedLocale = Locale(localeName.split(RegExp("[-_]")).first);
      final l10n = await AppLocalizations.delegate.load(
        AppLocalizations.delegate.isSupported(requestedLocale)
            ? requestedLocale
            : const Locale("en"),
      );

      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: l10n.deviceAuthenticationRequired,
            signInHint: l10n.verifyIdentity,
            cancelButton: l10n.cancel,
          ),
          IOSAuthMessages(
            cancelButton: l10n.cancel,
            localizedFallbackTitle: "",
          ),
        ],
        biometricOnly: true,
        sensitiveTransaction: false,
      );
    } catch (_) {
      return false;
    }
  }
}
