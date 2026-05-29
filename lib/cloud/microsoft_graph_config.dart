class MicrosoftGraphConfig {
  const MicrosoftGraphConfig._();

  static const clientId = "b5dbd32c-2599-4082-9955-28993f9fda82";
  static const tenant = "common";

  static const redirectScheme = "com.christopherbach.passwordsafe";
  static const redirectUri = "$redirectScheme://oauth2redirect/microsoft";

  static const graphScopes = <String>["Files.ReadWrite.AppFolder"];
  static const authorizationScopes = <String>["offline_access", ...graphScopes];
  static const authorizationScope = "offline_access Files.ReadWrite.AppFolder";
}
