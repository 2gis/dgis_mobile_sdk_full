import 'dart:async';
import 'dart:math';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';

enum _MarkerType { scooterPng, bridgeSvg, batLottie }

enum _GroupingType {
  clustering,
  generalization,
}

class ClusteringPage extends StatefulWidget {
  const ClusteringPage({required this.title, super.key});

  final String title;

  @override
  State<ClusteringPage> createState() => _SamplePageState();
}

class _SamplePageState extends State<ClusteringPage> {
  final sdkContext = AppContainer().initializeSdk();
  final mapWidgetController = sdk.MapWidgetController();
  final List<sdk.Marker> markers = [];
  final formKey = GlobalKey<FormState>();
  final scooterAssetsPath = 'assets/icons/scooter_model.png';
  final bridgeAssetsPath = 'assets/icons/bridge.svg';
  final batAssetsPath = 'assets/icons/bat.json';
  final clusterAssetsPath = 'assets/icons/icon_circle.png';
  final imageCache = <String, sdk.Image>{};
  static int markersCount = 0;

  late sdk.ImageLoader loader;
  late sdk.Camera camera;

  sdk.Map? sdkMap;
  sdk.MapObjectManager? mapObjectManager;
  int objectsCountText = 100;
  double minZoomText = 0;
  double maxZoomText = 19;
  _GroupingType? selectedGroupingType = _GroupingType.clustering;
  _MarkerType markerType = _MarkerType.scooterPng;
  sdk.SimpleClusterRenderer? clusterRenderer;

  Future<sdk.SimpleClusterRenderer> get lazyClusterRenderer async {
    clusterRenderer ??= SimpleClusterRendererImpl(
      image: await loader.loadPngFromAsset(clusterAssetsPath, 64, 64),
    );
    return clusterRenderer!;
  }

