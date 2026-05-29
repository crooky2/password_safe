import "package:local_auth/local_auth.dart";

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

  Future<bool> authenticateFingerprint({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: false,
      );
    } catch (_) {
      return false;
    }
  }
}
