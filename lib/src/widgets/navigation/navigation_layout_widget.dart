import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../map/base_map_state.dart';
import './../../generated/dart_bindings.dart' as sdk;
import './../common/rounded_corners.dart';
import './better_route_prompt/better_route_prompt_controller.dart';
import './better_route_prompt/better_route_prompt_widget.dart';
import './compass/compass_controller.dart';
import './compass/compass_widget.dart';
import './dashboard/dashboard_controller.dart';
import './dashboard/dashboard_widget.dart';
import './finish_route/finish_route_controller.dart';
import './finish_route/finish_route_widget.dart';
import './maneuvers/maneuver_controller.dart';
import './maneuvers/maneuver_widget.dart';
import './my_location/my_location_controller.dart';
import './my_location/my_location_widget.dart';
import './parking/parking_controller.dart';
import './parking/parking_widget.dart';
import './speed_limit/speed_limit_controller.dart';
import './speed_limit/speed_limit_widget.dart';
import './traffic/traffic_controller.dart';
import './traffic/traffic_widget.dart';
import './traffic_line/traffic_line_controller.dart';
import './traffic_line/traffic_line_widget.dart';
import './zoom/zoom_controller.dart';
import './zoom/zoom_widget.dart';

class NavigationLayoutWidget extends StatefulWidget {
  final sdk.NavigationManager navigationManager;
  final DashboardWidget Function(
    DashboardController,
    void Function(Offset) onHeaderChangeSize,
  )? _dashboardWidgetBuilder;
  final SpeedLimitWidget Function(SpeedLimitController)?
      _speedLimitWidgetBuilder;
  final ManeuverWidget Function(ManeuverController)? _maneuverWidgetBuilder;
  final TrafficLineWidget Function(TrafficLineController, DashboardController)?
      _trafficLineWidgetBuilder;
  final FinishRouteWidget Function(FinishRouteController)?
      _finishRouteWidgetBuilder;
  final NavigationTrafficWidget Function(
    RoundedCorners roundedCorners,
    TrafficController controller,
  )? _trafficWidgetBuilder;
  final NavigationParkingWidget Function(
    RoundedCorners roundedCorners,
    ParkingController controller,
  )? _parkingWidgetBuilder;
  final NavigationZoomWidget Function(ZoomController)? _zoomWidgetBuilder;
  final NavigationMyLocationWidget Function(MyLocationController)?
      _myLocationwidgetBuilder;
  final NavigationCompassWidget Function(CompassController)?
      _compassWidgetBuilder;
  final BetterRoutePromptWidget Function(
    BetterRoutePromptController,
    Duration,
  )? _betterRoutePromptWidgetBuilder;

  const NavigationLayoutWidget({
    required this.navigationManager,
    DashboardWidget Function(
      DashboardController,
      Function(Offset) onHeaderChangeSize,
    )? dashboardWidgetBuilder,
    SpeedLimitWidget Function(SpeedLimitController)? speedLimitWidgetBuilder,
    ManeuverWidget Function(ManeuverController)? maneuverWidgetBuilder,
    TrafficLineWidget Function(TrafficLineController, DashboardController)?
        trafficLineWidgetBuilder,
    FinishRouteWidget Function(FinishRouteController)? finishRouteWidgetBuilder,
    NavigationTrafficWidget Function(
      RoundedCorners,
      TrafficController,
    )? trafficWidgetBuilder,
    NavigationParkingWidget Function(RoundedCorners, ParkingController)?
        parkingWidgetBuilder,
    NavigationZoomWidget Function(ZoomController)? zoomWidgetBuilder,
    NavigationMyLocationWidget Function(MyLocationController)?
        myLocationWidgetBuilder,
    NavigationCompassWidget Function(CompassController)? compassWidgetbuilder,
    BetterRoutePromptWidget Function(
      BetterRoutePromptController,
      Duration,
    )? betterRoutePromptWidgetBuilder,
    super.key,
  })  : _dashboardWidgetBuilder = dashboardWidgetBuilder,
        _speedLimitWidgetBuilder = speedLimitWidgetBuilder,
        _maneuverWidgetBuilder = maneuverWidgetBuilder,
        _trafficLineWidgetBuilder = trafficLineWidgetBuilder,
        _finishRouteWidgetBuilder = finishRouteWidgetBuilder,
        _trafficWidgetBuilder = trafficWidgetBuilder,
        _parkingWidgetBuilder = parkingWidgetBuilder,
        _zoomWidgetBuilder = zoomWidgetBuilder,
        _myLocationwidgetBuilder = myLocationWidgetBuilder,
        _compassWidgetBuilder = compassWidgetbuilder,
        _betterRoutePromptWidgetBuilder = betterRoutePromptWidgetBuilder;

