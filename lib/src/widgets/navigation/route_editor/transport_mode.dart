import 'package:flutter/material.dart';

import '../../../generated/dart_bindings.dart' as sdk;

enum TransportMode {
  car,
  publicTransport,
  pedestrian,
  taxi,
  motorcycle,
  bicycle,
  scooter,
  truck,
}

extension TransportModeExtension on TransportMode {
  static List<TransportMode> get all => TransportMode.values;

  sdk.RouteSearchOptions toRouteSearchOptions() {
    switch (this) {
      case TransportMode.bicycle:
        return sdk.RouteSearchOptions.bicycle(
          const sdk.BicycleRouteSearchOptions(),
        );
      case TransportMode.car:
        return sdk.RouteSearchOptions.car(const sdk.CarRouteSearchOptions());
      case TransportMode.motorcycle:
        return sdk.RouteSearchOptions.motorcycle(
          const sdk.MotorcycleRouteSearchOptions(),
        );
      case TransportMode.pedestrian:
        return sdk.RouteSearchOptions.pedestrian(
          const sdk.PedestrianRouteSearchOptions(),
        );
      case TransportMode.publicTransport:
        return sdk.RouteSearchOptions.publicTransport(
          const sdk.PublicTransportRouteSearchOptions(),
        );
      case TransportMode.scooter:
        return sdk.RouteSearchOptions.scooter(
          const sdk.ScooterRouteSearchOptions(),
        );
      case TransportMode.taxi:
        return sdk.RouteSearchOptions.taxi(
          const sdk.TaxiRouteSearchOptions(sdk.CarRouteSearchOptions()),
        );
      case TransportMode.truck:
        return sdk.RouteSearchOptions.truck(
          const sdk.TruckRouteSearchOptions(
            car: sdk.CarRouteSearchOptions(),
          ),
        );
    }
  }

  IconData toIcon() {
    switch (this) {
      case TransportMode.bicycle:
        return Icons.directions_bike;
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.motorcycle:
        return Icons.two_wheeler;
      case TransportMode.pedestrian:
        return Icons.directions_walk;
      case TransportMode.publicTransport:
        return Icons.directions_bus;
      case TransportMode.scooter:
        return Icons.electric_scooter;
      case TransportMode.taxi:
        return Icons.local_taxi;
      case TransportMode.truck:
        return Icons.local_shipping;
    }
  }
}

abstract class TransportModeOptionsProvider {
  sdk.RouteSearchOptions provide(TransportMode type);
}

class DefaultTransportModeOptionsProvider
    implements TransportModeOptionsProvider {
  const DefaultTransportModeOptionsProvider();

  @override
  sdk.RouteSearchOptions provide(TransportMode type) {
    return type.toRouteSearchOptions();
  }
}
