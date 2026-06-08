import "dart:async";
import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "package:password_safe/cloud/cloud_controller.dart";
import "package:password_safe/cloud/cloud_sync_checkpoint_store.dart";
import "package:password_safe/cloud/microsoft_auth_service.dart";
import "package:password_safe/crypto/vault_file_validator.dart";
import "package:password_safe/storage/vault_file_store.dart";

class FakeVaultFileStore extends VaultFileStore {
  FakeVaultFileStore({
    this.text,
    this.throwOnLoad = false,
    this.throwOnSave = false,
    this.throwOnConflictSave = false,
  });

  String? text;
  bool throwOnLoad;
  bool throwOnSave;
  bool throwOnConflictSave;
  int loadTextCount = 0;
  int saveTextCount = 0;
  int saveConflictTextCount = 0;
  final savedTexts = <String>[];
  final conflictTexts = <String>[];
  final conflictSources = <String>[];

  @override
  Future<String?> loadTextIfExists() async {
    loadTextCount += 1;

    if (throwOnLoad) {
      throw StateError("Could not load local vault.");
    }

    return text;
  }

  @override
  Future<void> saveText(String jsonText) async {
    saveTextCount += 1;
    savedTexts.add(jsonText);

    if (throwOnSave) {
      throw StateError("Could not save local vault.");
    }

    VaultFileValidator.parse(jsonText);
    text = jsonText;
  }

  @override
  Future<String> saveConflictText(
    String jsonText, {
    required String source,
  }) async {
    saveConflictTextCount += 1;
    conflictTexts.add(jsonText);
    conflictSources.add(source);

    if (throwOnConflictSave) {
      throw StateError("Could not save conflict vault.");
    }

    return "fake/path/vault.$source.conflict.json";
  }
}

class FakeCloudSyncCheckpointStore extends CloudSyncCheckpointStore {
  FakeCloudSyncCheckpointStore({this.checkpoint});

  CloudSyncCheckpoint? checkpoint;
  int readCount = 0;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<CloudSyncCheckpoint?> read() async {
    readCount += 1;
    return checkpoint;
  }

  @override
  Future<void> write(CloudSyncCheckpoint checkpoint) async {
    writeCount += 1;
    this.checkpoint = checkpoint;
  }

  @override
  Future<void> clear() async {
    clearCount += 1;
    checkpoint = null;
  }

  @override
  Future<String> hashText(String text) async {
    return "hash:$text";
  }
}

class FakeMicrosoftAuthService extends MicrosoftAuthService {
  FakeMicrosoftAuthService({
    this.remoteText,
    this.eTag = "etag-initial",
    this.metadataStatus = 200,
    this.downloadStatus = 200,
    this.uploadStatus = 200,
    this.connectException,
    this.putGate,
  });

  String? remoteText;
  String eTag;
  int metadataStatus;
  int downloadStatus;
  int uploadStatus;
  Object? connectException;
  Completer<void>? putGate;
  bool signedOut = false;
  int connectCount = 0;
  int signOutCount = 0;
  int metadataRequestCount = 0;
  int downloadRequestCount = 0;
  int putRequestCount = 0;
  int _uploadSequence = 0;
  final requestedUrls = <String>[];
  final putBodies = <String>[];
  final putHeaders = <Map<String, String>?>[];

  @override
  Future<void> connect() async {
    connectCount += 1;

    final exception = connectException;
    if (exception != null) {
      throw exception;
    }
  }

  @override
  Future<void> signOut() async {
    signOutCount += 1;
    signedOut = true;
  }

  @override
  Future<http.Response> get(String url) async {
    requestedUrls.add(url);

    if (url.endsWith(":/content")) {
      downloadRequestCount += 1;

      if (downloadStatus == 404 || remoteText == null) {
        return http.Response("", 404);
      }

      if (downloadStatus != 200) {
        return http.Response("", downloadStatus);
      }

      return http.Response(remoteText!, 200);
    }

    metadataRequestCount += 1;

    if (metadataStatus == 404 || remoteText == null) {
      return http.Response("", 404);
    }

    if (metadataStatus != 200) {
      return http.Response("", metadataStatus);
    }

    return http.Response(_metadataJson(), 200);
  }

  @override
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    putRequestCount += 1;
    putHeaders.add(headers);

    final jsonText = body as String;
    putBodies.add(jsonText);

    final gate = putGate;
    if (gate != null) {
      await gate.future;
    }

    if (uploadStatus != 200 && uploadStatus != 201) {
      return http.Response("", uploadStatus);
    }

