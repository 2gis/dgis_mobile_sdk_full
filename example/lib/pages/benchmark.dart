import 'dart:async';

import 'package:async/async.dart';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'benchmark/camera_paths.dart';
import 'benchmark/fps_graph.dart';
import 'common.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({required this.title, super.key});

  final String title;

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  final sdkContext = AppContainer().initializeSdk();
  sdk.MapWidgetController? mapWidgetController;
  final List<double> fpsValues = [];

  sdk.Map? sdkMap;
  CancelableOperation<sdk.CameraAnimatedMoveResult>? moveCameraCancellable;
  StreamSubscription<sdk.Location?>? locationSubscription;
  double lastFps = 0;
  StreamSubscription<sdk.Fps>? fpsSubscription;

  //TODO: Сделать получение максимального фпс для девайса
  double maxFps = 120;

  @override
  void initState() {
    super.initState();
    initContext();
  }

  @override
  void dispose() {
    fpsSubscription?.cancel();
    locationSubscription?.cancel();
    moveCameraCancellable?.cancel();
    super.dispose();
  }

  Future<void> _startFpsTracking() async {
    await fpsSubscription?.cancel();
    fpsValues.clear();
    fpsSubscription = mapWidgetController?.fpsChannel.listen((fps) {
      setState(() {
        lastFps = fps.value.toDouble();
        fpsValues.add(lastFps);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMapWidgetController = mapWidgetController;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _showActionSheet,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          if (currentMapWidgetController == null)
            const SizedBox.shrink()
          else
            sdk.MapWidget(
              sdkContext: sdkContext,
              controller: currentMapWidgetController,
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FPSGraph(
              fpsValues: fpsValues,
              lastFps: lastFps,
              averageFps: _averageFps,
              onePercentLow: _calculatePercentile(0.01),
              zeroPointOnePercentLow: _calculatePercentile(0.001),
              maxFps: maxFps,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initContext() async {
    final createdMapWidgetController = await createMapWidgetController(
      sdkContext,
    );
    if (!mounted) {
      return;
    }

    sdkMap = createdMapWidgetController.map;
    setState(() {
      mapWidgetController = createdMapWidgetController
        ..copyrightAlignment = Alignment.bottomLeft;
    });
  }

  void _showActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Map scenarios'),
        actions: CameraPathType.values.map((pathType) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, pathType.toString());
              _testCamera(pathType);
            },
            child: Text(
              pathType.toString().split('.').last,
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _testCamera(CameraPathType pathType) {
    locationSubscription?.cancel();
    locationSubscription = null;
    if (sdkMap == null) {
      return;
    }
    _startFpsTracking();

    final selectedPath = cameraPaths[pathType];
    if (selectedPath != null) {
      sdkMap?.camera.position = sdk.CameraPosition(
        point: selectedPath.first.$1.point,
        zoom: const sdk.Zoom(13),
      );
      _move(0, selectedPath);
    }
  }

  Future<void> _move(int index, CameraPath path) async {
    if (index >= path.length) {
      return;
    }
    final tuple = path[index];
    moveCameraCancellable =
        sdkMap?.camera.moveToCameraPosition(tuple.$1, tuple.$2, tuple.$3);
    await moveCameraCancellable?.value.then((value) {
      _move(index + 1, path);
    });
  }

  List<double> filterLeadingZeros(List<double> fpsValues) {
    final firstNonZeroIndex = fpsValues.indexWhere((fps) => fps > 0);
    if (firstNonZeroIndex != -1) {
      return fpsValues.sublist(firstNonZeroIndex);
    } else {
      return [];
    }
  }

  double get _averageFps {
    final filteredFpsValues = filterLeadingZeros(fpsValues);
    if (filteredFpsValues.isEmpty) return 0;
    return filteredFpsValues.reduce((a, b) => a + b) / filteredFpsValues.length;
  }

  double _calculatePercentile(double percentile) {
    final filteredFpsValues = filterLeadingZeros(fpsValues);
    if (filteredFpsValues.isEmpty) return 0;
    final sortedValues = List<double>.from(filteredFpsValues)..sort();
    final index = ((percentile * sortedValues.length).ceil() - 1)
        .clamp(0, sortedValues.length - 1);
    return sortedValues[index];
  }
}
