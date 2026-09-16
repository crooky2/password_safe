import "package:flutter/material.dart";

import "dart:math" as math;

class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;
}

class SwipeActionCoordinator {
  static _SwipeActionOverlayState? _openOverlay;

  static bool _claim(_SwipeActionOverlayState overlay) {
    if (identical(_openOverlay, overlay)) {
      return false;
    }

    final previous = _openOverlay;
    _openOverlay = null;

    previous?._closeFromCoordinator();

    _openOverlay = overlay;
    return true;
  }

  static bool _owns(_SwipeActionOverlayState overlay) {
    return identical(_openOverlay, overlay);
  }

  static void _release(_SwipeActionOverlayState overlay) {
    if (identical(_openOverlay, overlay)) {
      _openOverlay = null;
    }
  }

  static void closeOpen() {
    final current = _openOverlay;
    _openOverlay = null;
    current?._closeFromCoordinator();
  }
}


class SwipeActionOverlay extends StatefulWidget {
  const SwipeActionOverlay({
    super.key,
    required this.actions,
    required this.child,
    this.panelColor,
    this.panelForegroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.onWillOpen,
  });

  final List<SwipeAction> actions;
  final Widget child;
  final Color? panelColor;
  final Color? panelForegroundColor;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback? onWillOpen;

  static void closeOpen() {
    SwipeActionCoordinator.closeOpen();
  }

  @override 
  State<SwipeActionOverlay> createState() => _SwipeActionOverlayState();
}

class _SwipeActionOverlayState extends State<SwipeActionOverlay> 
  with SingleTickerProviderStateMixin<SwipeActionOverlay> {
  
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _dragExtent = 96.0;
  static const double _fastSwipeVelocity = 450.0;
  static const double _actionWidth = 56.0;

  late final AnimationController _progress;

  double _dragDelta = 0.0;
  double _dragStartProgress = 0.0;
  bool _dragStartedOpen = false;
  bool _targetOpen = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    
    _progress = AnimationController(vsync: this, duration: _animationDuration);
  }

  @override
  void didUpdateWidget(covariant SwipeActionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.actions.isNotEmpty && widget.actions.isEmpty) {
      _settle(open: false, immediately: true);
    }
  }

  @override
  void dispose() {
    SwipeActionCoordinator._release(this);
    _progress.dispose();
    super.dispose();
  }

  void _claimCorrdinator() {
    final becameActive = SwipeActionCoordinator._claim(this);

    if (becameActive) {
      widget.onWillOpen?.call();
    }
  }

  void _settle({
    required bool open,
    bool immediately = false,
  }) {
    if (!mounted) {
      return;
    }

    _targetOpen = open;
    if (open) {
      _claimCorrdinator();
    } else {
      SwipeActionCoordinator._release(this);
    }

    final target = open ? 1.0 : 0.0;

    if (immediately) {
      _progress.value = target;
      return;
    }

    _progress.animateTo(target, curve: Curves.easeOutCubic);
  }

  void _closeFromCoordinator() {
    if (!mounted) {
      return;
    }

    _isDragging = false;
    _targetOpen = false;

    _progress.animateTo(0.0, curve: Curves.easeOutCubic);
  }

  void _onHorizontalDragStart(DragStartDetails _) {
    _progress.stop();

    _isDragging = true;
    _dragDelta = 0.0;
    _dragStartProgress = _progress.value;

    _dragStartedOpen = _targetOpen;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) {
      return;
    }

    _dragDelta += details.primaryDelta ?? 0.0;
    if (!_dragStartedOpen && _dragDelta < 0.0) {
      _claimCorrdinator();
    }

    final movement = _dragDelta / _dragExtent;
    final nextProgress = _dragStartProgress - movement;

    _progress.value = nextProgress.clamp(0.0, 1.0).toDouble();
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }

    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final isFastSwipe = velocity.abs() >= _fastSwipeVelocity;

    final bool shouldOpen;

    if (isFastSwipe && _dragDelta != 0.0) {
      shouldOpen = velocity < 0.0;
    } else {
      shouldOpen = _progress.value > 0.5;
    }

    _settle(open: shouldOpen);
  }

  void _onHorizontalDragCancel() {
    if (!_isDragging) {
      return;
    }

    _isDragging = false;
    _settle(open: _dragStartedOpen);
  }

  void _performAction(SwipeAction action) {
    _settle(open: false, immediately: true);
    action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) {
      return widget.child;
    }

    final colorScheme = Theme.of(context).colorScheme;

    final background =
        widget.panelColor ?? colorScheme.secondaryContainer;

    final foreground =
        widget.panelForegroundColor ?? colorScheme.onSecondaryContainer;

    return TapRegion(
      onTapOutside: (_) {
        if (_progress.value > 0.0 ||
          SwipeActionCoordinator._owns(this)) {
          _settle(open: false);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onHorizontalDragCancel: _onHorizontalDragCancel,

        child: LayoutBuilder(
          builder: (context, constraints) {
            final desiredWidth = widget.actions.length * _actionWidth;

            final availableWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : desiredWidth;

            final panelWidth = math.min<double>(
              desiredWidth,
              availableWidth,
            );

            return AnimatedBuilder(
              animation: _progress,
              child: widget.child,

              builder: (context, child) {
                final amount = _progress.value;
                final isRevealed = amount > 0.001;
                final actionsAreActive = amount >= 0.999;

                return ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 1.0 - (amount * 0.62),
                        child: ExcludeFocus(
                          excluding: isRevealed,
                          child: IgnorePointer(
                            ignoring: isRevealed,
                            child: child!,
                          ),
                        ),
                      ),

                      if (isRevealed)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            excludeFromSemantics: true,
                            onTap: () {
                              _settle(open: false);
                            },
                          ),
                        ),

                      PositionedDirectional(
                        top: 0.0,
                        bottom: 0.0,
                        end: -panelWidth * (1.0 - amount),
                        width: panelWidth,
                        child: Opacity(
                          opacity: amount,
                          child: IgnorePointer(
                            ignoring: !actionsAreActive,
                            child: ExcludeFocus(
                              excluding: !actionsAreActive,
                              child: ExcludeSemantics(
                                excluding: !actionsAreActive,
                                child: Material(
                                  color: background,
                                  borderRadius: widget.borderRadius,
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    children: [
                                      for (final action in widget.actions)
                                        Expanded(
                                          child: IconButton(
                                            tooltip: action.label,
                                            color: action.isDestructive
                                                ? colorScheme.error
                                                : foreground,
                                            onPressed: () {
                                              _performAction(action);
                                            },
                                            icon: Icon(action.icon),
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}