    remoteText = jsonText;
    _uploadSequence += 1;
    eTag = "etag-upload-$_uploadSequence";

    return http.Response(_metadataJson(), uploadStatus);
  }

  String _metadataJson() {
    return jsonEncode({
      "id": "vault",
      "eTag": eTag,
      "lastModifiedDateTime": "2026-05-27T12:00:00Z",
    });
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group("initialize", () {
    test("starts disabled by default and does not contact OneDrive", () async {
      final auth = FakeMicrosoftAuthService(remoteText: fakeVaultText("cloud"));
      final localStore = FakeVaultFileStore(text: fakeVaultText("local"));
      final controller = createController(localStore: localStore, auth: auth);

      await controller.initialize();

      expect(controller.mode, CloudSyncMode.disabled);
      expect(controller.syncHeld, isFalse);
      expect(controller.message, isNull);
      expect(controller.hasPendingConflict, isFalse);
      expect(controller.canAutoSyncLocalChange, isFalse);
      expect(auth.connectCount, 0);
      expect(localStore.loadTextCount, 0);
    });

    test("loads a held OneDrive sync without checking the cloud", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": true,
      });

      final auth = FakeMicrosoftAuthService(remoteText: fakeVaultText("cloud"));
      final localStore = FakeVaultFileStore(text: fakeVaultText("local"));
      final controller = createController(localStore: localStore, auth: auth);

      await controller.initialize();

      expect(controller.mode, CloudSyncMode.oneDrive);
      expect(controller.syncHeld, isTrue);
      expect(controller.hasUnresolvedSyncProblem, isTrue);
      expect(controller.canAutoSyncLocalChange, isFalse);
      expect(auth.connectCount, 0);
      expect(localStore.loadTextCount, 0);
    });

    test(
      "checks OneDrive on startup when sync is enabled and unheld",
      () async {
        SharedPreferences.setMockInitialValues({
          "cloud_sync_mode": "oneDrive",
          "cloud_sync_held": false,
        });

        final remoteText = fakeVaultText("cloud");
        final auth = FakeMicrosoftAuthService(remoteText: remoteText);
        final localStore = FakeVaultFileStore();
        final checkpointStore = FakeCloudSyncCheckpointStore();
        final controller = createController(
          localStore: localStore,
          auth: auth,
          checkpointStore: checkpointStore,
        );

        await controller.initialize();

        expect(controller.mode, CloudSyncMode.oneDrive);
        expect(controller.message, CloudMessage.downloadedFromOneDrive);
        expect(localStore.text, remoteText);
        await expectCheckpointFor(
          checkpointStore,
          remoteText,
          remoteETag: "etag-initial",
        );
      },
    );
  });

  group("setMode", () {
    test("enabling OneDrive uploads local vault when cloud is empty", () async {
      final localVault = fakeVaultText("local");
      final localStore = FakeVaultFileStore(text: localVault);
      final auth = FakeMicrosoftAuthService();
      final checkpointStore = FakeCloudSyncCheckpointStore();
      final controller = createController(
        localStore: localStore,
        auth: auth,
        checkpointStore: checkpointStore,
      );

      await controller.setMode(CloudSyncMode.oneDrive);

      expect(controller.mode, CloudSyncMode.oneDrive);
      expect(controller.message, CloudMessage.uploadedToOneDrive);
      expect(controller.syncHeld, isFalse);
      expect(controller.hasPendingConflict, isFalse);
      expect(controller.canAutoSyncLocalChange, isTrue);
      expect(auth.connectCount, 1);
      expect(auth.putBodies, [localVault]);
      expect(auth.putHeaders.single, {"Content-Type": "application/json"});
      expect(auth.remoteText, localVault);
      await expectCheckpointFor(
        checkpointStore,
        localVault,
        remoteETag: "etag-upload-1",
      );

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString("cloud_sync_mode"), "oneDrive");
      expect(preferences.getBool("cloud_sync_held"), isFalse);
    });

    test("enabling OneDrive accepts a created response from upload", () async {
      final localVault = fakeVaultText("local");
      final auth = FakeMicrosoftAuthService(uploadStatus: 201);
      final controller = createController(
        localStore: FakeVaultFileStore(text: localVault),
        auth: auth,
      );

      await controller.setMode(CloudSyncMode.oneDrive);

      expect(controller.mode, CloudSyncMode.oneDrive);
      expect(controller.message, CloudMessage.uploadedToOneDrive);
      expect(auth.remoteText, localVault);
    });

    test(
      "enabling OneDrive downloads cloud vault when local is missing",
      () async {
        final remoteVault = fakeVaultText("cloud");
        final localStore = FakeVaultFileStore();
        final auth = FakeMicrosoftAuthService(remoteText: remoteVault);
        final checkpointStore = FakeCloudSyncCheckpointStore();
        final controller = createController(
          localStore: localStore,
          auth: auth,
          checkpointStore: checkpointStore,
        );

        await controller.setMode(CloudSyncMode.oneDrive);

        expect(controller.mode, CloudSyncMode.oneDrive);
        expect(controller.message, CloudMessage.downloadedFromOneDrive);
        expect(localStore.text, remoteVault);
        expect(localStore.saveTextCount, 1);
        await expectCheckpointFor(
          checkpointStore,
          remoteVault,
          remoteETag: "etag-initial",
        );
      },
    );

    test(
      "enabling OneDrive reports no vault when both sides are empty",
      () async {
        final auth = FakeMicrosoftAuthService();
        final controller = createController(
          localStore: FakeVaultFileStore(),
          auth: auth,
        );

        await controller.setMode(CloudSyncMode.oneDrive);

        expect(controller.mode, CloudSyncMode.oneDrive);
        expect(controller.message, CloudMessage.oneDriveConnectedNoVault);
        expect(auth.putRequestCount, 0);
      },
    );

    test("enabling OneDrive detects a local and cloud conflict", () async {
      final localVault = fakeVaultText("local");
      final remoteVault = fakeVaultText("cloud");
      final localStore = FakeVaultFileStore(text: localVault);
      final auth = FakeMicrosoftAuthService(remoteText: remoteVault);
      final controller = createController(localStore: localStore, auth: auth);

      await controller.setMode(CloudSyncMode.oneDrive);

      expect(controller.mode, CloudSyncMode.oneDrive);
      expect(controller.message, CloudMessage.vaultsDiffer);
      expect(controller.hasPendingConflict, isTrue);
      expect(controller.hasUnresolvedSyncProblem, isTrue);
      expect(controller.canAutoSyncLocalChange, isFalse);
      expect(controller.pendingConflict!.localText, localVault);
      expect(controller.pendingConflict!.remoteText, remoteVault);
      expect(controller.pendingConflict!.remoteETag, "etag-initial");
      expect(localStore.text, localVault);
      expect(auth.remoteText, remoteVault);
    });

    test("sign-in cancel while enabling leaves sync disabled", () async {
      final auth = FakeMicrosoftAuthService(
        connectException: const MicrosoftSignInCanceledException(),
      );
      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: auth,
      );

      await controller.setMode(CloudSyncMode.oneDrive);

      expect(controller.mode, CloudSyncMode.disabled);
      expect(controller.message, CloudMessage.signInCanceled);
      expect(auth.connectCount, 1);
      expect(auth.putRequestCount, 0);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString("cloud_sync_mode"), isNull);
    });

    test("failure while enabling leaves the controller idle", () async {
      final auth = FakeMicrosoftAuthService(uploadStatus: 500);
      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: auth,
      );

      await controller.setMode(CloudSyncMode.oneDrive);

      expect(controller.mode, CloudSyncMode.oneDrive);
      expect(controller.message, CloudMessage.syncFailed);
      expect(controller.isBusy, isFalse);
      expect(controller.hasPendingConflict, isFalse);
    });

    test(
      "disabling OneDrive signs out, clears held state and checkpoint",
      () async {
        SharedPreferences.setMockInitialValues({
          "cloud_sync_mode": "oneDrive",
          "cloud_sync_held": false,
        });

        final localVault = fakeVaultText("local");
        final remoteVault = fakeVaultText("cloud");
        final checkpointStore = FakeCloudSyncCheckpointStore(
          checkpoint: const CloudSyncCheckpoint(
            provider: "oneDrive",
            remoteETag: "stale",
            remoteHash: "stale",
          ),
        );
        final auth = FakeMicrosoftAuthService(remoteText: remoteVault);
        final controller = createController(
          localStore: FakeVaultFileStore(text: localVault),
          auth: auth,
          checkpointStore: checkpointStore,
        );

        await controller.initialize();
        expect(controller.hasPendingConflict, isTrue);

        await controller.setMode(CloudSyncMode.disabled);

        expect(controller.mode, CloudSyncMode.disabled);
        expect(controller.message, CloudMessage.syncDisabled);
        expect(controller.syncHeld, isFalse);
        expect(controller.hasPendingConflict, isFalse);
        expect(auth.signOutCount, 1);
        expect(auth.signedOut, isTrue);
        expect(checkpointStore.clearCount, 1);
        expect(checkpointStore.checkpoint, isNull);

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getString("cloud_sync_mode"), "disabled");
        expect(preferences.getBool("cloud_sync_held"), isFalse);
      },
    );

    test("setMode ignores duplicate mode requests", () async {
      final auth = FakeMicrosoftAuthService();
      final controller = createController(
        localStore: FakeVaultFileStore(),
        auth: auth,
      );

      await controller.initialize();
      await controller.setMode(CloudSyncMode.disabled);

      expect(controller.mode, CloudSyncMode.disabled);
      expect(auth.connectCount, 0);
      expect(auth.signOutCount, 0);
    });
  });

  group("checkForCloudChanges and syncNow", () {
    test("disabled syncNow does not contact OneDrive", () async {
      final auth = FakeMicrosoftAuthService(remoteText: fakeVaultText("cloud"));
      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: auth,
      );

      await controller.syncNow();

      expect(controller.mode, CloudSyncMode.disabled);
      expect(controller.message, isNull);
      expect(auth.connectCount, 0);
    });

    test("held syncNow reports paused without contacting OneDrive", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": true,
      });

      final auth = FakeMicrosoftAuthService(remoteText: fakeVaultText("cloud"));
      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: auth,
      );

      await controller.initialize();
      await controller.syncNow();

      expect(controller.message, CloudMessage.syncPaused);
      expect(auth.connectCount, 0);
    });

    test("matching local and cloud vaults are already in sync", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final text = fakeVaultText("same");
      final checkpointStore = FakeCloudSyncCheckpointStore();
      final auth = FakeMicrosoftAuthService(remoteText: text);
      final controller = createController(
        localStore: FakeVaultFileStore(text: text),
        auth: auth,
        checkpointStore: checkpointStore,
      );

      await controller.initialize();

      expect(controller.message, CloudMessage.alreadyInSync);
      expect(controller.hasPendingConflict, isFalse);
      await expectCheckpointFor(
        checkpointStore,
        text,
        remoteETag: "etag-initial",
      );
    });

    test(
      "rollback is detected when matching remote differs from checkpoint",
      () async {
        SharedPreferences.setMockInitialValues({
          "cloud_sync_mode": "oneDrive",
          "cloud_sync_held": false,
        });

        final text = fakeVaultText("same");
        final checkpointStore = FakeCloudSyncCheckpointStore(
          checkpoint: const CloudSyncCheckpoint(
            provider: "oneDrive",
            remoteETag: "etag-old",
            remoteHash: "hash:previous-remote",
          ),
        );
        final controller = createController(
          localStore: FakeVaultFileStore(text: text),
          auth: FakeMicrosoftAuthService(remoteText: text),
          checkpointStore: checkpointStore,
        );

        await controller.initialize();

        expect(controller.message, CloudMessage.remoteRollbackDetected);
        expect(controller.syncHeld, isTrue);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.canAutoSyncLocalChange, isFalse);

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getBool("cloud_sync_held"), isTrue);
      },
    );

    test("rollback is detected before downloading a changed remote", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final remoteText = fakeVaultText("cloud-rollback");
      final localStore = FakeVaultFileStore();
      final checkpointStore = FakeCloudSyncCheckpointStore(
        checkpoint: const CloudSyncCheckpoint(
          provider: "oneDrive",
          remoteETag: "etag-old",
          remoteHash: "hash:previous-remote",
        ),
      );
      final controller = createController(
        localStore: localStore,
        auth: FakeMicrosoftAuthService(remoteText: remoteText),
        checkpointStore: checkpointStore,
      );

      await controller.initialize();

      expect(controller.message, CloudMessage.remoteRollbackDetected);
      expect(controller.syncHeld, isTrue);
      expect(localStore.text, isNull);
      expect(localStore.saveTextCount, 0);
    });

    test(
      "checkpoint from another provider does not trigger rollback",
      () async {
        SharedPreferences.setMockInitialValues({
          "cloud_sync_mode": "oneDrive",
          "cloud_sync_held": false,
        });

        final remoteText = fakeVaultText("cloud");
        final localStore = FakeVaultFileStore();
        final checkpointStore = FakeCloudSyncCheckpointStore(
          checkpoint: const CloudSyncCheckpoint(
            provider: "other",
            remoteETag: "etag-old",
            remoteHash: "hash:previous-remote",
          ),
        );
        final controller = createController(
          localStore: localStore,
          auth: FakeMicrosoftAuthService(remoteText: remoteText),
          checkpointStore: checkpointStore,
        );

        await controller.initialize();

        expect(controller.message, CloudMessage.downloadedFromOneDrive);
        expect(controller.syncHeld, isFalse);
        expect(localStore.text, remoteText);
      },
    );

    test("metadata failure reports sync failure", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final auth = FakeMicrosoftAuthService(
        remoteText: fakeVaultText("cloud"),
        metadataStatus: 500,
      );
      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: auth,
      );

      await controller.initialize();

      expect(controller.message, CloudMessage.syncFailed);
      expect(controller.isBusy, isFalse);
      expect(controller.hasPendingConflict, isFalse);
    });

    test("download failure reports sync failure", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final auth = FakeMicrosoftAuthService(
        remoteText: fakeVaultText("cloud"),
        downloadStatus: 503,
      );
      final controller = createController(
        localStore: FakeVaultFileStore(),
        auth: auth,
      );

      await controller.initialize();

      expect(controller.message, CloudMessage.syncFailed);
      expect(controller.isBusy, isFalse);
    });

    test("invalid local vault reports sync failure", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final controller = createController(
        localStore: FakeVaultFileStore(text: "{not valid json"),
        auth: FakeMicrosoftAuthService(),
      );

      await controller.initialize();

      expect(controller.message, CloudMessage.syncFailed);
      expect(controller.hasPendingConflict, isFalse);
    });

    test(
      "invalid remote vault reports sync failure without saving it",
      () async {
        SharedPreferences.setMockInitialValues({
          "cloud_sync_mode": "oneDrive",
          "cloud_sync_held": false,
        });

        final localStore = FakeVaultFileStore();
        final controller = createController(
          localStore: localStore,
          auth: FakeMicrosoftAuthService(remoteText: "{not valid json"),
        );

        await controller.initialize();

        expect(controller.message, CloudMessage.syncFailed);
        expect(localStore.saveTextCount, 0);
      },
    );

    test("sign-in cancel during check reports cancellation", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: FakeMicrosoftAuthService(
          connectException: const MicrosoftSignInCanceledException(),
        ),
      );

      await controller.initialize();

      expect(controller.message, CloudMessage.signInCanceled);
      expect(controller.isBusy, isFalse);
    });
  });

  group("syncLocalChange", () {
    test("does nothing while disabled", () async {
      final auth = FakeMicrosoftAuthService();
      final localStore = FakeVaultFileStore(text: fakeVaultText("local"));
      final controller = createController(localStore: localStore, auth: auth);

      await controller.syncLocalChange();

      expect(auth.connectCount, 0);
      expect(localStore.loadTextCount, 0);
      expect(controller.message, isNull);
    });

    test("does nothing while sync is held", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": true,
      });

      final auth = FakeMicrosoftAuthService();
      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: auth,
      );

      await controller.initialize();
      await controller.syncLocalChange();

      expect(auth.connectCount, 0);
      expect(controller.message, isNull);
    });

    test("does nothing while a conflict is pending", () async {
      final localText = fakeVaultText("local");
      final remoteText = fakeVaultText("remote");
      final auth = FakeMicrosoftAuthService(remoteText: remoteText);
      final controller = await enabledControllerWithConflict(
        localText: localText,
        auth: auth,
      );

      await controller.syncLocalChange();

      expect(auth.putRequestCount, 0);
      expect(controller.message, CloudMessage.vaultsDiffer);
      expect(controller.pendingConflict!.remoteText, remoteText);
    });

    test("uploads local vault when remote is missing", () async {
      final localText = fakeVaultText("local");
      final localStore = FakeVaultFileStore();
      final auth = FakeMicrosoftAuthService();
      final checkpointStore = FakeCloudSyncCheckpointStore();
      final controller = createController(
        localStore: localStore,
        auth: auth,
        checkpointStore: checkpointStore,
      );

      await controller.setMode(CloudSyncMode.oneDrive);
      localStore.text = localText;

      await controller.syncLocalChange();

      expect(controller.message, CloudMessage.uploadedToOneDrive);
      expect(auth.putBodies, [localText]);
      await expectCheckpointFor(
        checkpointStore,
        localText,
        remoteETag: "etag-upload-1",
      );
    });

    test("uploads local vault when remote matches checkpoint", () async {
      final previousText = fakeVaultText("previous");
      final currentText = fakeVaultText("current");
      final checkpointStore = FakeCloudSyncCheckpointStore();
      final auth = FakeMicrosoftAuthService(remoteText: previousText);
      final localStore = FakeVaultFileStore(text: previousText);
      final controller = createController(
        localStore: localStore,
        auth: auth,
        checkpointStore: checkpointStore,
      );

      await controller.setMode(CloudSyncMode.oneDrive);
      localStore.text = currentText;

      await controller.syncLocalChange();

      expect(controller.message, CloudMessage.uploadedToOneDrive);
      expect(controller.hasPendingConflict, isFalse);
      expect(auth.putBodies, [currentText]);
      expect(auth.remoteText, currentText);
      await expectCheckpointFor(
        checkpointStore,
        currentText,
        remoteETag: "etag-upload-1",
      );
    });

    test("detects conflict when remote changed outside checkpoint", () async {
      final previousText = fakeVaultText("previous");
      final localText = fakeVaultText("local");
      final remoteText = fakeVaultText("remote");
      final checkpointStore = FakeCloudSyncCheckpointStore();
      final auth = FakeMicrosoftAuthService(remoteText: previousText);
      final localStore = FakeVaultFileStore(text: previousText);
      final controller = createController(
        localStore: localStore,
        auth: auth,
        checkpointStore: checkpointStore,
      );

      await controller.setMode(CloudSyncMode.oneDrive);
      localStore.text = localText;
      auth.remoteText = remoteText;
      auth.eTag = "etag-remote-change";

      await controller.syncLocalChange();

      expect(controller.message, CloudMessage.vaultsDiffer);
      expect(controller.hasPendingConflict, isTrue);
      expect(controller.pendingConflict!.localText, localText);
      expect(controller.pendingConflict!.remoteText, remoteText);
      expect(auth.putRequestCount, 0);
    });

    test(
      "matching local and remote writes checkpoint and reports in sync",
      () async {
        SharedPreferences.setMockInitialValues({
          "cloud_sync_mode": "oneDrive",
          "cloud_sync_held": false,
        });

        final text = fakeVaultText("same");
        final checkpointStore = FakeCloudSyncCheckpointStore();
        final controller = createController(
          localStore: FakeVaultFileStore(text: text),
          auth: FakeMicrosoftAuthService(remoteText: text),
          checkpointStore: checkpointStore,
        );
        await controller.initialize();

        await controller.syncLocalChange();

        expect(controller.message, CloudMessage.alreadyInSync);
        expect(controller.hasPendingConflict, isFalse);
        await expectCheckpointFor(
          checkpointStore,
          text,
          remoteETag: "etag-initial",
        );
      },
    );

    test("missing local vault reports connected but no vault", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final auth = FakeMicrosoftAuthService();
      final controller = createController(
        localStore: FakeVaultFileStore(),
        auth: auth,
      );
      await controller.initialize();

      await controller.syncLocalChange();

      expect(controller.message, CloudMessage.oneDriveConnectedNoVault);
      expect(auth.putRequestCount, 0);
    });

    test("invalid local change reports sync failure", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final controller = createController(
        localStore: FakeVaultFileStore(text: "{not valid json"),
        auth: FakeMicrosoftAuthService(),
      );
      await controller.initialize();

      await controller.syncLocalChange();

      expect(controller.message, CloudMessage.syncFailed);
    });

    test("sign-in cancel during local sync reports cancellation", () async {
      SharedPreferences.setMockInitialValues({
        "cloud_sync_mode": "oneDrive",
        "cloud_sync_held": false,
      });

      final controller = createController(
        localStore: FakeVaultFileStore(text: fakeVaultText("local")),
        auth: FakeMicrosoftAuthService(
          connectException: const MicrosoftSignInCanceledException(),
        ),
      );
      await controller.initialize();

      await controller.syncLocalChange();

      expect(controller.message, CloudMessage.signInCanceled);
      expect(controller.isBusy, isFalse);
    });

    test("queues another local sync while one is in progress", () async {
      final firstText = fakeVaultText("local-v1");
      final secondText = fakeVaultText("local-v2");
      final putGate = Completer<void>();
      final auth = FakeMicrosoftAuthService();
      final localStore = FakeVaultFileStore();
      final controller = createController(localStore: localStore, auth: auth);

      await controller.setMode(CloudSyncMode.oneDrive);
      auth.putGate = putGate;
      localStore.text = firstText;

      final firstSync = controller.syncLocalChange();
      expect(controller.isBusy, isTrue);
      await waitUntil(() => auth.putRequestCount == 1);

      localStore.text = secondText;
      await controller.syncLocalChange();
      putGate.complete();
      await firstSync;
      await waitUntil(() => auth.putRequestCount == 2);

      expect(auth.putBodies, [firstText, secondText]);
      expect(auth.remoteText, secondText);
      expect(controller.message, CloudMessage.uploadedToOneDrive);
      expect(controller.isBusy, isFalse);
    });
  });

  group("conflict resolution", () {
    test(
      "useLocalVaultForConflict uploads the conflict's local text",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final localStore = FakeVaultFileStore(text: localText);
        final auth = FakeMicrosoftAuthService(remoteText: remoteText);
        final checkpointStore = FakeCloudSyncCheckpointStore();
        final controller = await enabledControllerWithConflict(
          localText: localText,
          localStore: localStore,
          auth: auth,
          checkpointStore: checkpointStore,
        );

        localStore.text = fakeVaultText("local-edited-after-conflict");
        await controller.useLocalVaultForConflict();

        expect(controller.message, CloudMessage.uploadedLocalConflict);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.syncHeld, isFalse);
        expect(auth.putBodies.last, localText);
        expect(auth.remoteText, localText);
        await expectCheckpointFor(
          checkpointStore,
          localText,
          remoteETag: "etag-upload-1",
        );
      },
    );

    test("useCloudVaultForConflict saves remote text and checkpoint", () async {
      final localText = fakeVaultText("local");
      final remoteText = fakeVaultText("remote");
      final localStore = FakeVaultFileStore(text: localText);
      final checkpointStore = FakeCloudSyncCheckpointStore();
      final controller = await enabledControllerWithConflict(
        localText: localText,
        localStore: localStore,
        auth: FakeMicrosoftAuthService(remoteText: remoteText),
        checkpointStore: checkpointStore,
      );

      await controller.useCloudVaultForConflict();

      expect(controller.message, CloudMessage.downloadedCloudConflict);
      expect(controller.hasPendingConflict, isFalse);
      expect(controller.syncHeld, isFalse);
      expect(localStore.text, remoteText);
      expect(localStore.savedTexts, [remoteText]);
      await expectCheckpointFor(
        checkpointStore,
        remoteText,
        remoteETag: "etag-initial",
      );
    });

    test(
      "keepBothVaultsForConflict saves cloud copy and pauses sync",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final localStore = FakeVaultFileStore(text: localText);
        final controller = await enabledControllerWithConflict(
          localText: localText,
          localStore: localStore,
          auth: FakeMicrosoftAuthService(remoteText: remoteText),
        );

        await controller.keepBothVaultsForConflict();

        expect(controller.message, CloudMessage.keptBothPaused);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.syncHeld, isTrue);
        expect(localStore.text, localText);
        expect(localStore.conflictTexts, [remoteText]);
        expect(localStore.conflictSources, ["onedrive"]);

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getBool("cloud_sync_held"), isTrue);
      },
    );

    test(
      "keepBothVaultsForConflict pauses even when saving copy fails",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final controller = await enabledControllerWithConflict(
          localText: localText,
          localStore: FakeVaultFileStore(
            text: localText,
            throwOnConflictSave: true,
          ),
          auth: FakeMicrosoftAuthService(remoteText: remoteText),
        );

        await controller.keepBothVaultsForConflict();

        expect(controller.message, CloudMessage.saveConflictFailed);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.syncHeld, isTrue);
      },
    );

    test(
      "uploadCurrentLocalVaultForConflict uploads the latest local text",
      () async {
        final conflictLocalText = fakeVaultText("local-at-conflict");
        final currentLocalText = fakeVaultText("local-current");
        final remoteText = fakeVaultText("remote");
        final localStore = FakeVaultFileStore(text: conflictLocalText);
        final auth = FakeMicrosoftAuthService(remoteText: remoteText);
        final checkpointStore = FakeCloudSyncCheckpointStore();
        final controller = await enabledControllerWithConflict(
          localText: conflictLocalText,
          localStore: localStore,
          auth: auth,
          checkpointStore: checkpointStore,
        );

        localStore.text = currentLocalText;
        final uploaded = await controller.uploadCurrentLocalVaultForConflict();

        expect(uploaded, isTrue);
        expect(controller.message, CloudMessage.uploadedLocalConflict);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.syncHeld, isFalse);
        expect(auth.putBodies.last, currentLocalText);
        expect(auth.remoteText, currentLocalText);
        await expectCheckpointFor(
          checkpointStore,
          currentLocalText,
          remoteETag: "etag-upload-1",
        );
      },
    );

    test(
      "uploadCurrentLocalVaultForConflict returns false without conflict",
      () async {
        final controller = createController(
          localStore: FakeVaultFileStore(text: fakeVaultText("local")),
          auth: FakeMicrosoftAuthService(),
        );

        final uploaded = await controller.uploadCurrentLocalVaultForConflict();

        expect(uploaded, isFalse);
        expect(controller.message, isNull);
      },
    );

    test(
      "uploadCurrentLocalVaultForConflict keeps conflict when local is missing",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final localStore = FakeVaultFileStore(text: localText);
        final auth = FakeMicrosoftAuthService(remoteText: remoteText);
        final controller = await enabledControllerWithConflict(
          localText: localText,
          localStore: localStore,
          auth: auth,
        );

        localStore.text = null;
        final uploaded = await controller.uploadCurrentLocalVaultForConflict();

        expect(uploaded, isFalse);
        expect(controller.message, CloudMessage.syncFailed);
        expect(controller.hasPendingConflict, isTrue);
        expect(auth.putRequestCount, 0);
      },
    );

    test(
      "uploadCurrentLocalVaultForConflict keeps conflict on upload failure",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final auth = FakeMicrosoftAuthService(
          remoteText: remoteText,
          uploadStatus: 500,
        );
        final controller = await enabledControllerWithConflict(
          localText: localText,
          auth: auth,
        );

        final uploaded = await controller.uploadCurrentLocalVaultForConflict();

        expect(uploaded, isFalse);
        expect(controller.message, CloudMessage.syncFailed);
        expect(controller.hasPendingConflict, isTrue);
        expect(auth.remoteText, remoteText);
      },
    );

    test(
      "useCloudVaultForConflict reports failure when local save fails",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final localStore = FakeVaultFileStore(
          text: localText,
          throwOnSave: true,
        );
        final controller = await enabledControllerWithConflict(
          localText: localText,
          localStore: localStore,
          auth: FakeMicrosoftAuthService(remoteText: remoteText),
        );

        await controller.useCloudVaultForConflict();

        expect(controller.message, CloudMessage.syncFailed);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.syncHeld, isFalse);
        expect(localStore.text, localText);
      },
    );

    test(
      "useLocalVaultForConflict reports failure when upload fails",
      () async {
        final localText = fakeVaultText("local");
        final remoteText = fakeVaultText("remote");
        final auth = FakeMicrosoftAuthService(
          remoteText: remoteText,
          uploadStatus: 500,
        );
        final controller = await enabledControllerWithConflict(
          localText: localText,
          auth: auth,
        );

        await controller.useLocalVaultForConflict();

        expect(controller.message, CloudMessage.syncFailed);
        expect(controller.hasPendingConflict, isFalse);
        expect(controller.syncHeld, isFalse);
        expect(auth.remoteText, remoteText);
      },
    );
  });
}