  const NavigationLayoutWidget.defaultLayout({
    required this.navigationManager,
    super.key,
  })  : _dashboardWidgetBuilder = DashboardWidget.defaultBuilder,
        _speedLimitWidgetBuilder = SpeedLimitWidget.defaultBuilder,
        _maneuverWidgetBuilder = ManeuverWidget.defaultBuilder,
        _trafficLineWidgetBuilder = TrafficLineWidget.defaultBuilder,
        _finishRouteWidgetBuilder = FinishRouteWidget.defaultBuilder,
        _trafficWidgetBuilder = NavigationTrafficWidget.defaultBuilder,
        _parkingWidgetBuilder = NavigationParkingWidget.defaultBuilder,
        _zoomWidgetBuilder = NavigationZoomWidget.defaultBuilder,
        _myLocationwidgetBuilder = NavigationMyLocationWidget.defaultBuilder,
        _compassWidgetBuilder = NavigationCompassWidget.defaultBuilder,
        _betterRoutePromptWidgetBuilder =
            BetterRoutePromptWidget.defaultBuilder;

  @override
  BaseMapWidgetState<NavigationLayoutWidget> createState() =>
      _NavigationLayoutWidgetState();
}

class _NavigationLayoutWidgetState
    extends BaseMapWidgetState<NavigationLayoutWidget> {
  final overlayController = OverlayPortalController();

  final isMapControlsVisible = ValueNotifier<bool>(true);
  Timer? hideMapControlsTimer;
  final hideControlsTimerDuration = const Duration(seconds: 20);
  final betterRoutePromptDuration = const Duration(seconds: 30);
  final dashboardHorizonatalWidthScaleFactor = 2.2;

  StreamSubscription<sdk.State>? navigationStateSubscription;
  final ValueNotifier<sdk.State?> navigationState = ValueNotifier(null);

  final ValueNotifier<bool> isBetterRoutePrompted = ValueNotifier(false);

  late DashboardController dashboardController;
  late CompassController compassController;
  late FinishRouteController finishRouteController;
  late ManeuverController maneuverController;
  late MyLocationController myLocationController;
  late ParkingController parkingController;
  late ZoomController zoomController;
  late SpeedLimitController speedLimitController;
  late TrafficLineController trafficLineController;
  late TrafficController trafficController;
  late BetterRoutePromptController betterRoutePromptController;

  final ValueNotifier<Offset?> dashboardSize = ValueNotifier(null);
  void startHideTimer() {
    hideMapControlsTimer?.cancel();
    hideMapControlsTimer = Timer(hideControlsTimerDuration, () {
      isMapControlsVisible.value = false;
    });
  }

  void handleInteraction() {
    isMapControlsVisible.value = true;
    startHideTimer();
  }

  @override
  void initState() {
    super.initState();
    startHideTimer();
    navigationStateSubscription = widget.navigationManager.uiModel.stateChannel
        .listen((state) => navigationState.value = state);

    navigationState.addListener(() {
      if (navigationState.value == sdk.State.finished) {
        overlayController.show();
      } else {
        if (overlayController.isShowing) overlayController.hide();
      }
    });
  }

  @override
  void dispose() {
    hideMapControlsTimer?.cancel();
    isMapControlsVisible.dispose();
    navigationStateSubscription?.cancel();
    super.dispose();
  }

  double _calculateBottomInset(Offset? size) {
    // ignore: omit_local_variable_types
    const double additionalPadding = 16;
    // ignore: omit_local_variable_types
    const double defaultInset = 80;
    return size?.dy != null
        ? MediaQuery.sizeOf(context).height - size!.dy + additionalPadding
        : defaultInset;
  }

  Widget _mapControlsColumn() {
    return Column(
      children: [
        if (widget._parkingWidgetBuilder != null ||
            widget._trafficWidgetBuilder != null)
          IntrinsicWidth(
            child: Column(
              children: [
                if (widget._trafficWidgetBuilder != null)
                  widget._trafficWidgetBuilder!.call(
                    const RoundedCorners.top(),
                    trafficController,
                  ),
                if (widget._parkingWidgetBuilder != null &&
                    widget._trafficWidgetBuilder != null)
                  const Divider(
                    height: 0,
                    thickness: 1,
                    color: CupertinoColors.separator,
                  ),
                if (widget._parkingWidgetBuilder != null)
                  widget._parkingWidgetBuilder!.call(
                    const RoundedCorners.bottom(),
                    parkingController,
                  ),
              ],
            ),
          ),
        const Spacer(),
        if (widget._zoomWidgetBuilder != null)
          widget._zoomWidgetBuilder!.call(zoomController),
        const Spacer(),
        if (widget._compassWidgetBuilder != null)
          widget._compassWidgetBuilder!.call(compassController),
        if (widget._myLocationwidgetBuilder != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: widget._myLocationwidgetBuilder!.call(myLocationController),
          ),
      ],
    );
  }

  Widget _buildOnGoingNavigationState(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          //
          // Portrait orientation
          //
          return Column(
            children: [
              SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget._maneuverWidgetBuilder != null)
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: widget._maneuverWidgetBuilder!
                              .call(maneuverController),
                        ),
                      ),
                    if (widget._speedLimitWidgetBuilder != null)
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: widget._speedLimitWidgetBuilder!
                              .call(speedLimitController),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (_) => handleInteraction(),
                  onPanDown: (_) => handleInteraction(),
                  child: Stack(
                    children: [
                      if (widget._trafficLineWidgetBuilder != null)
                        ValueListenableBuilder(
                          valueListenable: dashboardSize,
                          child: widget._trafficLineWidgetBuilder!
                              .call(trafficLineController, dashboardController),
                          builder: (context, size, child) {
                            return Positioned(
                              left: 0,
                              bottom: _calculateBottomInset(size),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 4,
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      ValueListenableBuilder(
                        valueListenable: dashboardSize,
                        child: ValueListenableBuilder(
                          valueListenable: isMapControlsVisible,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _mapControlsColumn(),
                          ),
                          builder: (context, isVisible, child) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: isVisible ? 0 : 1,
                                end: isVisible ? 1 : 0,
                              ),
                              duration: const Duration(milliseconds: 300),
                              child: IgnorePointer(
                                ignoring: !isVisible,
                                child: child,
                              ),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Visibility(
                                  visible: value > 0,
                                  child: child!,
                                ),
                              ),
                            );
                          },
                        ),
                        builder: (context, size, child) {
                          return Positioned(
                            top: 0,
                            right: 0,
                            bottom: _calculateBottomInset(size),
                            child: child!,
                          );
                        },
                      ),
                      if (isBetterRoutePrompted.value &&
                          widget._betterRoutePromptWidgetBuilder != null)
                        SafeArea(
                          child: Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: widget._betterRoutePromptWidgetBuilder!.call(
                              betterRoutePromptController,
                              betterRoutePromptDuration,
                            ),
                          ),
                        ),
                      if (widget._dashboardWidgetBuilder != null)
                        Visibility.maintain(
                          visible: !isBetterRoutePrompted.value,
                          child: IgnorePointer(
                            ignoring: isBetterRoutePrompted.value,
                            child: ValueListenableBuilder(
                              valueListenable: navigationState,
                              child: Align(
                                alignment: AlignmentDirectional.bottomCenter,
                                child: widget._dashboardWidgetBuilder!.call(
                                  dashboardController,
                                  (p0) => dashboardSize.value = p0,
                                ),
                              ),
                              builder: (context, state, child) {
                                if (widget._dashboardWidgetBuilder != null &&
                                    navigationState.value !=
                                        sdk.State.finished) {
                                  return child!;
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
          //
          // Landscape orientation
          //
        } else {
          return SafeArea(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          if (widget._maneuverWidgetBuilder != null)
                            Align(
                              alignment: AlignmentDirectional.topStart,
                              child: widget._maneuverWidgetBuilder!
                                  .call(maneuverController),
                            ),
                          Expanded(
                            flex: 20,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTapDown: (_) => handleInteraction(),
                              onPanDown: (_) => handleInteraction(),
                              child: Align(
                                alignment: AlignmentDirectional.bottomStart,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final newConstraints = constraints.copyWith(
                                      maxWidth: constraints.maxWidth /
                                          dashboardHorizonatalWidthScaleFactor,
                                    );
                                    return ConstrainedBox(
                                      constraints: newConstraints,
                                      child: Stack(
                                        children: [
                                          if (isBetterRoutePrompted.value &&
                                              widget._betterRoutePromptWidgetBuilder !=
                                                  null)
                                            SafeArea(
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .bottomCenter,
                                                child: widget
                                                    ._betterRoutePromptWidgetBuilder!
                                                    .call(
                                                  betterRoutePromptController,
                                                  betterRoutePromptDuration,
                                                ),
                                              ),
                                            ),
                                          if (widget._dashboardWidgetBuilder !=
                                              null)
                                            Visibility.maintain(
                                              visible:
                                                  !isBetterRoutePrompted.value,
                                              child: IgnorePointer(
                                                ignoring:
                                                    isBetterRoutePrompted.value,
                                                child: ValueListenableBuilder(
                                                  valueListenable:
                                                      navigationState,
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .bottomCenter,
                                                    child: widget
                                                        ._dashboardWidgetBuilder!
                                                        .call(
                                                      dashboardController,
                                                      (p0) => dashboardSize
                                                          .value = p0,
                                                    ),
                                                  ),
                                                  builder:
                                                      (context, state, child) {
                                                    if (widget._dashboardWidgetBuilder !=
                                                            null &&
                                                        navigationState.value !=
                                                            sdk.State
                                                                .finished) {
                                                      return child!;
                                                    } else {
                                                      return const SizedBox
                                                          .shrink();
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: widget._speedLimitWidgetBuilder!
                            .call(speedLimitController),
                      ),
                      ValueListenableBuilder(
                        valueListenable: isMapControlsVisible,
                        builder: (context, isVisible, _) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: isVisible ? 0 : 1,
                                end: isVisible ? 1 : 0,
                              ),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Visibility(
                                  visible: value > 0,
                                  child: IgnorePointer(
                                    ignoring: !isVisible,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _mapControlsColumn(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (widget._trafficLineWidgetBuilder != null)
                  ValueListenableBuilder(
                    valueListenable: isMapControlsVisible,
                    builder: (context, isVisible, _) {
                      return Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: isVisible ? 1 : 0,
                            end: isVisible ? 0 : 1,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Visibility(
                              visible: value > 0,
                              child: IgnorePointer(
                                ignoring: isVisible,
                                child: widget._trafficLineWidgetBuilder!.call(
                                  trafficLineController,
                                  dashboardController,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildFinishedNavigationState(BuildContext context) {
    if (widget._finishRouteWidgetBuilder != null) {
      const minLeftPadding = 38.0;
      const widthCoefficient = .54;

      final systemPadding = MediaQuery.paddingOf(context);
      final size = MediaQuery.sizeOf(context);

      var leftInset = .0;
      var rightInset = .0;

      if (MediaQuery.orientationOf(context) == Orientation.landscape) {
        leftInset = max(systemPadding.left, minLeftPadding);
        rightInset = size.width * widthCoefficient;
      }
      return OverlayPortal(
        controller: overlayController,
        overlayChildBuilder: (context) {
          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return widget._finishRouteWidgetBuilder!
                    .call(finishRouteController);
              }
              return Stack(
                children: [
                  Positioned(
                    left: leftInset,
                    right: rightInset,
                    top: 0,
                    bottom: 0,
                    child: widget._finishRouteWidgetBuilder!
                        .call(finishRouteController),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: navigationState,
      builder: (context, state, _) {
        return switch (state) {
          null => const SizedBox.shrink(),
          // TODO: add distinguish states for free roam.
          sdk.State.disabled ||
          sdk.State.navigation ||
          sdk.State.routeSearch =>
            _buildOnGoingNavigationState(context),
          sdk.State.finished => _buildFinishedNavigationState(context),
        };
      },
    );
  }

  @override
  void onAttachedToMap(sdk.Map map) {
    widget.navigationManager.mapManager.addMap(map);
    map.camera.setBehaviour(
      widget.navigationManager.mapFollowController.cameraBehaviour,
    );
    map.camera.positionPoint = const sdk.CameraPositionPoint(y: 5.0 / 6.5);

    dashboardController = DashboardController(
      navigationManager: widget.navigationManager,
      map: map,
    );
    compassController = CompassController(map: map);
    finishRouteController = FinishRouteController(
      map: map,
      navigationManager: widget.navigationManager,
    );
    maneuverController =
        ManeuverController(navigationManager: widget.navigationManager);
    myLocationController = MyLocationController(map: map);
    parkingController = ParkingController(map: map);
    zoomController = ZoomController(map: map);
    speedLimitController =
        SpeedLimitController(navigationManager: widget.navigationManager);
    trafficLineController =
        TrafficLineController(navigationManager: widget.navigationManager);
    trafficController = TrafficController(map: map);
    betterRoutePromptController = BetterRoutePromptController(
      navigationManager: widget.navigationManager,
      onBetterRoutePrompted: (info) {
        isBetterRoutePrompted.value = true;
        setState(() {});
      },
      onBetterRouteRejected: () {
        isBetterRoutePrompted.value = false;
        setState(() {});
      },
      onBetterRouteTimedOut: () {
        isBetterRoutePrompted.value = false;
        setState(() {});
      },
      onBetterRouteAccepted: (info) {
        isBetterRoutePrompted.value = false;
        setState(() {});
      },
    );
  }

  @override
  void onDetachedFromMap() {
    dashboardController.dispose();
    compassController.dispose();
    finishRouteController.dispose();
    maneuverController.dispose();
    myLocationController.dispose();
    parkingController.dispose();
    zoomController.dispose();
    speedLimitController.dispose();
    trafficLineController.dispose();
    trafficController.dispose();
    betterRoutePromptController.dispose();
  }
}
