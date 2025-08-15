import 'dart:async';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';
import 'common.dart';

class DownloadTerritoriesPage extends StatefulWidget {
  const DownloadTerritoriesPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<DownloadTerritoriesPage> createState() =>
      _DownloadTerritoriesPageState();
}

class _DownloadTerritoriesPageState extends State<DownloadTerritoriesPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();
  sdk.Map? sdkMap;

  final TextEditingController filterController = TextEditingController();
  late sdk.TerritoryManager territoryManager;
  List<sdk.Territory> territories = [];
  List<sdk.Territory> filteredTerritories = [];
  String filter = '';
  int filterMode = 0;

  StreamSubscription<Object?>? geometrySubscription;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    geometrySubscription?.cancel();
    filterController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    final context = AppContainer().initializeSdk();
    sdk.getPackageManager(context).checkForUpdates();
    territoryManager = sdk.getTerritoryManager(context);

    mapWidgetController.getMapAsync((map) {
      sdkMap = map;
      _updateGeometrySubscription();
    });

    territoryManager.territoriesChannel.listen((territoriesList) {
      setState(() {
        territories = List.from(territoriesList);
        _applyFilter();
        territories.sort((a, b) {
          final ai = a.info;
          final bi = b.info;
          if (ai.installed && !bi.installed) return -1;
          if (!ai.installed && bi.installed) return 1;
          return ai.name.compareTo(bi.name);
        });
      });
    });
  }

  void _updateGeometrySubscription() {
    geometrySubscription?.cancel();
    if (sdkMap == null) return;
    if (filterMode == 1) {
      geometrySubscription = sdkMap!.camera.positionChannel.listen((position) {
        _updateGeometryFilter();
      });
    } else if (filterMode == 2) {
      geometrySubscription = sdkMap!.camera.visibleRectChannel.listen((rect) {
        _updateGeometryFilter();
      });
    }
  }

  Future<void> _updateGeometryFilter() async {
    if (sdkMap == null) {
      filteredTerritories = territories;
    } else if (filterMode == 1) {
      final position = sdkMap!.camera.position;
      filteredTerritories = territoryManager.findByPoint(position.point);
    } else if (filterMode == 2) {
      final rect = sdkMap!.camera.visibleRect;
      filteredTerritories = territoryManager.findByRect(rect);
    } else {
      filteredTerritories = territories;
    }
    if (filter.isNotEmpty) {
      filteredTerritories = filteredTerritories
          .where(
            (t) => t.info.name.toLowerCase().contains(filter.toLowerCase()),
          )
          .toList();
    }
    setState(() {});
  }

  void _applyFilter() {
    _updateGeometryFilter();
  }

  void _updateFilter(String value) {
    setState(() {
      filter = value;
      _applyFilter();
    });
  }

  void _clearFilter() {
    filterController.clear();
    _updateFilter('');
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _statusText(sdk.PackageInfo info, int progress) {
    switch (info.updateStatus) {
      case sdk.PackageUpdateStatus.inProgress:
        return 'Installing: $progress%';
      case sdk.PackageUpdateStatus.paused:
        return 'Paused';
      default:
        return info.installed ? 'Installed' : 'Not installed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: sdk.MapWidget(
              sdkContext: sdkContext,
              mapOptions: sdk.MapOptions(),
              controller: mapWidgetController,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: sdk.ZoomWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ToggleButtons(
              isSelected: [filterMode == 0, filterMode == 1, filterMode == 2],
              onPressed: (index) async {
                setState(() {
                  filterMode = index;
                });
                _updateGeometrySubscription();
                await _updateGeometryFilter();
              },
              children: const [
                SizedBox(
                  width: 110,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'All',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Position',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Viewport',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: filterController,
                    onChanged: _updateFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter Territories',
                      border: const OutlineInputBorder(),
                      suffixIcon: filter.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearFilter,
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTerritories.length,
                    itemBuilder: (context, index) {
                      final territory = filteredTerritories[index];
                      return StreamBuilder<sdk.PackageInfo>(
                        stream: territory.infoChannel,
                        initialData: territory.info,
                        builder: (context, infoSnapshot) {
                          final info = infoSnapshot.data!;
                          return StreamBuilder<int>(
                            stream: territory.progressChannel,
                            initialData: info.installed ? 100 : 0,
                            builder: (context, progressSnapshot) {
                              final progress = progressSnapshot.data!;
                              final showProgress = info.updateStatus ==
                                  sdk.PackageUpdateStatus.inProgress;
                              final status = _statusText(info, progress);
                              return ListTile(
                                title: Text(info.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(status),
                                    if (info.finalSizeOnDisk != null)
                                      Text(
                                        'Size: ${_formatSize(info.finalSizeOnDisk)}',
                                      ),
                                    if (info.hasUpdate)
                                      const Text('Has update'),
                                    if (info.preinstalled)
                                      const Text('Preinstalled'),
                                    if (showProgress)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: LinearProgressIndicator(
                                          value: progress / 100.0,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (info.installed && !info.preinstalled)
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Uninstall',
                                        onPressed: territory.uninstall,
                                      ),
                                    if (info.hasUpdate || info.incomplete)
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        tooltip: 'Install',
                                        onPressed: territory.install,
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
