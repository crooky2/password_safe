import "dart:convert";

import "package:cryptography/cryptography.dart";
import "package:shared_preferences/shared_preferences.dart";

class CloudSyncCheckpoint {
  const CloudSyncCheckpoint({
    required this.provider,
    required this.remoteETag,
    required this.remoteHash,
  });

  final String provider;
  final String remoteETag;
  final String remoteHash;

  Map<String, Object> toJson() {
    return {
      "provider": provider,
      "remoteETag": remoteETag,
      "remoteHash": remoteHash,
    };
  }

  factory CloudSyncCheckpoint.fromJson(Map<String, Object?> json) {
    return CloudSyncCheckpoint(
      provider: json["provider"] as String,
      remoteETag: json["remoteETag"] as String,
      remoteHash: json["remoteHash"] as String,
    );
  }
}

class CloudSyncCheckpointStore {
  const CloudSyncCheckpointStore();

  static const _key = "cloud_sync_checkpoint";

  Future<CloudSyncCheckpoint?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final text = preferences.getString(_key);

    if (text == null) {
      return null;
    }

    try {
      final json = jsonDecode(text) as Map<String, Object?>;
      return CloudSyncCheckpoint.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(CloudSyncCheckpoint checkpoint) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(checkpoint.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }

  Future<String> hashText(String text) async {
    final hash = await Sha256().hash(utf8.encode(text));
    return base64UrlEncode(hash.bytes);
  }
}