import "text_bytes.dart";
import "vault_cipher.dart";
import "vault_models.dart";

import "../vault/password_database.dart";

class DatabaseEncrypter {
  const DatabaseEncrypter();

  Future<EncryptedBlob> encryptDatabase({
    required PasswordDatabase database,
    required List<int> vaultKey,
  }) async {
    final cipher = VaultCipher();

    return cipher.encrypt(
      plaintext: textToBytes(database.toJsonText()),
      key: vaultKey,
    );
  }
}
