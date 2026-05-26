import "dart:typed_data";
import "package:cryptography/cryptography.dart";

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

  static const int _maxAttemptsBeforeCooldown = 5;
  static const Duration _baseCooldown = Duration(seconds: 30);
  static const Duration _maxCooldown = Duration(minutes: 15);

  Future<void> enableQuickUnlock({
    required String pin,
    required List<int> vaultKey,
  }) async {
    final deviceSecret = bytesToBase64(generateRandomBytes(32));

    await secureStore.writeDeviceSecret(deviceSecret);

    final kdfParams = _createPinKdfParams();
    final pinKey = await _derivePinKey(
      pin: pin,
      deviceSecret: deviceSecret,
      params: kdfParams,
    );
    final wrappedVaultKey = await VaultCipher().encrypt(
      plaintext: vaultKey,
      key: pinKey,
    );
    final record = LocalUnlockRecord(
      version: 1,
      kdf: kdfParams,
      wrappedVaultKey: wrappedVaultKey,
    );

    await secureStore.writeQuickUnlockRecord(record.toJsonString());
    await _clearThrottleState();
  }

  Future<Uint8List> unlockWithPin({required String pin}) async {
    await _throwIfQuickUnlockBlocked();

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

    try {
      final vaultKey = await VaultCipher().decrypt(
        blob: record.wrappedVaultKey,
        key: pinKey,
      );

      await _clearThrottleState();

      return vaultKey;
    } on SecretBoxAuthenticationError {
      throw await _recordFailedAttempt();
    }
  }

  Future<bool> isEnabled() async {
    final hasRecord = await secureStore.hasQuickUnlockRecord();

    if (!hasRecord) {
      return false;
    }

    final throttleState = await readThrottleState();

    return !throttleState.requiresMasterPassword;
  }

  Future<void> disable() {
    return secureStore.deleteQuickUnlockRecord();
  }

  Future<void> clearThrottleState() {
    return _clearThrottleState();
  }

  Future<void> ensureMasterUnlockAllowed() async {
    final now = DateTime.now();
    final throttleState = await readThrottleState();

    if (!throttleState.requiresMasterPassword) {
      return;
    }

    if (!throttleState.isLocked(now)) {
      return;
    }

    throw QuickUnlockLockedException(
      throttleState.remainingLockTime(now),
      requiresMasterPassword: true,
    );
  }

  Future<QuickUnlockThrottleState> readThrottleState() async {
    final text = await secureStore.readQuickUnlockThrottle();

    if (text == null) {
      return const QuickUnlockThrottleState(
        failedAttempts: 0,
        lockedUntilMs: 0,
      );
    }

    try {
      return QuickUnlockThrottleState.fromJsonString(text);
    } catch (_) {
      return const QuickUnlockThrottleState(
        failedAttempts: 0,
        lockedUntilMs: 0,
      );
    }
  }

  Future<void> _clearThrottleState() {
    return secureStore.deleteQuickUnlockThrottle();
  }

  Duration _cooldownForAttempts(int failedAttempts) {
    if (failedAttempts < _maxAttemptsBeforeCooldown) {
      return Duration.zero;
    }

    final cooldownLevel = failedAttempts - _maxAttemptsBeforeCooldown;
    var seconds = _baseCooldown.inSeconds;

    for (var i = 0; i < cooldownLevel; i++) {
      seconds *= 2;

      if (seconds >= _maxCooldown.inSeconds) {
        return _maxCooldown;
      }
    }

    return Duration(seconds: seconds);
  }

  Future<void> _throwIfQuickUnlockBlocked() async {
  final now = DateTime.now();
  final throttleState = await readThrottleState();

  if (throttleState.requiresMasterPassword) {
    if (throttleState.isLocked(now)) {
      throw QuickUnlockLockedException(
        throttleState.remainingLockTime(now),
        requiresMasterPassword: true,
      );
    }

    throw const QuickUnlockMasterPasswordRequiredException();
  }

  if (throttleState.isLocked(now)) {
    throw QuickUnlockLockedException(
      throttleState.remainingLockTime(now),
    );
  }
}

  Future<QuickUnlockRejectedException> _recordFailedAttempt() async {
    final now = DateTime.now();
    final currentState = await readThrottleState();
    final failedAttempts = currentState.failedAttempts + 1;
    final cooldown = _cooldownForAttempts(failedAttempts);
    final requiresMasterPassword = cooldown == _maxCooldown;

    final updatedState = QuickUnlockThrottleState(
      failedAttempts: failedAttempts,
      lockedUntilMs: cooldown == Duration.zero
          ? 0
          : now.add(cooldown).millisecondsSinceEpoch,
      requiresMasterPassword: requiresMasterPassword,
    );

    await secureStore.writeQuickUnlockThrottle(updatedState.toJsonString());

    return QuickUnlockRejectedException(
      failedAttempts: failedAttempts,
      cooldown: cooldown == Duration.zero ? null : cooldown,
      requiresMasterPassword: requiresMasterPassword,
    );
  }

  KdfParams _createPinKdfParams() {
    return KdfParams(
      algorithm: "argon2id",
      memoryKb: 65536,
      iterations: 4,
      parallelism: 1,
      saltBase64: bytesToBase64(generateRandomBytes(16)),
    );
  }

  Future<Uint8List> _derivePinKey({
    required String pin,
    required String deviceSecret,
    required KdfParams params,
  }) {
    return keyDeriver.deriveKey(password: "$pin:$deviceSecret", params: params);
  }
}
