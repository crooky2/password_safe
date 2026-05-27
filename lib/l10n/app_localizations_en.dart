// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Password Safe';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get security => 'Security';

  @override
  String get quickUnlock => 'Quick unlock';

  @override
  String get masterPassword => 'Master password';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemLanguage => 'System';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get cloudMessageSyncDisabled => 'Cloud sync disabled.';

  @override
  String get cloudMessageSyncPaused => 'Cloud sync is paused.';

  @override
  String get cloudMessageOneDriveConnectedNoVault =>
      'OneDrive connected, but no vault file was found.';

  @override
  String get cloudMessageUploadedToOneDrive =>
      'Uploaded encrypted vault to OneDrive.';

  @override
  String get cloudMessageDownloadedFromOneDrive =>
      'Downloaded encrypted vault from OneDrive.';

  @override
  String get cloudMessageAlreadyInSync => 'Vault is already in sync.';

  @override
  String get cloudMessageVaultsDiffer =>
      'Local and OneDrive vault files differ.';

  @override
  String get cloudMessageSignInCanceled => 'Microsoft sign-in canceled.';

  @override
  String get cloudMessageEnableOneDriveFailed =>
      'Failed to enable OneDrive sync.';

  @override
  String get cloudMessageSyncFailed => 'Cloud sync failed.';

  @override
  String get cloudMessageUploadedLocalConflict =>
      'Uploaded this device\'s vault to OneDrive.';

  @override
  String get cloudMessageDownloadedCloudConflict =>
      'Downloaded OneDrive vault to this device.';

  @override
  String get cloudMessageKeptBothPaused =>
      'Saved OneDrive vault as a separate file on this device. Sync is paused.';

  @override
  String get cloudMessageSaveConflictFailed =>
      'Could not save the cloud conflict copy.';
}
