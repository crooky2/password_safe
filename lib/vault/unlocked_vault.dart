import "dart:typed_data";

import "password_database.dart";

class UnlockedVault {
  UnlockedVault({
    required this.vaultKey,
    required this.database,
  });

  final Uint8List vaultKey;
  PasswordDatabase database;

  
  void clearSecrets() {
    vaultKey.fillRange(0, vaultKey.length, 0);
  }
}