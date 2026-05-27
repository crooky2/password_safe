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
