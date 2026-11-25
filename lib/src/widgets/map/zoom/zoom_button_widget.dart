import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'zoom_widget.dart';

/// Zoom button position within the widget (top or bottom).
enum ZoomButtonPosition {
  top,
  bottom,
}

class ZoomButton extends StatefulWidget {
  final ZoomWidgetColorScheme colorScheme;
  final bool isEnabled;
  final VoidCallback onClick;
  final VoidCallback onRelease;
  final String iconResource;
  final ZoomButtonPosition position;
  final List<BoxShadow>? innerShadow;

  const ZoomButton({
    required this.colorScheme,
    required this.onClick,
    required this.onRelease,
    required this.iconResource,
    required this.position,
    this.innerShadow,
    this.isEnabled = true,
    super.key,
  });

  @override
  State<ZoomButton> createState() => _ZoomButtonState();
}

class _ZoomButtonState extends State<ZoomButton> {
  late final _isPressedNotifier = ValueNotifier(false);

  static const _pressDuration = Duration(milliseconds: 10);

  static const _releaseDuration = Duration(milliseconds: 150);

  void _handlePress() {
    if (_isPressedNotifier.value) return;

    _isPressedNotifier.value = true;
    widget.onClick.call();
  }

  void _handleRelease() {
    if (!_isPressedNotifier.value) return;

    _isPressedNotifier.value = false;
    widget.onRelease.call();
  }

  BorderRadius _getBorderRadius() {
    const radius = Radius.circular(10);
    switch (widget.position) {
      case ZoomButtonPosition.top:
        return const BorderRadius.only(topLeft: radius, topRight: radius);
      case ZoomButtonPosition.bottom:
        return const BorderRadius.only(bottomLeft: radius, bottomRight: radius);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;
    final theme = widget.colorScheme;

    return SizedBox(
      width: 44,
      height: 44,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled ? (_) => _handlePress() : null,
        onTapUp: isEnabled ? (_) => _handleRelease() : null,
        onTapCancel: isEnabled ? _handleRelease : null,
        child: ValueListenableBuilder(
          valueListenable: _isPressedNotifier,
          builder: (context, isPressed, child) {
            return AnimatedContainer(
              duration: isPressed ? _pressDuration : _releaseDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isPressed
                    ? theme.pressedBackgroundColor
                    : theme.backgroundColor,
                borderRadius: _getBorderRadius(),
                boxShadow: theme.shadows,
              ),
              alignment: Alignment.center,
              child: Center(
                child: SvgPicture.asset(
                  widget.iconResource,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    widget.isEnabled
                        ? theme.activeIconColor
                        : theme.inactiveIconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
