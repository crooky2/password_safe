import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';
import '../widgets/section_card.dart';

import "../auth/auth_controller.dart";

import "home/all_entries_tab.dart";

import "../widgets/home/entry_actions.dart";


class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key, 
    required this.authController
  });

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final entryActions = EntryActions(authController: authController);
    
    return ScreenFrame(
      icon: Icons.dashboard_rounded,
      title: "Dashboard",
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
        SectionCard(
          title: 'All entries',
          icon: Icons.list_rounded,
          action: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AllEntriesTab(authController: authController),
              ),
            );
          },
        ),
        SectionCard(title: 'Favorites', icon: Icons.star_rounded),
        SectionCard(title: 'Folders', icon: Icons.folder_rounded),
      ],
    );
  }
}
