import 'package:flutter/material.dart';

import "../../auth/auth_controller.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/section_card_lightweight.dart";
import "../../widgets/home/entry_actions.dart";
import "../../widgets/home/popup_entry.dart";

import "../../vault/password_database.dart";
import "../../l10n/app_localizations.dart";

class AllEntriesTab extends StatefulWidget {
  const AllEntriesTab({
    super.key,
    required this.authController,
    this.startInSearchMode = false,
    this.screenTitle,
    this.folderId,
    this.entryIds,
    this.emptyMessage,
  }) : assert(folderId == null || entryIds == null);

  final AuthController authController;
  final bool startInSearchMode;
  final String? screenTitle;
  final String? folderId;
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

    final action = await showGeneralDialog<EntryDetailsPopupAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeEntryDetails,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EntryDetailsPopup(entry: entry);
      },
    );

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case EntryDetailsPopupAction.edit:
        final savedEntry = await EntryActions(
          authController: authController,
        ).openEntryForm(context, entry: entry);

        if (savedEntry != null && context.mounted) {
          await _showEntryPopup(context, savedEntry);
        }
        return;
      case EntryDetailsPopupAction.delete:
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
      case EntryDetailsPopupAction.clone:
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

        final PasswordFolder? currentFolder =
            widget.folderId == null || database == null
            ? null
            : database.folderById(widget.folderId!);

        final Set<String>? entryIdFilter;

        if (widget.folderId != null) {
          entryIdFilter = currentFolder?.entryIds.toSet() ?? <String>{};
        } else {
          entryIdFilter = widget.entryIds?.toSet();
        }

        final entries = entryIdFilter == null
            ? allEntries
            : allEntries
                  .where((entry) => entryIdFilter!.contains(entry.id))
                  .toList();

        final visibleEntries = _filterEntries(entries);
        final isFiltering = _searchController.text.trim().isNotEmpty;
        final entryActions = EntryActions(authController: authController);
        return Scaffold(
          body: SafeArea(
            child: ScreenFrame(
              title:
                  currentFolder?.name ?? widget.screenTitle ?? l10n.allEntries,
              enableReturnButton: true,
              returnButtonAction: () {
                Navigator.of(context).pop();
              },
              headerActions: [
                IconButton(
                  tooltip: l10n.addEntry,
                  onPressed: () {
                    entryActions.openEntryForm(
                      context,
                      initialFolderIds: currentFolder == null
                          ? const <String>{}
                          : <String>{currentFolder.id},
                    );
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
                              label: "addToFolder", // TODO: Localization
                              icon: Icons.move_to_inbox_rounded,
                              onSelected: () {
                                entryActions.manageFolders(
                                  context,
                                  entry: entry,
                                );
                              },
                            ),
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
