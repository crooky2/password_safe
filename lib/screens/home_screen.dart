import 'package:flutter/material.dart';

import '../widgets/screen_frame.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Vault overview',
      enableSmallTitle: true,
      icon: Icons.dashboard_rounded,
      children: const [
        SectionCard(
          title: 'Quick status',
          subtitle:
              'Show the current vault state here later, such as synced, locked, or ready.',
          icon: Icons.shield_rounded,
        ),
        SectionCard(
          title: 'Recent activity',
          subtitle:
              'Reserve this area for recent changes, opened entries, or important alerts.',
          icon: Icons.history_rounded,
        ),
        SectionCard(
          title: 'Fast actions',
          subtitle:
              'This space can later host the main shortcuts without changing the app layout.',
          icon: Icons.flash_on_rounded,
        ),
      ],
    );
  }
}