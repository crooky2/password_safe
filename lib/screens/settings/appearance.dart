import "package:flutter/material.dart";

import "../../theme_controller.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/settings/settings_dropdown.dart";


class AppearanceTab extends StatefulWidget {
  const AppearanceTab({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;

  @override
  State<AppearanceTab> createState() => _AppearanceTabState();
}

class _AppearanceTabState extends State<AppearanceTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: "Appearance",
          enableReturnButton: true,
          returnButtonAction: () {
            Navigator.of(context).pop();
          },
          children: [
            SectionCard(
              children: [
                AnimatedBuilder(
                  animation: widget.themeController,
                  builder: (context, _) {
                    return SettingsDropdown<ThemeMode>(
                      title: "Theme",
                      value: widget.themeController.themeMode,
                      options: const [
                        SettingsDropdownOption(
                          label: "System",
                          value: ThemeMode.system,
                        ),
                        SettingsDropdownOption(
                          label: "Light",
                          value: ThemeMode.light,
                        ),
                        SettingsDropdownOption(
                          label: "Dark",
                          value: ThemeMode.dark,
                        ),
                      ],
                      onChanged: widget.themeController.setThemeMode,
                    );
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
