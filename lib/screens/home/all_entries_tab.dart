import 'package:flutter/material.dart';
import "package:flutter/services.dart";

import "../../auth/auth_controller.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/section_card_lightweight.dart";
import "../../widgets/screen_popup.dart";
import "../../widgets/home/entry_actions.dart";

import "../../vault/password_database.dart";
import "../../l10n/app_localizations.dart";

enum _EntryPopupAction { edit, delete, clone }

class AllEntriesTab extends StatefulWidget {
  const AllEntriesTab({
    super.key,
    required this.authController,
    this.startInSearchMode = false,
    this.screenTitle,
    this.entryIds,
    this.emptyMessage,
  });

  final AuthController authController;
  final bool startInSearchMode;
  final String? screenTitle;
  final List<String>? entryIds;
  final String? emptyMessage;

  @override
  State<AllEntriesTab> createState() => _AllEntriesTabState();
}

class _AllEntriesTabState extends State<AllEntriesTab> {
  late bool _isSearching;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  AuthController get authController => widget.authController;

  @override
  void initState() {
    super.initState();

    _isSearching = widget.startInSearchMode;

    if (_isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });

    _searchFocusNode.unfocus();
  }

  bool _entryMatchesSearch(PasswordEntry entry, String query) {
    final terms = query
        .toLowerCase()
        .split(RegExp(r"\s+"))
        .where((term) => term.isNotEmpty);

    final searchableText = [
      entry.title,
      entry.username,
      entry.url,
      entry.notes,
    ].join(" ").toLowerCase();

    return terms.every(searchableText.contains);
  }

  List<PasswordEntry> _filterEntries(List<PasswordEntry> entries) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return entries;
    }

    return entries.where((entry) => _entryMatchesSearch(entry, query)).toList();
  }

  Future<void> _showEntryPopup(
    BuildContext context,
    PasswordEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final action = await showGeneralDialog<_EntryPopupAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeEntryDetails,
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
                    label: Text(l10n.edit),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(_EntryPopupAction.clone);
                    },
                    icon: const Icon(Icons.copy_sharp, size: 18),
                    label: Text(l10n.clone),
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
                    label: Text(l10n.delete),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _EntryDetail(label: l10n.username, value: entry.username),
            _EntrySecretDetail(label: l10n.password, value: entry.password),
            _EntryDetail(label: l10n.url, value: entry.url),
            _EntryDetail(label: l10n.notes, value: entry.notes),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case _EntryPopupAction.edit:
        final savedEntry = await EntryActions(
          authController: authController,
        ).openEntryForm(context, entry: entry);

        if (savedEntry != null && context.mounted) {
          await _showEntryPopup(context, savedEntry);
        }
        return;
      case _EntryPopupAction.delete:
        final success = await EntryActions(
          authController: authController,
        ).deleteEntry(context, entry: entry);

        if (!context.mounted) {
          return;
        }
        if (!success) {
          await _showEntryPopup(context, entry);
        }
        return;
      case _EntryPopupAction.clone:
        final savedEntry = await EntryActions(
          authController: authController,
        ).openEntryForm(context, entry: entry, clone: true);

        if (savedEntry != null && context.mounted) {
          await _showEntryPopup(context, savedEntry);
        }
        return;
      case null:
        return;
    }
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onChanged: (_) {
        setState(() {});
      },

      decoration: InputDecoration(
        hintText: l10n.searchEntries,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.trim().isEmpty
            ? null
            : IconButton(
                tooltip: l10n.clearSearch,
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });

                  _searchFocusNode.requestFocus();
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final database = authController.database;

        final allEntries = database?.entries ?? const <PasswordEntry>[];
        final entryIdFilter = widget.entryIds?.toSet();

        final entries = entryIdFilter == null
            ? allEntries
            : allEntries
                  .where((entry) => entryIdFilter.contains(entry.id))
                  .toList();

        final visibleEntries = _filterEntries(entries);
        final isFiltering = _searchController.text.trim().isNotEmpty;
        final entryActions = EntryActions(authController: authController);
        return Scaffold(
          body: SafeArea(
            child: ScreenFrame(
              title: widget.screenTitle ?? l10n.allEntries,
              enableReturnButton: true,
              returnButtonAction: () {
                Navigator.of(context).pop();
              },
              headerActions: [
                IconButton(
                  tooltip: l10n.addEntry,
                  onPressed: () {
                    entryActions.openEntryForm(context);
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
                IconButton(
                  tooltip: _isSearching
                      ? l10n.closeSearch
                      : l10n.searchForEntry,
                  onPressed: _isSearching ? _closeSearch : _openSearch,
                  icon: _isSearching
                      ? const Icon(Icons.close_rounded)
                      : const Icon(Icons.search_rounded),
                ),
              ],
              children: [
                if (_isSearching) ...[
                  _buildSearchField(l10n),
                  const SizedBox(height: 12),
                ],
                if (entries.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        widget.emptyMessage ?? l10n.noEntriesFound,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (visibleEntries.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        isFiltering
                            ? l10n.noEntriesMatchSearch
                            : l10n.noEntriesFound,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SectionCard(
                    children: [
                      ...visibleEntries.asMap().entries.map((e) {
                        final i = e.key;
                        final entry = e.value;
                        final isLast = i == visibleEntries.length - 1;

                        return SectionCardLightweight(
                          title: entry.title,
                          subtitle: entry.username,
                          icon: Icons.key_rounded,
                          border: isLast
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.14),
                                  ),
                                ),
                          action: () {
                            _showEntryPopup(context, entry);
                          },
                          additionalActionIconButton: IconButton(
                            tooltip: entry.isFavorite
                                ? l10n.removeFromFavorites
                                : l10n.addToFavorites,
                            onPressed: () {
                              entryActions.toggleFavorite(
                                context,
                                entry: entry,
                              );
                            },
                            icon: Icon(
                              entry.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                            ),
                          ),
                          contextMenuItems: [
                            SectionCardMenuItem(
                              label: l10n.edit,
                              icon: Icons.edit_rounded,
                              isDestructive: false,
                              onSelected: () {
                                entryActions.openEntryForm(
                                  context,
                                  entry: entry,
                                );
                              },
                            ),
                            SectionCardMenuItem(
                              label: l10n.delete,
                              icon: Icons.delete_rounded,
                              isDestructive: true,
                              onSelected: () {
                                entryActions.deleteEntry(context, entry: entry);
                              },
                            ),
                          ],
                        );
                      }),
                    ],
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
    final l10n = AppLocalizations.of(context)!;
    final displayValue = value.trim().isEmpty ? l10n.notSet : value;

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
                tooltip: l10n.copyLabel(label),
                onPressed: value.trim().isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: value));

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.labelCopied(label))),
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
  const _EntrySecretDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_EntrySecretDetail> createState() => _EntrySecretDetailState();
}

class _EntrySecretDetailState extends State<_EntrySecretDetail> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasValue = widget.value.trim().isNotEmpty;
    final displayValue = hasValue
        ? _obscureText
              ? "•" * widget.value.length
              : widget.value
        : l10n.notSet;

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
                    ? l10n.showLabel(widget.label)
                    : l10n.hideLabel(widget.label),

                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },

                icon: Icon(
                  _obscureText
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 18,
                ),
              ),

              IconButton(
                tooltip: l10n.copyLabel(widget.label),
                onPressed: hasValue
                    ? () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.value),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.labelCopied(widget.label)),
                          ),
                        );
                      }
                    : null,
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
