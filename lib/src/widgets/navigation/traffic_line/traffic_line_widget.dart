import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import './traffic_line_color_scheme.dart';
import './traffic_line_segments_colors.dart';
import 'traffic_line_controller.dart';

// Used for measure collision between tUGC icons and location indicator
const double _locationIndicatorMargin = 15;

class TrafficLineWidget
    extends ThemedMapControllingWidget<TrafficLineColorScheme> {
  final double height;
  final TrafficLineController controller;

  const TrafficLineWidget({
    required this.controller,
    this.height = 160,
    TrafficLineColorScheme? light,
    TrafficLineColorScheme? dark,
    super.key,
  }) : super(
          light: light ?? TrafficLineColorScheme.defaultLight,
          dark: dark ?? TrafficLineColorScheme.defaultDark,
        );

  // ignore: prefer_constructors_over_static_methods
  static TrafficLineWidget defaultBuilder(TrafficLineController controller) =>
      TrafficLineWidget(
        controller: controller,
      );

  @override
  ThemedMapControllingWidgetState<TrafficLineWidget, TrafficLineColorScheme>
      createState() => _TrafficLineWidgetState();
}

class _TrafficLineWidgetState extends ThemedMapControllingWidgetState<
    TrafficLineWidget, TrafficLineColorScheme> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: widget.height,
      child: ValueListenableBuilder(
        valueListenable: widget.controller.state,
        builder: (context, state, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceColor,
                ),
                alignment: Alignment.bottomCenter,
              ),
              Positioned(
                top: 4,
                bottom: 4,
                left: 4,
                right: 28,
                child: _TrafficLineSegments(
                  colorScheme: colorScheme.trafficLineSegmentsColors,
                  speedColors: state.speedColors,
                  routeLength: state.routeLength,
                  height: widget.height,
                ),
              ),
              _RoadEventsWidget(
                events: state.roadEvents,
                routeLength: state.routeLength,
                routeProgress: state.routeProgress,
                height: widget.height,
              ),
              Positioned(
                left: -4,
                bottom: widget.height * state.routeProgress -
                    _locationIndicatorMargin,
                child: _buildLocationIndicator(state.routeProgress),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationIndicator(double routeProgress) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: widget.height * (1 - routeProgress),
        end: widget.height * (1 - routeProgress),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colorScheme.locationIconBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: colorScheme.locationIconBoxShadows,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset(
            'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_location_icon.svg',
            colorFilter: ColorFilter.mode(
              colorScheme.locationIconColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      builder: (context, value, child) {
        return child!;
      },
    );
  }

  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}
}

class _TrafficLineSegments extends StatelessWidget {
  final List<sdk.TrafficSpeedColorRouteLongEntry> speedColors;
  final double routeLength;
  final double height;
  final TrafficLineSegmentsColors colorScheme;

  const _TrafficLineSegments({
    required this.speedColors,
    required this.routeLength,
    required this.height,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (routeLength == 0 || speedColors.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.undefined,
        ),
      );
    }

    return CustomPaint(
      size: Size(16, height),
      painter: _TrafficLinePainter(
        speedColors: speedColors,
        routeLength: routeLength,
        colorScheme: colorScheme,
      ),
    );
  }
}

class _TrafficLinePainter extends CustomPainter {
  final List<sdk.TrafficSpeedColorRouteLongEntry> speedColors;
  final double routeLength;
  final TrafficLineSegmentsColors colorScheme;
  static const double minSegmentSize = 2;
  static const double gradientTransitionHeight = 8;

  _TrafficLinePainter({
    required this.speedColors,
    required this.routeLength,
    required this.colorScheme,
  });

