import 'dart:async';

import 'package:flutter/widgets.dart';

import 'navigation_settings_theme.dart';

/// Inset of the label and of the stepper against the row edges.
const _horizontalPadding = 16.0;

/// Gap between the value readout and the stepper.
const _valueGap = 16.0;

const _stepperWidth = 80.0;
const _stepperHeight = 32.0;
const _stepperRadius = Radius.circular(16);

/// Hairline between the two halves of the stepper.
const _dividerWidth = 1.0;
const _dividerHeight = 20.0;

const _glyphExtent = 14.0;
const _glyphStroke = 1.5;

/// Delay before a held button starts repeating, then the repeat period.
const _repeatDelay = Duration(milliseconds: 400);
const _repeatInterval = Duration(milliseconds: 80);

/// Label, value readout and a minus/plus stepper for a numeric setting.
///
/// The row renders state and reports intent — it neither steps nor clamps.
/// Pass null to [onDecrement] or [onIncrement] to show that half as disabled,
/// which is how a value sitting at its bound is communicated.
///
/// Holding a button repeats it, so a long range stays reachable.
///
/// ```dart
/// NavigationSettingsStepperRow(
///   label: 'Длина, м',
///   value: '3,8',
///   onDecrement: () => setLength(length - 100),
///   onIncrement: () => setLength(length + 100),
///   theme: theme,
/// )
/// ```
class NavigationSettingsStepperRow extends StatelessWidget {
  /// Descriptive text shown at the leading edge, unit included.
  final String label;

  /// Formatted current value, shown between the label and the stepper.
  final String value;

  /// Called for every press and repeat of the minus button.
  ///
  /// Null renders the button disabled and stops it reacting.
  final VoidCallback? onDecrement;

  /// Called for every press and repeat of the plus button.
  ///
  /// Null renders the button disabled and stops it reacting.
  final VoidCallback? onIncrement;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  const NavigationSettingsStepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = theme.typography.settingLabel.copyWith(
      color: theme.colors.settingLabel,
    );

    // Both halves expose their own tap semantics; annotating the row with
    // increase/decrease actions as well would need the next formatted value,
    // which only the caller knows.
    return Semantics(
      label: label,
      value: value,
      child: SizedBox(
        height: navigationSettingsRowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(value, style: labelStyle),
              const SizedBox(width: _valueGap),
              _Stepper(
                onDecrement: onDecrement,
                onIncrement: onIncrement,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final NavigationSettingsTheme theme;

  const _Stepper({
    required this.onDecrement,
    required this.onIncrement,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.segmentedTrack,
          borderRadius: const BorderRadius.all(_stepperRadius),
        ),
        child: SizedBox(
          width: _stepperWidth,
          height: _stepperHeight,
          child: Row(
            children: [
              Expanded(
                child: _StepperButton(
                  isIncrement: false,
                  onPressed: onDecrement,
                  theme: theme,
                ),
              ),
              SizedBox(
                width: _dividerWidth,
                height: _dividerHeight,
                child: ColoredBox(color: theme.colors.divider),
              ),
              Expanded(
                child: _StepperButton(
                  isIncrement: true,
                  onPressed: onIncrement,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      );
}

class _StepperButton extends StatefulWidget {
  final bool isIncrement;
  final VoidCallback? onPressed;
  final NavigationSettingsTheme theme;

  const _StepperButton({
    required this.isIncrement,
    required this.onPressed,
    required this.theme,
  });

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  Timer? _repeat;

  @override
  void didUpdateWidget(_StepperButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) {
      _stopRepeating();
    }
  }

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  void _startRepeating() {
    _stopRepeating();
    _repeat = Timer(_repeatDelay, () {
      _repeat = Timer.periodic(_repeatInterval, (_) {
        final onPressed = widget.onPressed;
        if (onPressed == null) {
          _stopRepeating();
          return;
        }
        onPressed();
      });
    });
  }

  void _stopRepeating() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed;
    final colors = widget.theme.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      onTapDown: onPressed == null ? null : (_) => _startRepeating(),
      onTapUp: (_) => _stopRepeating(),
      onTapCancel: _stopRepeating,
      child: Center(
        child: CustomPaint(
          size: const Size.square(_glyphExtent),
          painter: _StepperGlyph(
            color: onPressed == null ? colors.disabled : colors.settingLabel,
            isPlus: widget.isIncrement,
          ),
        ),
      ),
    );
  }
}

class _StepperGlyph extends CustomPainter {
  final Color color;
  final bool isPlus;

  const _StepperGlyph({required this.color, required this.isPlus});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _glyphStroke
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);

    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      paint,
    );
    if (isPlus) {
      canvas.drawLine(
        Offset(center.dx, 0),
        Offset(center.dx, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StepperGlyph oldDelegate) =>
      color != oldDelegate.color || isPlus != oldDelegate.isPlus;
}
