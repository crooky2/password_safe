import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:password_safe/cloud/cloudconfig/microsoft_graph_config.dart";

void main() {
  group("MicrosoftGraphConfig", () {
    test("uses the Azure public client redirect URI", () {
      expect(
        MicrosoftGraphConfig.redirectUri,
        "com.christopherbach.passwordsafe://oauth2redirect/microsoft",
      );
      expect(
        MicrosoftGraphConfig.redirectScheme,
        "com.christopherbach.passwordsafe",
      );
      expect(MicrosoftGraphConfig.webAuthOptions, {
        "httpsHost": "oauth2redirect",
        "httpsPath": "/microsoft",
      });
    });

    test("matches the Android callback activity intent filter", () {
      final manifest = File(
        "android/app/src/main/AndroidManifest.xml",
      ).readAsStringSync();

      expect(
        manifest,
        contains('android:scheme="${MicrosoftGraphConfig.redirectScheme}"'),
      );
      expect(
        manifest,
        contains('android:host="${MicrosoftGraphConfig.redirectHost}"'),
      );
      expect(
        manifest,
        contains('android:path="${MicrosoftGraphConfig.redirectPath}"'),
      );
    });
  });
}
