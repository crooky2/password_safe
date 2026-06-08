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

import "../cloud/cloud_controller.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.cloudController,
    required this.onOpenCloudScreen,
  });

  final AuthController authController;
  final CloudController cloudController;
  final VoidCallback onOpenCloudScreen;

  Color _cloudStatusColor(ColorScheme colorScheme) {
    if (cloudController.syncHeld || cloudController.hasPendingConflict) {
      return colorScheme.error;
    }

    if (cloudController.message == CloudMessage.syncFailed) {
      return Colors.orange.shade700;
    }

    if (cloudController.mode == CloudSyncMode.disabled) {
      return colorScheme.outline;
    }

    return Colors.green.shade600;
  }

  Widget _buildCloudStatusButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _cloudStatusColor(colorScheme);

    return statusColor == colorScheme.outline
        ? const SizedBox.shrink()
        : Material(
            elevation: 4,
            child: IconButton(
              tooltip: "Cloud Sync",
              onPressed: onOpenCloudScreen,
              icon: Icon(Icons.cloud_rounded, color: statusColor),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: authController,
          builder: (context, _) {
            final l10n = AppLocalizations.of(context)!;
            final entryActions = EntryActions(authController: authController);
            final entries =
                authController.database?.entries ?? const <PasswordEntry>[];
            final favoriteEntries = entries
                .where((entry) => entry.isFavorite)
                .toList();
            final customFolderCount =
                authController.database?.folders.length ?? 0;
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
                        builder: (_) =>
                            FoldersTab(authController: authController),
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
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.14),
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
                              entryActions.toggleFavorite(
                                context,
                                entry: entry,
                              );
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
        ),

        Positioned(
          left: 6,
          bottom: 6,
          child: AnimatedBuilder(
            animation: cloudController,
            builder: (context, _) {
              return _buildCloudStatusButton(context);
            },
          ),
        ),
      ],
    );
  }
}
