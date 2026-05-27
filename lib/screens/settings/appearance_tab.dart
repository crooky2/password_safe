import "package:flutter/material.dart";

import "../../theme_controller.dart";

import "../../widgets/screen_frame.dart";
import "../../widgets/section_card.dart";
import "../../widgets/settings/settings_dropdown.dart";

import "../../l10n/app_localizations.dart";

class AppearanceTab extends StatefulWidget {
  const AppearanceTab({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<AppearanceTab> createState() => _AppearanceTabState();
}

class _AppearanceTabState extends State<AppearanceTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScreenFrame(
          title: l10n.appearance,
          enableReturnButton: true,
          children: [
            SectionCard(
              children: [
                AnimatedBuilder(
                  animation: widget.themeController,
                  builder: (context, _) {
                    return SettingsDropdown<ThemeMode>(
                      title: l10n.theme,
                      value: widget.themeController.themeMode,
                      options: [
                        SettingsDropdownOption(
                          label: l10n.system,
                          value: ThemeMode.system,
                        ),
                        SettingsDropdownOption(
                          label: l10n.light,
                          value: ThemeMode.light,
                        ),
                        SettingsDropdownOption(
                          label: l10n.dark,
                          value: ThemeMode.dark,
                        ),
                      ],
                      onChanged: widget.themeController.setThemeMode,
                    );
                  },
                ),
                SettingsDropdown<AppLanguage>(
                    title: l10n.language,
                    value: widget.themeController.language,
                    options: [
                      SettingsDropdownOption(
                        label: l10n.systemLanguage,
                        value: AppLanguage.system,
                      ),
                      SettingsDropdownOption(
                        label: l10n.english,
                        value: AppLanguage.english,
                      ),
                      SettingsDropdownOption(
                        label: l10n.german,
                        value: AppLanguage.german,
                      ),
                    ],
                    onChanged: widget.themeController.setLanguage,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
