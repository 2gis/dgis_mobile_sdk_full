import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

class RoutingPage extends StatefulWidget {
  final String title;

  const RoutingPage({required this.title, super.key});

  @override
  State<RoutingPage> createState() => _RoutingPageState();
}

final kTabs = [
  sdk.RouteTypeTab(
    icon: 'assets/icons/dgis_car_routing.svg',
    duration: Duration.zero,
    options: sdk.RouteSearchOptions.car(
      sdk.CarRouteSearchOptions(),
    ),
  ),
  sdk.RouteTypeTab(
    icon: 'assets/icons/dgis_pedestrian_routing.svg',
    duration: Duration.zero,
    options: sdk.RouteSearchOptions.pedestrian(
      sdk.PedestrianRouteSearchOptions(),
    ),
  ),
  sdk.RouteTypeTab(
    icon: 'assets/icons/dgis_bicycle_routing.svg',
    duration: Duration.zero,
    options: sdk.RouteSearchOptions.bicycle(
      sdk.BicycleRouteSearchOptions(),
    ),
  ),
];

class _RoutingPageState extends State<RoutingPage> {
  final mapWidgetController = sdk.MapWidgetController();
  final sdkContext = sdk.DGis.initialize();

  final _routesModel = ValueNotifier<sdk.RoutesListModel>(
    sdk.RoutesListModel(
      routes: [],
      tabs: kTabs,
      startLabel: 'Моё местоположение',
      finishLabel: 'Burger King',
    ),
  );

  late sdk.TrafficRouter trafficRouter;

  sdk.RouteSearchOptions _options = sdk.RouteSearchOptions.car(
    sdk.CarRouteSearchOptions(),
  );

  sdk.RouteSearchPoint _startPoint = sdk.RouteSearchPoint(
    coordinates: sdk.GeoPoint(
      latitude: sdk.Latitude(55.749451),
      longitude: sdk.Longitude(37.542824),
    ),
  );
  sdk.RouteSearchPoint _finishPoint = sdk.RouteSearchPoint(
    coordinates: sdk.GeoPoint(
      latitude: sdk.Latitude(55.757670),
      longitude: sdk.Longitude(37.660160),
    ),
  );

  @override
  void initState() {
    trafficRouter = sdk.TrafficRouter(sdkContext);

    super.initState();
    _searchRoutes();
    _tabDurations();
  }

  Future<void> _tabDurations() async {
    _routesModel.value = _routesModel.value.copyWith(tabs: kTabs);

    List<sdk.RouteTypeTab> tabs = [];

    for (final tab in kTabs) {
      final briefInfo = await trafficRouter.findBriefRouteInfos(
        [
          sdk.BriefRouteInfoSearchPoints(startPoint: _startPoint, finishPoint: _finishPoint),
        ],
        tab.options,
      ).valueOrCancellation();
      final duration = briefInfo?.first?.duration ?? Duration.zero;

      tabs.add(
        sdk.RouteTypeTab(
          icon: tab.icon,
          duration: duration,
          options: tab.options,
        ),
      );
    }

    _routesModel.value = _routesModel.value.copyWith(tabs: tabs);
  }

  Future<void> _searchRoutes() async {
    _routesModel.value = _routesModel.value.copyWith(routes: []);
    final routes = await trafficRouter
            .findRoute(
              _startPoint,
              _finishPoint,
              _options,
            )
            .valueOrCancellation() ??
        [];
    _routesModel.value = _routesModel.value.copyWith(routes: routes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: sdk.MapWidget(
        sdkContext: sdkContext,
        mapOptions: sdk.MapOptions(),
        controller: mapWidgetController,
        child: ValueListenableBuilder(
          valueListenable: _routesModel,
          builder: (context, model, child) {
            return sdk.RoutesListWidget(
              model: model,
              selectedOptions: _options,
              itemBuilder: (route, theme) => sdk.RouteCard(
                theme: theme,
                route: route,
                onGoPressed: (value) {},
              ),
              onSwapPoints: () {
                final temp = _startPoint;
                setState(() {
                  _startPoint = _finishPoint;
                  _finishPoint = temp;
                });
                _routesModel.value = _routesModel.value.copyWith(
                  startLabel: _routesModel.value.finishLabel,
                  finishLabel: _routesModel.value.startLabel,
                );
                _searchRoutes();
                _tabDurations();
              },
              onTabChanged: (options) {
                setState(() {
                  _options = options;
                });
                _searchRoutes();
              },
            );
          },
        ),
      ),
    );
  }
}
