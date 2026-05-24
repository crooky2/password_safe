import "dart:typed_data";

import "text_bytes.dart";
import "master_key_deriver.dart";
import "vault_cipher.dart";
import "vault_models.dart";

import "../vault/password_database.dart";
import "../vault/unlocked_vault.dart";


class VaultUnlocker {
  const VaultUnlocker({
    this.keyDeriver = const MasterKeyDeriver(),
  });

  final MasterKeyDeriver keyDeriver;

  Future<UnlockedVault> unlock({
    required VaultFile vaultFile,
    required String masterPassword,
  }) async {
    final keyEncryptionKey = await keyDeriver.deriveKey(
      password: masterPassword,
      params: vaultFile.kdf,
    );

    final cipher = VaultCipher();

    final vaultKey = await cipher.decrypt(
      blob: vaultFile.wrappedVaultKey,
      key: keyEncryptionKey,
    );

    final databaseBytes = await cipher.decrypt(
      blob: vaultFile.encryptedDatabase,
      key: vaultKey,
    );

    final databaseText = bytesToText(databaseBytes);

    return UnlockedVault(
      vaultKey: vaultKey,
      database: PasswordDatabase.fromJsonText(databaseText),
    );
  }

  Future<UnlockedVault> unlockWithVaultKey({
    required VaultFile vaultFile,
    required Uint8List vaultKey,
  }) async {
    final cipher = VaultCipher();

    final databaseBytes = await cipher.decrypt(
      blob: vaultFile.encryptedDatabase,
      key: vaultKey
    );

    final databaseText = bytesToText(databaseBytes);

    return UnlockedVault(
      vaultKey: vaultKey,
      database: PasswordDatabase.fromJsonText(databaseText),
    );
  }
}