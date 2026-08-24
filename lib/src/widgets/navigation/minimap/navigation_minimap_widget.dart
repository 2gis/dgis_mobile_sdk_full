import 'dart:async';

import 'package:flutter/material.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/map/map_widget_options.dart';
import '../../map/map_widget.dart';
import '../dashboard/dashboard_controller.dart';
import 'navigation_minimap_controller.dart';

class NavigationMiniMapWidget extends StatefulWidget {
  final sdk.Context sdkContext;
  final MapWidgetController controller;
  final MapWidgetOptions viewOptions;
  final double size;
  final NavigationMiniMapController miniMapController;
  final DashboardController? dashboardController;

  static const double _defaultSize = 160;
  static const double _maxSize = 300;

  const NavigationMiniMapWidget({
    required this.sdkContext,
    required this.controller,
    required this.miniMapController,
    this.dashboardController,
    this.viewOptions = const MapWidgetOptions(),
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
    unawaited(_onMapReady());
  }

  Future<void> _onMapReady() async {
    final map = await widget.controller.mapAsync;
    if (!mounted) {
      return;
    }

    widget.miniMapController.onMapReady(map);
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
                controller: widget.controller,
                viewOptions: widget.viewOptions,
                showCopyright: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
