// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Passwort-Safe';

  @override
  String get dashboard => 'Übersicht';

  @override
  String get settings => 'Einstellungen';

  @override
  String get security => 'Sicherheit';

  @override
  String get quickUnlock => 'Schnellentsperren';

  @override
  String get masterPassword => 'Master-Passwort';

  @override
  String get cloudSync => 'Cloud-Synchronisierung';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get theme => 'Thema';

  @override
  String get language => 'Sprache';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get cloudMessageSyncDisabled => 'Cloud-Synchronisierung deaktiviert.';

  @override
  String get cloudMessageSyncPaused => 'Cloud-Synchronisierung pausiert.';

  @override
  String get cloudMessageOneDriveConnectedNoVault =>
      'OneDrive verbunden, aber keine Tresordatei gefunden.';

  @override
  String get cloudMessageUploadedToOneDrive =>
      'Verschlüsselter Tresor auf OneDrive hochgeladen.';

  @override
  String get cloudMessageDownloadedFromOneDrive =>
      'Verschlüsselter Tresor von OneDrive heruntergeladen.';

  @override
  String get cloudMessageAlreadyInSync =>
      'Der Tresor ist bereits synchronisiert.';

  @override
  String get cloudMessageVaultsDiffer =>
      'Lokale und OneDrive-Tresordateien unterscheiden sich.';

  @override
  String get cloudMessageSignInCanceled => 'Microsoft-Anmeldung abgebrochen.';

  @override
  String get cloudMessageEnableOneDriveFailed =>
      'Aktivierung der OneDrive-Synchronisierung fehlgeschlagen.';

  @override
  String get cloudMessageSyncFailed => 'Cloud-Synchronisierung fehlgeschlagen.';

  @override
  String get cloudMessageUploadedLocalConflict =>
      'Tresor dieses Geräts auf OneDrive hochgeladen.';

  @override
  String get cloudMessageDownloadedCloudConflict =>
      'OneDrive-Tresor auf dieses Gerät heruntergeladen.';

  @override
  String get cloudMessageKeptBothPaused =>
      'OneDrive-Tresor als separate Datei auf diesem Gerät gespeichert. Synchronisierung pausiert.';

  @override
  String get cloudMessageSaveConflictFailed =>
      'Konnte die Konfliktkopie nicht speichern.';
}
