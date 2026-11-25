import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../extensions.dart';
import './better_route_prompt_model.dart';

/// Controller for managing better route suggestions during navigation.
///
/// This controller handles:
/// * Better route detection and prompts
/// * Route comparison (time differences)
/// * User responses to route suggestions
/// * Timeout management for route prompts
///
/// The controller provides real-time route alternatives through [BetterRoutePromptModel]
/// and manages user interactions with better route suggestions.
///
/// Usage example:
/// ```dart
/// final controller = BetterRoutePromptController(
///   navigationManager: navigationManagerInstance,
///   onBetterRoutePrompted: (info) {
///     print('New route suggested: ${info.timeWinning} minutes faster');
///   },
///   onBetterRouteAccepted: (info) {
///     print('Better route accepted');
///   },
///   onBetterRouteRejected: () {
///     print('Better route rejected by user');
///   },
///   onBetterRouteTimedOut: () {
///     print('Better route prompt timed out');
///   },
/// );
///
/// // Listen to better route suggestions
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Time difference: ${model.timeWinning} minutes');
///   print('Route type: ${model.type}');
/// });
///
/// // Handle user decisions
/// controller.acceptBetterRoute();  // Accept suggested route
/// controller.rejectBetterRoute(); // Reject suggested route
/// ```
///
/// The controller maintains a subscription to better route suggestions
/// and provides methods to handle user responses to these suggestions.
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class BetterRoutePromptController {
  final sdk.NavigationManager navigationManager;
  final void Function(sdk.BetterRouteInfo info) _onBetterRoutePrompted;
  final void Function(sdk.BetterRouteInfo info) _onBetterRouteAccepted;

  final void Function() _onBetterRouteRejected;
  final void Function() _onBetterRouteTimedOut;

  sdk.BetterRouteInfo? _currentBetterRoutePromptInfo;

  late final StreamSubscription<sdk.BetterRouteInfo?>
  _betterRouteInfoSubscription;

  late final ValueNotifier<BetterRoutePromptModel> _model;

  /// The current state of better route suggestions as a [ValueNotifier].
  /// Contains information about time differences and route types.
  ValueNotifier<BetterRoutePromptModel> get state => _model;

  BetterRoutePromptController({
    required this.navigationManager,
    required void Function(sdk.BetterRouteInfo) onBetterRoutePrompted,
    required void Function() onBetterRouteRejected,
    required void Function() onBetterRouteTimedOut,
    required void Function(sdk.BetterRouteInfo) onBetterRouteAccepted,
  }) : _onBetterRouteTimedOut = onBetterRouteTimedOut,
       _onBetterRouteRejected = onBetterRouteRejected,
       _onBetterRouteAccepted = onBetterRouteAccepted,
       _onBetterRoutePrompted = onBetterRoutePrompted {
    _init();
  }

  void _init() {
    _model = ValueNotifier(
      const BetterRoutePromptModel(
        timeWinning: null,
        type: BetterRouteType.unspecified,
      ),
    );
    _betterRouteInfoSubscription = navigationManager.uiModel.betterRouteChannel
        .listen((betterRouteInfo) {
          if (betterRouteInfo != null) {
            _currentBetterRoutePromptInfo = betterRouteInfo;
            _onBetterRoutePrompted(betterRouteInfo);
            _calculateTimeForModel(betterRouteInfo);
          } else {
            rejectBetterRoute();
            _model.value = _model.value.copyWith(
              timeWinning: () => null,
              type: BetterRouteType.unspecified,
            );
          }
        });
  }

  void _calculateTimeForModel(sdk.BetterRouteInfo info) {
    final newDuration = info.trafficRoute.traffic.durations
        .calculateDurationToRoutePoint(info.startPoint);
    final currentDuration = navigationManager.uiModel.duration();

    if (currentDuration == null) {
      _model.value = _model.value.copyWith(
        timeWinning: () => null,
        type: BetterRouteType.unspecified,
      );
      return;
    }

    final difference = (currentDuration - newDuration).inMinutes;
    BetterRouteType type;
    if (difference > 0) {
      type = BetterRouteType.winnigTime;
    } else if (difference < 0) {
      type = BetterRouteType.losingTime;
    } else {
      type = BetterRouteType.sameTime;
    }

    _model.value = _model.value.copyWith(
      timeWinning: () => difference,
      type: type,
    );
  }

  /// Accepts the currently suggested better route.
  ///
  /// * Updates navigation to use new route
  /// * Triggers acceptance callback
  /// * Updates navigation manager with acceptance response
  void acceptBetterRoute() {
    navigationManager.uiModel.betterRouteResponse(
      sdk.BetterRouteResponse.accept,
    );
    _onBetterRouteAccepted(_currentBetterRoutePromptInfo!);
  }

  /// Rejects the currently suggested better route.
  ///
  /// * Maintains current route
  /// * Triggers rejection callback
  /// * Clears current suggestion
  void rejectBetterRoute() {
    navigationManager.uiModel.betterRouteResponse(
      sdk.BetterRouteResponse.reject,
    );
    _onBetterRouteRejected();
    _currentBetterRoutePromptInfo = null;
  }

  /// Handles timeout of the better route prompt.
  ///
  /// * Triggers timeout callback
  /// * Clears current suggestion
  /// * Updates navigation manager with timeout response
  void timeoutBetterRoutePrompt() {
    navigationManager.uiModel.betterRouteResponse(
      sdk.BetterRouteResponse.timeout,
    );
    _onBetterRouteTimedOut();
    _currentBetterRoutePromptInfo = null;
  }

  /// Cleans up resources by canceling the better route subscription.
  /// Should be called when the controller is no longer needed.
  void dispose() {
    _betterRouteInfoSubscription.cancel();
  }
}
