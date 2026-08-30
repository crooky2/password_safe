import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Safe'**
  String get appTitle;

  /// No description provided for @generatePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate password'**
  String get generatePassword;

  /// No description provided for @passwordGenerator.
  ///
  /// In en, this message translates to:
  /// **'Password generator'**
  String get passwordGenerator;

  /// No description provided for @closePasswordGenerator.
  ///
  /// In en, this message translates to:
  /// **'Close password generator'**
  String get closePasswordGenerator;

  /// No description provided for @passwordGeneratorNormalCharacters.
  ///
  /// In en, this message translates to:
  /// **'Normal characters'**
  String get passwordGeneratorNormalCharacters;

  /// No description provided for @passwordGeneratorUppercaseCharacters.
  ///
  /// In en, this message translates to:
  /// **'Uppercase characters'**
  String get passwordGeneratorUppercaseCharacters;

  /// No description provided for @passwordGeneratorSpecialCharacters.
  ///
  /// In en, this message translates to:
  /// **'Special characters'**
  String get passwordGeneratorSpecialCharacters;

  /// No description provided for @passwordGeneratorNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get passwordGeneratorNumbers;

  /// No description provided for @passwordGeneratorLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get passwordGeneratorLength;

  /// No description provided for @passwordGeneratorNoCharactersSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one character type.'**
  String get passwordGeneratorNoCharactersSelected;

  /// No description provided for @usePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get usePassword;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @useFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get useFingerprint;

  /// No description provided for @enterFingerprintToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint to unlock.'**
  String get enterFingerprintToUnlock;

  /// No description provided for @usePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @quickUnlock.
  ///
  /// In en, this message translates to:
  /// **'Quick unlock'**
  String get quickUnlock;

  /// No description provided for @masterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get masterPassword;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntry;

  /// No description provided for @searchForEntry.
  ///
  /// In en, this message translates to:
  /// **'Search for entry'**
  String get searchForEntry;

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get allEntries;

  /// No description provided for @entryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 entries} =1{1 entry} other{{count} entries}}'**
  String entryCount(int count);

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @homeScreenFoldersInfo.
  ///
  /// In en, this message translates to:
  /// **'{customCount, plural, =1{1 created} other{{customCount} created}}, {detectedCount, plural, =1{1 detected} other{{detectedCount} detected}}'**
  String homeScreenFoldersInfo(int customCount, int detectedCount);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @clone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get clone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @oneDrive.
  ///
  /// In en, this message translates to:
  /// **'OneDrive'**
  String get oneDrive;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @copyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy {label}'**
  String copyLabel(Object label);

  /// No description provided for @labelCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied.'**
  String labelCopied(Object label);

  /// No description provided for @showLabel.
  ///
  /// In en, this message translates to:
  /// **'Show {label}'**
  String showLabel(Object label);

  /// No description provided for @hideLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide {label}'**
  String hideLabel(Object label);

  /// No description provided for @closeEntryDetails.
  ///
  /// In en, this message translates to:
  /// **'Close entry details'**
  String get closeEntryDetails;

  /// No description provided for @closeEntryForm.
  ///
  /// In en, this message translates to:
  /// **'Close entry form'**
  String get closeEntryForm;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @searchEntries.
  ///
  /// In en, this message translates to:
  /// **'Search entries'**
  String get searchEntries;

  /// No description provided for @noEntriesFound.
  ///
  /// In en, this message translates to:
  /// **'No entries found.'**
  String get noEntriesFound;

  /// No description provided for @noEntriesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No entries match your search.'**
  String get noEntriesMatchSearch;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get appLocked;

  /// No description provided for @enterPinToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to unlock.'**
  String get enterPinToUnlock;

  /// No description provided for @enterPasswordToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to unlock.'**
  String get enterPasswordToUnlock;

  /// No description provided for @enterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterYourPin;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @useMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Use master password'**
  String get useMasterPassword;

  /// No description provided for @useQuickUnlock.
  ///
  /// In en, this message translates to:
  /// **'Use quick unlock'**
  String get useQuickUnlock;

  /// No description provided for @lockScreenTooManyPinAttemptsMasterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Too many PIN attempts. Master password unlock is available in {countdown}.'**
  String lockScreenTooManyPinAttemptsMasterAvailable(Object countdown);

  /// No description provided for @lockScreenWrongPinTryAgainUseMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again in {countdown} or use master password.'**
  String lockScreenWrongPinTryAgainUseMasterPassword(Object countdown);

  /// No description provided for @lockScreenQuickUnlockDisabledFor.
  ///
  /// In en, this message translates to:
  /// **'Quick unlock is disabled for {countdown}.'**
  String lockScreenQuickUnlockDisabledFor(Object countdown);

  /// No description provided for @setupVault.
  ///
  /// In en, this message translates to:
  /// **'Setup vault'**
  String get setupVault;

  /// No description provided for @useAtLeast12Characters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 12 characters.'**
  String get useAtLeast12Characters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @atLeast12Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters'**
  String get atLeast12Characters;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @createVault.
  ///
  /// In en, this message translates to:
  /// **'Create vault'**
  String get createVault;

  /// No description provided for @lockApp.
  ///
  /// In en, this message translates to:
  /// **'Lock app'**
  String get lockApp;

  /// No description provided for @resetAppData.
  ///
  /// In en, this message translates to:
  /// **'Reset app data'**
  String get resetAppData;

  /// No description provided for @resetAppDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Reset app data.'**
  String get resetAppDataMessage;

  /// No description provided for @quickUnlockDescription.
  ///
  /// In en, this message translates to:
  /// **'Use quick unlock for faster access. This does not replace your master password, is only stored on this device, and your vault remains encrypted with the master password.'**
  String get quickUnlockDescription;

  /// No description provided for @failedToEnableQuickUnlock.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable quick unlock.'**
  String get failedToEnableQuickUnlock;

  /// No description provided for @masterPasswordChangedQuickUnlockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Master password changed successfully. Quick unlock has been disabled.'**
  String get masterPasswordChangedQuickUnlockDisabled;

  /// No description provided for @failedToChangeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change master password. Current password may be incorrect or vault file may be damaged.'**
  String get failedToChangeMasterPassword;

  /// No description provided for @masterPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'The master password is used to encrypt and decrypt your vault data.'**
  String get masterPasswordDescription;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @cloudSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Store an encrypted vault copy in the cloud. You can still access your vault without internet connection, and your data is never shared unencrypted.'**
  String get cloudSyncDescription;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @cloudSyncPausedResolve.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is paused. Use Sync now after choosing which vault should win.'**
  String get cloudSyncPausedResolve;

  /// No description provided for @closePinSetup.
  ///
  /// In en, this message translates to:
  /// **'Close PIN setup'**
  String get closePinSetup;

  /// No description provided for @closeMasterPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'Close master password change'**
  String get closeMasterPasswordChange;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @useAtLeast4Characters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 4 characters.'**
  String get useAtLeast4Characters;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinsDoNotMatch;

  /// No description provided for @enablePin.
  ///
  /// In en, this message translates to:
  /// **'Enable PIN'**
  String get enablePin;

  /// No description provided for @changeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change master password'**
  String get changeMasterPassword;

  /// No description provided for @quickUnlockDisabledAfterPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'Quick unlock will be disabled after this change.'**
  String get quickUnlockDisabledAfterPasswordChange;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password.'**
  String get enterCurrentPassword;

  /// No description provided for @cloudSyncConflict.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync conflict'**
  String get cloudSyncConflict;

  /// No description provided for @closeCloudSyncConflict.
  ///
  /// In en, this message translates to:
  /// **'Close cloud sync conflict'**
  String get closeCloudSyncConflict;

  /// No description provided for @closeVersionComparison.
  ///
  /// In en, this message translates to:
  /// **'Close version comparison'**
  String get closeVersionComparison;

  /// No description provided for @cloudConflictSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The vault file on this device differs from the one in the cloud.'**
  String get cloudConflictSubtitle;

  /// No description provided for @useThisDevicesVersion.
  ///
  /// In en, this message translates to:
  /// **'Use this device\'s version'**
  String get useThisDevicesVersion;

  /// No description provided for @useCloudVersion.
  ///
  /// In en, this message translates to:
  /// **'Use cloud version'**
  String get useCloudVersion;

  /// No description provided for @keepBothVersions.
  ///
  /// In en, this message translates to:
  /// **'Keep both versions'**
  String get keepBothVersions;

  /// No description provided for @cloudNewOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'New on this device'**
  String get cloudNewOnThisDevice;

  /// No description provided for @cloudAvailableInCloud.
  ///
  /// In en, this message translates to:
  /// **'Available in cloud'**
  String get cloudAvailableInCloud;

  /// No description provided for @cloudDifferentVersions.
  ///
  /// In en, this message translates to:
  /// **'Different versions'**
  String get cloudDifferentVersions;

  /// No description provided for @chooseVersionToInspect.
  ///
  /// In en, this message translates to:
  /// **'Choose which version you want to inspect.'**
  String get chooseVersionToInspect;

  /// No description provided for @enterMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password.'**
  String get enterMasterPassword;

  /// No description provided for @cloudVaultDecryptPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'The cloud vault could not be decrypted. Check the master password and try again.'**
  String get cloudVaultDecryptPasswordFailed;

  /// No description provided for @confirmMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm master password'**
  String get confirmMasterPassword;

  /// No description provided for @cloudVaultMasterPasswordReason.
  ///
  /// In en, this message translates to:
  /// **'This cloud vault was created separately, so the app needs your master password once to compare it with this device.'**
  String get cloudVaultMasterPasswordReason;

  /// No description provided for @unlockCloudVault.
  ///
  /// In en, this message translates to:
  /// **'Unlock cloud vault'**
  String get unlockCloudVault;

  /// No description provided for @cloudVaultDecryptFailed.
  ///
  /// In en, this message translates to:
  /// **'The cloud vault could not be decrypted.'**
  String get cloudVaultDecryptFailed;

  /// No description provided for @cloudMergedVaultSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save merged vault.'**
  String get cloudMergedVaultSaveFailed;

  /// No description provided for @cloudUploadAfterLocalSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved locally, but cloud upload failed.'**
  String get cloudUploadAfterLocalSaveFailed;

  /// No description provided for @cloudSyncChangesApplied.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync changes applied.'**
  String get cloudSyncChangesApplied;

  /// No description provided for @cloudApplySelectedChangesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not apply selected changes.'**
  String get cloudApplySelectedChangesFailed;

  /// No description provided for @checkingCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Checking cloud sync'**
  String get checkingCloudSync;

  /// No description provided for @checkingCloudSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while the encrypted vault is compared.'**
  String get checkingCloudSyncSubtitle;

  /// No description provided for @cloudSyncPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is paused'**
  String get cloudSyncPausedTitle;

  /// No description provided for @resolveSyncIssueBeforeUpload.
  ///
  /// In en, this message translates to:
  /// **'Resolve the sync issue before changes can upload again.'**
  String get resolveSyncIssueBeforeUpload;

  /// No description provided for @cloudSyncNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync needs attention'**
  String get cloudSyncNeedsAttention;

  /// No description provided for @cloudSyncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is up to date'**
  String get cloudSyncUpToDate;

  /// No description provided for @noCloudSyncIssuesFound.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync issues were found.'**
  String get noCloudSyncIssuesFound;

  /// No description provided for @cloudReviewChanges.
  ///
  /// In en, this message translates to:
  /// **'Review changes'**
  String get cloudReviewChanges;

  /// No description provided for @cloudAllChangesReviewed.
  ///
  /// In en, this message translates to:
  /// **'All changes have been reviewed.'**
  String get cloudAllChangesReviewed;

  /// No description provided for @cloudReviewDifferenceCount.
  ///
  /// In en, this message translates to:
  /// **'Review {undecidedCount} of {totalCount, plural, =1{1 difference} other{{totalCount} differences}}.'**
  String cloudReviewDifferenceCount(int undecidedCount, int totalCount);

  /// No description provided for @cloudApplyingChanges.
  ///
  /// In en, this message translates to:
  /// **'Applying changes...'**
  String get cloudApplyingChanges;

  /// No description provided for @cloudApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get cloudApplyChanges;

  /// No description provided for @cloudSelectForAll.
  ///
  /// In en, this message translates to:
  /// **'Select for all:'**
  String get cloudSelectForAll;

  /// No description provided for @cloudKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep local'**
  String get cloudKeepLocal;

  /// No description provided for @cloudKeepCloud.
  ///
  /// In en, this message translates to:
  /// **'Keep cloud'**
  String get cloudKeepCloud;

  /// No description provided for @cloudUploadToCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload to cloud'**
  String get cloudUploadToCloud;

  /// No description provided for @cloudDeleteCloud.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud'**
  String get cloudDeleteCloud;

  /// No description provided for @cloudDeleteLocal.
  ///
  /// In en, this message translates to:
  /// **'Delete local'**
  String get cloudDeleteLocal;

  /// No description provided for @cloudImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get cloudImport;

  /// No description provided for @cloudUseCloud.
  ///
  /// In en, this message translates to:
  /// **'Use cloud'**
  String get cloudUseCloud;

  /// No description provided for @cloudOnlyLocalDescription.
  ///
  /// In en, this message translates to:
  /// **'This entry exists only on this device.'**
  String get cloudOnlyLocalDescription;

  /// No description provided for @cloudOnlyCloudDescription.
  ///
  /// In en, this message translates to:
  /// **'This entry exists only in your cloud vault.'**
  String get cloudOnlyCloudDescription;

  /// No description provided for @cloudOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get cloudOnThisDevice;

  /// No description provided for @cloudInCloud.
  ///
  /// In en, this message translates to:
  /// **'In cloud'**
  String get cloudInCloud;

  /// No description provided for @cloudFieldOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'{field} on this device'**
  String cloudFieldOnThisDevice(Object field);

  /// No description provided for @cloudFieldInCloud.
  ///
  /// In en, this message translates to:
  /// **'{field} in cloud'**
  String cloudFieldInCloud(Object field);

  /// No description provided for @cloudChangedFieldsFallback.
  ///
  /// In en, this message translates to:
  /// **'This entry has different local and cloud versions.'**
  String get cloudChangedFieldsFallback;

  /// No description provided for @cloudChangedFieldsList.
  ///
  /// In en, this message translates to:
  /// **'Changes: {fields}'**
  String cloudChangedFieldsList(Object fields);

  /// No description provided for @cloudChangedFieldsListWithMore.
  ///
  /// In en, this message translates to:
  /// **'Changes: {fields} +{count} more'**
  String cloudChangedFieldsListWithMore(Object fields, int count);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get titleRequired;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @cloneEntry.
  ///
  /// In en, this message translates to:
  /// **'Clone entry'**
  String get cloneEntry;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @createEntry.
  ///
  /// In en, this message translates to:
  /// **'Create entry'**
  String get createEntry;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved.'**
  String get entrySaved;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted.'**
  String get entryDeleted;

  /// No description provided for @entryMarkedAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Entry marked as favorite.'**
  String get entryMarkedAsFavorite;

  /// No description provided for @entryRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Entry removed from favorites.'**
  String get entryRemovedFromFavorites;

  /// No description provided for @failedToSaveEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to save entry.'**
  String get failedToSaveEntry;

  /// No description provided for @failedToDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete entry.'**
  String get failedToDeleteEntry;

  /// No description provided for @failedToUpdateEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to update entry.'**
  String get failedToUpdateEntry;

  /// No description provided for @deleteEntryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryDialogTitle;

  /// No description provided for @deleteEntryDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" for \"{username}\"?\n\nThis action cannot be undone.'**
  String deleteEntryDialogContent(Object title, Object username);

  /// No description provided for @closeFolderForm.
  ///
  /// In en, this message translates to:
  /// **'Close folder form'**
  String get closeFolderForm;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entries;

  /// No description provided for @noEntriesAvailableToAddToFolder.
  ///
  /// In en, this message translates to:
  /// **'No entries available to add to folder.'**
  String get noEntriesAvailableToAddToFolder;

  /// No description provided for @folderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created.'**
  String get folderCreated;

  /// No description provided for @failedToCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to create folder.'**
  String get failedToCreateFolder;

  /// No description provided for @createNewFolder.
  ///
  /// In en, this message translates to:
  /// **'Create new folder'**
  String get createNewFolder;

  /// No description provided for @customFolders.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get customFolders;

  /// No description provided for @noCustomFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No created folders yet.'**
  String get noCustomFoldersYet;

  /// No description provided for @detectedFolders.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detectedFolders;

  /// No description provided for @noDetectedFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No detected folders yet.'**
  String get noDetectedFoldersYet;

  /// No description provided for @thisFolderIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty.'**
  String get thisFolderIsEmpty;

  /// No description provided for @noEntriesInThisFolder.
  ///
  /// In en, this message translates to:
  /// **'No entries in this folder.'**
  String get noEntriesInThisFolder;

  /// No description provided for @folderSourceInfo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 entries} =1{1 entry} other{{count} entries}} - {source}'**
  String folderSourceInfo(int count, Object source);

  /// No description provided for @detectedFolderSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get detectedFolderSourceTitle;

  /// No description provided for @detectedFolderSourceUsername.
  ///
  /// In en, this message translates to:
  /// **'Same username'**
  String get detectedFolderSourceUsername;

  /// No description provided for @detectedFolderSourceUrlHost.
  ///
  /// In en, this message translates to:
  /// **'Same website'**
  String get detectedFolderSourceUrlHost;

  /// No description provided for @durationMinutesAndSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}} and {seconds, plural, =1{1 second} other{{seconds} seconds}}'**
  String durationMinutesAndSeconds(int minutes, int seconds);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String durationMinutes(int minutes);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{1 second} other{{seconds} seconds}}'**
  String durationSeconds(int seconds);

  /// No description provided for @authCouldNotCreateVault.
  ///
  /// In en, this message translates to:
  /// **'Could not create vault.'**
  String get authCouldNotCreateVault;

  /// No description provided for @authTooManyPinAttemptsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Too many PIN attempts. Try again in {duration}.'**
  String authTooManyPinAttemptsTryAgain(Object duration);

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password.'**
  String get authWrongPassword;

  /// No description provided for @authVaultIsLocked.
  ///
  /// In en, this message translates to:
  /// **'Vault is locked.'**
  String get authVaultIsLocked;

  /// No description provided for @authCouldNotSaveDatabase.
  ///
  /// In en, this message translates to:
  /// **'Could not save database.'**
  String get authCouldNotSaveDatabase;

  /// No description provided for @authUseAtLeast12CharactersForPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 12 characters for the password.'**
  String get authUseAtLeast12CharactersForPassword;

  /// No description provided for @authCurrentPasswordIncorrectOrVaultDamaged.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect or vault file is damaged.'**
  String get authCurrentPasswordIncorrectOrVaultDamaged;

  /// No description provided for @authUseAtLeast4DigitsForPin.
  ///
  /// In en, this message translates to:
  /// **'Use at least 4 digits for the PIN.'**
  String get authUseAtLeast4DigitsForPin;

  /// No description provided for @authPinMustContainOnlyNumbers.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain only numbers.'**
  String get authPinMustContainOnlyNumbers;

  /// No description provided for @authCouldNotEnableQuickUnlock.
  ///
  /// In en, this message translates to:
  /// **'Could not enable quick unlock.'**
  String get authCouldNotEnableQuickUnlock;

  /// No description provided for @authTooManyPinAttemptsWaitThenUseMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Too many PIN attempts. Wait {duration}, then use your master password.'**
  String authTooManyPinAttemptsWaitThenUseMasterPassword(Object duration);

  /// No description provided for @authQuickUnlockDisabledUseMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Quick unlock is disabled. Use your master password.'**
  String get authQuickUnlockDisabledUseMasterPassword;

  /// No description provided for @authWrongPinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again in {duration}.'**
  String authWrongPinTryAgain(Object duration);

  /// No description provided for @authWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN.'**
  String get authWrongPin;

  /// No description provided for @confirmDeviceAuthForQuickUnlock.
  ///
  /// In en, this message translates to:
  /// **'Confirm your device unlock to use quick unlock.'**
  String get confirmDeviceAuthForQuickUnlock;

  /// No description provided for @authLocalAuthenticationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Device authentication is not available.'**
  String get authLocalAuthenticationUnavailable;

  /// No description provided for @authLocalAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Device authentication failed or was cancelled.'**
  String get authLocalAuthenticationFailed;

  /// No description provided for @cloudMessageSyncDisabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync disabled.'**
  String get cloudMessageSyncDisabled;

  /// No description provided for @cloudMessageSyncPaused.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is paused.'**
  String get cloudMessageSyncPaused;

  /// No description provided for @cloudMessageOneDriveConnectedNoVault.
  ///
  /// In en, this message translates to:
  /// **'OneDrive connected, but no vault file was found.'**
  String get cloudMessageOneDriveConnectedNoVault;

  /// No description provided for @cloudMessageUploadedToOneDrive.
  ///
  /// In en, this message translates to:
  /// **'Uploaded encrypted vault to OneDrive.'**
  String get cloudMessageUploadedToOneDrive;

  /// No description provided for @cloudMessageDownloadedFromOneDrive.
  ///
  /// In en, this message translates to:
  /// **'Downloaded encrypted vault from OneDrive.'**
  String get cloudMessageDownloadedFromOneDrive;

  /// No description provided for @cloudMessageAlreadyInSync.
  ///
  /// In en, this message translates to:
  /// **'Vault is already in sync.'**
  String get cloudMessageAlreadyInSync;

  /// No description provided for @cloudMessageVaultsDiffer.
  ///
  /// In en, this message translates to:
  /// **'Local and OneDrive vault files differ.'**
  String get cloudMessageVaultsDiffer;

  /// No description provided for @cloudMessageSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Microsoft sign-in canceled.'**
  String get cloudMessageSignInCanceled;

  /// No description provided for @cloudMessageEnableOneDriveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable OneDrive sync.'**
  String get cloudMessageEnableOneDriveFailed;

  /// No description provided for @cloudMessageSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed.'**
  String get cloudMessageSyncFailed;

  /// No description provided for @cloudMessageUploadedLocalConflict.
  ///
  /// In en, this message translates to:
  /// **'Uploaded this device\'s vault to OneDrive.'**
  String get cloudMessageUploadedLocalConflict;

  /// No description provided for @cloudMessageDownloadedCloudConflict.
  ///
  /// In en, this message translates to:
  /// **'Downloaded OneDrive vault to this device.'**
  String get cloudMessageDownloadedCloudConflict;

  /// No description provided for @cloudMessageKeptBothPaused.
  ///
  /// In en, this message translates to:
  /// **'Saved OneDrive vault as a separate file on this device. Sync is paused.'**
  String get cloudMessageKeptBothPaused;

  /// No description provided for @cloudMessageSaveConflictFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the cloud conflict copy.'**
  String get cloudMessageSaveConflictFailed;

  /// No description provided for @cloudMessageRemoteRollbackDetected.
  ///
  /// In en, this message translates to:
  /// **'Cloud vault changed unexpectedly. Sync has been paused to protect your local vault.'**
  String get cloudMessageRemoteRollbackDetected;

  /// No description provided for @debugNoVaultLoaded.
  ///
  /// In en, this message translates to:
  /// **'No vault loaded.'**
  String get debugNoVaultLoaded;

  /// No description provided for @debugTestEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'test entry'**
  String get debugTestEntryTitle;

  /// No description provided for @debugTestEntryUsername.
  ///
  /// In en, this message translates to:
  /// **'testuser'**
  String get debugTestEntryUsername;

  /// No description provided for @debugTestEntryPassword.
  ///
  /// In en, this message translates to:
  /// **'testpassword'**
  String get debugTestEntryPassword;

  /// No description provided for @debugTestEntryNotes.
  ///
  /// In en, this message translates to:
  /// **'test entry notes'**
  String get debugTestEntryNotes;

  /// No description provided for @debugSavedEntries.
  ///
  /// In en, this message translates to:
  /// **'Saved entries: {count}'**
  String debugSavedEntries(int count);

  /// No description provided for @debugSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed.'**
  String get debugSaveFailed;

  /// No description provided for @debugAddTestEntry.
  ///
  /// In en, this message translates to:
  /// **'Add test entry'**
  String get debugAddTestEntry;

  /// No description provided for @debugNoLocalVaultAndNoOneDriveVault.
  ///
  /// In en, this message translates to:
  /// **'No local vault and no OneDrive vault found.'**
  String get debugNoLocalVaultAndNoOneDriveVault;

  /// No description provided for @debugUploadedVaultToOneDrive.
  ///
  /// In en, this message translates to:
  /// **'Uploaded vault to OneDrive: {eTag}'**
  String debugUploadedVaultToOneDrive(Object eTag);

  /// No description provided for @debugErrorDuringOneDriveSync.
  ///
  /// In en, this message translates to:
  /// **'Error during OneDrive sync: {error}'**
  String debugErrorDuringOneDriveSync(Object error);

  /// No description provided for @debugTestOneDriveSync.
  ///
  /// In en, this message translates to:
  /// **'Test OneDrive sync'**
  String get debugTestOneDriveSync;

  /// No description provided for @debugTestMicrosoftSignOutAndReSignIn.
  ///
  /// In en, this message translates to:
  /// **'Test Microsoft sign-out and re-sign-in'**
  String get debugTestMicrosoftSignOutAndReSignIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
