import "package:flutter/material.dart";
import "package:flutter/foundation.dart";

import "../../../auth/auth_controller.dart";

import "../../../vault/password_database.dart";
import "../../../l10n/app_localizations.dart";
import "../../../l10n/localized_messages.dart";

import "../folder/popup_folder_picker.dart";

import "entry_details_popup.dart";
import "entry_edit_popup.dart";

class EntryActions {
  const EntryActions({required this.authController});

  final AuthController authController;

  Future<void> popupEntryDetails(
    BuildContext context, {
    required PasswordEntry entry,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final action = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeEntryDetails,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return EntryDetailsPopup(entry: entry);
      },
    );

    if (!context.mounted) return;

    switch (action) {
      case EntryDetailsPopupAction.edit:
        final savedEntry = await popupEntryEdit(context, entry: entry);

        if (context.mounted && authController.database != null) {
          await popupEntryDetails(context, entry: savedEntry ?? entry);
        }
        return;

      case EntryDetailsPopupAction.delete:
        final success = await deleteEntry(context, entry: entry);

        if (!success && context.mounted) {
          await popupEntryDetails(context, entry: entry);
        }
        return;

      case EntryDetailsPopupAction.clone:
        final savedEntry = await popupEntryEdit(
          context,
          entry: entry,
          clone: true,
        );

        if (savedEntry != null && context.mounted) {
          await popupEntryDetails(context, entry: savedEntry);
        }
        return;

      case null:
        return;
    }
  }

  Future<PasswordEntry?> popupEntryEdit(
    BuildContext context, {
    PasswordEntry? entry,
    bool clone = false,
    Set<String> initialFolderIds = const <String>{},
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final initialDatabase = authController.database;

    if (initialDatabase == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authVaultIsLocked)));
      return null;
    }

    final startingFolderIds = <String>{
      if (entry != null) ...initialDatabase.folderIdsForEntry(entry.id),

      ...initialFolderIds,
    };

    final result = await showGeneralDialog<EntryFormResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeEntryForm,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EntryEditPopup(
          entry: entry,
          clone: clone,
          folders: initialDatabase.folders,
          initialFolderIds: startingFolderIds,
        );
      },
    );

    if (result == null) {
      return null;
    }

    final latestDatabase = authController.database;

    if (latestDatabase == null) {
      if (!context.mounted) {
        return null;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authVaultIsLocked)));
      return null;
    }

    var updatedDatabase = entry != null && !clone
        ? latestDatabase.updateEntry(result.entry)
        : latestDatabase.addEntry(result.entry);

    updatedDatabase = updatedDatabase.setEntryFolderMembership(
      entryId: result.entry.id,
      folderIds: result.folderIds,
    );

    final success = await authController.saveDatabase(updatedDatabase);

    if (!context.mounted) {
      return null;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage == null
                ? l10n.failedToSaveEntry
                : l10n.authFeedback(authController.errorMessage!),
          ),
        ),
      );
      return null;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.entrySaved)));

    return result.entry;
  }

  Future<bool> deleteEntry(
    BuildContext context, {
    required PasswordEntry entry,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteEntryDialogTitle),
          content: Text(
            l10n.deleteEntryDialogContent(entry.title, entry.username),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return false;
    }

    final database = authController.database;

    if (database == null) {
      if (!context.mounted) {
        return false;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authVaultIsLocked)));
      return false;
    }

    final updatedDatabase = database.removeEntry(entry.id);
    final success = await authController.saveDatabase(updatedDatabase);

    if (!context.mounted) {
      return false;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage == null
                ? l10n.failedToDeleteEntry
                : l10n.authFeedback(authController.errorMessage!),
          ),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.entryDeleted)));
    return true;
  }

  Future<bool> toggleFavorite(
    BuildContext context, {
    required PasswordEntry entry,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final database = authController.database;

    if (database == null) {
      return false;
    }

    final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);

    final updatedDatabase = database.updateEntry(updatedEntry);
    final success = await authController.saveDatabase(updatedDatabase);

    if (!context.mounted) {
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (updatedEntry.isFavorite
                    ? l10n.entryMarkedAsFavorite
                    : l10n.entryRemovedFromFavorites)
              : authController.errorMessage == null
              ? l10n.failedToUpdateEntry
              : l10n.authFeedback(authController.errorMessage!),
        ),
      ),
    );
    return success;
  }

  Future<bool> manageFolders(
    BuildContext context, {
    required PasswordEntry entry,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final database = authController.database;

    if (database == null) {
      return false;
    }

    final currentFolderIds = database.folderIdsForEntry(entry.id);
    final selectedFolderIds = await showFolderPickerPopup(
      context,
      folders: database.folders,
      initiallySelectedFolderIds: currentFolderIds,
    );

    if (selectedFolderIds == null || !context.mounted) {
      return false;
    }

    if (setEquals(selectedFolderIds, currentFolderIds)) {
      return true;
    }

    final latestDatabase = authController.database;

    if (latestDatabase == null) {
      return false;
    }

    final updatedDatabase = latestDatabase.setEntryFolderMembership(
      entryId: entry.id,
      folderIds: selectedFolderIds,
    );
    final success = await authController.saveDatabase(updatedDatabase);

    if (!context.mounted) {
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.folderMembershipUpdated : l10n.failedToUpdateFolders,
        ),
      ),
    );
    return success;
  }
}
