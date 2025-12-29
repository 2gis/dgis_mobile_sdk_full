import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../common/formatted_measure.dart';
import '../navigation_layout_widget.dart';
import './../../../generated/dart_bindings.dart' as sdk;
import './../extensions.dart';
import './dashboard_model.dart';
import './dashboard_widget.dart';

/// Controller for managing the dashboard widget's state and functionality during navigation.
///
/// This controller handles:
/// * Real-time navigation updates (distance, duration)
/// * Sound settings management
/// * Route visualization
/// * Navigation state formatting
///
/// The controller requires both [navigationManager] and [map] instances to function properly.
///
/// Usage with [NavigationLayoutWidget]:
/// This controller is created automatically by the widget and provided through
/// the builder function in [NavigationLayoutWidget]'s constructor:
///
/// ```dart
/// NavigationLayoutWidget(
///   dashboardWidgetBuilder: (controller, callback) => DashboardWidget(
///     controller: controller,
///     onHeaderChangeSize: callback,
///     onFinishClicked: () => navigationManager.stop(),
///   ),
/// ),
/// ```
///
/// This architecture allows the controller to be used by custom widgets
/// derived from [DashboardWidget].
///
/// Example of controller usage:
/// ```dart
/// // Access current state
/// print(controller.distance);
/// print(controller.duration);
///
/// // Format values
/// final formattedDistance = controller.formatDistance(localizations);
/// final formattedDuration = controller.formatDuration(localizations);
///
/// // Control navigation
/// controller.toggleSounds();
/// controller.showRoute();
/// controller.stopNavigation();
/// ```
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
///
/// Controller also exposes [sdk.Map] and [sdk.NavigationManager] to widget
/// so they can be used for some non-standart logic inside widget.
class DashboardController {
  final sdk.NavigationManager navigationManager;
  final sdk.Map map;

  late final StreamSubscription<sdk.RoutePoint?> _routePositionSubscription;
  late final ValueNotifier<DashboardModel> _model;

  // Callback to control overlay from widget
  Function()? _closeOverlayCallback;

  DashboardController({
    required this.navigationManager,
    required this.map,
  }) {
    _init();
  }

  /// The current state of the dashboard as a [ValueNotifier].
  /// Contains distance, duration, and sound settings.
  ValueNotifier<DashboardModel> get state => _model;

  /// The current distance remaining in meters.
  int get distance => _model.value.distance;

  /// The current duration remaining in seconds.
  int get duration => _model.value.duration;

  /// Whether navigation voice instructions are enabled.
  bool get soundsEnabled => _model.value.soundsEnabled;

  /// Whether the dashboard is in route view mode (collapsed state).
  bool get isRouteViewMode => _model.value.isRouteViewMode;

  /// The estimated time of arrival based on current [duration].
  DateTime get estimatedArrivalTime =>
      DateTime.now().add(Duration(seconds: duration));

  /// Sets the callback to close overlay from widget.
  /// This allows the controller to manage overlay state when switching modes.
  void setOverlayCallback(Function()? callback) {
    _closeOverlayCallback = callback;
  }

  void _init() {
    _routePositionSubscription = navigationManager.uiModel.routePositionChannel
        .listen(_handleRoutePositionUpdate);

    _model = ValueNotifier(
      DashboardModel(
        distance: navigationManager.uiModel.distance() ?? 0,
        duration: navigationManager.uiModel.duration()?.inSeconds ?? 0,
        soundsEnabled: _isSoundEnabled(),
      ),
    );

    _model.value = _model.value.copyWith(
      soundsEnabled: _isSoundEnabled(),
    );
  }

  void _handleRoutePositionUpdate(sdk.RoutePoint? position) {
    final duration = navigationManager.uiModel.duration();
    final distance = navigationManager.uiModel.distance();

    _model.value = _model.value.copyWith(
      distance: distance,
      duration: duration?.inSeconds,
    );
  }