CloudController createController({
  required FakeVaultFileStore localStore,
  required FakeMicrosoftAuthService auth,
  FakeCloudSyncCheckpointStore? checkpointStore,
}) {
  return CloudController(
    vaultFileStore: localStore,
    microsoftAuthService: auth,
    checkpointStore: checkpointStore ?? FakeCloudSyncCheckpointStore(),
  );
}

Future<CloudController> enabledControllerWithConflict({
  required String localText,
  FakeVaultFileStore? localStore,
  FakeMicrosoftAuthService? auth,
  FakeCloudSyncCheckpointStore? checkpointStore,
}) async {
  SharedPreferences.setMockInitialValues({
    "cloud_sync_mode": "oneDrive",
    "cloud_sync_held": false,
  });

  final controller = createController(
    localStore: localStore ?? FakeVaultFileStore(text: localText),
    auth: auth ?? FakeMicrosoftAuthService(remoteText: fakeVaultText("remote")),
    checkpointStore: checkpointStore,
  );
  await controller.initialize();

  expect(controller.hasPendingConflict, isTrue);
  return controller;
}

Future<CloudSyncCheckpoint> checkpointFor(
  FakeCloudSyncCheckpointStore store,
  String text, {
  String provider = "oneDrive",
  String remoteETag = "etag-checkpoint",
}) async {
  return CloudSyncCheckpoint(
    provider: provider,
    remoteETag: remoteETag,
    remoteHash: await store.hashText(text),
  );
}

Future<void> expectCheckpointFor(
  FakeCloudSyncCheckpointStore store,
  String text, {
  required String remoteETag,
}) async {
  final checkpoint = store.checkpoint;

  expect(checkpoint, isNotNull);
  expect(checkpoint!.provider, "oneDrive");
  expect(checkpoint.remoteETag, remoteETag);
  expect(checkpoint.remoteHash, await store.hashText(text));
}

Future<void> waitUntil(bool Function() predicate, {int attempts = 20}) async {
  for (var attempt = 0; attempt < attempts; attempt += 1) {
    if (predicate()) {
      return;
    }

    await Future<void>.delayed(Duration.zero);
  }

  fail("Condition was not met after $attempts event-loop turns.");
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
