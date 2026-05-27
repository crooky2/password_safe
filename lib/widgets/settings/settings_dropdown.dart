import "package:flutter/material.dart";

class SettingsDropdownOption<T> {
  const SettingsDropdownOption({required this.value, required this.label});

  final T value;
  final String label;
}

class SettingsDropdown<T> extends StatelessWidget {
  const SettingsDropdown({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<SettingsDropdownOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 16),
        DropdownButton<T>(
          value: value,
          onChanged: (newValue) {
            if (newValue == null) {
              return;
            }

            onChanged(newValue);
          },
          items: [
            for (final option in options)
              DropdownMenuItem<T>(
                value: option.value,
                child: Text(option.label),
              ),
          ],
        ),
      ],
    );
  }
}
