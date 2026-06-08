import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "package:password_safe/auth/auth_controller.dart";
import "package:password_safe/auth/local_unlock_service.dart";
import "package:password_safe/cloud/cloud_controller.dart";
import "package:password_safe/cloud/microsoft_auth_service.dart";
import "package:password_safe/crypto/master_key_deriver.dart";
import "package:password_safe/crypto/secure_bytes.dart";
import "package:password_safe/crypto/vault_builder.dart";
import "package:password_safe/crypto/vault_file_validator.dart";
import "package:password_safe/crypto/vault_models.dart";
import "package:password_safe/crypto/vault_unlocker.dart";
import "package:password_safe/l10n/app_localizations.dart";
import "package:password_safe/screens/cloud_screen.dart";
import "package:password_safe/storage/vault_file_store.dart";
import "package:password_safe/vault/password_database.dart";

const _masterPassword = "correct horse battery staple";

class FastMasterKeyDeriver extends MasterKeyDeriver {
  const FastMasterKeyDeriver();

  @override
  KdfParams createDefaultParams() {
    return KdfParams(
      algorithm: "argon2id",
      memoryKb: VaultFileValidator.minKdfMemoryKb,
      iterations: VaultFileValidator.minKdfIterations,
      parallelism: VaultFileValidator.minKdfParallelism,
      saltBase64: bytesToBase64(List<int>.filled(16, 7)),
    );
  }

  @override
  Future<Uint8List> deriveKey({
    required String password,
    required KdfParams params,
  }) async {
    VaultFileValidator.validateKdf(params);
    final passwordBytes = utf8.encode(password);
    return Uint8List.fromList(
      List<int>.generate(32, (index) {
        return passwordBytes.fold<int>(
          index,
          (value, byte) => (value + byte + index) & 0xff,
        );
      }),
    );
  }
}

class MemoryVaultFileStore extends VaultFileStore {
  MemoryVaultFileStore({this.text});

  String? text;

  @override
  Future<bool> exists() async => text != null;

  @override
  Future<VaultFile> load() async {
    final currentText = text;

    if (currentText == null) {
      throw StateError("No vault file in memory.");
    }

    return VaultFileValidator.parse(currentText);
  }

  @override
  Future<String?> loadTextIfExists() async => text;

  @override
  Future<void> save(VaultFile vaultFile) async {
    VaultFileValidator.validate(vaultFile);
    text = jsonEncode(vaultFile.toJson());
  }

  @override
  Future<void> saveText(String jsonText) async {
    VaultFileValidator.parse(jsonText);
    text = jsonText;
  }
}

class FakeLocalUnlockService extends LocalUnlockService {
  const FakeLocalUnlockService();

  @override
  Future<void> ensureMasterUnlockAllowed() async {}

  @override
  Future<void> clearThrottleState() async {}

  @override
  Future<void> restoreFingerprintUnlockIfNeeded({
    required List<int> vaultKey,
  }) async {}
}

class FakeMicrosoftAuthService extends MicrosoftAuthService {
  FakeMicrosoftAuthService({this.remoteText});

  String? remoteText;

  @override
  Future<void> connect() async {}

  @override
  Future<http.Response> get(String url) async {
    final currentRemoteText = remoteText;

    if (currentRemoteText == null) {
      return http.Response("", 404);
    }

    if (url.endsWith(":/content")) {
      return http.Response(currentRemoteText, 200);
    }

    return http.Response(
      jsonEncode({
        "id": "vault",
        "eTag": "etag",
        "lastModifiedDateTime": "2026-05-27T12:00:00Z",
      }),
      200,
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      "cloud_sync_mode": "oneDrive",
      "cloud_sync_held": false,
    });
  });

  testWidgets(
    "cloud conflict can be compared when the cloud vault uses a different vault key",
    (tester) async {
      const keyDeriver = FastMasterKeyDeriver();
      final builder = VaultBuilder(keyDeriver: keyDeriver);
      final unlocker = VaultUnlocker(keyDeriver: keyDeriver);

      final localText = await _createVaultText(
        builder,
        const PasswordDatabase(
          version: 1,
          entries: [
            PasswordEntry(
              id: "local-entry",
              title: "Local Entry",
              username: "local",
              password: "local-password",
            ),
          ],
        ),
      );
      final cloudText = await _createVaultText(
        builder,
        const PasswordDatabase(
          version: 1,
          entries: [
            PasswordEntry(
              id: "cloud-entry",
              title: "Cloud Entry",
              username: "cloud",
              password: "cloud-password",
            ),
          ],
        ),
      );

      final localStore = MemoryVaultFileStore(text: localText);
      final authController = AuthController(
        store: localStore,
        unlocker: unlocker,
        localUnlockService: const FakeLocalUnlockService(),
      );
      final cloudController = CloudController(
        vaultFileStore: localStore,
        microsoftAuthService: FakeMicrosoftAuthService(remoteText: cloudText),
      );

      expect(await authController.unlock(_masterPassword), isTrue);
      await cloudController.initialize();
      expect(cloudController.hasPendingConflict, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale("en"),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CloudScreen(
            authController: authController,
            cloudController: cloudController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Confirm master password"), findsNothing);
      expect(find.text("Available in cloud"), findsOneWidget);
      expect(find.text("Cloud Entry"), findsOneWidget);
    },
  );
}

Future<String> _createVaultText(
  VaultBuilder builder,
  PasswordDatabase database,
) async {
  final created = await builder.createNewVault(
    masterPassword: _masterPassword,
    initialDatabase: database,
  );
  return jsonEncode(created.vaultFile.toJson());
}
