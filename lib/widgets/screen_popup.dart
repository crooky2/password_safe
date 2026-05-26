import 'package:flutter/material.dart';

class ScreenPopup extends StatelessWidget {
  const ScreenPopup({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.onClose,
    this.maxWidth = 640,
    this.maxHeightFactor = 0.9,
    this.barrierColor,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final VoidCallback? onClose;
  final double maxWidth;
  final double maxHeightFactor;
  final Color? barrierColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final keyboardInset = mediaQuery.viewInsets.bottom;

    final popupWidth = screenSize.width > maxWidth
        ? maxWidth
        : screenSize.width;
    final popupHeight = (screenSize.height - keyboardInset) * maxHeightFactor;

    final hasHeaderText =
        (title?.trim().isNotEmpty ?? false) ||
        (subtitle?.trim().isNotEmpty ?? false);

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: barrierColor ?? colorScheme.scrim.withValues(alpha: 0.55),
          ),
        ),
        AnimatedPadding(
          padding: EdgeInsets.only(bottom: keyboardInset),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: popupWidth,
                    maxHeight: popupHeight,
                  ),
                  child: Material(
                    color: colorScheme.surface,
                    elevation: 18,
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(28),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasHeaderText)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 22, 16, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (title != null &&
                                          title!.trim().isNotEmpty)
                                        Text(
                                          title!.trim(),
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      if (subtitle != null &&
                                          subtitle!.trim().isNotEmpty) ...[
                                        if (title != null &&
                                            title!.trim().isNotEmpty)
                                          const SizedBox(height: 6),
                                        Text(
                                          subtitle!.trim(),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                height: 1.35,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (onClose != null)
                                  IconButton(
                                    onPressed: onClose,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                              ],
                            ),
                          ),
                        if (hasHeaderText) const Divider(height: 1),
                        Flexible(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final child in children) ...[child],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
