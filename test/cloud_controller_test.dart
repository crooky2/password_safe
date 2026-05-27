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

    return http.Response(remoteText!, 200);
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
    final localStore = FakeVaultFileStore(text: "local-vault");
    final auth = FakeMicrosoftAuthService();

    final controller = CloudController(
      vaultFileStore: localStore,
      microsoftAuthService: auth,
    );

    await controller.setMode(CloudSyncMode.oneDrive);

    expect(controller.mode, CloudSyncMode.oneDrive);
    expect(auth.connected, isTrue);
    expect(auth.remoteText, "local-vault");
    expect(controller.hasPendingConflict, isFalse);
  });

  test("startup detects conflict when local and cloud differ", () async {
    SharedPreferences.setMockInitialValues({
      "cloud_sync_mode": "oneDrive",
      "cloud_sync_held": false,
    });

    final controller = CloudController(
      vaultFileStore: FakeVaultFileStore(text: "local-vault"),
      microsoftAuthService: FakeMicrosoftAuthService(remoteText: "cloud-vault"),
    );

    await controller.initialize();

    expect(controller.mode, CloudSyncMode.oneDrive);
    expect(controller.hasPendingConflict, isTrue);
    expect(controller.pendingConflict!.localText, "local-vault");
    expect(controller.pendingConflict!.remoteText, "cloud-vault");
  });

  test("keep both saves cloud copy and pauses sync", () async {
    SharedPreferences.setMockInitialValues({
      "cloud_sync_mode": "oneDrive",
      "cloud_sync_held": false,
    });

    final localStore = FakeVaultFileStore(text: "local-vault");

    final controller = CloudController(
      vaultFileStore: localStore,
      microsoftAuthService: FakeMicrosoftAuthService(remoteText: "cloud-vault"),
    );

    await controller.initialize();
    await controller.keepBothVaultsForConflict();

    expect(controller.hasPendingConflict, isFalse);
    expect(controller.syncHeld, isTrue);
    expect(localStore.text, "local-vault");
    expect(localStore.conflictText, "cloud-vault");
  });
}
