import "package:flutter/material.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";

import "../../../l10n/app_localizations.dart";
import "../../../theme_controller.dart";
import "../../screen_popup.dart";
import "../../settings/settings_dropdown.dart";

class ThemeColorSetting extends StatelessWidget {
  const ThemeColorSetting({super.key, required this.themeController});

  final ThemeController themeController;

  Future<void> _pickColor(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedColor = await showGeneralDialog<Color>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.closeThemeColor,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _ThemeColorPopup(initialColor: themeController.customThemeColor);
      },
    );

    if (!context.mounted || selectedColor == null) return;

    themeController.setCustomThemeColor(selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsDropdown<ThemeColorMode>(
              title: l10n.themeColor,
              value: themeController.themeColorMode,
              options: [
                SettingsDropdownOption(
                  value: ThemeColorMode.defaultColor,
                  label: l10n.themeColorDefault,
                ),
                SettingsDropdownOption(
                  value: ThemeColorMode.custom,
                  label: l10n.themeColorCustom,
                ),
              ],
              onChanged: (mode) {
                if (mode == ThemeColorMode.defaultColor) {
                  themeController.setThemeColorMode(mode);
                } else {
                  _pickColor(context);
                }
              },
            ),

            if (themeController.themeColorMode == ThemeColorMode.custom) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _pickColor(context);
                  },
                  icon: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: themeController.customThemeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  label: Text(l10n.chooseThemeColor),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ThemeColorPopup extends StatefulWidget {
  const _ThemeColorPopup({required this.initialColor});

  final Color initialColor;

  @override
  State<_ThemeColorPopup> createState() => _ThemeColorPopupState();
}

class _ThemeColorPopupState extends State<_ThemeColorPopup> {
  late Color _draftColor;

  @override
  void initState() {
    super.initState();

    _draftColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenPopup(
      title: l10n.chooseThemeColor,
      icon: Icons.palette_rounded,
      maxWidth: 440,
      onClose: () {
        Navigator.of(context).pop();
      },
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return ColorPicker(
              pickerColor: _draftColor,
              onColorChanged: (color) {
                setState(() {
                  _draftColor = color;
                });
              },
              enableAlpha: false,
              hexInputBar: true,
              labelTypes: const [ColorLabelType.rgb],
              displayThumbColor: true,
              portraitOnly: true,
              colorPickerWidth: constraints.maxWidth,
              pickerAreaHeightPercent: 0.7,
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop<Color>(_draftColor);
              },
              child: Text(l10n.saveChanges),
            ),
          ],
        ),
      ],
    );
  }
}
