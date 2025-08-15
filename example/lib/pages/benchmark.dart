import 'dart:async';

import 'package:async/async.dart';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../fps_graph_painter.dart';
import 'camera_paths.dart';
import 'common.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({required this.title, super.key});

  final String title;

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  final sdkContext = AppContainer().initializeSdk();
  final mapWidgetController = sdk.MapWidgetController();
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
    fpsSubscription = mapWidgetController.fpsChannel.listen((fps) {
      setState(() {
        lastFps = fps.value.toDouble();
        fpsValues.add(lastFps);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          sdk.MapWidget(
            sdkContext: sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: mapWidgetController,
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
    mapWidgetController
      ..getMapAsync((map) {
        sdkMap = map;
      })
      ..copyrightAlignment = Alignment.bottomLeft;
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

class FPSGraph extends StatelessWidget {
  final List<double> fpsValues;
  final double lastFps;
  final double averageFps;
  final double onePercentLow;
  final double zeroPointOnePercentLow;
  final double maxFps;

  const FPSGraph({
    required this.fpsValues,
    required this.lastFps,
    required this.averageFps,
    required this.onePercentLow,
    required this.zeroPointOnePercentLow,
    this.maxFps = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomPaint(
              painter: FPSGraphPainter(fpsValues: fpsValues, maxFps: maxFps),
              child: Container(),
            ),
          ),
          Text(
            'FPS: ${lastFps.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Avg: ${averageFps.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '1%: ${onePercentLow.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '0.1%: ${zeroPointOnePercentLow.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
