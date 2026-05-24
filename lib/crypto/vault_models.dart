class EncryptedBlob {
  const EncryptedBlob({
    required this.algorithm,
    required this.nonceBase64,
    required this.ciphertextBase64,
    required this.macBase64,
  });

  final String algorithm;
  final String nonceBase64;
  final String ciphertextBase64;
  final String macBase64;

  Map<String, Object> toJson() {
    return {
      "algorithm":algorithm,
      "nonce": nonceBase64,
      "ciphertext": ciphertextBase64,
      "mac": macBase64,
    };
  }


  factory EncryptedBlob.fromJson(Map<String, Object?> json) {
    return EncryptedBlob(
      algorithm: json["algorithm"] as String,
      nonceBase64: json["nonce"] as String,
      ciphertextBase64: json["ciphertext"] as String,
      macBase64: json["mac"] as String,
    );
  }
}




class KdfParams {
  const KdfParams({
    required this.algorithm,
    required this.memoryKb,
    required this.iterations,
    required this.parallelism,
    required this.saltBase64,
  });

  final String algorithm;
  final int memoryKb;
  final int iterations;
  final int parallelism;
  final String saltBase64;

  Map<String, Object> toJson() {
    return {
      "algorithm": algorithm,
      "memoryKb": memoryKb,
      "iterations": iterations,
      "parallelism": parallelism,
      "salt": saltBase64,
    };
  }

  factory KdfParams.fromJson(Map<String, Object?> json) {
    return KdfParams(
      algorithm: json["algorithm"] as String,
      memoryKb: json["memoryKb"] as int,
      iterations: json["iterations"] as int,
      parallelism: json["parallelism"] as int,
      saltBase64: json["salt"] as String,
    );
  }
}





class VaultFile {
  const VaultFile({
    required this.version,
    required this.kdf,
    required this.wrappedVaultKey,
    required this.encryptedDatabase,
  });

  final int version;
  final KdfParams kdf;
  final EncryptedBlob wrappedVaultKey;
  final EncryptedBlob encryptedDatabase;

  Map<String, Object> toJson() {
    return {
      "version": version,
      "kdf": kdf.toJson(),
      "wrappedVaultKey": wrappedVaultKey.toJson(),
      "encryptedDatabase": encryptedDatabase.toJson(),
    };
  }

  factory VaultFile.fromJson(Map<String, Object?> json) {
    return VaultFile(
      version: json["version"] as int,
      kdf: KdfParams.fromJson(json["kdf"] as Map<String, Object?>),
      wrappedVaultKey: EncryptedBlob.fromJson(
        json["wrappedVaultKey"] as Map<String, Object?>,
      ),
      encryptedDatabase: EncryptedBlob.fromJson(json["encryptedDatabase"] as Map<String, Object?>),
    );
  }

  VaultFile copyWith({
    int? version,
    KdfParams? kdf,
    EncryptedBlob? wrappedVaultKey,
    EncryptedBlob? encryptedDatabase,
  }) {
    return VaultFile(
      version: version ?? this.version,
      kdf: kdf ?? this.kdf,
      wrappedVaultKey: wrappedVaultKey ?? this.wrappedVaultKey,
      encryptedDatabase: encryptedDatabase ?? this.encryptedDatabase,
    );
  }
}