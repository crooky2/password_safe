import "dart:convert";
import "dart:io";

import "package:path_provider/path_provider.dart";

import "../crypto/vault_models.dart";


class VaultFileStore {
  const VaultFileStore();

  static const String _fileName = "vault.json";

  Future<File> _getVaultFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/$_fileName");
  }

  Future<bool> exists() async {
    final file = await _getVaultFile();
    return file.exists();
  }

  Future<void> save(VaultFile vaultFile) async {
    final file = await _getVaultFile();
    final jsonMap = vaultFile.toJson();
    final jsonText = jsonEncode(jsonMap);

    await file.writeAsString(jsonText);
  }

  Future<VaultFile> load() async {
    final file = await _getVaultFile();
    
    final jsonText = await file.readAsString();
    final jsonMap = jsonDecode(jsonText) as Map<String, Object?>;

    return VaultFile.fromJson(jsonMap);
  }

  Future<void> delete() async {
    final file = await _getVaultFile();

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> getDebugPath() async {
    final file = await _getVaultFile();
    return file.path;
  }
}