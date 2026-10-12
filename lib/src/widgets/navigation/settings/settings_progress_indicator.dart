import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'navigation_settings_theme.dart';

const _defaultSize = 24.0;
const _sweepDuration = Duration(milliseconds: 300);

/// Circular 0–100 progress arc.
class NavigationSettingsProgressIndicator extends StatelessWidget {
  /// Current progress, clamped to 0–100.
  final int progress;

  /// Navigation settings color tokens.
  final NavigationSettingsTheme theme;

  /// Arc color, or null to use [NavigationSettingsColors.primary].
  final Color? color;

  /// Width and height of the indicator.
  final double size;

  const NavigationSettingsProgressIndicator({
    required this.progress,
    required this.theme,
    this.color,
    this.size = _defaultSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? theme.colors.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0, 100) / 100),
      duration: _sweepDuration,
      builder: (context, value, _) => SizedBox.square(
        dimension: size,
        child: Transform.rotate(
          angle: math.pi,
          child: CircularProgressIndicator(
            value: value,
            backgroundColor: Colors.transparent,
            color: color,
            strokeWidth: size / 12,
            strokeCap: StrokeCap.butt,
            trackGap: 0,
            strokeAlign: CircularProgressIndicator.strokeAlignCenter,
            padding: EdgeInsets.zero,
            // Deprecated parameter, we specifically pass false, since this behavior
            // will be set after the default parameter is removed.
            // We immediately rely on the new behavior.
            // ignore: deprecated_member_use
            year2023: false,
          ),
        ),
      ),
    );
  }
}
