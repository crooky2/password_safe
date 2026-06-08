import "dart:typed_data";

import "package:flutter/material.dart";
import "package:password_safe/vault/password_database.dart";

import "../auth/auth_controller.dart";

import "../cloud/cloud_controller.dart";
import "../cloud/cloud_diff.dart";

import "../crypto/vault_file_validator.dart";
import "../crypto/vault_models.dart";

import "../vault/unlocked_vault.dart";

import "../l10n/app_localizations.dart";
import "../l10n/localized_messages.dart";

import "../widgets/section_card.dart";
import "../widgets/screen_frame.dart";
import "../widgets/secret_text_field.dart";
import "../widgets/home/popup_entry.dart";
import "../widgets/screen_popup.dart";
import "../widgets/cloud/review_summary.dart";
import "../widgets/cloud/diff_group.dart";
import "../widgets/cloud/changed_fields.dart";

class _CloudVaultNeedsMasterPasswordException implements Exception {
  const _CloudVaultNeedsMasterPasswordException();
}

class _CloudVaultMasterPasswordRejectedException implements Exception {
  const _CloudVaultMasterPasswordRejectedException();
}

class CloudScreen extends StatefulWidget {
  const CloudScreen({
    super.key,
    required this.authController,
    required this.cloudController,
  });

  final AuthController authController;
  final CloudController cloudController;

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  late Future<CloudDatabaseDiff?> _pendingDiffFuture;
  final TextEditingController _cloudMasterPasswordController =
      TextEditingController();
  final Map<String, CloudEntryChoice> _choices = {};

  CloudSyncConflict? _lastPendingConflict;
  PasswordDatabase? _lastLocalDatabase;
  String? _cloudMasterPasswordInputError;

  bool _isApplying = false;

  bool _messageNeedsAttention(CloudMessage? message) {
    return switch (message) {
      CloudMessage.syncFailed ||
      CloudMessage.signInCanceled ||
      CloudMessage.enableOneDriveFailed ||
      CloudMessage.saveConflictFailed ||
      CloudMessage.remoteRollbackDetected => true,
      _ => false,
    };
  }

  Future<CloudDatabaseDiff?> _loadPendingDiff({
    String? cloudMasterPassword,
  }) async {
    final conflict = widget.cloudController.pendingConflict;
    final unlockedVault = widget.authController.unlockedVault;
    final localDatabase = widget.authController.database;

    if (conflict == null || unlockedVault == null || localDatabase == null) {
      return null;
    }

    final cloudVaultFile = VaultFileValidator.parse(conflict.remoteText);

    final cloudVault = await _unlockCloud(
      cloudVaultFile,
      unlockedVault.vaultKey,
      cloudMasterPassword: cloudMasterPassword,
    );

    return CloudDatabaseDiff.compare(
      localDatabase: localDatabase,
      cloudDatabase: cloudVault.database,
    );
  }

  void _refreshPendingDiff() {
    if (_isApplying) {
      return;
    }

    final conflict = widget.cloudController.pendingConflict;
    final localDatabase = widget.authController.database;

    if (identical(conflict, _lastPendingConflict) &&
        identical(localDatabase, _lastLocalDatabase)) {
      return;
    }

    setState(() {
      _lastPendingConflict = conflict;
      _lastLocalDatabase = localDatabase;
      _choices.clear();
      _cloudMasterPasswordController.clear();
      _cloudMasterPasswordInputError = null;
      _pendingDiffFuture = _loadPendingDiff();
    });
  }

  Future<UnlockedVault> _unlockCloud(
    VaultFile cloudVaultFile,
    Uint8List localVaultKey, {
    String? cloudMasterPassword,
  }) async {
    final masterPassword =
        cloudMasterPassword ??
        widget.authController.currentSessionMasterPassword;

    try {
      return await widget.authController.unlocker.unlockWithVaultKey(
        vaultFile: cloudVaultFile,
        vaultKey: localVaultKey,
      );
    } catch (_) {
      if (masterPassword == null) {
        throw const _CloudVaultNeedsMasterPasswordException();
      }
    }

    try {
      return await widget.authController.unlocker.unlock(
        vaultFile: cloudVaultFile,
        masterPassword: masterPassword,
      );
    } catch (_) {
      if (cloudMasterPassword == null) {
        throw const _CloudVaultNeedsMasterPasswordException();
      }

      throw const _CloudVaultMasterPasswordRejectedException();
    }
  }

