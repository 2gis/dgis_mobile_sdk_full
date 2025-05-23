import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import './speed_limit_controller.dart';
import './speed_limit_widget_theme.dart';

class SpeedLimitWidget
    extends ThemedMapControllingWidget<SpeedLimitWidgetTheme> {
  final SpeedLimitController controller;

  const SpeedLimitWidget({
    required this.controller,
    SpeedLimitWidgetTheme? light,
    SpeedLimitWidgetTheme? dark,
    super.key,
  }) : super(
          light: light ?? SpeedLimitWidgetTheme.defaultLight,
          dark: dark ?? SpeedLimitWidgetTheme.defaultDark,
        );

  // ignore: prefer_constructors_over_static_methods
  static SpeedLimitWidget defaultBuilder(SpeedLimitController controller) =>
      SpeedLimitWidget(
        controller: controller,
      );

  @override
  ThemedMapControllingWidgetState<SpeedLimitWidget, SpeedLimitWidgetTheme>
      createState() => _SpeedLimitWidgetState();
}

class _SpeedLimitWidgetState extends ThemedMapControllingWidgetState<
    SpeedLimitWidget, SpeedLimitWidgetTheme> {
  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.state,
      builder: (context, state, child) {
        final cameraIcon = state.cameraIcon();

        return Material(
          color: Colors.transparent,
          child: SizedBox(
            width: colorScheme.size,
            height: colorScheme.size,
            child: Stack(
              children: [
                Positioned(
                  right: (state.speedLimit != null && state.speedLimit != 0)
                      ? null
                      : 0,
                  bottom: (state.speedLimit != null && state.speedLimit != 0)
                      ? 0
                      : null,
                  left: (state.speedLimit != null && state.speedLimit != 0)
                      ? 0
                      : null,
                  child: SizedBox(
                    width: colorScheme.speedometerTheme.size,
                    height: colorScheme.speedometerTheme.size,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: colorScheme.speedometerTheme.size +
                          colorScheme.speedometerTheme.iconSize,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: colorScheme.speedometerTheme.size,
                            height: colorScheme.speedometerTheme.size,
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                  side: state.cameraProgressInfo != null
                                      ? BorderSide(
                                          width: colorScheme
                                              .cameraProgressTheme.thickness,
                                          color: colorScheme
                                              .cameraProgressTheme.surfaceColor,
                                          strokeAlign:
                                              BorderSide.strokeAlignCenter,
                                        )
                                      : BorderSide.none,
                                ),
                                color:
                                    colorScheme.speedometerTheme.surfaceColor,
                                shadows: colorScheme.speedometerTheme.shadows,
                              ),
                              child: Center(
                                child: Baseline(
                                  baselineType: TextBaseline.alphabetic,
                                  baseline: colorScheme
                                      .speedometerTheme.textStyle.fontSize!,
                                  child: Text(
                                    '${(state.currentSpeed ?? 0).floor()}',
                                    style:
                                        colorScheme.speedometerTheme.textStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (state.cameraProgressInfo != null &&
                              cameraIcon != null)
                            SizedBox(
                              width: colorScheme.speedometerTheme.size,
                              height: colorScheme.speedometerTheme.size,
                              child: CircularProgressIndicator(
                                color: state.exceeding
                                    ? colorScheme.cameraProgressTheme
                                        .progressExceededColor
                                    : colorScheme
                                        .cameraProgressTheme.progressColor,
                                value: state.cameraProgressInfo!.progress,
                              ),
                            ),
                          if (cameraIcon != null)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SvgPicture.asset(
                                cameraIcon,
                                fit: BoxFit.scaleDown,
                                width: colorScheme.speedometerTheme.iconSize,
                                height:
                                    colorScheme.speedometerTheme.iconSize * 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.speedLimit != null && state.speedLimit != 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: RepaintBoundary(
                      child: _PulsatingAnimationWidget(
                        shouldPulsate: state.exceeding,
                        child: SizedBox(
                          width: colorScheme.speedLimitTheme.size,
                          height: colorScheme.speedLimitTheme.size,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme
                                    .speedLimitTheme.exceededSurfaceColor,
                                width: colorScheme.speedLimitTheme.borderWidth,
                              ),
                              boxShadow: state.exceeding
                                  ? colorScheme.speedLimitTheme.exceededShadows
                                  : null,
                              color: state.exceeding
                                  ? colorScheme
                                      .speedLimitTheme.exceededSurfaceColor
                                  : colorScheme.speedLimitTheme.surfaceColor,
                            ),
                            child: Center(
                              child: Text(
                                '${state.speedLimit!.floor()}',
                                style: state.exceeding
                                    ? colorScheme
                                        .speedLimitTheme.exceededTextStyle
                                    : colorScheme.speedLimitTheme.textStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsatingAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool shouldPulsate;

  const _PulsatingAnimationWidget({
    required this.child,
    this.shouldPulsate = false,
  });

  @override
  State<_PulsatingAnimationWidget> createState() =>
      _PulsatingAnimationWidgetState();
}

class _PulsatingAnimationWidgetState extends State<_PulsatingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.shouldPulsate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_PulsatingAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulsate != oldWidget.shouldPulsate) {
      if (widget.shouldPulsate) {
        _controller.repeat();
      } else {
        _controller
          ..stop()
          ..reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