  Color _getColorForType(sdk.TrafficSpeedColor type) {
    switch (type) {
      case sdk.TrafficSpeedColor.undefined:
        return colorScheme.undefined;
      case sdk.TrafficSpeedColor.green:
        return colorScheme.green;
      case sdk.TrafficSpeedColor.yellow:
        return colorScheme.yellow;
      case sdk.TrafficSpeedColor.red:
        return colorScheme.red;
      case sdk.TrafficSpeedColor.deepRed:
        return colorScheme.deepRed;
      default:
        return colorScheme.undefined;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.clipRRect(rect);

    final sortedSegments = List<sdk.TrafficSpeedColorRouteLongEntry>.from(
      speedColors,
    )..sort(
        (a, b) => a.point.distance.millimeters
            .compareTo(b.point.distance.millimeters),
      );

    for (var i = 0; i < sortedSegments.length; i++) {
      final current = sortedSegments[i];
      final next = i < sortedSegments.length - 1 ? sortedSegments[i + 1] : null;

      final startPoint = current.point.distance.millimeters.toDouble();
      final endPoint = startPoint + current.length.millimeters.toDouble();

      final startY =
          (startPoint / routeLength * size.height).clamp(0.0, size.height - 1);
      var endY =
          (endPoint / routeLength * size.height).clamp(0.0, size.height - 1);

      if (endY - startY < minSegmentSize) {
        endY = startY + minSegmentSize;
      }

      final currentColor = _getColorForType(current.value);

      if (next != null) {
        final nextColor = _getColorForType(next.value);
        final transitionStart = endY - gradientTransitionHeight;

        paint
          ..shader = null
          ..color = currentColor;
        canvas.drawRect(
          Rect.fromLTRB(0, startY, size.width, transitionStart),
          paint,
        );

        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [currentColor, nextColor],
        ).createShader(
          Rect.fromLTRB(0, transitionStart, size.width, endY),
        );
        canvas.drawRect(
          Rect.fromLTRB(0, transitionStart, size.width, endY),
          paint,
        );
      } else {
        paint
          ..shader = null
          ..color = currentColor;
        canvas.drawRect(
          Rect.fromLTRB(0, startY, size.width, endY),
          paint,
        );
      }
    }

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = CupertinoColors.systemGrey3
      ..strokeWidth = 1;
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_TrafficLinePainter oldDelegate) {
    return oldDelegate.speedColors != speedColors ||
        oldDelegate.routeLength != routeLength;
  }
}

enum _RoadEventIcon {
  accidentLargeIcon(
    path:
        'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_accident.svg',
  ),
  accidentSmallIcon(
    path:
        'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_accident_small.svg',
  ),
  roadWorksLargeIcon(
    path:
        'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_road_works.svg',
  ),
  roadWorksSmallIcon(
    path:
        'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_road_works_small.svg',
  ),
  defaultLargeIcon(
    path:
        'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_large_icon.svg',
  ),
  defailtSmallIcon(
    path:
        'packages/$pluginName/assets/icons/navigation/dgis_traffic_line_small_icon.svg',
  );

  const _RoadEventIcon({required this.path});

  final String path;
}

class _RoadEventsWidget extends StatefulWidget {
  final List<sdk.RoadEventRouteEntry> events;
  final double routeLength;
  final double routeProgress;
  final double height;

  const _RoadEventsWidget({
    required this.events,
    required this.routeLength,
    required this.routeProgress,
    required this.height,
  });

  @override
  State<_RoadEventsWidget> createState() => _RoadEventsWidgetState();
}

class _RoadEventsWidgetState extends State<_RoadEventsWidget> {
  final Map<int, DateTime> eventFirstAppearance = {};
  final Map<String, PictureInfo> svgCache = {};

  @override
  void initState() {
    super.initState();
    _preloadSvgs();
  }

  Future<void> _preloadSvgs() async {
    final iconPaths = _RoadEventIcon.values.map((icon) => icon.path);

    for (final path in iconPaths) {
      try {
        final loader = SvgAssetLoader(path);
        final pictureInfo = await vg.loadPicture(loader, null);
        svgCache[path] = pictureInfo;
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        debugPrint('Error loading SVG $path: $e');
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final pictureInfo in svgCache.values) {
      pictureInfo.picture.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(40, widget.height),
      painter: _RoadEventsPainter(
        events: widget.events,
        routeLength: widget.routeLength,
        routeProgress: widget.routeProgress,
        eventFirstAppearance: eventFirstAppearance,
        currentTime: DateTime.now(),
        onEventFirstSeen: (eventId) {
          if (!eventFirstAppearance.containsKey(eventId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              eventFirstAppearance[eventId] = DateTime.now();
            });
          }
        },
        svgCache: svgCache,
      ),
    );
  }
}

