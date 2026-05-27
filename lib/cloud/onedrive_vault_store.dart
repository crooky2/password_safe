import "dart:convert";

import "microsoft_auth_service.dart";

class OneDriveVaultInfo {
  const OneDriveVaultInfo({
    required this.id,
    required this.eTag,
    required this.lastModifiedDateTime,
  });

  final String id;
  final String eTag;
  final DateTime lastModifiedDateTime;
}

class OneDriveVaultStore {
  const OneDriveVaultStore({required this.authService});

  final MicrosoftAuthService authService;

  static const _vaultMetadataUrl =
      "https://graph.microsoft.com/v1.0/me/drive/special/approot:/vault.json";
  static const _vaultContentUrl =
      "https://graph.microsoft.com/v1.0/me/drive/special/approot:/vault.json:/content";

  Future<OneDriveVaultInfo?> getInfo() async {
    final response = await authService.get(_vaultMetadataUrl);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw StateError(
        "Could not load OneDrive vault metadata: ${response.statusCode}",
      );
    }

    final json = jsonDecode(response.body) as Map<String, Object?>;

    return OneDriveVaultInfo(
      id: json["id"] as String,
      eTag: json["eTag"] as String,
      lastModifiedDateTime: DateTime.parse(
        json["lastModifiedDateTime"] as String,
      ),
    );
  }

  Future<String?> downloadText() async {
    final response = await authService.get(_vaultContentUrl);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw StateError(
        "Could not download OneDrive vault content: ${response.statusCode}",
      );
    }

    return response.body;
  }

  Future<OneDriveVaultInfo> uploadText(String jsonText) async {
    final response = await authService.put(
      _vaultContentUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonText,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError(
        "Could not upload OneDrive vault content: ${response.statusCode}",
      );
    }

    final json = jsonDecode(response.body) as Map<String, Object?>;

    return OneDriveVaultInfo(
      id: json["id"] as String,
      eTag: json["eTag"] as String,
      lastModifiedDateTime: DateTime.parse(
        json["lastModifiedDateTime"] as String,
      ),
    );
  }
}
