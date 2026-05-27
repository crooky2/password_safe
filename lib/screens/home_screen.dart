import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';
import '../widgets/section_card.dart';
import "../widgets/section_card_lightweight.dart";

import "../auth/auth_controller.dart";

import "home/all_entries_tab.dart";
import "home/folders_tab.dart";

import "../widgets/home/entry_actions.dart";

import "../vault/password_database.dart";
import "../vault/folder_detector.dart";
import "../l10n/app_localizations.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final entryActions = EntryActions(authController: authController);
        final entries =
            authController.database?.entries ?? const <PasswordEntry>[];
        final favoriteEntries = entries
            .where((entry) => entry.isFavorite)
            .toList();
        final customFolderCount = authController.database?.folders.length ?? 0;
        final detectedFolderCount = detectFolders(entries).length;

        return ScreenFrame(
          icon: Icons.dashboard_rounded,
          title: l10n.dashboard,
          headerActions: [
            IconButton(
              tooltip: l10n.addEntry,
              onPressed: () {
                entryActions.openEntryForm(context);
              },
              icon: const Icon(Icons.add_rounded),
            ),
            IconButton(
              tooltip: l10n.searchForEntry,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AllEntriesTab(
                      authController: authController,
                      startInSearchMode: true,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ],
          children: [
            SectionCard(
              title: l10n.allEntries,
              subtitle: l10n.entryCount(entries.length),
              icon: Icons.list_rounded,
              action: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AllEntriesTab(authController: authController),
                  ),
                );
              },
            ),

            SectionCard(
              title: l10n.folders,
              subtitle: l10n.homeScreenFoldersInfo(
                customFolderCount,
                detectedFolderCount,
              ),
              icon: Icons.folder_rounded,
              action: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FoldersTab(authController: authController),
                  ),
                );
              },
            ),
            SectionCard(
              title: l10n.favorites,
              icon: Icons.star_rounded,
              children: [
                for (final entry in favoriteEntries)
                  SectionCardLightweight(
                    title: entry.title,
                    subtitle: entry.username.trim().isEmpty
                        ? null
                        : entry.username,
                    icon: Icons.key_rounded,
                    border: entry.id == favoriteEntries.last.id
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.14),
                            ),
                          ),
                    action: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AllEntriesTab(authController: authController),
                        ),
                      );
                    },
                    contextMenuItems: [
                      SectionCardMenuItem(
                        label: l10n.unfavorite,
                        icon: Icons.star_outline_rounded,
                        isDestructive: true,
                        onSelected: () {
                          entryActions.toggleFavorite(context, entry: entry);
                        },
                      ),
                      SectionCardMenuItem(
                        label: l10n.edit,
                        icon: Icons.edit_rounded,
                        onSelected: () {
                          entryActions.openEntryForm(context, entry: entry);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
