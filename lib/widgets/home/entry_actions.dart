import "package:flutter/material.dart";

import "../../auth/auth_controller.dart";

import "../../vault/password_database.dart";

import "popup_entry_form.dart";

class EntryActions {
  const EntryActions({
    required this.authController,
  });

  final AuthController authController;

  Future<PasswordEntry?> openEntryForm(
    BuildContext context, {
    PasswordEntry? entry,
    bool clone = false,
  }) async {
    final savedEntry = await showGeneralDialog<PasswordEntry>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close entry form",
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EntryFormPopup(entry: entry, clone: clone);
      },
    );

    if (savedEntry == null) {
      return null;
    }

    final database = authController.database;


    if (database == null) {
      if(!context.mounted) {
        return null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vault is locked.")),
      );
      return null;
    }

    final updatedDatabase = entry != null && !clone
        ? database.updateEntry(savedEntry)
        : database.addEntry(savedEntry);

    final success = await authController.saveDatabase(updatedDatabase);

    if (!context.mounted) {
      return null;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? "Failed to save entry."),
        ),
      );
      return null;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry saved.")),
    );

    return savedEntry;
  }

  Future<bool> deleteEntry(BuildContext context, {
    required PasswordEntry entry,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text ("Delete entry?"),
          content: Text('Delete "${entry.title}" for "${entry.username}"? \n\n This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text("Delete"),
            ),
          ]
        );
      }
    );
    if (confirmed != true) {
      return false;
    }

    final database = authController.database;

    if (database == null) {
      if(!context.mounted) {
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vault is locked.")),
      );
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
          content: Text(authController.errorMessage ?? "Failed to delete entry."),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry deleted.")),
    );
    return true;
  }

  Future<bool> toggleFavorite(BuildContext context, {
    required PasswordEntry entry,
  }) async {
    final database = authController.database;

    if (database == null) {
      return false;
    }

    final updatedEntry = entry.copyWith(
      isFavorite: !entry.isFavorite,
    );

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
                  ? "Entry marked as favorite."
                  : "Entry removed from favorites.")
              : authController.errorMessage ?? "Failed to update entry.",
        ),
      ),
    );
    return success;
  }
}