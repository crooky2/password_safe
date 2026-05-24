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
      wrappedVaultKey: EncryptedBlob.fromJson(json["wrappedVaultKey"] as Map<String, Object?>),
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory LocalUnlockRecord.fromJsonString(String jsonText) {
    return LocalUnlockRecord.fromJson(jsonDecode(jsonText) as Map<String, Object?>);
  }
}