import "package:http/http.dart" as http;
import "package:oauth2_client/microsoft_oauth2_client.dart";
import "package:oauth2_client/oauth2_helper.dart";
import "package:oauth2_client/oauth2_exception.dart";

import "PasswordSafe_CloudConfig/microsoft_graph_config.dart";

class MicrosoftSignInCanceledException implements Exception {
  const MicrosoftSignInCanceledException();
}

class MicrosoftAuthService {
  MicrosoftAuthService();

  late final MicrosoftOauth2Client _client = MicrosoftOauth2Client(
    tenant: MicrosoftGraphConfig.tenant,
    redirectUri: MicrosoftGraphConfig.redirectUri,
    customUriScheme: MicrosoftGraphConfig.redirectScheme,
  );

  late final OAuth2Helper _helper = OAuth2Helper(
    _client,
    grantType: OAuth2Helper.authorizationCode,
    clientId: MicrosoftGraphConfig.clientId,
    scopes: MicrosoftGraphConfig.graphScopes,
    authCodeParams: {"scope": MicrosoftGraphConfig.authorizationScope},
    webAuthOpts: MicrosoftGraphConfig.webAuthOptions,
  );

  Future<void> connect() async {
    await _runAuthRequest(() async {
      await _helper.getToken();
    });
  }

  Future<T> _runAuthRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on OAuth2Exception catch (error) {
      final text = error.toString();

      if (text.contains("CANCELED")) {
        throw const MicrosoftSignInCanceledException();
      }

      rethrow;
    }
  }

  Future<http.Response> get(String url) async {
    return _runAuthRequest(() => _helper.get(url));
  }

  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _runAuthRequest(
      () => _helper.put(url, headers: headers, body: body),
    );
  }

  Future<void> signOut() {
    return _helper.removeAllTokens();
  }
}
