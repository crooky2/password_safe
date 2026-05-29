import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "package:password_safe/cloud/cloud_controller.dart";
import "package:password_safe/cloud/microsoft_auth_service.dart";
import "package:password_safe/storage/vault_file_store.dart";

class FakeVaultFileStore extends VaultFileStore {
  FakeVaultFileStore({this.text});

  String? text;
  String? conflictText;

  @override
  Future<String?> loadTextIfExists() async => text;

  @override
  Future<void> saveText(String jsonText) async {
    text = jsonText;
  }

  @override
  Future<String> saveConflictText(
    String jsonText, {
    required String source,
  }) async {
    conflictText = jsonText;
    return "fake/path/vault.$source.conflict.json";
  }
}

class FakeMicrosoftAuthService extends MicrosoftAuthService {
  FakeMicrosoftAuthService({this.remoteText});

  String? remoteText;
  bool connected = false;
  bool signedOut = false;

  @override
  Future<void> connect() async {
    connected = true;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<http.Response> get(String url) async {
    if (remoteText == null) {
      return http.Response("", 404);
    }

    if (url.endsWith(":/content")) {
      return http.Response(remoteText!, 200);
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

  @override
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    remoteText = body as String;

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
    SharedPreferences.setMockInitialValues({});
  });

  test("enabling OneDrive uploads local vault when cloud is empty", () async {
    final localVault = fakeVaultText("local");

    final localStore = FakeVaultFileStore(text: localVault);
    final auth = FakeMicrosoftAuthService();

    final controller = CloudController(
      vaultFileStore: localStore,
      microsoftAuthService: auth,
    );

    await controller.setMode(CloudSyncMode.oneDrive);

    expect(controller.mode, CloudSyncMode.oneDrive);
    expect(auth.connected, isTrue);
    expect(auth.remoteText, localVault);
    expect(controller.hasPendingConflict, isFalse);
  });

  test("startup detects conflict when local and cloud differ", () async {
    SharedPreferences.setMockInitialValues({
      "cloud_sync_mode": "oneDrive",
      "cloud_sync_held": false,
    });

    final controller = CloudController(
      vaultFileStore: FakeVaultFileStore(text: fakeVaultText("local")),
      microsoftAuthService: FakeMicrosoftAuthService(
        remoteText: fakeVaultText("cloud"),
      ),
    );

    await controller.initialize();

    expect(controller.mode, CloudSyncMode.oneDrive);
    expect(controller.hasPendingConflict, isTrue);
    expect(controller.pendingConflict!.localText, fakeVaultText("local"));
    expect(controller.pendingConflict!.remoteText, fakeVaultText("cloud"));
  });

  test("keep both saves cloud copy and pauses sync", () async {
    SharedPreferences.setMockInitialValues({
      "cloud_sync_mode": "oneDrive",
      "cloud_sync_held": false,
    });

    final localStore = FakeVaultFileStore(text: fakeVaultText("local"));

    final controller = CloudController(
      vaultFileStore: localStore,
      microsoftAuthService: FakeMicrosoftAuthService(
        remoteText: fakeVaultText("cloud"),
      ),
    );

    await controller.initialize();
    await controller.keepBothVaultsForConflict();

    expect(controller.hasPendingConflict, isFalse);
    expect(controller.syncHeld, isTrue);
    expect(localStore.text, fakeVaultText("local"));
    expect(localStore.conflictText, fakeVaultText("cloud"));
  });
}

String fakeVaultText(String label) {
  return jsonEncode({
    "version": 1,
    "kdf": {
      "algorithm": "argon2id",
      "memoryKb": 65536,
      "iterations": 3,
      "parallelism": 1,
      "salt": base64Encode(List<int>.filled(16, 1)),
    },
    "wrappedVaultKey": fakeBlob("wrapped-$label"),
    "encryptedDatabase": fakeBlob("database-$label"),
  });
}

Map<String, Object> fakeBlob(String label) {
  return {
    "algorithm": "aes-256-gcm",
    "nonce": base64Encode(List<int>.filled(12, 2)),
    "ciphertext": base64Encode(utf8.encode(label)),
    "mac": base64Encode(List<int>.filled(16, 3)),
  };
}
