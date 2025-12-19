import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class RouteEditorPage extends StatefulWidget {
  final String title;

  const RouteEditorPage({required this.title, super.key});

  @override
  State<RouteEditorPage> createState() => _RouteEditorPageState();
}

class _RouteEditorPageState extends State<RouteEditorPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = AppContainer().initializeSdk();
  final List<sdk.RouteSearchPoint> intermediatePoints = [];

  final TextEditingController truckLengthController =
      TextEditingController(text: '3800');
  final TextEditingController truckHeightController =
      TextEditingController(text: '2000');
  final TextEditingController truckWidthController =
      TextEditingController(text: '2100');
  final TextEditingController actualMassController =
      TextEditingController(text: '3500');
  final TextEditingController maxPermittedMassController =
      TextEditingController(text: '3500');
  final TextEditingController axleLoadController =
      TextEditingController(text: '1500');

  final pinStartPath = 'assets/icons/pina64.png';
  final pinFinishPath = 'assets/icons/pinb64.png';
  final pinPath = 'assets/icons/pin64.png';

  bool showSettingsButtons = true;
  bool showRedCross = false;
  int selectedRadio = 1;
  bool switchAvoidTollRoads = false;
  bool switchAvoidUnpavedRoads = false;
  bool switchAvoidFerries = false;
  bool switchTaxiAvoidTollRoads = false;
  bool switchTaxiAvoidUnpavedRoads = false;
  bool switchTaxiAvoidFerries = false;
  bool switchAvoidCarRoads = false;
  bool switchAvoidStairways = false;
  bool switchAvoidUnderpassesAndOverpasses = false;
  bool switchTruckAvoidTollRoads = false;
  bool switchTruckAvoidUnpavedRoads = false;
  bool switchTruckAvoidFerries = false;
  bool switchTruckDangerousCargo = false;
  bool switchTruckExplosiveCargo = false;
  bool switchPublicUseSchedule = false;
  sdk.PublicTransportTypeEnumSet selectedTransportTypes =
      sdk.PublicTransportTypeEnumSet();
  sdk.RouteSearchPoint? startPoint;
  sdk.RouteSearchPoint? finishPoint;
  sdk.Map? sdkMap;
  sdk.MapObjectManager? mapObjectManager;
  sdk.RouteSearchOptions? routeSearchOptions;
  sdk.RouteSearchType carRouteSearchType = sdk.RouteSearchType.jam;
  sdk.RouteSearchType taxiRouteSearchType = sdk.RouteSearchType.jam;
  sdk.RouteSearchType truckRouteSearchType = sdk.RouteSearchType.jam;
  DateTime? selectedDateTime;
  sdk.Marker? startMarker;
  sdk.Marker? finishMarker;

  late sdk.ImageLoader loader;
  late sdk.RouteEditor routeEditor;
  late sdk.RouteEditorSource routeEditorSource;

  @override
  void initState() {
    super.initState();
    loader = sdk.ImageLoader(sdkContext);
    final locationService = sdk.LocationService(sdkContext);
    checkLocationPermissions(locationService).then((_) {
      mapWidgetController.getMapAsync((map) {
        final locationSource = sdk.MyLocationMapObjectSource(sdkContext);
        map.addSource(locationSource);
        routeEditor = sdk.RouteEditor(sdkContext);
        routeEditorSource = sdk.RouteEditorSource(sdkContext, routeEditor);
        map.addSource(routeEditorSource);
        sdkMap = map;
        map.camera.position = const sdk.CameraPosition(
          point: sdk.GeoPoint(
            latitude: sdk.Latitude(55.35),
            longitude: sdk.Longitude(37.42),
          ),
          zoom: sdk.Zoom(10),
        );
        mapObjectManager = sdk.MapObjectManager(map);
      });
    });
    _updateRouteSearchOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          sdk.MapWidget(
            sdkContext: sdkContext,
            mapOptions: sdk.MapOptions(),
            controller: mapWidgetController,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: sdk.TrafficWidget(),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            sdk.ZoomWidget(),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: sdk.CompassWidget(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: sdk.MyLocationWidget(),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: sdk.IndoorWidget(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: showSettingsButtons
                  ? [
                      ElevatedButton(
                        onPressed: toggleButtons,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getOptionText(selectedRadio),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Icon(
                              _getTransportIcon(selectedRadio),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showBottomSheet(context);
                        },
                        child: const Icon(Icons.settings),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          if (!showSettingsButtons)
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _setupStartPoint,
                    child: Column(
                      children: [
                        Text(
                          getStartPointButtonText(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Setup',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: _setupFinishPoint,
                    child: Column(
                      children: [
                        Text(
                          getFinishPointButtonText(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Setup',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (selectedRadio != 2)
                    ElevatedButton(
                      onPressed: _setupIntermediatePoints,
                      child: Column(
                        children: [
                          Text(
                            getIntermediatePointButtonText(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Setup',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      _findRoute(context);
                    },
                    child: const Text('Find route'),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: toggleButtons,
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          if (showRedCross)
            const Center(
              child: Icon(
                Icons.add,
                color: Colors.red,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  void toggleButtons() {
    setState(() {
      showSettingsButtons = !showSettingsButtons;
      showRedCross = !showRedCross;
      startPoint = null;
      finishPoint = null;
      intermediatePoints.clear();
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Settings:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Transport type:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTransportTypeGrid(setState),
                        const SizedBox(height: 10),
                        _buildAutoOptions(setState),
                        const SizedBox(height: 10),
                        _buildPublicOptions(setState),
                        const SizedBox(height: 10),
                        _buildTruckOptions(setState),
                        const SizedBox(height: 10),
                        _buildTaxiOptions(setState),
                        const SizedBox(height: 10),
                        _buildBicycleOptions(setState),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTransportTypeGrid(StateSetter setState) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final i = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRadio = i;
            });
            this.setState(() {
              selectedRadio = i;
            });
            _updateRouteSearchOptions();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selectedRadio == i
                  ? Colors.deepPurple.shade100
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedRadio == i
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                ),
                Expanded(
                  child: Text(
                    _getOptionText(i),
                    style: TextStyle(
                      color:
                          selectedRadio == i ? Colors.deepPurple : Colors.black,
                      fontWeight: selectedRadio == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Radio<int>(
                  value: i,
                  groupValue: selectedRadio,
                  onChanged: (value) {
                    setState(() {
                      selectedRadio = value!;
                    });
                    this.setState(() {
                      selectedRadio = value!;
                    });
                    _updateRouteSearchOptions();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPublicOptions(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Public:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SwitchListTile(
          title: const Text('Use public schedule'),
          value: switchPublicUseSchedule,
          onChanged: (value) {
            setState(() {
              switchPublicUseSchedule = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        const Text(
          'Date and time:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null) {
              if (mounted) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  setState(() {
                    selectedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                  _updateRouteSearchOptions();
                }
              }
            }
          },
          child: Text(
            selectedDateTime == null
                ? 'Choose date and time'
                : 'Chosen time: ${selectedDateTime!.toLocal()}',
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Public transport type:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'If not selected, routes will be built for all supported types of public transport.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        SwitchListTile(
          title: const Text('Bus'),
          value: selectedTransportTypes.contains(sdk.PublicTransportType.bus),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.bus);
              } else {
                selectedTransportTypes.remove(sdk.PublicTransportType.bus);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Trolleybus'),
          value: selectedTransportTypes
              .contains(sdk.PublicTransportType.trolleybus),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.trolleybus);
              } else {
                selectedTransportTypes
                    .remove(sdk.PublicTransportType.trolleybus);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Tram'),
          value: selectedTransportTypes.contains(sdk.PublicTransportType.tram),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.tram);
              } else {
                selectedTransportTypes.remove(sdk.PublicTransportType.tram);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Shuttle bus'),
          value: selectedTransportTypes
              .contains(sdk.PublicTransportType.shuttleBus),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.shuttleBus);
              } else {
                selectedTransportTypes
                    .remove(sdk.PublicTransportType.shuttleBus);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Metro'),
          value: selectedTransportTypes.contains(sdk.PublicTransportType.metro),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.metro);
              } else {
                selectedTransportTypes.remove(sdk.PublicTransportType.metro);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Suburban train'),
          value: selectedTransportTypes
              .contains(sdk.PublicTransportType.suburbanTrain),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes
                    .add(sdk.PublicTransportType.suburbanTrain);
              } else {
                selectedTransportTypes.remove(
                  sdk.PublicTransportType.suburbanTrain,
                );
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Funicular railway'),
          value: selectedTransportTypes.contains(
            sdk.PublicTransportType.funicularRailway,
          ),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(
                  sdk.PublicTransportType.funicularRailway,
                );
              } else {
                selectedTransportTypes.remove(
                  sdk.PublicTransportType.funicularRailway,
                );
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Monorail'),
          value:
              selectedTransportTypes.contains(sdk.PublicTransportType.monorail),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.monorail);
              } else {
                selectedTransportTypes.remove(sdk.PublicTransportType.monorail);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Waterway'),
          value: selectedTransportTypes.contains(
            sdk.PublicTransportType.waterwayTransport,
          ),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(
                  sdk.PublicTransportType.waterwayTransport,
                );
              } else {
                selectedTransportTypes.remove(
                  sdk.PublicTransportType.waterwayTransport,
                );
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Cable car'),
          value:
              selectedTransportTypes.contains(sdk.PublicTransportType.cableCar),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.cableCar);
              } else {
                selectedTransportTypes.remove(sdk.PublicTransportType.cableCar);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Speed tram'),
          value: selectedTransportTypes
              .contains(sdk.PublicTransportType.speedTram),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.speedTram);
              } else {
                selectedTransportTypes
                    .remove(sdk.PublicTransportType.speedTram);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('underground tram'),
          value:
              selectedTransportTypes.contains(sdk.PublicTransportType.premetro),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.premetro);
              } else {
                selectedTransportTypes.remove(sdk.PublicTransportType.premetro);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Light metro'),
          value: selectedTransportTypes
              .contains(sdk.PublicTransportType.lightMetro),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.lightMetro);
              } else {
                selectedTransportTypes
                    .remove(sdk.PublicTransportType.lightMetro);
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Aeroexpress'),
          value: selectedTransportTypes
              .contains(sdk.PublicTransportType.aeroexpress),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(sdk.PublicTransportType.aeroexpress);
              } else {
                selectedTransportTypes.remove(
                  sdk.PublicTransportType.aeroexpress,
                );
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Moscow central ring'),
          value: selectedTransportTypes.contains(
            sdk.PublicTransportType.moscowCentralRing,
          ),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(
                  sdk.PublicTransportType.moscowCentralRing,
                );
              } else {
                selectedTransportTypes.remove(
                  sdk.PublicTransportType.moscowCentralRing,
                );
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        SwitchListTile(
          title: const Text('Moscow central diameters'),
          value: selectedTransportTypes.contains(
            sdk.PublicTransportType.moscowCentralDiameters,
          ),
          onChanged: (value) {
            setState(() {
              if (value) {
                selectedTransportTypes.add(
                  sdk.PublicTransportType.moscowCentralDiameters,
                );
              } else {
                selectedTransportTypes.remove(
                  sdk.PublicTransportType.moscowCentralDiameters,
                );
              }
              _updateRouteSearchOptions();
            });
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTruckOptions(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trucks:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SwitchListTile(
          title: const Text('Truck dungerous cargo'),
          value: switchTruckDangerousCargo,
          onChanged: (value) {
            setState(() {
              switchTruckDangerousCargo = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text(
            'Truck explosive cargo',
          ),
          value: switchTruckExplosiveCargo,
          onChanged: (value) {
            setState(() {
              switchTruckExplosiveCargo = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid toll roads'),
          value: switchTruckAvoidTollRoads,
          onChanged: (value) {
            setState(() {
              switchTruckAvoidTollRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid unpaved roads'),
          value: switchTruckAvoidUnpavedRoads,
          onChanged: (value) {
            setState(() {
              switchTruckAvoidUnpavedRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid ferries'),
          value: switchTruckAvoidFerries,
          onChanged: (value) {
            setState(() {
              switchTruckAvoidFerries = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        const Text(
          'Route search type:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Jam'),
                ),
                value: sdk.RouteSearchType.jam,
                groupValue: truckRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    truckRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Shortest'),
                ),
                value: sdk.RouteSearchType.shortest,
                groupValue: truckRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    truckRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Statistic'),
                ),
                value: sdk.RouteSearchType.statistic,
                groupValue: truckRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    truckRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Truck params:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        _buildNumberInputField(
          controller: truckLengthController,
          label: 'Length (мм)',
        ),
        _buildNumberInputField(
          controller: truckHeightController,
          label: 'Height (мм)',
        ),
        _buildNumberInputField(
          controller: truckWidthController,
          label: 'Width (мм)',
        ),
        _buildNumberInputField(
          controller: actualMassController,
          label: 'Actual mass (kg)',
        ),
        _buildNumberInputField(
          controller: maxPermittedMassController,
          label: 'Max permited mass (kg)',
        ),
        _buildNumberInputField(
          controller: axleLoadController,
          label: 'Axle load (kg)',
        ),
      ],
    );
  }

  Widget _buildBicycleOptions(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bicycle:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SwitchListTile(
          title: const Text('Avoid car roads'),
          value: switchAvoidCarRoads,
          onChanged: (value) {
            setState(() {
              switchAvoidCarRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid stairways'),
          value: switchAvoidStairways,
          onChanged: (value) {
            setState(() {
              switchAvoidStairways = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text(
            'Awoid underpasses and overpasses',
          ),
          value: switchAvoidUnderpassesAndOverpasses,
          onChanged: (value) {
            setState(() {
              switchAvoidUnderpassesAndOverpasses = value;
            });
            _updateRouteSearchOptions();
          },
        ),
      ],
    );
  }

  Widget _buildTaxiOptions(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Taxi:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SwitchListTile(
          title: const Text('Avoid toll roads'),
          value: switchTaxiAvoidTollRoads,
          onChanged: (value) {
            setState(() {
              switchTaxiAvoidTollRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid unpaved roads'),
          value: switchTaxiAvoidUnpavedRoads,
          onChanged: (value) {
            setState(() {
              switchTaxiAvoidUnpavedRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid ferries'),
          value: switchTaxiAvoidFerries,
          onChanged: (value) {
            setState(() {
              switchTaxiAvoidFerries = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        const Text(
          'Route search type:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Jam'),
                ),
                value: sdk.RouteSearchType.jam,
                groupValue: taxiRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    taxiRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Shortest'),
                ),
                value: sdk.RouteSearchType.shortest,
                groupValue: taxiRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    taxiRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Statistic'),
                ),
                value: sdk.RouteSearchType.statistic,
                groupValue: taxiRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    taxiRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutoOptions(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auto:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SwitchListTile(
          title: const Text('Avoid toll roads'),
          value: switchAvoidTollRoads,
          onChanged: (value) {
            setState(() {
              switchAvoidTollRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid unpaved roads'),
          value: switchAvoidUnpavedRoads,
          onChanged: (value) {
            setState(() {
              switchAvoidUnpavedRoads = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        SwitchListTile(
          title: const Text('Avoid ferries'),
          value: switchAvoidFerries,
          onChanged: (value) {
            setState(() {
              switchAvoidFerries = value;
            });
            _updateRouteSearchOptions();
          },
        ),
        const Text(
          'Route search type:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Jam'),
                ),
                value: sdk.RouteSearchType.jam,
                groupValue: carRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    carRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Shortest'),
                ),
                value: sdk.RouteSearchType.shortest,
                groupValue: carRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    carRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<sdk.RouteSearchType>(
                title: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Statistic'),
                ),
                value: sdk.RouteSearchType.statistic,
                groupValue: carRouteSearchType,
                onChanged: (value) {
                  setState(() {
                    carRouteSearchType = value!;
                    _updateRouteSearchOptions();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
      ),
      onChanged: (value) {
        setState(() {});
        _updateRouteSearchOptions();
      },
    );
  }

  String _getOptionText(int index) {
    switch (index) {
      case 1:
        return 'Car';
      case 2:
        return 'Public';
      case 3:
        return 'Bicycle';
      case 4:
        return 'Pedestrian';
      case 5:
        return 'Taxi';
      case 6:
        return 'Truck';
      default:
        return 'Car';
    }
  }

  void _updateRouteSearchOptions() {
    switch (selectedRadio) {
      case 1:
        routeSearchOptions = sdk.RouteSearchOptions.car(
          sdk.CarRouteSearchOptions(
            avoidTollRoads: switchAvoidTollRoads,
            avoidUnpavedRoads: switchAvoidUnpavedRoads,
            avoidFerries: switchAvoidFerries,
            routeSearchType: carRouteSearchType,
          ),
        );
      case 2:
        routeSearchOptions = sdk.RouteSearchOptions.publicTransport(
          sdk.PublicTransportRouteSearchOptions(
            startTime: selectedDateTime,
            useSchedule: switchPublicUseSchedule,
            transportTypes: selectedTransportTypes,
          ),
        );
      case 3:
        routeSearchOptions = sdk.RouteSearchOptions.bicycle(
          sdk.BicycleRouteSearchOptions(
            avoidCarRoads: switchAvoidCarRoads,
            avoidStairways: switchAvoidStairways,
            avoidUnderpassesAndOverpasses: switchAvoidUnderpassesAndOverpasses,
          ),
        );
      case 4:
        routeSearchOptions = sdk.RouteSearchOptions.pedestrian(
          const sdk.PedestrianRouteSearchOptions(),
        );
      case 5:
        routeSearchOptions = sdk.RouteSearchOptions.taxi(
          sdk.TaxiRouteSearchOptions(
            sdk.CarRouteSearchOptions(
              avoidTollRoads: switchTaxiAvoidTollRoads,
              avoidUnpavedRoads: switchTaxiAvoidUnpavedRoads,
              avoidFerries: switchTaxiAvoidFerries,
              routeSearchType: taxiRouteSearchType,
            ),
          ),
        );
      case 6:
        routeSearchOptions = sdk.RouteSearchOptions.truck(
          sdk.TruckRouteSearchOptions(
            car: sdk.CarRouteSearchOptions(
              avoidTollRoads: switchTruckAvoidTollRoads,
              avoidUnpavedRoads: switchTruckAvoidUnpavedRoads,
              avoidFerries: switchTruckAvoidFerries,
              routeSearchType: truckRouteSearchType,
            ),
            dangerousCargo: switchTruckDangerousCargo,
            explosiveCargo: switchTruckExplosiveCargo,
            truckLength: int.tryParse(truckLengthController.text),
            truckHeight: int.tryParse(truckHeightController.text),
            truckWidth: int.tryParse(truckWidthController.text),
            actualMass: int.tryParse(actualMassController.text),
            maxPermittedMass: int.tryParse(maxPermittedMassController.text),
            axleLoad: int.tryParse(axleLoadController.text),
          ),
        );
    }

    switch (carRouteSearchType) {
      case sdk.RouteSearchType.jam:
        carRouteSearchType = sdk.RouteSearchType.jam;
      case sdk.RouteSearchType.statistic:
        carRouteSearchType = sdk.RouteSearchType.statistic;
      case sdk.RouteSearchType.shortest:
        carRouteSearchType = sdk.RouteSearchType.shortest;
    }

    switch (taxiRouteSearchType) {
      case sdk.RouteSearchType.jam:
        taxiRouteSearchType = sdk.RouteSearchType.jam;
      case sdk.RouteSearchType.statistic:
        taxiRouteSearchType = sdk.RouteSearchType.statistic;
      case sdk.RouteSearchType.shortest:
        taxiRouteSearchType = sdk.RouteSearchType.shortest;
    }
  }

  String getStartPointButtonText() {
    if (startPoint == null) {
      return 'A: Not installed';
    } else {
      final latitude =
          startPoint!.coordinates.latitude.value.toStringAsFixed(2);
      final longitude =
          startPoint!.coordinates.longitude.value.toStringAsFixed(2);
      return 'A lat: $latitude, long: $longitude';
    }
  }

  String getFinishPointButtonText() {
    if (finishPoint == null) {
      return 'B: Not installed';
    } else {
      final latitude =
          finishPoint!.coordinates.latitude.value.toStringAsFixed(2);
      final longitude =
          finishPoint!.coordinates.longitude.value.toStringAsFixed(2);
      return 'B lat: $latitude, long: $longitude';
    }
  }

  String getIntermediatePointButtonText() {
    if (intermediatePoints.isEmpty) {
      return 'int: Not installed';
    } else {
      final size = intermediatePoints.length;
      return 'Number intermediate points: $size';
    }
  }

  IconData _getTransportIcon(int index) {
    switch (index) {
      case 1:
        return Icons.directions_car;
      case 2:
        return Icons.directions_bus;
      case 3:
        return Icons.directions_bike;
      case 4:
        return Icons.directions_walk;
      case 5:
        return Icons.local_taxi;
      case 6:
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  void _setupStartPoint() {
    setState(() {
      startPoint =
          sdk.RouteSearchPoint(coordinates: sdkMap!.camera.position.point);
      if (startMarker != null) {
        mapObjectManager?.removeObject(startMarker!);
      }
      _addMarker(pinStartPath).then((marker) {
        startMarker = marker;
      });
    });
  }

  void _setupFinishPoint() {
    setState(() {
      finishPoint =
          sdk.RouteSearchPoint(coordinates: sdkMap!.camera.position.point);
      if (finishMarker != null) {
        mapObjectManager?.removeObject(finishMarker!);
      }
      _addMarker(pinFinishPath).then((marker) {
        finishMarker = marker;
      });
    });
  }

  void _setupIntermediatePoints() {
    final point =
        sdk.RouteSearchPoint(coordinates: sdkMap!.camera.position.point);
    setState(() {
      intermediatePoints.add(point);
    });
    _addMarker(pinPath);
  }

  Future<sdk.Marker> _addMarker(String iconPath) async {
    final marker = sdk.Marker(
      sdk.MarkerOptions(
        position: sdk.GeoPointWithElevation(
          latitude: sdkMap!.camera.position.point.latitude,
          longitude: sdkMap!.camera.position.point.longitude,
        ),
        icon: await loader.loadPngFromAsset(iconPath, 64, 64),
      ),
    );
    mapObjectManager?.addObject(marker);
    return marker;
  }

  void _findRoute(BuildContext context) {
    try {
      routeEditor.setRouteParams(
        sdk.RouteEditorRouteParams(
          startPoint: startPoint!,
          finishPoint: finishPoint!,
          intermediatePoints: intermediatePoints,
          routeSearchOptions: routeSearchOptions!,
        ),
      );
      if (routeEditor.routesInfo.routes.isNotEmpty) {
        mapObjectManager?.removeAll();
      }
    } on Exception {
      _showRouteNotFoundDialog(context);
    }
  }

  void _showRouteNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Start and finish points are not defined'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
