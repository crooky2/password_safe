import "package:flutter/material.dart";

import "../../widgets/screen_frame.dart";

import "../../auth/auth_controller.dart";

import "../../vault/password_database.dart";

class DebugTab extends StatefulWidget {
  const DebugTab({super.key, required this.authController});

  final AuthController authController;

  @override
  State<DebugTab> createState() => _DebugTabState();
}

class _DebugTabState extends State<DebugTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: "Debug",
          enableReturnButton: true,
          returnButtonAction: () {
            Navigator.of(context).pop();
          },
          children: [
            FilledButton(
              onPressed: () async {
                final database = widget.authController.database;

                if (database == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No vault loaded.")),
                  );
                  return;
                }

                final newEntry = PasswordEntry(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  title: "test entry",
                  username: "testuser",
                  password: "testpassword",
                  notes: "test entry notes",
                );

                final updatedDatabase = database.addEntry(newEntry);

                final success = await widget.authController.saveDatabase(
                  updatedDatabase,
                );

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Saved entries: ${updatedDatabase.entries.length}'
                          : widget.authController.errorMessage ??
                                'Save failed.',
                    ),
                  ),
                );
              },
              child: const Text("Add test entry"),
            ),
          ],
        ),
      ),
    );
  }
}
