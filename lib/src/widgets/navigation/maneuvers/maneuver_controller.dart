import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import 'maneuver_model.dart';

/// Controller for managing navigation maneuvers and related information during route navigation.
///
/// This controller handles:
/// * Next maneuver information updates
/// * Maneuver icons and distances
/// * Road names and rules
/// * Additional maneuver information (exits, roundabouts)
///
/// The controller requires a [navigationManager] instance to function properly and manages
/// the maneuver state through [ManeuverModel].
///
/// Usage example:
/// ```dart
/// final controller = ManeuverController(
///   navigationManager: navigationManagerInstance,
/// );
///
/// // Access current maneuver state
/// print(controller.state.value.maneuverDistance);
/// print(controller.state.value.roadName);
///
/// // Listen to maneuver updates
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Next maneuver: ${model.maneuverIcon}');
///   print('Distance: ${model.maneuverDistance}');
/// });
/// ```
///
/// The controller maintains three main subscriptions:
/// * Route updates
/// * Position updates
/// * Navigation state updates
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class ManeuverController {
  final sdk.NavigationManager navigationManager;

  sdk.InstructionRouteAttribute? _instructions;
  sdk.RoadRuleRouteLongAttribute? _roadRule;

  late StreamSubscription<sdk.RouteInfo> _routeSubscription;
  late StreamSubscription<sdk.RoutePoint?> _routePositionSubscription;
  late StreamSubscription<sdk.State> _stateSubscription;

  late final ValueNotifier<ManeuverModel> _model;

  ValueNotifier<ManeuverModel> get state => _model;

  ManeuverController({required this.navigationManager}) {
    _init();
  }

  void _init() {
    _model = ValueNotifier(
      const ManeuverModel(
        maneuverDistance: null,
        maneuverIcon: null,
        roadName: null,
        additionalManeuver: null,
      ),
    );

    _routeSubscription = navigationManager.uiModel.routeChannel.listen((route) {
      _instructions = route.route.instructions;
      _roadRule = route.route.roadRules;

      if (_instructions != null &&
          navigationManager.uiModel.routePosition != null) {
        _updateNextManeuverInfo(
          navigationManager.uiModel.routePosition!,
          _instructions!,
          _roadRule,
        );
      }
    });
    _routePositionSubscription = navigationManager.uiModel.routePositionChannel
        .listen((position) {
          if (_instructions != null && position != null) {
            _updateNextManeuverInfo(position, _instructions!, _roadRule);
          }
        });
    _stateSubscription = navigationManager.uiModel.stateChannel.listen((state) {
      if (_instructions != null &&
          navigationManager.uiModel.routePosition != null) {
        _updateNextManeuverInfo(
          navigationManager.uiModel.routePosition!,
          _instructions!,
          _roadRule,
        );
      }
    });
  }

  void _updateNextManeuverInfo(
    sdk.RoutePoint position,
    sdk.InstructionRouteAttribute instructions,
    sdk.RoadRuleRouteLongAttribute? roadRule,
  ) {
    final nearBackward = instructions.findNearBackward(position);
    if (nearBackward != null &&
        position.distance.millimeters <=
            nearBackward.point.distance.millimeters +
                nearBackward.value.range.millimeters) {
      _updateModel(
        nearBackward,
        position,
      );
      return;
    }

    final nearForward = instructions.findNearForward(position);
    if (nearForward != null) {
      _updateModel(
        nearForward,
        position,
      );
    }
  }

  void _updateModel(
    sdk.InstructionRouteEntry instruction,
    sdk.RoutePoint position,
  ) {
    final distance = _maneuverDistance(
      instruction,
      position,
    );
    final roadName = instruction.value.roadName;
    final currentRules = _roadRule?.entry(position)?.value;
    final icon = _getManeuverIconPath(
      sdk.getInstructionManeuver(instruction.value.extraInstructionInfo),
      currentRules,
    );
    final additional = _additionalManeuver(instruction, position);

    _model.value = _model.value.copyWith(
      maneuverDistance: () => distance,
      roadName: () => roadName,
      maneuverIcon: () => icon,
      additionalManeuver: () => additional,
    );
  }

  int? _maneuverDistance(
    sdk.InstructionRouteEntry? instruction,
    sdk.RoutePoint? routePoint,
  ) {
    if (instruction == null || routePoint == null) {
      return null;
    }

    return instruction.point.distance.millimeters -
        routePoint.distance.millimeters;
  }

  AdditionalManeuverModel? _additionalManeuver(
    sdk.InstructionRouteEntry? instruction,
    sdk.RoutePoint routePoint,
  ) {
    if (instruction == null || _instructions == null) {
      return null;
    }

    final maneuver = sdk.getInstructionManeuver(
      instruction.value.extraInstructionInfo,
    );
    if (maneuver == sdk.InstructionManeuver.finish) {
      return null;
    }

    // Corner cases for additional maneuvers like "exit":
    // name of the exit (string) in any form or the number of the exit + predefined phrase ("Exit").
    if (instruction.value.extraInstructionInfo.isCarRoundabout) {
      final roundaboutInstruction =
          instruction.value.extraInstructionInfo.asCarRoundabout!;
      if (roundaboutInstruction.type == sdk.CarInstructionRoundaboutType.exit) {
        return null;
      }

      if (roundaboutInstruction.exitName.isNotEmpty) {
        return ExitName(exitName: roundaboutInstruction.exitName);
      }
      if (roundaboutInstruction.exitNumber != 0) {
        return ExitNumber(exitNumber: roundaboutInstruction.exitNumber);
      }
    }

    if (instruction.value.extraInstructionInfo.isCarCrossroad) {
      final carCrossroadInstruction =
          instruction.value.extraInstructionInfo.asCarCrossroad!;
      if (carCrossroadInstruction.exitName.isNotEmpty) {
        return ExitName(exitName: carCrossroadInstruction.exitName);
      }
    }

    if (instruction.value.extraInstructionInfo.isCarUturn) {
      final carUturnInstruction =
          instruction.value.extraInstructionInfo.asCarUturn!;
      if (carUturnInstruction.exitName.isNotEmpty) {
        return ExitName(exitName: carUturnInstruction.exitName);
      }
    }

    // Hide the additional maneuver if the distance to the next main maneuver is greater than 1000 m.
    if ((instruction.point.distance.millimeters -
                routePoint.distance.millimeters) /
            1000 >
        1000) {
      return null;
    }

    final nextInstructionEntry = _instructions!.findNearForward(
      sdk.RoutePoint(
        sdk.RouteDistance(instruction.point.distance.millimeters + 1000),
      ),
    );

    if (nextInstructionEntry == null) {
      return null;
    }

    final nextInstructionManeuver = sdk.getInstructionManeuver(
      nextInstructionEntry.value.extraInstructionInfo,
    );
    if (nextInstructionManeuver == sdk.InstructionManeuver.none) {
      return null;
    }

    // Hide the additional maneuver if the distance between the main and additional (next)
    // maneuver > 50 m.
    final distance =
        (nextInstructionEntry.point.distance.millimeters -
            instruction.point.distance.millimeters) /
        1000;
    if (distance > 50) {
      return null;
    }

    final currentRules = _roadRule?.entry(routePoint)?.value;

    return ManeuverWithIcon(
      icon: _getManeuverIconPath(
        nextInstructionManeuver,
        currentRules,
      ),
    );
  }

  ManeuverIcon? _getManeuverIconPath(
    sdk.InstructionManeuver maneuver,
    sdk.RoadRule? rule,
  ) {
    final isLeftHandTraffic = rule == sdk.RoadRule.leftHandTraffic;
    return switch (maneuver) {
      sdk.InstructionManeuver.none => null,
      sdk.InstructionManeuver.start => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_start.svg',
        false,
      ),
      sdk.InstructionManeuver.finish => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_finish.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadStraight => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_start.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadSlightlyLeft => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_slightly_left.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadLeft => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_left.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadSharplyLeft => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_sharply_left.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadSlightlyRight => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_slightly_right.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadRight => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_right.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadSharplyRight => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_sharply_right.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadKeepLeft => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_left.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadKeepRight => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_right.svg',
        false,
      ),
      sdk.InstructionManeuver.crossroadUTurn => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_uturn.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutForward => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_forward.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutLeft45 => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_${isLeftHandTraffic ? "right" : "left"}_45.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutLeft90 => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_${isLeftHandTraffic ? "right" : "left"}_90.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutLeft135 => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_${isLeftHandTraffic ? "right" : "left"}_135.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutRight45 => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_${isLeftHandTraffic ? "left" : "right"}_45.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutRight90 => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_${isLeftHandTraffic ? "left" : "right"}_90.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutRight135 => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_${isLeftHandTraffic ? "left" : "right"}_135.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutBackward => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_backward.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roundaboutExit => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_ringroad_exit.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.uTurn => (
        'packages/$pluginName/assets/icons/navigation/maneuvers/dgis_crossroad_uturn.svg',
        isLeftHandTraffic,
      ),
      sdk.InstructionManeuver.roadCrossing => null,
    };
  }

  void dispose() {
    _routeSubscription.cancel();
    _routePositionSubscription.cancel();
    _stateSubscription.cancel();
  }
}
