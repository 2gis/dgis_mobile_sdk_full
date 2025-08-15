import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'common.dart';

class MapSnapshotPage extends StatefulWidget {
  const MapSnapshotPage({required this.title, super.key});

  final String title;

  @override
  State<MapSnapshotPage> createState() => _MapSnapshotState();
}

class _MapSnapshotState extends State<MapSnapshotPage> {
  final sdkContext = AppContainer().initializeSdk();
  final mapWidgetController = sdk.MapWidgetController();
  final ValueNotifier<ByteData?> imageData = ValueNotifier(null);
  double mapHeight = 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _MeasureSize(
          onChange: (newSize) {
            setState(() {
              mapHeight = newSize.height / 2.0 - 50.0;
            });
          },
          child: Column(
            children: <Widget>[
              SizedBox(
                height: mapHeight,
                child: sdk.MapWidget(
                  sdkContext: sdkContext,
                  mapOptions: sdk.MapOptions(),
                  controller: mapWidgetController,
                ),
              ),
              SizedBox(
                height: 50,
                child: Center(
                  child: ElevatedButton(
                    child: const Text('Take snapshot'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      elevation: 0,
                    ),
                    onPressed: _takeSnapshot,
                  ),
                ),
              ),
              SizedBox(
                height: mapHeight,
                child: ValueListenableBuilder<ByteData?>(
                  valueListenable: imageData,
                  builder: (_, imageDataValue, __) =>
                      _makeImageWidget(imageDataValue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _makeImageWidget(ByteData? imageData) {
    if (imageData == null) {
      return const Center(
        child: Text('Snapshot will appear here'),
      );
    }
    return Align(
      alignment: Alignment.topLeft,
      child: Image.memory(imageData.buffer.asUint8List()),
    );
  }

  void _takeSnapshot() {
    mapWidgetController.getMapAsync(
      (map) {
        mapWidgetController.takeSnapshot().value.then((uiImage) {
          setState(() {
            imageData.value = uiImage;
          });
        });
      },
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class _MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size;
    if (newSize == null || oldSize == newSize) {
      return;
    }

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const _MeasureSize({
    required this.onChange,
    required Widget super.child,
    // ignore: unused_element, unused_element_parameter
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}
