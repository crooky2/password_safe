import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../l10n/app_localizations.dart";
import "../../security/timed_clipboard.dart";

import "../../vault/password_generator.dart";

import "../screen_popup.dart";

class PasswordGeneratorPopup extends StatefulWidget {
  const PasswordGeneratorPopup({super.key});

  @override
  State<PasswordGeneratorPopup> createState() => _PasswordGeneratorPopupState();
}

class _PasswordGeneratorPopupState extends State<PasswordGeneratorPopup> {
  final PasswordGenerator _generator = PasswordGenerator();

  late final TextEditingController _lengthController;
  late String _password;

  int _length = 12;
  bool _includeLetters = true;
  bool _includeUppercase = true;
  bool _includeSpecial = true;
  bool _includeNumbers = true;

  bool get _hasCharacterSet =>
      _includeLetters ||
      _includeUppercase ||
      _includeSpecial ||
      _includeNumbers;

  PasswordGeneratorOptions get _options => PasswordGeneratorOptions(
    length: _length,
    includeLetters: _includeLetters,
    includeUpperLetters: _includeUppercase,
    includeSpecialChars: _includeSpecial,
    includeNumbers: _includeNumbers,
  );

  @override
  void initState() {
    super.initState();
    _lengthController = TextEditingController(text: _length.toString());
    _password = _generator.generate(_options);
  }

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  void _regenerate() {
    _password = _generator.generate(_options);
  }

  void _setLength(int length, {bool updateTextField = true}) {
    setState(() {
      _length = length;
      if (updateTextField) {
        _lengthController.text = length.toString();
        _lengthController.selection = TextSelection.collapsed(
          offset: _lengthController.text.length,
        );
      }

      _regenerate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sliderValue = _length.clamp(2, 24).toDouble();
    final previewText = _hasCharacterSet
        ? _password
        : l10n.passwordGeneratorNoCharactersSelected;

    return ScreenPopup(
      title: l10n.passwordGenerator,
      maxWidth: 400,
      onClose: () => Navigator.of(context).pop(),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  previewText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: "monospace",
                    color: _hasCharacterSet
                        ? null
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.generatePassword,
                onPressed: _hasCharacterSet
                    ? () {
                        setState(() {
                          _regenerate();
                        });
                      }
                    : null,
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: l10n.copyLabel(l10n.password),
                onPressed: _hasCharacterSet
                    ? () async {
                        await TimedClipboard.copyText(_password);

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.labelCopied(l10n.password)),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.passwordGeneratorNormalCharacters),
          value: _includeLetters,
          onChanged: (value) => setState(() {
            _includeLetters = value;
            _regenerate();
          }),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.passwordGeneratorUppercaseCharacters),
          value: _includeUppercase,
          onChanged: (value) => setState(() {
            _includeUppercase = value;
            _regenerate();
          }),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.passwordGeneratorSpecialCharacters),
          value: _includeSpecial,
          onChanged: (value) => setState(() {
            _includeSpecial = value;
            _regenerate();
          }),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.passwordGeneratorNumbers),
          value: _includeNumbers,
          onChanged: (value) => setState(() {
            _includeNumbers = value;
            _regenerate();
          }),
        ),

        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 2,
                max: 24,
                divisions: 24,
                value: sliderValue,
                label: _length.toString(),
                onChanged: (value) => _setLength(value.round()),
              ),
            ),
            SizedBox(
              width: 84,
              child: TextField(
                controller: _lengthController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.passwordGeneratorLength,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed == null) {
                    return;
                  }

                  _setLength(parsed, updateTextField: false);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _password.isEmpty
              ? null
              : () => Navigator.of(context).pop(_password),
          icon: const Icon(Icons.check_rounded),
          label: Text(l10n.usePassword),
        ),
      ],
    );
  }
}
