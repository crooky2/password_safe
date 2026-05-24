// import "dart:convert";

import "vault_models.dart";
import "secure_bytes.dart";


VaultFile createFakeVaultFile() {
  final salt = bytesToBase64(generateRandomBytes(16));
  final wrappedKeyNonce = bytesToBase64(generateRandomBytes(12));
  final databaseNonce = bytesToBase64(generateRandomBytes(12));
  final fakeWrappedKeyCiphertext = bytesToBase64(generateRandomBytes(32));
  final fakeDatabaseCiphertext = bytesToBase64(generateRandomBytes(64));
  final fakeMac = bytesToBase64(generateRandomBytes(16));


  return VaultFile(
    version: 1,
    kdf: KdfParams(
      algorithm: "agon2id",
      memoryKb: 65536,
      iterations: 3,
      parallelism: 1,
      saltBase64: salt,
    ),
    wrappedVaultKey: EncryptedBlob(
      algorithm: "aes-256-gcm", 
      nonceBase64: wrappedKeyNonce, 
      ciphertextBase64: fakeWrappedKeyCiphertext,
      macBase64: fakeMac,
    ),
    encryptedDatabase: EncryptedBlob(
      algorithm: "aes-256-gcm",
      nonceBase64: databaseNonce,
      ciphertextBase64: fakeDatabaseCiphertext,
      macBase64: fakeMac,
    ),
  );
}