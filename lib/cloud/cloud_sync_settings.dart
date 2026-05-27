import "package:shared_preferences/shared_preferences.dart";

enum CloudSyncMode {disabled, oneDrive}

class CloudSyncSettings {
  const CloudSyncSettings();

  static const _modeKey = "cloud_sync_mode";

  Future<CloudSyncMode> loadMode() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_modeKey);
    return switch (value) {
      "oneDrive" => CloudSyncMode.oneDrive,
      _ => CloudSyncMode.disabled,
    };
  }

  Future<void> saveMode(CloudSyncMode mode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _modeKey,
      switch (mode) {
        CloudSyncMode.oneDrive => "oneDrive",
        CloudSyncMode.disabled => "disabled",
      }
    );
  }
}