import 'package:flutter/material.dart';

import '../../util/rounded_corners.dart';
import 'map_widget_theme.dart';

class BaseMapControl extends StatefulWidget {
  const BaseMapControl({
    super.key,
    required this.theme,
    required this.child,
    required this.isEnabled,
    this.roundedCorners = const RoundedCorners.all(),
    this.onTap,
    this.onPress,
    this.onRelease,
  });

  final bool isEnabled;
  final RoundedCorners roundedCorners;
  final MapControlTheme theme;
  final Widget child;

  final VoidCallback? onTap;
  final VoidCallback? onPress;
  final VoidCallback? onRelease;

  @override
  State<BaseMapControl> createState() => _BaseMapControlState();
}

class _BaseMapControlState extends State<BaseMapControl> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (details) {
        if (widget.isEnabled) {
          setState(() {
            isPressed = true;
            widget.onPress?.call();
          });
        }
      },
      onTapUp: (details) {
        setState(() {
          widget.onRelease?.call();
          isPressed = false;
        });
      },
      onLongPressUp: () {
        setState(() {
          widget.onRelease?.call();
          isPressed = false;
        });
      },
      onLongPressCancel: () {
        setState(() {
          widget.onRelease?.call();
          isPressed = false;
        });
      },
      child: Container(
        width: widget.theme.size,
        height: widget.theme.size,
        decoration: BoxDecoration(
          color: isPressed ? widget.theme.surfacePressedColor : widget.theme.surfaceColor,
          boxShadow: widget.theme.shadows,
          borderRadius: BorderRadius.only(
            topLeft: widget.roundedCorners.topLeft ? Radius.circular(widget.theme.borderRadius) : Radius.zero,
            topRight: widget.roundedCorners.topRight ? Radius.circular(widget.theme.borderRadius) : Radius.zero,
            bottomLeft: widget.roundedCorners.bottomLeft ? Radius.circular(widget.theme.borderRadius) : Radius.zero,
            bottomRight: widget.roundedCorners.bottomRight ? Radius.circular(widget.theme.borderRadius) : Radius.zero,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class MapControlTheme extends MapWidgetTheme {
  final double size;
  final double borderRadius;

  final Color surfaceColor;
  final Color surfacePressedColor;

  final double iconSize;

  final Color iconDisabledColor;
  final Color iconInactiveColor;
  final Color iconActiveColor;

  final List<BoxShadow> shadows;

  const MapControlTheme({
    required this.size,
    required this.borderRadius,
    required this.surfaceColor,
    required this.surfacePressedColor,
    required this.iconSize,
    required this.iconDisabledColor,
    required this.iconInactiveColor,
    required this.iconActiveColor,
    required this.shadows,
  });

  /// Цветовая схема UI–элемента для светлого режима по умолчанию.
  static const MapControlTheme defaultLight = MapControlTheme(
    size: 44,
    borderRadius: 8,
    surfaceColor: Color(0xffffffff),
    surfacePressedColor: Color(0xffeeeeee),
    iconSize: 24,
    iconInactiveColor: Color(0xff4d4d4d),
    iconDisabledColor: Color(0xffcccccc),
    iconActiveColor: Color(0xff057ddf),
    shadows: [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 1,
      ),
      BoxShadow(
        color: Color(0x0D000000),
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const MapControlTheme defaultDark = MapControlTheme(
    size: 44,
    borderRadius: 8,
    surfaceColor: Color(0xff121212),
    surfacePressedColor: Color(0xff3C3C3C),
    iconSize: 24,
    iconInactiveColor: Color(0xffcccccc),
    iconDisabledColor: Color(0xff808080),
    iconActiveColor: Color(0xff70aee0),
    shadows: [
      BoxShadow(
        color: Color(0x14000000),
        offset: Offset(0, 1),
        blurRadius: 4,
      ),
      BoxShadow(
        color: Color(0x0A000000),
        spreadRadius: 0.5,
      ),
    ],
  );

  @override
  MapControlTheme copyWith({
    double? size,
    double? borderRadius,
    Color? surfaceColor,
    Color? surfacePressedColor,
    double? iconSize,
    Color? iconDisabledColor,
    Color? iconInactiveColor,
    Color? iconActiveColor,
    List<BoxShadow>? shadows,
  }) {
    return MapControlTheme(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      surfacePressedColor: surfacePressedColor ?? this.surfacePressedColor,
      iconSize: iconSize ?? this.iconSize,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
      shadows: shadows ?? this.shadows,
    );
  }
}