class _RoadEventsPainter extends CustomPainter {
  final List<sdk.RoadEventRouteEntry> events;
  final double routeLength;
  final double routeProgress;
  final Map<int, DateTime> eventFirstAppearance;
  final DateTime currentTime;
  final Function(int eventId) onEventFirstSeen;
  final Map<String, PictureInfo> svgCache;

  static const double bigIconSize = 24;
  static const double smallIconSize = 16;
  static const Duration bigIconDuration = Duration(seconds: 20);
  static const iconRightPadding = 20;

  const _RoadEventsPainter({
    required this.events,
    required this.routeLength,
    required this.routeProgress,
    required this.eventFirstAppearance,
    required this.currentTime,
    required this.onEventFirstSeen,
    required this.svgCache,
  });

  String _getEventIcon(sdk.RoadEventType type, bool isBigIcon) {
    switch (type) {
      case sdk.RoadEventType.accident:
        return isBigIcon
            ? _RoadEventIcon.accidentLargeIcon.path
            : _RoadEventIcon.accidentSmallIcon.path;

      case sdk.RoadEventType.roadWorks:
        return isBigIcon
            ? _RoadEventIcon.roadWorksLargeIcon.path
            : _RoadEventIcon.roadWorksSmallIcon.path;
      default:
        return isBigIcon
            ? _RoadEventIcon.defaultLargeIcon.path
            : _RoadEventIcon.defailtSmallIcon.path;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (events.isEmpty || routeLength == 0) return;

    final locationIndicatorY = size.height * (1 - routeProgress);

    final visibleEvents = events
      ..where((event) {
        final eventY =
            size.height * (1 - event.point.distance.millimeters / routeLength);
        return eventY < locationIndicatorY - _locationIndicatorMargin;
      })
      ..toList()
      ..sort(
        (a, b) => (a.point.distance.millimeters / routeLength)
            .compareTo(b.point.distance.millimeters / routeLength),
      )
      ..reversed;

    var lastY = locationIndicatorY + _locationIndicatorMargin;

    for (final event in visibleEvents) {
      final eventY =
          size.height * (1 - event.point.distance.millimeters / routeLength);
      final isBigIcon = _shouldShowBigIcon(event.value.id);
      final iconSize = isBigIcon ? bigIconSize : smallIconSize;

      if (lastY - eventY >= iconSize) {
        final iconPath = _getEventIcon(event.value.eventType, isBigIcon);
        final pictureInfo = svgCache[iconPath];

        if (pictureInfo != null) {
          final center = Offset(size.width - iconRightPadding, eventY);

          canvas.save();

          final scale = iconSize /
              math.max(pictureInfo.size.width, pictureInfo.size.height);

          canvas
            ..translate(
              center.dx - (pictureInfo.size.width * scale / 2),
              center.dy - (pictureInfo.size.height * scale / 2),
            )
            ..scale(scale)
            ..drawPicture(pictureInfo.picture)
            ..restore();
        }

        lastY = eventY;
      }
    }
  }

  bool _shouldShowBigIcon(int eventId) {
    final firstSeen = eventFirstAppearance[eventId];
    if (firstSeen == null) {
      onEventFirstSeen(eventId);
      return true;
    }

    final elapsed = currentTime.difference(firstSeen);
    if (elapsed >= bigIconDuration) return false;

    return true;
  }

  @override
  bool shouldRepaint(_RoadEventsPainter oldDelegate) {
    return oldDelegate.events != events ||
        oldDelegate.routeLength != routeLength ||
        oldDelegate.routeProgress != routeProgress ||
        oldDelegate.currentTime != currentTime;
  }
}
