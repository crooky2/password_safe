import "dart:typed_data";

import "../crypto/master_key_deriver.dart";
import "../crypto/secure_bytes.dart";
import "../crypto/vault_cipher.dart";
import "../crypto/vault_models.dart";

import "../storage/secure_store.dart";

import "local_unlock_models.dart";


class LocalUnlockService {
  const LocalUnlockService({
    this.secureStore = const SecureStore(),
    this.keyDeriver = const MasterKeyDeriver(),
  });

  final SecureStore secureStore;
  final MasterKeyDeriver keyDeriver;

  Future<void> enableQuickUnlock({
    required String pin,
    required List<int> vaultKey
  }) async {
    final deviceSecret = bytesToBase64(generateRandomBytes(32));

    await secureStore.writeDeviceSecret(deviceSecret);

    final kdfParams = _createPinKdfParams();
    final pinKey = await _derivePinKey(pin: pin, deviceSecret: deviceSecret, params: kdfParams);
    final wrappedVaultKey = await VaultCipher().encrypt(plaintext: vaultKey, key: pinKey);
    final record = LocalUnlockRecord(version: 1, kdf: kdfParams, wrappedVaultKey: wrappedVaultKey);

    await secureStore.writeQuickUnlockRecord(record.toJsonString());
  }

  Future <Uint8List> unlockWithPin({
    required String pin,
  }) async {
    final deviceSecret = await secureStore.readDeviceSecret();
    final recordText = await secureStore.readQuickUnlockRecord();

    if (deviceSecret == null || recordText == null) {
      throw StateError("No quick unlock record found");
    }

    final record = LocalUnlockRecord.fromJsonString(recordText);

    final pinKey = await _derivePinKey(
      pin: pin,
      deviceSecret: deviceSecret,
      params: record.kdf,
    );

    return VaultCipher().decrypt(
      blob: record.wrappedVaultKey,
      key: pinKey
     );
  }

  Future<bool> isEnabled() {
    return secureStore.hasQuickUnlockRecord();
  }

  Future<void> disable() {
    return secureStore.deleteQuickUnlockRecord();
  }

  KdfParams _createPinKdfParams() {
    return KdfParams(
      algorithm: "argon2id",
      memoryKb: 19456,
      iterations: 2,
      parallelism: 1,
      saltBase64: bytesToBase64(generateRandomBytes(16)),
    );
  }

  Future<Uint8List> _derivePinKey({
    required String pin,
    required String deviceSecret,
    required KdfParams params
  }) {
    return keyDeriver.deriveKey(
      password: "$pin:$deviceSecret",
      params: params
    );
  }
}