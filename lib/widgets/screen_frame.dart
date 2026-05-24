import 'package:flutter/material.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    this.subtitle,
    this.enableSmallTitle = false,
    this.disableTitle = false,
    required this.icon,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final bool enableSmallTitle;
  final bool disableTitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final showHeader = !disableTitle;
    final hasSubtitle =
        showHeader && subtitle != null && subtitle!.trim().isNotEmpty;

    final headerPadding = enableSmallTitle ? 16.0 : 20.0;
    final headerRadius = enableSmallTitle ? 20.0 : 24.0;
    final iconPadding = enableSmallTitle ? 10.0 : 12.0;
    final iconRadius = enableSmallTitle ? 14.0 : 18.0;
    final iconSize = enableSmallTitle ? 24.0 : 28.0;
    final titleGap = enableSmallTitle ? 12.0 : 16.0;
    final subtitleTopSpacing = enableSmallTitle ? 6.0 : 8.0;
    final headerBottomSpacing = enableSmallTitle ? 16.0 : 20.0;
    final iconContainerSize = (iconPadding * 2) + iconSize;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (showHeader) ...[
          Container(
            padding: EdgeInsets.all(headerPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(headerRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: titleGap),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: iconContainerSize,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: (enableSmallTitle
                                    ? Theme.of(context).textTheme.titleLarge
                                    : Theme.of(context).textTheme.headlineSmall)
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      if (hasSubtitle) ...[
                        SizedBox(height: subtitleTopSpacing),
                        Text(
                          subtitle!,
                          style: (enableSmallTitle
                                  ? Theme.of(context).textTheme.bodySmall
                                  : Theme.of(context).textTheme.bodyMedium)
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: headerBottomSpacing),
        ],
        ...children,
      ],
    );
  }
}