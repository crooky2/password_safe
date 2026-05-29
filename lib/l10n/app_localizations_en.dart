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
  String get generatePassword => 'Generate password';

  @override
  String get passwordGenerator => 'Password generator';

  @override
  String get closePasswordGenerator => 'Close password generator';

  @override
  String get passwordGeneratorNormalCharacters => 'Normal characters';

  @override
  String get passwordGeneratorSpecialCharacters => 'Special characters';

  @override
  String get passwordGeneratorNumbers => 'Numbers';

  @override
  String get passwordGeneratorLength => 'Length';

  @override
  String get passwordGeneratorNoCharactersSelected =>
      'Select at least one character type.';

  @override
  String get usePassword => 'Use password';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get useFingerprint => 'Use fingerprint';

  @override
  String get enterFingerprintToUnlock => 'Use your fingerprint to unlock.';

  @override
  String get usePin => 'Use PIN';

  @override
  String get enabled => 'Enabled';

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
  String get debug => 'Debug';

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
  String get addEntry => 'Add entry';

  @override
  String get searchForEntry => 'Search for entry';

  @override
  String get allEntries => 'All entries';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: '0 entries',
    );
    return '$_temp0';
  }

  @override
  String get folders => 'Folders';

  @override
  String homeScreenFoldersInfo(int customCount, int detectedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      customCount,
      locale: localeName,
      other: '$customCount created',
      one: '1 created',
    );
    String _temp1 = intl.Intl.pluralLogic(
      detectedCount,
      locale: localeName,
      other: '$detectedCount detected',
      one: '1 detected',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get edit => 'Edit';

  @override
  String get clone => 'Clone';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get discard => 'Discard';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get disabled => 'Disabled';

  @override
  String get type => 'Type';

  @override
  String get provider => 'Provider';

  @override
  String get oneDrive => 'OneDrive';

  @override
  String get titleLabel => 'Title';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get pin => 'PIN';

  @override
  String get url => 'URL';

  @override
  String get notes => 'Notes';

  @override
  String get notSet => 'Not set';

  @override
  String copyLabel(Object label) {
    return 'Copy $label';
  }

  @override
  String labelCopied(Object label) {
    return '$label copied.';
  }

  @override
  String showLabel(Object label) {
    return 'Show $label';
  }

  @override
  String hideLabel(Object label) {
    return 'Hide $label';
  }

  @override
  String get closeEntryDetails => 'Close entry details';

  @override
  String get closeEntryForm => 'Close entry form';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get closeSearch => 'Close search';

  @override
  String get searchEntries => 'Search entries';

  @override
  String get noEntriesFound => 'No entries found.';

  @override
  String get noEntriesMatchSearch => 'No entries match your search.';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get appLocked => 'App locked';

  @override
  String get enterPinToUnlock => 'Enter your PIN to unlock.';

  @override
  String get enterPasswordToUnlock => 'Enter your password to unlock.';

  @override
  String get enterYourPin => 'Enter your PIN';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get unlock => 'Unlock';

  @override
  String get useMasterPassword => 'Use master password';

  @override
  String get useQuickUnlock => 'Use quick unlock';

  @override
  String lockScreenTooManyPinAttemptsMasterAvailable(Object countdown) {
    return 'Too many PIN attempts. Master password unlock is available in $countdown.';
  }

  @override
  String lockScreenWrongPinTryAgainUseMasterPassword(Object countdown) {
    return 'Wrong PIN. Try again in $countdown or use master password.';
  }

  @override
  String lockScreenQuickUnlockDisabledFor(Object countdown) {
    return 'Quick unlock is disabled for $countdown.';
  }

  @override
  String get setupVault => 'Setup vault';

  @override
  String get useAtLeast12Characters => 'Use at least 12 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get atLeast12Characters => 'At least 12 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get createVault => 'Create vault';

  @override
  String get lockApp => 'Lock app';

  @override
  String get resetAppData => 'Reset app data';

  @override
  String get resetAppDataMessage => 'Reset app data.';

  @override
  String get quickUnlockDescription =>
      'Use quick unlock for faster access. This does not replace your master password, is only stored on this device, and your vault remains encrypted with the master password.';

  @override
  String get failedToEnableQuickUnlock => 'Failed to enable quick unlock.';

  @override
  String get masterPasswordChangedQuickUnlockDisabled =>
      'Master password changed successfully. Quick unlock has been disabled.';

  @override
  String get failedToChangeMasterPassword =>
      'Failed to change master password. Current password may be incorrect or vault file may be damaged.';

  @override
  String get masterPasswordDescription =>
      'The master password is used to encrypt and decrypt your vault data.';

  @override
  String get changePassword => 'Change password';

  @override
  String get cloudSyncDescription =>
      'Store an encrypted vault copy in the cloud. You can still access your vault without internet connection, and your data is never shared unencrypted.';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNow => 'Sync now';

  @override
  String get cloudSyncPausedResolve =>
      'Cloud sync is paused. Use Sync now after choosing which vault should win.';

  @override
  String get closePinSetup => 'Close PIN setup';

  @override
  String get closeMasterPasswordChange => 'Close master password change';

  @override
  String get setPin => 'Set PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get useAtLeast4Characters => 'Use at least 4 characters.';

  @override
  String get pinsDoNotMatch => 'PINs do not match.';

  @override
  String get enablePin => 'Enable PIN';

  @override
  String get changeMasterPassword => 'Change master password';

  @override
  String get quickUnlockDisabledAfterPasswordChange =>
      'Quick unlock will be disabled after this change.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get enterCurrentPassword => 'Enter current password.';

  @override
  String get cloudSyncConflict => 'Cloud sync conflict';

  @override
  String get closeCloudSyncConflict => 'Close cloud sync conflict';

  @override
  String get cloudConflictSubtitle =>
      'The vault file on this device differs from the one in the cloud.';

  @override
  String get useThisDevicesVersion => 'Use this device\'s version';

  @override
  String get useCloudVersion => 'Use cloud version';

  @override
  String get keepBothVersions => 'Keep both versions';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get cloneEntry => 'Clone entry';

  @override
  String get newEntry => 'New entry';

  @override
  String get createEntry => 'Create entry';

  @override
  String get entrySaved => 'Entry saved.';

  @override
  String get entryDeleted => 'Entry deleted.';

  @override
  String get entryMarkedAsFavorite => 'Entry marked as favorite.';

  @override
  String get entryRemovedFromFavorites => 'Entry removed from favorites.';

  @override
  String get failedToSaveEntry => 'Failed to save entry.';

  @override
  String get failedToDeleteEntry => 'Failed to delete entry.';

  @override
  String get failedToUpdateEntry => 'Failed to update entry.';

  @override
  String get deleteEntryDialogTitle => 'Delete entry?';

  @override
  String deleteEntryDialogContent(Object title, Object username) {
    return 'Delete \"$title\" for \"$username\"?\n\nThis action cannot be undone.';
  }

  @override
  String get closeFolderForm => 'Close folder form';

  @override
  String get newFolder => 'New folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get entries => 'Entries';

  @override
  String get noEntriesAvailableToAddToFolder =>
      'No entries available to add to folder.';

  @override
  String get folderCreated => 'Folder created.';

  @override
  String get failedToCreateFolder => 'Failed to create folder.';

  @override
  String get createNewFolder => 'Create new folder';

  @override
  String get customFolders => 'Created';

  @override
  String get noCustomFoldersYet => 'No created folders yet.';

  @override
  String get detectedFolders => 'Detected';

  @override
  String get noDetectedFoldersYet => 'No detected folders yet.';

  @override
  String get thisFolderIsEmpty => 'This folder is empty.';

  @override
  String get noEntriesInThisFolder => 'No entries in this folder.';

  @override
  String folderSourceInfo(int count, Object source) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: '0 entries',
    );
    return '$_temp0 - $source';
  }

  @override
  String get detectedFolderSourceTitle => 'Title';

  @override
  String get detectedFolderSourceUsernameDomain => 'Same username domain';

  @override
  String get detectedFolderSourceUrlHost => 'Same website';

  @override
  String durationMinutesAndSeconds(int minutes, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return '$_temp0 and $_temp1';
  }

  @override
  String durationMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String durationSeconds(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get authCouldNotCreateVault => 'Could not create vault.';

  @override
  String authTooManyPinAttemptsTryAgain(Object duration) {
    return 'Too many PIN attempts. Try again in $duration.';
  }

  @override
  String get authWrongPassword => 'Wrong password.';

  @override
  String get authVaultIsLocked => 'Vault is locked.';

  @override
  String get authCouldNotSaveDatabase => 'Could not save database.';

  @override
  String get authUseAtLeast12CharactersForPassword =>
      'Use at least 12 characters for the password.';

  @override
  String get authCurrentPasswordIncorrectOrVaultDamaged =>
      'Current password is incorrect or vault file is damaged.';

  @override
  String get authUseAtLeast4DigitsForPin =>
      'Use at least 4 digits for the PIN.';

  @override
  String get authPinMustContainOnlyNumbers => 'PIN must contain only numbers.';

  @override
  String get authCouldNotEnableQuickUnlock => 'Could not enable quick unlock.';

  @override
  String authTooManyPinAttemptsWaitThenUseMasterPassword(Object duration) {
    return 'Too many PIN attempts. Wait $duration, then use your master password.';
  }

  @override
  String get authQuickUnlockDisabledUseMasterPassword =>
      'Quick unlock is disabled. Use your master password.';

  @override
  String authWrongPinTryAgain(Object duration) {
    return 'Wrong PIN. Try again in $duration.';
  }

  @override
  String get authWrongPin => 'Wrong PIN.';

  @override
  String get confirmDeviceAuthForQuickUnlock =>
      'Confirm your device unlock to use quick unlock.';

  @override
  String get authLocalAuthenticationUnavailable =>
      'Device authentication is not available.';

  @override
  String get authLocalAuthenticationFailed =>
      'Device authentication failed or was cancelled.';

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

  @override
  String get cloudMessageRemoteRollbackDetected =>
      'Cloud vault changed unexpectedly. Sync has been paused to protect your local vault.';

  @override
  String get debugNoVaultLoaded => 'No vault loaded.';

  @override
  String get debugTestEntryTitle => 'test entry';

  @override
  String get debugTestEntryUsername => 'testuser';

  @override
  String get debugTestEntryPassword => 'testpassword';

  @override
  String get debugTestEntryNotes => 'test entry notes';

  @override
  String debugSavedEntries(int count) {
    return 'Saved entries: $count';
  }

  @override
  String get debugSaveFailed => 'Save failed.';

  @override
  String get debugAddTestEntry => 'Add test entry';

  @override
  String get debugNoLocalVaultAndNoOneDriveVault =>
      'No local vault and no OneDrive vault found.';

  @override
  String debugUploadedVaultToOneDrive(Object eTag) {
    return 'Uploaded vault to OneDrive: $eTag';
  }

  @override
  String debugErrorDuringOneDriveSync(Object error) {
    return 'Error during OneDrive sync: $error';
  }

  @override
  String get debugTestOneDriveSync => 'Test OneDrive sync';

  @override
  String get debugTestMicrosoftSignOutAndReSignIn =>
      'Test Microsoft sign-out and re-sign-in';
}
