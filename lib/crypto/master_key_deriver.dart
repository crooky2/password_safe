import "dart:typed_data";

import "package:cryptography/cryptography.dart";

import "secure_bytes.dart";
import "vault_models.dart";

class MasterKeyDeriver {
  const MasterKeyDeriver();

  static const int keyLength = 32;

  KdfParams createDefaultParams() {
    return KdfParams(
      algorithm: "argon2id",
      memoryKb: 131072,
      iterations: 3,
      parallelism: 2,
      saltBase64: bytesToBase64(generateRandomBytes(16)),
    );
  }

  Future<Uint8List> deriveKey({
    required String password,
    required KdfParams params,
  }) async {
    if (params.algorithm != "argon2id") {
      throw UnsupportedError("Unsupported KDF algorithm: ${params.algorithm}");
    }

    final algorithm = Argon2id(
      memory: params.memoryKb,
      iterations: params.iterations,
      parallelism: params.parallelism,
      hashLength: keyLength,
    );

    final secretKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: base64ToBytes(params.saltBase64),
    );

    final keyBytes = await secretKey.extractBytes();

    return Uint8List.fromList(keyBytes);
  }
}
