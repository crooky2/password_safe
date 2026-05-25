import 'package:flutter/material.dart';
import "package:flutter/services.dart";

import "../../auth/auth_controller.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/screen_popup.dart";
import "../../widgets/home/entry_actions.dart";

import "../../vault/password_database.dart";

enum _EntryPopupAction { edit, delete, clone }

class AllEntriesTab extends StatelessWidget {
  const AllEntriesTab({super.key, required this.authController});

  final AuthController authController;

  

  Future<void> _showEntryPopup(
    BuildContext context,
    PasswordEntry entry,
  ) async {
    final action = await showGeneralDialog<_EntryPopupAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close entry details",
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScreenPopup(
          title: entry.title,
          onClose: () {
            Navigator.of(context).pop();
          },
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(_EntryPopupAction.edit);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(_EntryPopupAction.clone);
                    },
                    icon: const Icon(Icons.copy_sharp, size: 18),
                    label: const Text("Clone"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(_EntryPopupAction.delete);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text("Delete"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _EntryDetail(label: "Username", value: entry.username),
            _EntrySecretDetail(label: "Password", value: entry.password),
            _EntryDetail(label: "URL", value: entry.url),
            _EntryDetail(label: "Notes", value: entry.notes),
          ],
        );
      },
    );

    if (action == _EntryPopupAction.edit) {
      final savedEntry = await EntryActions(authController: authController)
          .openEntryForm(context, entry: entry);
      
      if (savedEntry != null && context.mounted) {
        await _showEntryPopup(context, savedEntry);
      }
    }

    if (action == _EntryPopupAction.delete) {
      bool success = await EntryActions(
        authController: authController,
      ).deleteEntry(context, entry: entry);

      if (!context.mounted) {
        return;
      }
      if (!success) {
        await _showEntryPopup(context, entry);
      }
    }

    if (action == _EntryPopupAction.clone) {
      final savedEntry = await EntryActions(authController: authController)
          .openEntryForm(context, entry: entry, clone: true);
      
      if (savedEntry != null && context.mounted) {
        await _showEntryPopup(context, savedEntry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final database = authController.database;
        final entries = database?.entries ?? const <PasswordEntry>[];
        final entryActions = EntryActions(authController: authController);
        return Scaffold(
          body: SafeArea(
            child: ScreenFrame(
              title: "All entries",
              enableReturnButton: true,
              returnButtonAction: () {
                Navigator.of(context).pop();
              },
              headerActions: [
                IconButton(
                  tooltip: "Add entry",
                  onPressed: () {
                    entryActions.openEntryForm(context);
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
                IconButton(
                  tooltip: "Search for entry",
                  onPressed: () {
                    // We will implement search here soon.
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
              children: [
                if (entries.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        "No entries found.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...entries.map(
                    (entry) => SectionCard(
                      title: entry.title,
                      subtitle: entry.username,
                      icon: Icons.key_rounded,
                      additionalActionIconButton: IconButton(
                        tooltip: entry.isFavorite
                          ? "Remove from favorites"
                          : "Add to favorites",
                        onPressed: () {
                          entryActions.toggleFavorite(context, entry: entry);
                        },
                        icon: Icon(
                          entry.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        ),
                      ),
                      contextMenuItems: [
                        SectionCardMenuItem(
                          label: "Clone",
                          icon: Icons.copy_rounded,
                          onSelected: () {
                            entryActions.openEntryForm(context, entry: entry, clone: true);
                          }
                        ),
                        SectionCardMenuItem(
                          label: "Delete",
                          icon: Icons.delete_rounded,
                          isDestructive: true,
                          onSelected: () {
                            entryActions.deleteEntry(context, entry: entry);
                          }
                        ),
                      ],
                      action: () {
                        _showEntryPopup(context, entry);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EntryDetail extends StatelessWidget {
  const _EntryDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? "Not set" : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),

          Row(
            children: [
              Expanded(child: SelectableText(displayValue)),
              IconButton(
                tooltip: "Copy $label",
                onPressed: value.trim().isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: value));

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$label copied.")),
                        );
                      },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }
}



class _EntrySecretDetail extends StatefulWidget {
  const _EntrySecretDetail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  State<_EntrySecretDetail> createState() => _EntrySecretDetailState();
}


class _EntrySecretDetailState extends State<_EntrySecretDetail> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value.trim().isNotEmpty;
    final displayValue = hasValue 
        ? _obscureText
            ? "•" * widget.value.length
            : widget.value
      : "Not set";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SelectableText(displayValue)),
              IconButton(
                tooltip: _obscureText 
                    ? "Show ${widget.label}" 
                    : "Hide ${widget.label}",

                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },

                icon: Icon(
                  _obscureText 
                      ? Icons.visibility_rounded 
                      : Icons.visibility_off_rounded, 
                  size: 18
                )
              ),

              IconButton(
                tooltip: "Copy ${widget.label}",
                onPressed: hasValue
                    ? () async {
                        await Clipboard.setData(ClipboardData(text: widget.value));

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${widget.label} copied.")),
                        );
                      }
                    : null,
                icon: const Icon(Icons.copy_rounded, size: 18),
              )
            ]
          ),
          const Divider(height: 1, thickness: 1),
        ]
      )
    );
  }
}