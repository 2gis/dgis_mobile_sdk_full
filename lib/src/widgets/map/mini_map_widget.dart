import 'package:flutter/material.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../platform/map/map_options.dart';
import 'map_widget.dart';

class MiniMapWidget extends StatefulWidget {
  final sdk.Context sdkContext;
  final MapOptions mapOptions;
  final MapWidgetController controller;
  final double size;

  static const double _defaultSize = 160;
  static const double _maxSize = 300;

  const MiniMapWidget({
    required this.sdkContext,
    required this.mapOptions,
    required this.controller,
    this.size = _defaultSize,
    super.key,
  }) : assert(size <= _maxSize);

  double get _effectiveSize => size.clamp(0, _maxSize);

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  @override
  void initState() {
    super.initState();

    widget.controller.getMapAsync((map) {
      map
        ..interactive = false
        ..graphicsPreset = sdk.GraphicsPreset.lite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget._effectiveSize;

    return ClipOval(
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
    );
  }
}
