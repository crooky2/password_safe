import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.additionalActionIconButton,
    this.contextMenuItems,
    this.children = const [],
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? action;
  final IconButton? additionalActionIconButton;
  final List<PopupMenuEntry>? contextMenuItems;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = action != null;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasIcon = icon != null;
    final hasHeaderContent = hasTitle || hasSubtitle || hasIcon || isInteractive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHeaderContent)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (hasIcon) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (hasTitle || hasSubtitle)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasTitle)
                                Text(
                                  title!,
                                  style: (isInteractive
                                          ? theme.textTheme.titleLarge
                                          : hasSubtitle
                                              ? theme.textTheme.titleMedium
                                              : theme.textTheme.titleLarge)
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              if (hasSubtitle) ...[
                                if (hasTitle) const SizedBox(height: 6),
                                Text(
                                  subtitle!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (additionalActionIconButton != null) ...[
                        const SizedBox(width: 8),
                        additionalActionIconButton!,
                      ],
                      if (isInteractive) ...[
                        if (hasTitle || hasSubtitle || hasIcon)
                          const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                if (children.isNotEmpty) ...[
                  if (hasHeaderContent) const SizedBox(height: 16),
                  ...children,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
