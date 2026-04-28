import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Zoom button position within the widget (top or bottom).
enum ModernZoomButtonPosition {
  top,
  bottom,
}

class ModernZoomButton extends StatefulWidget {
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final bool isEnabled;
  final VoidCallback onClick;
  final VoidCallback onRelease;
  final String iconResource;
  final ModernZoomButtonPosition position;
  final List<BoxShadow>? innerShadow;

  const ModernZoomButton({
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.onClick,
    required this.onRelease,
    required this.iconResource,
    required this.position,
    this.innerShadow,
    this.isEnabled = true,
    super.key,
  });

  @override
  State<ModernZoomButton> createState() => _ModernZoomButtonState();
}

class _ModernZoomButtonState extends State<ModernZoomButton> {
  bool isPressed = false;

  BorderRadius _getBorderRadius() {
    const radius = Radius.circular(10);
    switch (widget.position) {
      case ModernZoomButtonPosition.top:
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
        );
      case ModernZoomButtonPosition.bottom:
        return const BorderRadius.only(
          bottomLeft: radius,
          bottomRight: radius,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (widget.isEnabled) {
          setState(() {
            isPressed = true;
            widget.onClick();
          });
        }
      },
      onTapUp: (details) {
        setState(() {
          widget.onRelease();
          isPressed = false;
        });
      },
      onLongPressUp: () {
        setState(() {
          widget.onRelease();
          isPressed = false;
        });
      },
      onLongPressCancel: () {
        setState(() {
          widget.onRelease();
          isPressed = false;
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPressed
              ? widget.pressedBackgroundColor
              : widget.backgroundColor,
          borderRadius: _getBorderRadius(),
          boxShadow: widget.innerShadow,
        ),
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          widget.iconResource,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            widget.isEnabled
                ? widget.activeIconColor
                : widget.inactiveIconColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
