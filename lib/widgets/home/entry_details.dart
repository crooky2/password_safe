import 'package:flutter/material.dart';

import "../../l10n/app_localizations.dart";

import "../../security/timed_clipboard.dart";

class EntryDetail extends StatelessWidget {
  const EntryDetail({super.key, required this.label, required this.value});

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
                        await TimedClipboard.copyText(value);

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

class EntrySecretDetail extends StatefulWidget {
  const EntrySecretDetail({
    super.key,
    required this.label,
    required this.value,
    this.showCopy = true,
  });

  final String label;
  final String value;
  final bool showCopy;

  @override
  State<EntrySecretDetail> createState() => EntrySecretDetailState();
}

class EntrySecretDetailState extends State<EntrySecretDetail> {
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

              if (widget.showCopy == true)
                IconButton(
                  tooltip: l10n.copyLabel(widget.label),
                  onPressed: hasValue
                      ? () async {
                          await TimedClipboard.copyText(widget.value);

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
