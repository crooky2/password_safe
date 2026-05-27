import 'package:flutter/material.dart';

import "section_card.dart";

import "context_menu_coordinator.dart";

class SectionCardLightweight extends StatelessWidget {
  const SectionCardLightweight({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.additionalActionIconButton,
    this.border,
    this.contextMenuItems = const [],
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? action;
  final IconButton? additionalActionIconButton;
  final BoxBorder? border;
  final List<SectionCardMenuItem> contextMenuItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = action != null;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasIcon = icon != null;
    final hasContextMenu = contextMenuItems.isNotEmpty;
    final hasAdditionalAction = additionalActionIconButton != null;
    final menuController = MenuController();

    return MenuAnchor(
      controller: menuController,
      menuChildren: [
        for (final item in contextMenuItems)
          MenuItemButton(
            onPressed: () {
              ContextMenuCoordinator.close(menuController);
              item.onSelected();
            },
            leadingIcon: item.icon == null
                ? null
                : Icon(
                    item.icon,
                    color: item.isDestructive ? theme.colorScheme.error : null,
                  ),
            child: Text(
              item.label,
              style: item.isDestructive
                  ? TextStyle(color: theme.colorScheme.error)
                  : null,
            ),
          ),
      ],

      builder: (context, controller, child) {
        return Container(
          decoration: border != null ? BoxDecoration(border: border) : null,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: hasIcon ? Icon(icon) : null,
            title: hasTitle ? Text(title!) : null,
            subtitle: hasSubtitle ? Text(subtitle!) : null,
            trailing: hasAdditionalAction ? additionalActionIconButton : null,
            onTap: isInteractive
                ? () {
                    ContextMenuCoordinator.closeOpenMenu();
                    action!();
                  }
                : null,
            onLongPress: hasContextMenu
                ? () => ContextMenuCoordinator.open(controller)
                : null,
          ),
        );
      },
    );
  }
}
