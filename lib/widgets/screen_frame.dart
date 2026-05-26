import 'package:flutter/material.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    this.title,
    this.subtitle,
    this.disableTitle = false,
    this.enableReturnButton = false,
    this.returnButtonAction,
    this.headerActions = const [],
    this.icon,
    required this.children,
  });

  final String? title;
  final String? subtitle;
  final bool enableReturnButton;
  final VoidCallback? returnButtonAction;
  final bool disableTitle;
  final List<Widget> headerActions;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleText = title?.trim();
    final subtitleText = subtitle?.trim();

    final hasTitle = titleText != null && titleText.isNotEmpty;
    final hasSubtitle = subtitleText != null && subtitleText.isNotEmpty;
    final hasText = hasTitle || hasSubtitle;
    final hasIcon = icon != null;
    final hasHeaderActions = headerActions.isNotEmpty;

    final showHeader = !disableTitle;

    const iconSize = 28.0;
    const returnButtonSize = iconSize;
    const headerPadding = 11.0;
    const headerRadius = 26.0;
    const titleGap = 16.0;
    const subtitleTopSpacing = 6.0;
    const headerBottomSpacing = 22.0;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxTitleWidth = constraints.maxWidth;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxTitleWidth,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 0),
                              padding: EdgeInsets.all(headerPadding),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    colorScheme.primary.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  headerRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.14,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: hasSubtitle
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                children: [
                                  if (enableReturnButton)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: hasIcon ? 6.0 : 0.0,
                                      ),
                                      child: SizedBox(
                                        width: returnButtonSize,
                                        height: returnButtonSize,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          visualDensity: VisualDensity.compact,
                                          icon: Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            size: returnButtonSize,
                                            color: colorScheme.onPrimary
                                                .withValues(alpha: 0.88),
                                          ),
                                          onPressed: returnButtonAction ?? () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ),
                                  if (hasIcon)
                                    Icon(
                                      icon,
                                      size: iconSize,
                                      color: colorScheme.onPrimary,
                                    ),
                                  if (hasText) ...[
                                    SizedBox(width: titleGap),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (hasTitle)
                                            Text(
                                              titleText,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme.onPrimary,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.4,
                                                  ),
                                            ),
                                          if (hasSubtitle) ...[
                                            if (hasTitle)
                                              SizedBox(
                                                height: subtitleTopSpacing,
                                              ),
                                            Text(
                                              subtitleText,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.onPrimary
                                                        .withValues(
                                                          alpha: 0.88,
                                                        ),
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (hasHeaderActions) ...[
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: headerActions,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: headerBottomSpacing),
        ],

        for (final child in children)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
      ],
    );
  }
}
