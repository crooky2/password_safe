import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:flutter_test/flutter_test.dart";

import "package:password_safe/storage/secure_store.dart";

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    "fingerprint unlock requires both preference flag and vault key",
    () async {
      FlutterSecureStorage.setMockInitialValues({
        SecureStore.fingerprintUnlockEnabledKey: "true",
      });

      final store = SecureStore();

      expect(await store.hasFingerprintUnlock(), isFalse);

      await store.writeFingerprintVaultKey("vault-key");

      expect(await store.hasFingerprintUnlock(), isTrue);
      expect(await store.readFingerprintVaultKey(), "vault-key");
    },
  );
}
