import "dart:convert";
import "dart:io";

import "package:path_provider/path_provider.dart";

import "../crypto/vault_models.dart";
import "../crypto/vault_file_validator.dart";

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
    VaultFileValidator.validate(vaultFile);

    final jsonMap = vaultFile.toJson();
    final jsonText = jsonEncode(jsonMap);

    await _saveTextAtomically(jsonText);
  }

  Future<VaultFile> load() async {
    final file = await _getVaultFile();

    final jsonText = await _readTextWithSizeLimit(file);
    return VaultFileValidator.parse(jsonText);
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

  Future<String?> loadTextIfExists() async {
    final file = await _getVaultFile();

    if (!await file.exists()) {
      return null;
    }

    return _readTextWithSizeLimit(file);
  }

  Future<void> saveText(String jsonText) async {
    VaultFileValidator.parse(jsonText);
    await _saveTextAtomically(jsonText);
  }

  Future<String> saveConflictText(
    String jsonText, {
    required String source,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      RegExp(r"[:.]"),
      "-",
    );

    final file = File(
      "${directory.path}/vault.$source.conflict.$timestamp.json",
    );
    await file.writeAsString(jsonText);
    return file.path;
  }

  Future<void> _saveTextAtomically(String jsonText) async {
    VaultFileValidator.ensureTextWithinLimit(jsonText);

    final file = await _getVaultFile();
    final tempFile = File("${file.path}.tmp");
    final backupFile = File("${file.path}.previous");

    await tempFile.writeAsString(jsonText, flush: true);

    if (await file.exists()) {
      await backupFile.writeAsBytes(await file.readAsBytes(), flush: true);
    }

    try {
      await tempFile.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) {
        await file.delete();
      }

      await tempFile.rename(file.path);
    }
  }

  Future<String> _readTextWithSizeLimit(File file) async {
    final size = await file.length();

    if (size > VaultFileValidator.maxVaultFileBytes) {
      throw const VaultFileValidationException("Vault file is too large.");
    }

    return file.readAsString();
  }
}
