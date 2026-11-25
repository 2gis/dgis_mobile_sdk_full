import 'package:flutter/cupertino.dart';

import '../common/rounded_corners.dart';
import 'navigation_map_control_theme.dart';

class BaseNavigationMapControl extends StatefulWidget {
  const BaseNavigationMapControl({
    required this.theme,
    required this.child,
    required this.isEnabled,
    this.roundedCorners = const RoundedCorners.all(),
    super.key,
    this.onTap,
    this.onPress,
    this.onRelease,
  });

  final bool isEnabled;
  final RoundedCorners roundedCorners;
  final NavigationMapControlTheme theme;
  final Widget child;

  final VoidCallback? onTap;
  final VoidCallback? onPress;
  final VoidCallback? onRelease;

  @override
  State<BaseNavigationMapControl> createState() =>
      _BaseNavigationMapControlState();
}

class _BaseNavigationMapControlState extends State<BaseNavigationMapControl> {
  late final _isPressedNotifier = ValueNotifier<bool>(false);

  static const _pressDuration = Duration(milliseconds: 10);

  static const _releaseDuration = Duration(milliseconds: 150);

  void _handlePress() {
    if (_isPressedNotifier.value) return;

    _isPressedNotifier.value = true;
    widget.onPress?.call();
  }

  void _handleRelease() {
    if (!_isPressedNotifier.value) return;

    _isPressedNotifier.value = false;
    widget.onRelease?.call();
  }

  @override
  void dispose() {
    _isPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: widget.roundedCorners.topLeft
          ? Radius.circular(widget.theme.borderRadius)
          : Radius.zero,
      topRight: widget.roundedCorners.topRight
          ? Radius.circular(widget.theme.borderRadius)
          : Radius.zero,
      bottomLeft: widget.roundedCorners.bottomLeft
          ? Radius.circular(widget.theme.borderRadius)
          : Radius.zero,
      bottomRight: widget.roundedCorners.bottomRight
          ? Radius.circular(widget.theme.borderRadius)
          : Radius.zero,
    );
    final isEnabled = widget.isEnabled;
    final theme = widget.theme;

    return SizedBox(
      width: theme.size,
      height: theme.size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled ? widget.onTap : null,
        onTapDown: isEnabled ? (_) => _handlePress() : null,
        onTapUp: isEnabled ? (_) => _handleRelease() : null,
        onTapCancel: isEnabled ? _handleRelease : null,
        child: ValueListenableBuilder(
          valueListenable: _isPressedNotifier,
          builder: (context, isPressed, child) {
            return AnimatedContainer(
              duration: isPressed ? _pressDuration : _releaseDuration,
              decoration: BoxDecoration(
                color: isPressed
                    ? theme.surfacePressedColor
                    : theme.surfaceColor,
                borderRadius: borderRadius,
                boxShadow: theme.shadows,
              ),
              alignment: Alignment.center,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
