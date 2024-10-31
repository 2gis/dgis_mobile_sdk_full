import 'dart:async';

import 'package:dgis_mobile_sdk_full/src/util/fromat_distance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/optional.dart';
import '../../util/plugin_name.dart';
import '../map/base_map_control.dart';
import '../map/map_widget_theme.dart';
import '../map/themed_map_controlling_widget.dart';

class ManeuverWidget extends ThemedMapControllingWidget<ManeuverWidgetTheme> {
  final sdk.NavigationManager navigationManager;

  const ManeuverWidget({
    super.key,
    required this.navigationManager,
    ManeuverWidgetTheme? light,
    ManeuverWidgetTheme? dark,
  }) : super(
          light: light ?? ManeuverWidgetTheme.defaultLight,
          dark: dark ?? ManeuverWidgetTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<ManeuverWidget, ManeuverWidgetTheme> createState() => _ManeuverWidgetState();
}

class _ManeuverWidgetState extends ThemedMapControllingWidgetState<ManeuverWidget, ManeuverWidgetTheme> {
  late StreamSubscription<sdk.RouteInfo> _routeSubscription;
  late StreamSubscription<sdk.RoutePoint?> _routePositionSubscription;
  late StreamSubscription<sdk.State> _stateSubscription;

  sdk.InstructionRouteAttribute? _instructions;

  ValueNotifier<ManeuverModel> _maneuverModel = ValueNotifier(
    ManeuverModel(
      instruction: null,
      routePoint: null,
    ),
  );

  @override
  void onAttachedToMap(sdk.Map map) {
    _routeSubscription = widget.navigationManager.uiModel.routeChannel.listen((route) {
      _instructions = route.route.instructions;

      if (this._instructions != null && widget.navigationManager.uiModel.routePosition != null) {
        _nextManeuverInfo(widget.navigationManager.uiModel.routePosition!, this._instructions!);
      }
    });
    _routePositionSubscription = widget.navigationManager.uiModel.routePositionChannel.listen((position) {
      if (this._instructions != null && position != null) {
        _nextManeuverInfo(position, this._instructions!);
      }
    });
    _stateSubscription = widget.navigationManager.uiModel.stateChannel.listen((state) {
      if (this._instructions != null && widget.navigationManager.uiModel.routePosition != null) {
        _nextManeuverInfo(widget.navigationManager.uiModel.routePosition!, this._instructions!);
      }
    });
  }

  void _nextManeuverInfo(sdk.RoutePoint position, sdk.InstructionRouteAttribute instructions) {
    final nearBackward = instructions.findNearBackward(position);
    if (nearBackward != null &&
        position.distance.millimeters <=
            nearBackward.point.distance.millimeters + nearBackward.value.range.millimeters) {
      _maneuverModel.value = _maneuverModel.value.copyWith(
        instruction: Optional(nearBackward),
        routePoint: Optional(position),
      );
      return;
    }

    final nearForward = instructions.findNearForward(position);
    if (nearForward != null) {
      _maneuverModel.value = _maneuverModel.value.copyWith(
        instruction: Optional(nearForward),
        routePoint: Optional(position),
      );
    }
  }

