import "package:flutter/material.dart";

class ContextMenuCoordinator {
  static MenuController? _openMenu;

  static void open(MenuController controller, {Offset? position}) {
    if (_openMenu != controller) {
      _openMenu?.close();
    }

    _openMenu = controller;
    controller.open(position: position);
  }

  static void close(MenuController controller) {
    if (_openMenu == controller) {
      _openMenu = null;
    }

    controller.close();
  }

  static void closeOpenMenu() {
    _openMenu?.close();
    _openMenu = null;
  }
}