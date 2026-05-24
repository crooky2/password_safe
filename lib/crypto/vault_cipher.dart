import "dart:convert";
import "dart:developer";
import "dart:typed_data";

import "package:cryptography/cryptography.dart";

import "secure_bytes.dart";
import "vault_models.dart";


class VaultCipher {
  VaultCipher();

  static const String algorithmName = "aes-256-gcm";
  static const int _keyLength = 32;
  static const int _nonceLength = 12;

  final AesGcm _algorithm = AesGcm.with256bits();

  Future<EncryptedBlob> encrypt({
    required List<int> plaintext,
    required List<int> key,
  }) async {
    if (key.length != _keyLength) {
      throw ArgumentError.value(key.length, "key.length", "AES-256-GCM requires a 32-byte key");
    };

    final nonce = generateRandomBytes(_nonceLength);

    final secretBox = await _algorithm.encrypt(plaintext, secretKey: SecretKey(key), nonce: nonce);

    return EncryptedBlob(
      algorithm: algorithmName,
      nonceBase64: bytesToBase64(secretBox.nonce),
      ciphertextBase64: bytesToBase64(secretBox.cipherText),
      macBase64: bytesToBase64(secretBox.mac.bytes),
    );
  }

  Future<Uint8List> decrypt({
    required EncryptedBlob blob,
    required List<int> key,
  }) async {
    if (blob.algorithm != algorithmName) {
      throw UnsupportedError("Unsupported algorithm: ${blob.algorithm}");
    }

    if (key.length != _keyLength) {
      throw ArgumentError.value(key.length, "key.length", "AES-256-GCM requires a 32-byte key");
    }

    final secretBox = SecretBox(
      base64ToBytes(blob.ciphertextBase64),
      nonce: base64ToBytes(blob.nonceBase64),
      mac: Mac(base64ToBytes(blob.macBase64)),
    );


    final plaintext = await _algorithm.decrypt(
      secretBox,
      secretKey: SecretKey(key),
    );

    return Uint8List.fromList(plaintext);
  }
}