  bool _isSoundEnabled() {
    return navigationManager.soundNotificationSettings.enabledSoundCategories
        .contains(sdk.SoundCategory.instructions);
  }

  /// Formats the current [distance] according to the provided localizations.
  /// Returns a [FormattedMeasure] containing the value and unit.
  FormattedMeasure formatDistance(DgisLocalizations localizations) {
    return metersToFormattedMeasure(distance, localizations);
  }

  /// Formats the current [duration] according to the provided localizations.
  /// Returns a [FormattedMeasure] containing the value and unit.
  FormattedMeasure formatDuration(DgisLocalizations localizations) {
    return durationToFormattedMeasure(
      Duration(seconds: duration),
      localizations,
    );
  }

  /// Formats the [estimatedArrivalTime] using the provided date formatter.
  String formatArrivalTime(DateFormat formatter) {
    return formatter.format(estimatedArrivalTime);
  }

  /// Toggles the sound state for navigation instructions.
  /// Updates the [soundsEnabled] state and [state] accordingly.
  void toggleSounds() {
    final categories = navigationManager
        .soundNotificationSettings.enabledSoundCategories
        .toMutableEnumSet();

    if (soundsEnabled) {
      categories.remove(sdk.SoundCategory.instructions);
    } else {
      categories.add(sdk.SoundCategory.instructions);
    }

    navigationManager.soundNotificationSettings.enabledSoundCategories =
        categories.toEnumSet();

    _model.value = _model.value.copyWith(
      soundsEnabled: _isSoundEnabled(),
    );
  }

  /// Shows the remaining route on the map and switches to route view mode.
  /// Calculates and moves the camera to fit the remaining route geometry.
  /// Also collapses the dashboard to show only the accept button.
  Future<void> showRoute() async {
    // Close overlay if it's showing
    _closeOverlayCallback?.call();
    final fullRouteGeometry = navigationManager.uiModel.route.route.geometry;
    final currentRoutePoint = navigationManager.uiModel.routePosition;

    final remainingGeometry = currentRoutePoint != null
        ? sdk.ComplexGeometry(
            sdk
                .remainingRouteGeometry(
                  fullRouteGeometry,
                  currentRoutePoint,
                )
                .entries
                .map<sdk.PointGeometry>(
                  (entry) => sdk.PointGeometry(entry.value),
                )
                .toList(),
          )
        : sdk.ComplexGeometry(
            fullRouteGeometry.entries
                .map((entry) => sdk.PointGeometry(entry.value))
                .toList(),
          );

    final cameraPosition = sdk.calcPositionForGeometry(
      map.camera,
      remainingGeometry,
      null,
      const sdk.Padding(
        top: 32,
        bottom: 92,
        left: 32,
        right: 32,
      ),
      null,
      null,
      null,
    );

    await map.camera.moveToCameraPosition(cameraPosition).value;

    // Switch to route view mode
    _model.value = _model.value.copyWith(isRouteViewMode: true);
  }

  /// Returns from route view mode to normal navigation view.
  /// Restores the camera to follow the current position and exits route view mode.
  Future<void> returnToNavigation() async {
    // Close overlay if it's showing
    _closeOverlayCallback?.call();
    // Return to full navigation camera behavior (follow position with bearing and tilt)
    map.camera.setBehaviour(
      const sdk.CameraBehaviour(
        position: sdk.FollowPosition(
          bearing: sdk.FollowBearing.on_,
          styleZoom: sdk.FollowStyleZoom.on_,
        ),
        tilt: sdk.FollowTilt.on_,
      ),
    );

    // Exit route view mode
    _model.value = _model.value.copyWith(isRouteViewMode: false);
  }

  /// Stops the current navigation session.
  void stopNavigation() {
    navigationManager.stop();
  }

  void dispose() {
    _routePositionSubscription.cancel();
    _model.dispose();
  }
}
