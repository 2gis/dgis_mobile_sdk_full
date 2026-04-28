import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import './route_editor_controller.dart';
import 'transport_mode.dart';

/// Immutable model containing brief information about a route.
///
/// This model provides essential route information without the full route details.
@immutable
class BriefInfo {
  /// The estimated duration to complete the route.
  final Duration duration;

  const BriefInfo({
    required this.duration,
  });
}

/// Abstract provider for brief route information across all transport types.
///
/// This provider extends [ValueNotifier] and holds a map of [TransportMode] to
/// [BriefInfo], automatically updating when dependencies change.
///
/// Implementations must:
/// * Initialize with a [RouteEditorController] via [initialize]
/// * Update the value map when relevant data changes
/// * Dispose of all resources in [dispose]
///
/// The provider is reactive and notifies listeners whenever brief info changes
/// for any transport type.
abstract class BriefInfoProvider
    extends ValueNotifier<Map<TransportMode, BriefInfo?>> {
  BriefInfoProvider() : super({});

  /// Initializes the provider with the route editor controller.
  ///
  /// This method is called automatically by [RouteEditorController] after
  /// construction. Implementations should set up listeners and subscriptions here.
  void initialize(RouteEditorController controller);

  @override
  void dispose();
}

/// Provides brief route information by fetching from [sdk.TrafficRouter].
///
/// This provider automatically fetches brief route information for all available
/// transport types whenever route points change. It uses the SDK's [sdk.TrafficRouter]
/// to calculate estimated durations without computing full routes.
///
/// Usage example:
/// ```dart
/// final provider = TrafficRouterBriefInfoProvider(
///   trafficRouter: trafficRouter,
/// );
///
/// final controller = RouteEditorController(
///   routeEditor: routeEditor,
///   briefInfoProvider: provider,
/// );
///
/// // Provider automatically updates when route points change
/// provider.addListener(() {
///   final briefInfo = provider.value;
///   print('Car duration: ${briefInfo[TransportMode.car]?.duration}');
/// });
/// ```
///
/// The provider fetches brief info for all transport types in parallel,
/// providing fast estimates without full route calculation.
class TrafficRouterBriefInfoProvider extends BriefInfoProvider {
  /// The traffic router instance used to fetch brief route information.
  final sdk.TrafficRouter trafficRouter;

  RouteEditorController? controller;

  StreamSubscription<void>? _routePointsSubscription;
  bool _isLoading = false;

  TrafficRouterBriefInfoProvider({
    required this.trafficRouter,
  });

  @override
  void initialize(RouteEditorController controller) {
    this.controller = controller;
    controller.routePoints.addListener(_updateBriefInfo);
    _updateBriefInfo();
  }

  Future<void> _updateBriefInfo() async {
    if (_isLoading || controller == null) return;
    _isLoading = true;

    try {
      if (controller!.routePoints.value.isEmpty) {
        value = {};
        return;
      }

      final startPoint = controller!.routePoints.value.first.point;
      final finishPoint = controller!.routePoints.value.last.point;
      final newValue = <TransportMode, BriefInfo?>{};

      await Future.wait(
        controller!.availableTransportModes.map((transportType) async {
          final options =
              controller!.transportTypeOptionsProvider.provide(transportType);
          final briefInfoList = await trafficRouter.findBriefRouteInfos(
            [
              sdk.BriefRouteInfoSearchPoints(
                startPoint: startPoint,
                finishPoint: finishPoint,
              ),
            ],
            options,
          ).value;

          if (briefInfoList.isNotEmpty && briefInfoList[0] != null) {
            final briefInfo = briefInfoList[0]!;
            newValue[transportType] = BriefInfo(
              duration: briefInfo.duration,
            );
          } else {
            newValue[transportType] = null;
          }
        }),
      );

      value = newValue;
    } finally {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _routePointsSubscription?.cancel();
    controller?.routePoints.removeListener(_updateBriefInfo);
    super.dispose();
  }
}

/// Provides brief route information from the currently active calculated route.
///
/// This provider extracts brief information from routes that have already been
/// calculated by the route editor. It updates whenever the active route or
/// route list changes.
///
/// Usage example:
/// ```dart
/// final provider = ActiveRouteBriefInfoProvider();
///
/// final controller = RouteEditorController(
///   routeEditor: routeEditor,
///   briefInfoProvider: provider,
/// );
///
/// // Provider automatically updates when routes are calculated
/// provider.addListener(() {
///   final briefInfo = provider.value;
///   final activeType = controller.activeTransportMode.value;
///   if (activeType != null) {
///     print('Active route duration: ${briefInfo[activeType]?.duration}');
///   }
/// });
/// ```
///
/// This is the default provider used by [RouteEditorController] if no other
/// provider is specified. It's more efficient than [TrafficRouterBriefInfoProvider]
/// since it uses already-calculated route data.
///
/// The provider caches brief info for transport types that have already been
/// calculated, preserving them when switching between tabs.
class ActiveRouteBriefInfoProvider extends BriefInfoProvider {
  RouteEditorController? controller;

  StreamSubscription<sdk.RouteEditorRoutesInfo>? _routesInfoSubscription;

  ActiveRouteBriefInfoProvider();

  @override
  void initialize(RouteEditorController controller) {
    this.controller = controller;

    _routesInfoSubscription = withBssEventsSourceFromSdk(
      () => controller.routeEditor.routesInfoChannel,
    ).listen((_) => _updateBriefInfo());
    controller.routePoints.addListener(_onRoutePointsChanged);
    _updateBriefInfo();
  }

  void _onRoutePointsChanged() {
    value = {};
  }

  void _updateBriefInfo() {
    if (controller == null) return;

    final routesInfo = controller!.routeEditor.routesInfoChannel.value;
    if (routesInfo.routes.isEmpty) {
      return;
    }

    final activeRoute = routesInfo.routes[0];
    final briefInfo = BriefInfo(
      duration: activeRoute.traffic.durations.duration,
    );

    final activeType = controller!.activeTransportMode.value;
    if (activeType == null) {
      return;
    }

    final newValue = Map<TransportMode, BriefInfo?>.from(value);
    newValue[activeType] = briefInfo;
    value = newValue;
  }

  @override
  void dispose() {
    _routesInfoSubscription?.cancel();
    controller?.routePoints.removeListener(_onRoutePointsChanged);
    super.dispose();
  }
}
