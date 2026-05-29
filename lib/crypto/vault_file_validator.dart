import "dart:convert";

import "vault_models.dart";

class VaultFileValidationException implements Exception {
  const VaultFileValidationException(this.message);

  final String message;

  @override
  String toString() => "VaultFileValidationException: $message";
}

class VaultFileValidator {
  const VaultFileValidator._();

  static const int supportedVersion = 1;
  static const int maxVaultFileBytes = 5 * 1024 * 1024;

  static const int minKdfMemoryKb = 32768;
  static const int maxKdfMemoryKb = 262144;
  static const int minKdfIterations = 2;
  static const int maxKdfIterations = 8;
  static const int minKdfParallelism = 1;
  static const int maxKdfParallelism = 4;

  static VaultFile parse(String text) {
    ensureTextWithinLimit(text);

    try {
      final decoded = jsonDecode(text);

      if (decoded is! Map) {
        throw const VaultFileValidationException("Vault root must be an object.");
      }

      final vaultFile = VaultFile.fromJson(decoded.cast<String, Object?>());
      validate(vaultFile);
      return vaultFile;
    } on VaultFileValidationException {
      rethrow;
    } catch (_) {
      throw const VaultFileValidationException("Vault file has an invalid format.");
    }
  }

  static void ensureTextWithinLimit(String text) {
    final byteLength = utf8.encode(text).length;

    if (byteLength > maxVaultFileBytes) {
      throw const VaultFileValidationException("Vault file is too large.");
    }
  }

  static void validate(VaultFile vaultFile) {
    if (vaultFile.version != supportedVersion) {
      throw VaultFileValidationException(
        "Unsupported vault version: ${vaultFile.version}.",
      );
    }

    validateKdf(vaultFile.kdf);
    _validateBlob("wrappedVaultKey", vaultFile.wrappedVaultKey);
    _validateBlob("encryptedDatabase", vaultFile.encryptedDatabase);
  }

  static void validateKdf(KdfParams params) {
    if (params.algorithm != "argon2id") {
      throw VaultFileValidationException(
        "Unsupported KDF algorithm: ${params.algorithm}.",
      );
    }

    if (params.memoryKb < minKdfMemoryKb || params.memoryKb > maxKdfMemoryKb) {
      throw VaultFileValidationException(
        "KDF memory is outside the allowed range: ${params.memoryKb}.",
      );
    }

    if (params.iterations < minKdfIterations ||
        params.iterations > maxKdfIterations) {
      throw VaultFileValidationException(
        "KDF iterations are outside the allowed range: ${params.iterations}.",
      );
    }

    if (params.parallelism < minKdfParallelism ||
        params.parallelism > maxKdfParallelism) {
      throw VaultFileValidationException(
        "KDF parallelism is outside the allowed range: ${params.parallelism}.",
      );
    }

    final salt = _decodeBase64("kdf.salt", params.saltBase64);

    if (salt.length < 16 || salt.length > 64) {
      throw VaultFileValidationException(
        "KDF salt length is outside the allowed range: ${salt.length}.",
      );
    }
  }

  static void _validateBlob(String name, EncryptedBlob blob) {
    if (blob.algorithm != "aes-256-gcm") {
      throw VaultFileValidationException(
        "Unsupported encryption algorithm for $name: ${blob.algorithm}.",
      );
    }

    final nonce = _decodeBase64("$name.nonce", blob.nonceBase64);
    final ciphertext = _decodeBase64("$name.ciphertext", blob.ciphertextBase64);
    final mac = _decodeBase64("$name.mac", blob.macBase64);

    if (nonce.length != 12) {
      throw VaultFileValidationException("$name nonce must be 12 bytes.");
    }

    if (mac.length != 16) {
      throw VaultFileValidationException("$name MAC must be 16 bytes.");
    }

    if (ciphertext.isEmpty) {
      throw VaultFileValidationException("$name ciphertext must not be empty.");
    }
  }

  static List<int> _decodeBase64(String fieldName, String value) {
    try {
      return base64Decode(value);
    } catch (_) {
      throw VaultFileValidationException("$fieldName must be valid base64.");
    }
  }
}