  void _submitCloudMasterPassword() {
    final l10n = AppLocalizations.of(context)!;
    final password = _cloudMasterPasswordController.text;

    if (password.trim().isEmpty) {
      setState(() {
        _cloudMasterPasswordInputError = l10n.enterMasterPassword;
      });
      return;
    }

    setState(() {
      _cloudMasterPasswordInputError = null;
      _pendingDiffFuture = _loadPendingDiff(cloudMasterPassword: password);
    });

    _cloudMasterPasswordController.clear();
  }

  void _chooseEntry(String entryId, CloudEntryChoice choice) {
    setState(() {
      _choices[entryId] = choice;
    });
  }

  void _chooseAllEntries(CloudDatabaseDiff diff, CloudEntryChoice choice) {
    setState(() {
      for (final entryDiff in diff.all) {
        _choices[entryDiff.id] = choice;
      }
    });
  }

  int _selectedChoiceCount() {
    return _choices.values
        .where((choice) => choice != CloudEntryChoice.undecided)
        .length;
  }

  Future<void> _applySelectedChanges(CloudDatabaseDiff diff) async {
    if (_isApplying) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isApplying = true;
    });

    try {
      final mergedDatabase = diff.mergeWithChoices(_choices);
      final saved = await widget.authController.saveDatabase(
        mergedDatabase,
        notifyDatabaseSaved: false,
      );

      if (!mounted) {
        return;
      }

      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cloudMergedVaultSaveFailed)),
        );
        return;
      }

      final uploaded = await widget.cloudController
          .uploadCurrentLocalVaultForConflict();

      if (!mounted) {
        return;
      }

      if (!uploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cloudUploadAfterLocalSaveFailed)),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cloudSyncChangesApplied)));

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cloudApplySelectedChangesFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  Future<void> _openDiffDetails(
    BuildContext context,
    CloudEntryDiff diff,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    if (diff.type != CloudEntryDiffType.changed) {
      final entry = diff.localEntry ?? diff.cloudEntry!;

      await _openEntryDetails(context, entry, null);
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeVersionComparison,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return ScreenPopup(
          title: diff.title,
          subtitle: l10n.chooseVersionToInspect,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
          children: [CloudChangedFields(diff: diff)],
        );
      },
    );
  }

  Future<void> _openEntryDetails(
    BuildContext context,
    PasswordEntry entry,
    String? titlePrefix,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeEntryDetails,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EntryDetailsPopup(
          entry: entry,
          showActions: false,
          titlePrefix: titlePrefix,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _lastPendingConflict = widget.cloudController.pendingConflict;
    _lastLocalDatabase = widget.authController.database;
    _pendingDiffFuture = _loadPendingDiff();

    widget.cloudController.addListener(_refreshPendingDiff);
    widget.authController.addListener(_refreshPendingDiff);
  }

  @override
  void dispose() {
    widget.cloudController.removeListener(_refreshPendingDiff);
    widget.authController.removeListener(_refreshPendingDiff);
    _cloudMasterPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          enableReturnButton: true,
          title: l10n.cloudSync,
          children: [
            AnimatedBuilder(
              animation: widget.cloudController,
              builder: (context, _) {
                if (!widget.cloudController.hasPendingConflict) {
                  return _buildNoConflictStatus(context);
                }

                return FutureBuilder<CloudDatabaseDiff?>(
                  future: _pendingDiffFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      final error = snapshot.error;

                      if (error is _CloudVaultNeedsMasterPasswordException ||
                          error is _CloudVaultMasterPasswordRejectedException) {
                        return _buildCloudMasterPasswordPrompt(
                          context,
                          didRejectPassword:
                              error
                                  is _CloudVaultMasterPasswordRejectedException,
                        );
                      }

                      return _buildCloudDecryptError(context);
                    }

                    final diff = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CloudReviewSummary(
                          diff: diff,
                          selectionCount: _selectedChoiceCount(),
                          isApplying: _isApplying,
                          onApply: () {
                            _applySelectedChanges(diff);
                          },
                          onSelectAll: (choice) {
                            _chooseAllEntries(diff, choice);
                          },
                        ),
                        CloudDiffGroup(
                          title: l10n.cloudNewOnThisDevice,
                          entries: diff.onlyLocal,
                          choices: _choices,
                          onChoiceChanged: _chooseEntry,
                          onOpenDetails: (diff) {
                            _openDiffDetails(context, diff);
                          },
                        ),
                        CloudDiffGroup(
                          title: l10n.cloudAvailableInCloud,
                          entries: diff.onlyCloud,
                          choices: _choices,
                          onChoiceChanged: _chooseEntry,
                          onOpenDetails: (diff) {
                            _openDiffDetails(context, diff);
                          },
                        ),
                        CloudDiffGroup(
                          title: l10n.cloudDifferentVersions,
                          entries: diff.changed,
                          choices: _choices,
                          onChoiceChanged: _chooseEntry,
                          onOpenDetails: (diff) {
                            _openDiffDetails(context, diff);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudMasterPasswordPrompt(
    BuildContext context, {
    required bool didRejectPassword,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final errorMessage = didRejectPassword
        ? l10n.cloudVaultDecryptPasswordFailed
        : _cloudMasterPasswordInputError;

    return SectionCard(
      title: l10n.confirmMasterPassword,
      subtitle: l10n.cloudVaultMasterPasswordReason,
      icon: Icons.cloud_queue_rounded,
      borderColor: didRejectPassword ? theme.colorScheme.error : null,
      children: [
        SecretTextField(
          controller: _cloudMasterPasswordController,
          labelText: l10n.masterPassword,
          enableBorder: true,
          onSubmitted: (_) => _submitCloudMasterPassword(),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(errorMessage, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _submitCloudMasterPassword,
          icon: const Icon(Icons.lock_open_rounded),
          label: Text(l10n.unlockCloudVault),
        ),
      ],
    );
  }

  Widget _buildCloudDecryptError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.cloudVaultDecryptFailed,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }

  Widget _buildNoConflictStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cloud = widget.cloudController;
    final message = cloud.message;

    if (cloud.isBusy) {
      return SectionCard(
        title: l10n.checkingCloudSync,
        subtitle: l10n.checkingCloudSyncSubtitle,
        icon: Icons.sync_rounded,
      );
    }

    if (cloud.syncHeld) {
      return SectionCard(
        title: l10n.cloudSyncPausedTitle,
        subtitle: message == null
            ? l10n.resolveSyncIssueBeforeUpload
            : l10n.cloudFeedback(message),
        icon: Icons.pause_circle_rounded,
        borderColor: Theme.of(context).colorScheme.error,
      );
    }

    if (_messageNeedsAttention(message)) {
      return SectionCard(
        title: l10n.cloudSyncNeedsAttention,
        subtitle: l10n.cloudFeedback(message!),
        icon: Icons.warning_amber_rounded,
        borderColor: Colors.orange.shade700,
        children: [
          OutlinedButton.icon(
            onPressed: cloud.isBusy ? null : cloud.syncNow,
            icon: const Icon(Icons.sync_rounded),
            label: Text(l10n.syncNow),
          ),
        ],
      );
    }

    return SectionCard(
      title: l10n.cloudSyncUpToDate,
      subtitle: message == null
          ? l10n.noCloudSyncIssuesFound
          : l10n.cloudFeedback(message),
      icon: Icons.cloud_done_rounded,
      // borderColor: Colors.green.shade600,
    );
  }
}
