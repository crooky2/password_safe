import "../auth/auth_controller.dart";
import "../cloud/cloud_controller.dart";
import "../vault/folder_detector.dart";

import "app_localizations.dart";

extension LocalizedMessages on AppLocalizations {
  String durationLabel(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    if (minutes > 0 && seconds > 0) {
      return durationMinutesAndSeconds(minutes, seconds);
    }
    if (minutes > 0) {
      return durationMinutes(minutes);
    }
    return durationSeconds(seconds);
  }

  String authFeedback(AuthFeedbackMessage feedback) {
    final duration = feedback.duration == null
        ? null
        : durationLabel(feedback.duration!);

    return switch (feedback.message) {
      AuthMessage.couldNotCreateVault => authCouldNotCreateVault,
      AuthMessage.tooManyPinAttemptsTryAgain => authTooManyPinAttemptsTryAgain(
        duration ?? durationLabel(Duration.zero),
      ),
      AuthMessage.wrongPassword => authWrongPassword,
      AuthMessage.vaultIsLocked => authVaultIsLocked,
      AuthMessage.couldNotSaveDatabase => authCouldNotSaveDatabase,
      AuthMessage.useAtLeast12CharactersForPassword =>
        authUseAtLeast12CharactersForPassword,
      AuthMessage.currentPasswordIncorrectOrVaultDamaged =>
        authCurrentPasswordIncorrectOrVaultDamaged,
      AuthMessage.useAtLeast4DigitsForPin => authUseAtLeast4DigitsForPin,
      AuthMessage.pinMustContainOnlyNumbers => authPinMustContainOnlyNumbers,
      AuthMessage.couldNotEnableQuickUnlock => authCouldNotEnableQuickUnlock,
      AuthMessage.tooManyPinAttemptsWaitThenUseMasterPassword =>
        authTooManyPinAttemptsWaitThenUseMasterPassword(
          duration ?? durationLabel(Duration.zero),
        ),
      AuthMessage.quickUnlockDisabledUseMasterPassword =>
        authQuickUnlockDisabledUseMasterPassword,
      AuthMessage.wrongPinTryAgain => authWrongPinTryAgain(
        duration ?? durationLabel(Duration.zero),
      ),
      AuthMessage.wrongPin => authWrongPin,
    };
  }

  String cloudFeedback(CloudMessage message) {
    return switch (message) {
      CloudMessage.syncDisabled => cloudMessageSyncDisabled,
      CloudMessage.syncPaused => cloudMessageSyncPaused,
      CloudMessage.oneDriveConnectedNoVault =>
        cloudMessageOneDriveConnectedNoVault,
      CloudMessage.uploadedToOneDrive => cloudMessageUploadedToOneDrive,
      CloudMessage.downloadedFromOneDrive => cloudMessageDownloadedFromOneDrive,
      CloudMessage.alreadyInSync => cloudMessageAlreadyInSync,
      CloudMessage.vaultsDiffer => cloudMessageVaultsDiffer,
      CloudMessage.signInCanceled => cloudMessageSignInCanceled,
      CloudMessage.enableOneDriveFailed => cloudMessageEnableOneDriveFailed,
      CloudMessage.syncFailed => cloudMessageSyncFailed,
      CloudMessage.uploadedLocalConflict => cloudMessageUploadedLocalConflict,
      CloudMessage.downloadedCloudConflict =>
        cloudMessageDownloadedCloudConflict,
      CloudMessage.keptBothPaused => cloudMessageKeptBothPaused,
      CloudMessage.saveConflictFailed => cloudMessageSaveConflictFailed,
    };
  }

  String detectedFolderSourceLabel(DetectedFolderSource source) {
    return switch (source) {
      DetectedFolderSource.title => detectedFolderSourceTitle,
      DetectedFolderSource.usernameDomain => detectedFolderSourceUsernameDomain,
      DetectedFolderSource.urlHost => detectedFolderSourceUrlHost,
    };
  }
}