  @override
  void initState() {
    super.initState();
    initContext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          sdk.MapWidget(
            sdkContext: sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: mapWidgetController,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: CupertinoButton(
              onPressed: _show,
              child: const Icon(Icons.format_list_bulleted),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: CupertinoButton(
              onPressed: _showSettings,
              child: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initContext() async {
    loader = sdk.ImageLoader(sdkContext);
    mapWidgetController
      ..getMapAsync((map) async {
        sdkMap = map;
        mapObjectManager = await _makeMapObjectManager(
          map,
          _GroupingType.clustering,
          minZoomText,
          maxZoomText,
        );
        camera = map.camera;
        await _waitNotNullMapSize();
        await _add();
      })
      ..copyrightAlignment = Alignment.bottomLeft;
  }

  Future<void> _waitNotNullMapSize() async {
    final completer = Completer<void>();
    final subscription = camera.sizeChannel.listen((size) {
      if (size.height > 0) {
        completer.complete();
      }
    });
    await completer.future;
    await subscription.cancel();
  }

  void _show() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: _add,
            child: const Text('Add markers'),
          ),
          CupertinoActionSheetAction(
            onPressed: _removeMarkers,
            child: const Text('Delete markers'),
          ),
          CupertinoActionSheetAction(
            onPressed: _removeAndAddMarkers,
            child: const Text('Delete and add markers'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              mapObjectManager = await _makeMapObjectManager(
                sdkMap!,
                selectedGroupingType!,
                minZoomText,
                maxZoomText,
              );
            },
            child: const Text('ReInit MapObjectManager'),
          ),
          CupertinoActionSheetAction(
            onPressed: _removeAll,
            child: const Text('Delete all markers'),
          ),
        ],
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

  void _showSettings() {
    final objectsCount =
        TextEditingController(text: objectsCountText.toString());
    final minZoomController =
        TextEditingController(text: minZoomText.toString());
    final maxZoomController =
        TextEditingController(text: maxZoomText.toString());

    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Options'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  height: 250,
                  width: 50,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      ListTile(
                        title: TextFormField(
                          controller: objectsCount,
                          decoration: const InputDecoration(
                            labelText: 'Number of mutable objects',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid integer';
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: minZoomController,
                          decoration: const InputDecoration(
                            labelText: 'Min Zoom',
                          ),
                          validator: _validateDouble,
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: maxZoomController,
                          decoration: const InputDecoration(
                            labelText: 'Max Zoom',
                          ),
                          validator: _validateDouble,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Grouping type:'),
                      Column(
                        children: <Widget>[
                          RadioListTile<_GroupingType>(
                            title: const Text('Clustering'),
                            value: _GroupingType.clustering,
                            groupValue: selectedGroupingType,
                            onChanged: (value) {
                              setState(() {
                                selectedGroupingType = value;
                              });
                            },
                          ),
                          RadioListTile<_GroupingType>(
                            title: const Text('Generalization'),
                            value: _GroupingType.generalization,
                            groupValue: selectedGroupingType,
                            onChanged: (value) {
                              setState(() {
                                selectedGroupingType = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const Text('Marker type:'),
                      Column(
                        children: <Widget>[
                          RadioListTile<_MarkerType>(
                            title: const Text('Scooter'),
                            value: _MarkerType.scooterPng,
                            groupValue: markerType,
                            onChanged: (value) =>
                                setState(() => markerType = value!),
                          ),
                          RadioListTile<_MarkerType>(
                            title: const Text('Bridge'),
                            value: _MarkerType.bridgeSvg,
                            groupValue: markerType,
                            onChanged: (value) =>
                                setState(() => markerType = value!),
                          ),
                          RadioListTile<_MarkerType>(
                            title: const Text('Bat'),
                            value: _MarkerType.batLottie,
                            groupValue: markerType,
                            onChanged: (value) =>
                                setState(() => markerType = value!),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      objectsCountText = int.tryParse(objectsCount.text)!;
                      minZoomText = double.tryParse(minZoomController.text)!;
                      maxZoomText = double.tryParse(maxZoomController.text)!;
                      mapObjectManager = await _makeMapObjectManager(
                        sdkMap!,
                        selectedGroupingType!,
                        minZoomText,
                        maxZoomText,
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _add() async {
    for (var i = 0; i < objectsCountText; i++) {
      markersCount++;
      final markerOptions = sdk.MarkerOptions(
        icon: await _getMarkerImage(markerType),
        position: _makePoint(),
        iconWidth: const sdk.LogicalPixel(30),
        text: 'marker $markersCount',
        userData: 'marker ${markers.length}',
      );
      markers.add(
        sdk.Marker(markerOptions),
      );
    }
    mapObjectManager?.addObjects(markers);
  }

  void _removeMarkers() {
    if (objectsCountText >= markers.length) {
      _removeAll();
      return;
    }
    mapObjectManager?.removeObjects(markers.sublist(0, objectsCountText));
    markers.removeRange(0, objectsCountText);
  }

  void _removeAndAddMarkers() {
    if (objectsCountText <= markers.length) {
      mapObjectManager?.removeObjects(markers.sublist(0, objectsCountText));
      markers.removeRange(0, objectsCountText);
      _add();
    } else {
      _removeAll();
      _add();
    }
  }

  void _removeAll() {
    mapObjectManager?.removeAll();
    markers.clear();
  }

  sdk.GeoPointWithElevation _makePoint() {
    final random = Random();
    final minHeight = camera.size.height / 3;
    final maxHeight = camera.size.height - (camera.size.height / 3);
    final randomHeight =
        minHeight + (random.nextDouble() * (maxHeight - minHeight));

    final point = camera.projection.screenToMap(
      sdk.ScreenPoint(
        x: random.nextDouble() * camera.size.width,
        y: randomHeight,
      ),
    );
    return sdk.GeoPointWithElevation(
      longitude: point!.longitude,
      latitude: point.latitude,
    );
  }

  Future<sdk.MapObjectManager> _makeMapObjectManager(
    sdk.Map map,
    _GroupingType type,
    double minZoom,
    double maxZoom,
  ) async {
    if (mapObjectManager != null) {
      _removeAll();
      mapObjectManager = null;
    }

    switch (type) {
      case _GroupingType.clustering:
        return sdk.MapObjectManager.withClustering(
          map,
          const sdk.LogicalPixel(80),
          sdk.Zoom(maxZoom),
          await lazyClusterRenderer,
          sdk.Zoom(minZoom),
        );
      case _GroupingType.generalization:
        return sdk.MapObjectManager.withGeneralization(
          map,
          const sdk.LogicalPixel(80),
          sdk.Zoom(maxZoom),
          sdk.Zoom(minZoom),
        );
    }
  }

  Future<sdk.Image> _getMarkerImage(_MarkerType type) async {
    switch (type) {
      case _MarkerType.scooterPng:
        imageCache[scooterAssetsPath] ??=
            await loader.loadPngFromAsset(scooterAssetsPath, 170, 170);
        return imageCache[scooterAssetsPath]!;
      case _MarkerType.bridgeSvg:
        imageCache[bridgeAssetsPath] ??=
            await loader.loadSVGFromAsset(bridgeAssetsPath);
        return imageCache[bridgeAssetsPath]!;
      case _MarkerType.batLottie:
        imageCache[batAssetsPath] ??=
            await loader.loadLottieFromAsset(batAssetsPath);
        return imageCache[batAssetsPath]!;
    }
  }

  String? _validateDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}

class SimpleClusterRendererImpl implements sdk.SimpleClusterRenderer {
  final sdk.Image image;
  int idx = 0;

  SimpleClusterRendererImpl({
    required this.image,
  });

  @override
  sdk.SimpleClusterOptions renderCluster(sdk.SimpleClusterObject cluster) {
    final objectCount = cluster.objectCount;
    final iconMapDirection =
        objectCount < 5 ? const sdk.MapDirection(45) : null;
    idx += 1;

    const baseSize = 30.0;
    final sizeMultiplier = 1.0 + (objectCount / 50.0);
    final double iconSize = min(baseSize * sizeMultiplier, 100);

    return sdk.SimpleClusterOptions(
      icon: image,
      iconMapDirection: iconMapDirection,
      text: objectCount.toString(),
      iconWidth: sdk.LogicalPixel(iconSize),
      userData: idx,
      zIndex: const sdk.ZIndex(1),
    );
  }
}
