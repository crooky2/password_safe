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
    final password = _cloudMasterPasswordController.text;

    if (password.trim().isEmpty) {
      setState(() {
        _cloudMasterPasswordInputError = "Enter your master password.";
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
          const SnackBar(content: Text("Could not save merged vault.")),
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
          const SnackBar(
            content: Text("Saved locally, but cloud upload failed."),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cloud sync changes applied.")),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not apply selected changes.")),
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
    if (diff.type != CloudEntryDiffType.changed) {
      final entry = diff.localEntry ?? diff.cloudEntry!;

      await _openEntryDetails(context, entry, null);
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close version comparison",
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return ScreenPopup(
          title: diff.title,
          subtitle: "Choose which version you want to inspect.",
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
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close entry details",
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          enableReturnButton: true,
          title: "Cloud Sync",
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
                          title: "New on this device",
                          entries: diff.onlyLocal,
                          choices: _choices,
                          onChoiceChanged: _chooseEntry,
                          onOpenDetails: (diff) {
                            _openDiffDetails(context, diff);
                          },
                        ),
                        CloudDiffGroup(
                          title: "Available in cloud",
                          entries: diff.onlyCloud,
                          choices: _choices,
                          onChoiceChanged: _chooseEntry,
                          onOpenDetails: (diff) {
                            _openDiffDetails(context, diff);
                          },
                        ),
                        CloudDiffGroup(
                          title: "Different versions",
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
    final errorMessage = didRejectPassword
        ? "The cloud vault could not be decrypted. Check the master password and try again."
        : _cloudMasterPasswordInputError;

    return SectionCard(
      title: "Confirm master password",
      subtitle:
          "This cloud vault was created separately, so the app needs your master password once to compare it with this device.",
      icon: Icons.cloud_queue_rounded,
      borderColor: didRejectPassword ? theme.colorScheme.error : null,
      children: [
        SecretTextField(
          controller: _cloudMasterPasswordController,
          labelText: "Master password",
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
          label: const Text("Unlock cloud vault"),
        ),
      ],
    );
  }

  Widget _buildCloudDecryptError(BuildContext context) {
    return Text(
      "The cloud vault could not be decrypted.",
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }

  Widget _buildNoConflictStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cloud = widget.cloudController;
    final message = cloud.message;

    if (cloud.isBusy) {
      return const SectionCard(
        title: "Checking cloud sync",
        subtitle: "Please wait while the encrypted vault is compared.",
        icon: Icons.sync_rounded,
      );
    }

    if (cloud.syncHeld) {
      return SectionCard(
        title: "Cloud sync is paused",
        subtitle: message == null
            ? "Resolve the sync issue before changes can upload again."
            : l10n.cloudFeedback(message),
        icon: Icons.pause_circle_rounded,
        borderColor: Theme.of(context).colorScheme.error,
      );
    }

    if (_messageNeedsAttention(message)) {
      return SectionCard(
        title: "Cloud sync needs attention",
        subtitle: l10n.cloudFeedback(message!),
        icon: Icons.warning_amber_rounded,
        borderColor: Colors.orange.shade700,
        children: [
          OutlinedButton.icon(
            onPressed: cloud.isBusy ? null : cloud.syncNow,
            icon: const Icon(Icons.sync_rounded),
            label: const Text("Sync now"),
          ),
        ],
      );
    }

    return SectionCard(
      title: "Cloud sync is up to date",
      subtitle: message == null
          ? "No cloud sync issues were found."
          : l10n.cloudFeedback(message),
      icon: Icons.cloud_done_rounded,
      // borderColor: Colors.green.shade600,
    );
  }
}
