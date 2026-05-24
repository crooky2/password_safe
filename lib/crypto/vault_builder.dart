import "secure_bytes.dart";
import "text_bytes.dart";
import "master_key_deriver.dart";
import "vault_cipher.dart";
import "vault_models.dart";


import "../vault/password_database.dart";
import "../vault/unlocked_vault.dart";

class VaultBuilder {
  const VaultBuilder({
    this.keyDeriver = const MasterKeyDeriver(),
  });

  final MasterKeyDeriver keyDeriver;

  Future<CreatedVault> createNewVault({
    required String masterPassword,
    PasswordDatabase? initialDatabase,
  }) async {
    final database = initialDatabase ?? PasswordDatabase.empty();

    final kdfParams = keyDeriver.createDefaultParams();

    final keyEncryptionKey = await keyDeriver.deriveKey(
      password: masterPassword,
      params: kdfParams,
    );

    final vaultKey = generateRandomBytes(32);
    final cipher = VaultCipher();

    final wrappedVaultKey = await cipher.encrypt(
      plaintext: vaultKey,
      key: keyEncryptionKey,
    );

    final encryptedDatabase = await cipher.encrypt(
      plaintext: textToBytes(database.toJsonText()),
      key: vaultKey,
    );

    return CreatedVault(
      vaultFile: VaultFile(
        version: 1,
        kdf: kdfParams,
        wrappedVaultKey: wrappedVaultKey,
        encryptedDatabase: encryptedDatabase,
      ),
      unlockedVault: UnlockedVault(
        vaultKey: vaultKey,
        database: database,
      ),
    );
  }
}


class CreatedVault {
  const CreatedVault({
    required this.vaultFile,
    required this.unlockedVault,
  });

  final VaultFile vaultFile;
  final UnlockedVault unlockedVault;
}