  @override
  void onDetachedFromMap() {
    _routeSubscription.cancel();
    _routePositionSubscription.cancel();
    _stateSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: theme.maxWidth,
        minWidth: theme.minWidth,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.controlTheme.surfaceColor,
          boxShadow: theme.controlTheme.shadows,
          borderRadius: BorderRadius.circular(theme.controlTheme.borderRadius),
        ),
        padding: EdgeInsets.all(8),
        child: ValueListenableBuilder(
          valueListenable: _maneuverModel,
          builder: (context, vaue, child) {
            final maneuverDistance = vaue.maneuverDistance();
            final maneuverIcon = vaue.maneuverIcon();
            final roadName = vaue.instruction?.value.roadName;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    maneuverIcon != null
                        ? SvgPicture.asset(
                            maneuverIcon,
                            fit: BoxFit.none,
                            width: theme.iconSize,
                            height: theme.iconSize,
                          )
                        : SizedBox(
                            width: theme.iconSize,
                            height: theme.iconSize,
                          ),
                    if (maneuverDistance != null)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formatMeters(maneuverDistance).value,
                              style: theme.maneuverDistanceTextStyle,
                            ),
                            TextSpan(
                              text: formatMeters(maneuverDistance).unit,
                              style: theme.maneuverDistanceUnitTextStyle,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (roadName != null && roadName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      roadName,
                      style: theme.roadNameTextStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

class ManeuverModel {
  final sdk.InstructionRouteEntry? instruction;
  final sdk.RoutePoint? routePoint;

  ManeuverModel({
    required this.instruction,
    required this.routePoint,
  });

  int? maneuverDistance() {
    if (instruction == null || routePoint == null) {
      return null;
    }

    return instruction!.point.distance.millimeters - routePoint!.distance.millimeters;
  }

  String? maneuverIcon() {
    if (instruction == null) {
      return null;
    }

    final maneuver = sdk.getInstructionManeuver(instruction!.value.extraInstructionInfo);

    return switch (maneuver) {
      sdk.InstructionManeuver.none => null,
      sdk.InstructionManeuver.start => 'packages/$pluginName/assets/icons/maneuvers/dgis_start.svg',
      sdk.InstructionManeuver.finish => 'packages/$pluginName/assets/icons/maneuvers/dgis_finish.svg',
      sdk.InstructionManeuver.crossroadStraight => 'packages/$pluginName/assets/icons/maneuvers/dgis_start.svg',
      sdk.InstructionManeuver.crossroadSlightlyLeft =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_slightly_left.svg',
      sdk.InstructionManeuver.crossroadLeft => 'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_left.svg',
      sdk.InstructionManeuver.crossroadSharplyLeft =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_sharply_left.svg',
      sdk.InstructionManeuver.crossroadSlightlyRight =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_slightly_right.svg',
      sdk.InstructionManeuver.crossroadRight => 'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_right.svg',
      sdk.InstructionManeuver.crossroadSharplyRight =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_sharply_right.svg',
      sdk.InstructionManeuver.crossroadKeepLeft => 'packages/$pluginName/assets/icons/maneuvers/dgis_left.svg',
      sdk.InstructionManeuver.crossroadKeepRight => 'packages/$pluginName/assets/icons/maneuvers/dgis_right.svg',
      sdk.InstructionManeuver.crossroadUTurn => 'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_uturn.svg',
      sdk.InstructionManeuver.roundaboutForward =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_forward.svg',
      sdk.InstructionManeuver.roundaboutLeft45 =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_left_45.svg',
      sdk.InstructionManeuver.roundaboutLeft90 =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_left_90.svg',
      sdk.InstructionManeuver.roundaboutLeft135 =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_left_135.svg',
      sdk.InstructionManeuver.roundaboutRight45 =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_right_45.svg',
      sdk.InstructionManeuver.roundaboutRight90 =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_right_90.svg',
      sdk.InstructionManeuver.roundaboutRight135 =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_right_135.svg',
      sdk.InstructionManeuver.roundaboutBackward =>
        'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_backward.svg',
      sdk.InstructionManeuver.roundaboutExit => 'packages/$pluginName/assets/icons/maneuvers/dgis_ringroad_exit.svg',
      sdk.InstructionManeuver.uTurn => 'packages/$pluginName/assets/icons/maneuvers/dgis_crossroad_uturn.svg',
      sdk.InstructionManeuver.roadCrossing => null,
    };
  }

  ManeuverModel copyWith({
    Optional<sdk.InstructionRouteEntry?>? instruction,
    Optional<sdk.RoutePoint?>? routePoint,
  }) {
    return ManeuverModel(
      instruction: instruction != null ? instruction.value : this.instruction,
      routePoint: routePoint != null ? routePoint.value : this.routePoint,
    );
  }
}

class ManeuverWidgetTheme extends MapWidgetTheme {
  final MapControlTheme controlTheme;
  final TextStyle roadNameTextStyle;
  final TextStyle maneuverDistanceTextStyle;
  final TextStyle maneuverDistanceUnitTextStyle;
  final double iconSize;
  final double maxWidth;
  final double minWidth;

  const ManeuverWidgetTheme({
    required this.controlTheme,
    required this.roadNameTextStyle,
    required this.maneuverDistanceTextStyle,
    required this.maneuverDistanceUnitTextStyle,
    required this.iconSize,
    required this.maxWidth,
    required this.minWidth,
  });

  /// Цветовая схема UI–элемента для светлого режима по умолчанию.
  static const ManeuverWidgetTheme defaultLight = ManeuverWidgetTheme(
    controlTheme: MapControlTheme.defaultLight,
    roadNameTextStyle: TextStyle(
      height: 1.25,
      color: Color(0xff141414),
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    maneuverDistanceTextStyle: TextStyle(
      height: 1.14,
      color: Color(0xff141414),
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    maneuverDistanceUnitTextStyle: TextStyle(
      height: 1.2,
      color: Color(0xff141414),
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    iconSize: 36,
    maxWidth: 189,
    minWidth: 140,
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const ManeuverWidgetTheme defaultDark = ManeuverWidgetTheme(
    controlTheme: MapControlTheme.defaultDark,
    roadNameTextStyle: TextStyle(
      height: 1.25,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    maneuverDistanceTextStyle: TextStyle(
      height: 1.14,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w500,
      fontSize: 28,
    ),
    maneuverDistanceUnitTextStyle: TextStyle(
      height: 1.2,
      color: Color(0xffffffff),
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    iconSize: 36,
    maxWidth: 189,
    minWidth: 140,
  );

  @override
  ManeuverWidgetTheme copyWith({
    MapControlTheme? controlTheme,
    TextStyle? roadNameTextStyle,
    TextStyle? maneuverDistanceTextStyle,
    TextStyle? maneuverDistanceUnitTextStyle,
    double? maxWidth,
    double? minWidth,
    double? iconSize,
  }) {
    return ManeuverWidgetTheme(
      controlTheme: controlTheme ?? this.controlTheme,
      roadNameTextStyle: roadNameTextStyle ?? this.roadNameTextStyle,
      maneuverDistanceTextStyle: maneuverDistanceTextStyle ?? this.maneuverDistanceTextStyle,
      maneuverDistanceUnitTextStyle: maneuverDistanceUnitTextStyle ?? this.maneuverDistanceUnitTextStyle,
      maxWidth: maxWidth ?? this.maxWidth,
      minWidth: minWidth ?? this.minWidth,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}
