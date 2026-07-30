import 'package:flutter/material.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/map/map_options.dart';
import '../../map/map_widget.dart';
import '../dashboard/dashboard_controller.dart';
import 'navigation_minimap_controller.dart';

class NavigationMiniMapWidget extends StatefulWidget {
  final sdk.Context sdkContext;
  final MapOptions mapOptions;
  final MapWidgetController controller;
  final double size;
  final NavigationMiniMapController miniMapController;
  final DashboardController? dashboardController;

  static const double _defaultSize = 160;
  static const double _maxSize = 300;

  const NavigationMiniMapWidget({
    required this.sdkContext,
    required this.mapOptions,
    required this.controller,
    required this.miniMapController,
    this.dashboardController,
    this.size = _defaultSize,
    super.key,
  }) : assert(size <= _maxSize);

  double get _effectiveSize => size.clamp(0, _maxSize);

  @override
  State<NavigationMiniMapWidget> createState() =>
      _NavigationMiniMapWidgetState();
}

class _NavigationMiniMapWidgetState extends State<NavigationMiniMapWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.getMapAsync(widget.miniMapController.onMapReady);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget._effectiveSize;

    return GestureDetector(
      onTap: widget.dashboardController?.showRoute,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Opacity(
            opacity: 0.75,
            child: Center(
              child: MapWidgetInternal(
                sdkContext: widget.sdkContext,
                mapOptions: widget.mapOptions,
                controller: widget.controller,
                showCopyright: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
