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
  String get generatePassword => 'Passwort generieren';

  @override
  String get passwordGenerator => 'Passwortgenerator';

  @override
  String get closePasswordGenerator => 'Passwortgenerator schließen';

  @override
  String get passwordGeneratorNormalCharacters => 'Normale Zeichen';

  @override
  String get passwordGeneratorSpecialCharacters => 'Sonderzeichen';

  @override
  String get passwordGeneratorNumbers => 'Zahlen';

  @override
  String get passwordGeneratorLength => 'Länge';

  @override
  String get passwordGeneratorNoCharactersSelected =>
      'Wähle mindestens einen Zeichentyp aus.';

  @override
  String get usePassword => 'Passwort übernehmen';

  @override
  String get fingerprint => 'Fingerabdruck';

  @override
  String get useFingerprint => 'Fingerabdruck verwenden';

  @override
  String get enterFingerprintToUnlock =>
      'Verwende deinen Fingerabdruck zum Entsperren.';

  @override
  String get usePin => 'PIN verwenden';

  @override
  String get enabled => 'Aktiviert';

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
  String get appearance => 'Darstellung';

  @override
  String get debug => 'Debug';

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
  String get addEntry => 'Eintrag hinzufügen';

  @override
  String get searchForEntry => 'Eintrag suchen';

  @override
  String get allEntries => 'Alle Einträge';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
      zero: '0 Einträge',
    );
    return '$_temp0';
  }

  @override
  String get folders => 'Ordner';

  @override
  String homeScreenFoldersInfo(int customCount, int detectedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      customCount,
      locale: localeName,
      other: '$customCount Erstellte',
      one: '1 Erstellter',
    );
    String _temp1 = intl.Intl.pluralLogic(
      detectedCount,
      locale: localeName,
      other: '$detectedCount Erkannte',
      one: '1 Erkannter',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get favorites => 'Favoriten';

  @override
  String get unfavorite => 'Aus Favoriten entfernen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get clone => 'Klonen';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get discard => 'Verwerfen';

  @override
  String get show => 'Anzeigen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get type => 'Typ';

  @override
  String get provider => 'Anbieter';

  @override
  String get oneDrive => 'OneDrive';

  @override
  String get titleLabel => 'Titel';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get pin => 'PIN';

  @override
  String get url => 'URL';

  @override
  String get notes => 'Notizen';

  @override
  String get notSet => 'Nicht gesetzt';

  @override
  String copyLabel(Object label) {
    return '$label kopieren';
  }

  @override
  String labelCopied(Object label) {
    return '$label kopiert.';
  }

  @override
  String showLabel(Object label) {
    return '$label anzeigen';
  }

  @override
  String hideLabel(Object label) {
    return '$label ausblenden';
  }

  @override
  String get closeEntryDetails => 'Eintragsdetails schließen';

  @override
  String get closeEntryForm => 'Eintragsformular schließen';

  @override
  String get clearSearch => 'Suche leeren';

  @override
  String get closeSearch => 'Suche schließen';

  @override
  String get searchEntries => 'Einträge suchen';

  @override
  String get noEntriesFound => 'Keine Einträge gefunden.';

  @override
  String get noEntriesMatchSearch => 'Keine Einträge passen zur Suche.';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get appLocked => 'App gesperrt';

  @override
  String get enterPinToUnlock => 'Gib deine PIN ein, um zu entsperren.';

  @override
  String get enterPasswordToUnlock =>
      'Gib dein Passwort ein, um zu entsperren.';

  @override
  String get enterYourPin => 'Gib deine PIN ein';

  @override
  String get enterYourPassword => 'Gib dein Passwort ein';

  @override
  String get unlock => 'Entsperren';

  @override
  String get useMasterPassword => 'Master-Passwort verwenden';

  @override
  String get useQuickUnlock => 'Schnellentsperren verwenden';

  @override
  String lockScreenTooManyPinAttemptsMasterAvailable(Object countdown) {
    return 'Zu viele PIN-Versuche. Entsperren mit Master-Passwort ist in $countdown verfügbar.';
  }

  @override
  String lockScreenWrongPinTryAgainUseMasterPassword(Object countdown) {
    return 'Falsche PIN. Versuche es in $countdown erneut oder verwende das Master-Passwort.';
  }

  @override
  String lockScreenQuickUnlockDisabledFor(Object countdown) {
    return 'Schnellentsperren ist für $countdown deaktiviert.';
  }

  @override
  String get setupVault => 'Tresor einrichten';

  @override
  String get useAtLeast12Characters => 'Verwende mindestens 12 Zeichen.';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get atLeast12Characters => 'Mindestens 12 Zeichen';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get createVault => 'Tresor erstellen';

  @override
  String get lockApp => 'App sperren';

  @override
  String get resetAppData => 'App-Daten zurücksetzen';

  @override
  String get resetAppDataMessage => 'App-Daten zurückgesetzt.';

  @override
  String get quickUnlockDescription =>
      'Nutze Schnellentsperren für schnelleren Zugriff. Es ersetzt dein Master-Passwort nicht, wird nur auf diesem Gerät gespeichert und dein Tresor bleibt mit dem Master-Passwort verschlüsselt.';

  @override
  String get failedToEnableQuickUnlock =>
      'Schnellentsperren konnte nicht aktiviert werden.';

  @override
  String get masterPasswordChangedQuickUnlockDisabled =>
      'Master-Passwort erfolgreich geändert. Schnellentsperren wurde deaktiviert.';

  @override
  String get failedToChangeMasterPassword =>
      'Master-Passwort konnte nicht geändert werden. Das aktuelle Passwort ist möglicherweise falsch oder die Tresordatei ist beschädigt.';

  @override
  String get masterPasswordDescription =>
      'Das Master-Passwort wird verwendet, um deine Tresordaten zu verschlüsseln und zu entschlüsseln.';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get cloudSyncDescription =>
      'Speichere eine verschlüsselte Tresorkopie in der Cloud. Du kannst weiterhin ohne Internetverbindung auf deinen Tresor zugreifen, und deine Daten werden nie unverschlüsselt geteilt.';

  @override
  String get syncing => 'Synchronisiere...';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get cloudSyncPausedResolve =>
      'Cloud-Synchronisierung pausiert. Nutze Jetzt synchronisieren, nachdem du entschieden hast, welcher Tresor übernommen werden soll.';

  @override
  String get closePinSetup => 'PIN-Einrichtung schließen';

  @override
  String get closeMasterPasswordChange => 'Master-Passwort-Änderung schließen';

  @override
  String get setPin => 'PIN festlegen';

  @override
  String get confirmPin => 'PIN bestätigen';

  @override
  String get useAtLeast4Characters => 'Verwende mindestens 4 Zeichen.';

  @override
  String get pinsDoNotMatch => 'Die PINs stimmen nicht überein.';

  @override
  String get enablePin => 'PIN aktivieren';

  @override
  String get changeMasterPassword => 'Master-Passwort ändern';

  @override
  String get quickUnlockDisabledAfterPasswordChange =>
      'Schnellentsperren wird nach dieser Änderung deaktiviert.';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get enterCurrentPassword => 'Gib das aktuelle Passwort ein.';

  @override
  String get cloudSyncConflict => 'Cloud-Synchronisierungskonflikt';

  @override
  String get closeCloudSyncConflict =>
      'Cloud-Synchronisierungskonflikt schließen';

  @override
  String get cloudConflictSubtitle =>
      'Die Tresordatei auf diesem Gerät unterscheidet sich von der in der Cloud.';

  @override
  String get useThisDevicesVersion => 'Version dieses Geräts verwenden';

  @override
  String get useCloudVersion => 'Cloud-Version verwenden';

  @override
  String get keepBothVersions => 'Beide Versionen behalten';

  @override
  String get titleRequired => 'Titel ist erforderlich.';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get cloneEntry => 'Eintrag klonen';

  @override
  String get newEntry => 'Neuer Eintrag';

  @override
  String get createEntry => 'Eintrag erstellen';

  @override
  String get entrySaved => 'Eintrag gespeichert.';

  @override
  String get entryDeleted => 'Eintrag gelöscht.';

  @override
  String get entryMarkedAsFavorite => 'Eintrag als Favorit markiert.';

  @override
  String get entryRemovedFromFavorites => 'Eintrag aus Favoriten entfernt.';

  @override
  String get failedToSaveEntry => 'Eintrag konnte nicht gespeichert werden.';

  @override
  String get failedToDeleteEntry => 'Eintrag konnte nicht gelöscht werden.';

  @override
  String get failedToUpdateEntry => 'Eintrag konnte nicht aktualisiert werden.';

  @override
  String get deleteEntryDialogTitle => 'Eintrag löschen?';

  @override
  String deleteEntryDialogContent(Object title, Object username) {
    return '\"$title\" für \"$username\" löschen?\n\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get closeFolderForm => 'Ordnerformular schließen';

  @override
  String get newFolder => 'Neuer Ordner';

  @override
  String get folderName => 'Ordnername';

  @override
  String get entries => 'Einträge';

  @override
  String get noEntriesAvailableToAddToFolder =>
      'Keine Einträge zum Hinzufügen verfügbar.';

  @override
  String get folderCreated => 'Ordner erstellt.';

  @override
  String get failedToCreateFolder => 'Ordner konnte nicht erstellt werden.';

  @override
  String get createNewFolder => 'Neuen Ordner erstellen';

  @override
  String get customFolders => 'Erstellt';

  @override
  String get noCustomFoldersYet => 'Noch keine erstellten Ordner.';

  @override
  String get detectedFolders => 'Erkannt';

  @override
  String get noDetectedFoldersYet => 'Noch keine erkannten Ordner.';

  @override
  String get thisFolderIsEmpty => 'Dieser Ordner ist leer.';

  @override
  String get noEntriesInThisFolder => 'Keine Einträge in diesem Ordner.';

  @override
  String folderSourceInfo(int count, Object source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
      zero: '0 Einträge',
    );
    return '$_temp0 - $source';
  }

  @override
  String get detectedFolderSourceTitle => 'Titel';

  @override
  String get detectedFolderSourceUsernameDomain => 'Gleiche Domain';

  @override
  String get detectedFolderSourceUrlHost => 'Gleiche Website';

  @override
  String durationMinutesAndSeconds(int minutes, int seconds) {
    return '$minutes Min. und $seconds Sek.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds Sek.';
  }

  @override
  String get authCouldNotCreateVault => 'Tresor konnte nicht erstellt werden.';

  @override
  String authTooManyPinAttemptsTryAgain(Object duration) {
    return 'Zu viele PIN-Versuche. Versuche es in $duration erneut.';
  }

  @override
  String get authWrongPassword => 'Falsches Passwort.';

  @override
  String get authVaultIsLocked => 'Tresor ist gesperrt.';

  @override
  String get authCouldNotSaveDatabase =>
      'Datenbank konnte nicht gespeichert werden.';

  @override
  String get authUseAtLeast12CharactersForPassword =>
      'Verwende mindestens 12 Zeichen für das Passwort.';

  @override
  String get authCurrentPasswordIncorrectOrVaultDamaged =>
      'Das aktuelle Passwort ist falsch oder die Tresordatei ist beschädigt.';

  @override
  String get authUseAtLeast4DigitsForPin =>
      'Verwende mindestens 4 Ziffern für die PIN.';

  @override
  String get authPinMustContainOnlyNumbers =>
      'Die PIN darf nur Zahlen enthalten.';

  @override
  String get authCouldNotEnableQuickUnlock =>
      'Schnellentsperren konnte nicht aktiviert werden.';

  @override
  String authTooManyPinAttemptsWaitThenUseMasterPassword(Object duration) {
    return 'Zu viele PIN-Versuche. Warte $duration und verwende dann dein Master-Passwort.';
  }

  @override
  String get authQuickUnlockDisabledUseMasterPassword =>
      'Schnellentsperren ist deaktiviert. Verwende dein Master-Passwort.';

  @override
  String authWrongPinTryAgain(Object duration) {
    return 'Falsche PIN. Versuche es in $duration erneut.';
  }

  @override
  String get authWrongPin => 'Falsche PIN.';

  @override
  String get confirmDeviceAuthForQuickUnlock =>
      'Bestätige deine Geräteentsperrung, um Schnellentsperren zu verwenden.';

  @override
  String get authLocalAuthenticationUnavailable =>
      'Geräteauthentifizierung ist nicht verfügbar.';

  @override
  String get authLocalAuthenticationFailed =>
      'Geräteauthentifizierung fehlgeschlagen oder abgebrochen.';

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

  @override
  String get cloudMessageRemoteRollbackDetected =>
      'Der Cloud-Tresor hat sich unerwartet geändert. Die Synchronisierung wurde zum Schutz deines lokalen Tresors pausiert.';

  @override
  String get debugNoVaultLoaded => 'Kein Tresor geladen.';

  @override
  String get debugTestEntryTitle => 'Testeintrag';

  @override
  String get debugTestEntryUsername => 'Testbenutzer';

  @override
  String get debugTestEntryPassword => 'Testpasswort';

  @override
  String get debugTestEntryNotes => 'Notizen zum Testeintrag';

  @override
  String debugSavedEntries(int count) {
    return 'Gespeicherte Einträge: $count';
  }

  @override
  String get debugSaveFailed => 'Speichern fehlgeschlagen.';

  @override
  String get debugAddTestEntry => 'Testeintrag hinzufügen';

  @override
  String get debugNoLocalVaultAndNoOneDriveVault =>
      'Kein lokaler Tresor und kein OneDrive-Tresor gefunden.';

  @override
  String debugUploadedVaultToOneDrive(Object eTag) {
    return 'Tresor auf OneDrive hochgeladen: $eTag';
  }

  @override
  String debugErrorDuringOneDriveSync(Object error) {
    return 'Fehler bei der OneDrive-Synchronisierung: $error';
  }

  @override
  String get debugTestOneDriveSync => 'OneDrive-Synchronisierung testen';

  @override
  String get debugTestMicrosoftSignOutAndReSignIn =>
      'Microsoft-Abmeldung und erneute Anmeldung testen';
}
