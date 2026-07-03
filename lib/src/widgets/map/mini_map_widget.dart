import 'package:flutter/material.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../platform/map/map_widget_options.dart';
import 'map_widget.dart';

class MiniMapWidget extends StatefulWidget {
  final sdk.Context sdkContext;
  final MapWidgetController controller;
  final MapWidgetOptions viewOptions;
  final double size;

  static const double _defaultSize = 160;
  static const double _maxSize = 300;

  const MiniMapWidget({
    required this.sdkContext,
    required this.controller,
    this.viewOptions = const MapWidgetOptions(),
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

    widget.controller.map
      ..interactive = false
      ..graphicsPreset = sdk.GraphicsPreset.lite;
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
              controller: widget.controller,
              viewOptions: widget.viewOptions,
              showCopyright: false,
            ),
          ),
        ),
      ),
    );
  }
}
