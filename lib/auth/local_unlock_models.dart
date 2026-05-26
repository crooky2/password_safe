import "dart:convert";

import "../crypto/vault_models.dart";

class LocalUnlockRecord {
  const LocalUnlockRecord({
    required this.version,
    required this.kdf,
    required this.wrappedVaultKey,
  });

  final int version;
  final KdfParams kdf;
  final EncryptedBlob wrappedVaultKey;

  Map<String, Object> toJson() {
    return {
      "version": version,
      "kdf": kdf.toJson(),
      "wrappedVaultKey": wrappedVaultKey.toJson(),
    };
  }

  factory LocalUnlockRecord.fromJson(Map<String, Object?> json) {
    return LocalUnlockRecord(
      version: json["version"] as int,
      kdf: KdfParams.fromJson(json["kdf"] as Map<String, Object?>),
      wrappedVaultKey: EncryptedBlob.fromJson(
        json["wrappedVaultKey"] as Map<String, Object?>,
      ),
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory LocalUnlockRecord.fromJsonString(String jsonText) {
    return LocalUnlockRecord.fromJson(
      jsonDecode(jsonText) as Map<String, Object?>,
    );
  }
}

class QuickUnlockThrottleState {
  const QuickUnlockThrottleState({
    required this.failedAttempts,
    required this.lockedUntilMs,
    this.requiresMasterPassword = false,
  });

  final int failedAttempts;
  final int lockedUntilMs;
  final bool requiresMasterPassword;

  bool isLocked(DateTime now) {
    return lockedUntilMs > now.millisecondsSinceEpoch;
  }

  Duration remainingLockTime(DateTime now) {
    final remainingMs = lockedUntilMs - now.millisecondsSinceEpoch;

    if (remainingMs <= 0) {
      return Duration.zero;
    }

    return Duration(milliseconds: remainingMs);
  }

  Map<String, Object> toJson() {
    return {
      "failedAttempts": failedAttempts,
      "lockedUntilMs": lockedUntilMs,
      "requiresMasterPassword": requiresMasterPassword,
    };
  }

  factory QuickUnlockThrottleState.fromJson(Map<String, Object?> json) {
    return QuickUnlockThrottleState(
      failedAttempts: json["failedAttempts"] as int? ?? 0,
      lockedUntilMs: json["lockedUntilMs"] as int? ?? 0,
      requiresMasterPassword: json["requiresMasterPassword"] as bool? ?? false,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory QuickUnlockThrottleState.fromJsonString(String jsonText) {
    return QuickUnlockThrottleState.fromJson(
      jsonDecode(jsonText) as Map<String, Object?>,
    );
  }
}

class QuickUnlockLockedException implements Exception {
  const QuickUnlockLockedException(
    this.remainingLockTime, {
    this.requiresMasterPassword = false,
  });

  final Duration remainingLockTime;
  final bool requiresMasterPassword;
}

class QuickUnlockRejectedException implements Exception {
  const QuickUnlockRejectedException({
    required this.failedAttempts,
    this.cooldown,
    this.requiresMasterPassword = false,
  });

  final int failedAttempts;
  final Duration? cooldown;
  final bool requiresMasterPassword;
}

class QuickUnlockMasterPasswordRequiredException implements Exception {
  const QuickUnlockMasterPasswordRequiredException();
}
