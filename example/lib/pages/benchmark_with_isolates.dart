import 'dart:async';
import 'dart:isolate';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'benchmark/benchmark_polygons.dart';
import 'benchmark/camera_paths.dart';
import 'benchmark/fps_graph.dart';
import 'common.dart';

class BenchmarkWithIsolatesPage extends StatefulWidget {
  const BenchmarkWithIsolatesPage({required this.title, super.key});

  final String title;

  @override
  State<BenchmarkWithIsolatesPage> createState() =>
      _BenchmarkWithIsolatesPageState();
}

class _BenchmarkWithIsolatesPageState extends State<BenchmarkWithIsolatesPage> {
  final sdkContext = AppContainer().initializeSdk();
  sdk.MapWidgetController? mapWidgetController;
  final List<double> fpsValues = [];

  sdk.Map? sdkMap;
  sdk.MapObjectManager? mapObjectManager;
  sdk.GeometryMapObjectSource? geometryMapObjectSource;
  double lastFps = 0;
  StreamSubscription<sdk.Fps>? fpsSubscription;
  Isolate? _runningIsolate;
  ReceivePort? _receivePort;

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

    _killIsolate();

    mapObjectManager?.removeAll();
    geometryMapObjectSource?.clear();

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
    final source =
        sdk.GeometryMapObjectSourceBuilder(sdkContext).createSource();
    geometryMapObjectSource = source;
    final createdMapWidgetController = await createMapWidgetController(
      sdkContext,
    );
    if (!mounted) {
      return;
    }

    final map = createdMapWidgetController.map..addSource(source);
    sdkMap = map;
    mapObjectManager = sdk.MapObjectManager(map);
    setState(() {
      mapWidgetController = createdMapWidgetController
        ..copyrightAlignment = Alignment.bottomLeft;
    });
  }

  void _showActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Benchmark'),
        actions: CameraPathType.values.map((pathType) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, pathType.name);
              _testCamera(pathType);
            },
            child: Text(
              pathType.name.split('.').last,
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

  Future<void> _testCamera(CameraPathType pathType) async {
    final map = sdkMap;
    final manager = mapObjectManager;
    final source = geometryMapObjectSource;
    if (map == null || manager == null || source == null) {
      return;
    }
    manager.removeAll();
    source.clear();

    await _startFpsTracking();

    String? moscowGeoJson;
    if (pathType == CameraPathType.moscowGeoJson) {
      moscowGeoJson =
          await rootBundle.loadString('assets/json/moscow_geo_json.json');
    }

    _killIsolate();

    // Запуск движения в изоляте
    _receivePort = ReceivePort();
    _runningIsolate = await Isolate.spawn(
      _moveIsolateEntry,
      _IsolateMoveData(
        sendPort: _receivePort!.sendPort,
        mapMessage: map.message(),
        mapObjectManagerMessage: manager.message(),
        geometryMapObjectSourceMessage: source.message(),
        moscowGeoJson: moscowGeoJson,
        cameraPathType: pathType,
      ),
    );
  }

  void _killIsolate() {
    _receivePort?.close();
    _runningIsolate?.kill(priority: Isolate.immediate);
    _runningIsolate = null;
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

class _IsolateMoveData {
  final SendPort sendPort;
  final sdk.ClassMessage<sdk.Map> mapMessage;
  final sdk.ClassMessage<sdk.MapObjectManager> mapObjectManagerMessage;
  final sdk.ClassMessage<sdk.GeometryMapObjectSource>
      geometryMapObjectSourceMessage;
  final String? moscowGeoJson;
  final CameraPathType cameraPathType;

  _IsolateMoveData({
    required this.sendPort,
    required this.mapMessage,
    required this.mapObjectManagerMessage,
    required this.geometryMapObjectSourceMessage,
    required this.moscowGeoJson,
    required this.cameraPathType,
  });
}

Future<void> _moveIsolateEntry(_IsolateMoveData data) async {
  final selectedPath = cameraPaths[data.cameraPathType];
  if (selectedPath == null) {
    data.sendPort.send(false);
    return;
  }

  final sdkMap = sdk.Map.fromMessage(data.mapMessage);
  sdkMap.camera.position = sdk.CameraPosition(
    point: selectedPath.first.$1.point,
    zoom: const sdk.Zoom(13),
  );

  switch (data.cameraPathType) {
    case CameraPathType.polygonsFlight:
      _addPolygonsOnMap(data);
    case CameraPathType.moscowGeoJson:
      _parseGeoJsonAndObjectsInGeometrySource(data);
    default:
      break;
  }

  await _moveIsolateEntryImpl(0, selectedPath, sdkMap);

  data.sendPort.send(true);
}

void _addPolygonsOnMap(_IsolateMoveData data) {
  final mapObjectManager =
      sdk.MapObjectManager.fromMessage(data.mapObjectManagerMessage);
  for (final polygonOptions in PolygonOptionsExtension.testPolygons) {
    mapObjectManager.addObject(sdk.Polygon(polygonOptions));
  }
}

void _parseGeoJsonAndObjectsInGeometrySource(_IsolateMoveData data) {
  if (data.moscowGeoJson == null) return;
  final geometryObjects = sdk.parseGeoJson(data.moscowGeoJson!);
  sdk.GeometryMapObjectSource.fromMessage(data.geometryMapObjectSourceMessage)
      .addObjects(geometryObjects);
}

Future<void> _moveIsolateEntryImpl(
  int index,
  CameraPath path,
  sdk.Map sdkMap,
) async {
  if (index >= path.length) {
    return;
  }
  final tuple = path[index];
  final moveCameraCancellable =
      sdkMap.camera.moveToCameraPosition(tuple.$1, tuple.$2, tuple.$3);
  await moveCameraCancellable.value.then((value) {
    moveCameraCancellable.cancel();
    _moveIsolateEntryImpl(index + 1, path, sdkMap);
  });
}
