import 'package:flutter/material.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../settings/navigation_setting_keys.dart';
import '../settings/navigation_settings_repository.dart';
import '../settings/truck_preset.dart';

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

class SettingsTransportModeProvider implements TransportModeOptionsProvider {
  const SettingsTransportModeProvider(this.navigationSettings);

  final NavigationSettingsRepository navigationSettings;

  @override
  sdk.RouteSearchOptions provide(TransportMode type) {
    final settings = navigationSettings;

    return switch (type) {
      TransportMode.car => sdk.RouteSearchOptions.car(
        sdk.CarRouteSearchOptions(
          avoidTollRoads: settings.get(
            NavigationSettingKeys.carAvoidTollRoads,
          ),
          avoidUnpavedRoads: settings.get(
            NavigationSettingKeys.carAvoidUnpavedRoads,
          ),
          avoidFerries: settings.get(NavigationSettingKeys.carAvoidFerries),
          avoidLockedRoads: settings.get(
            NavigationSettingKeys.carAvoidLockedRoads,
          ),
          routeSearchType: settings.get(
            NavigationSettingKeys.carRouteSearchType,
          ),
        ),
      ),
      TransportMode.publicTransport => sdk.RouteSearchOptions.publicTransport(
        sdk.PublicTransportRouteSearchOptions(
          startTime: DateTime.tryParse(
            settings.get(NavigationSettingKeys.ptStartTime) ?? '',
          ),
          useSchedule: settings.get(NavigationSettingKeys.ptUseSchedule),
          transportTypes: sdk.PublicTransportTypeEnumSet.of(
            settings.get(NavigationSettingKeys.ptTransportTypes),
          ),
          quickFilter: settings.get(NavigationSettingKeys.ptQuickFilter),
        ),
      ),
      TransportMode.pedestrian => sdk.RouteSearchOptions.pedestrian(
        sdk.PedestrianRouteSearchOptions(
          avoidLockedRoads: settings.get(
            NavigationSettingKeys.pedestrianAvoidLockedRoads,
          ),
          avoidStairways: settings.get(
            NavigationSettingKeys.pedestrianAvoidStairways,
          ),
          avoidUnderpassesAndOverpasses: settings.get(
            NavigationSettingKeys.pedestrianAvoidUnderpasses,
          ),
          avoidUnpavedRoads: settings.get(
            NavigationSettingKeys.pedestrianAvoidUnpavedRoads,
          ),
          useIndoor: settings.get(
            NavigationSettingKeys.pedestrianUseIndoor,
          ),
        ),
      ),
      TransportMode.taxi => sdk.RouteSearchOptions.taxi(
        sdk.TaxiRouteSearchOptions(
          sdk.CarRouteSearchOptions(
            avoidTollRoads: settings.get(
              NavigationSettingKeys.taxiAvoidTollRoads,
            ),
            avoidUnpavedRoads: settings.get(
              NavigationSettingKeys.taxiAvoidUnpavedRoads,
            ),
            avoidFerries: settings.get(
              NavigationSettingKeys.taxiAvoidFerries,
            ),
            avoidLockedRoads: settings.get(
              NavigationSettingKeys.taxiAvoidLockedRoads,
            ),
            routeSearchType: settings.get(
              NavigationSettingKeys.taxiRouteSearchType,
            ),
          ),
        ),
      ),
      TransportMode.motorcycle => sdk.RouteSearchOptions.motorcycle(
        sdk.MotorcycleRouteSearchOptions(
          avoidTollRoads: settings.get(
            NavigationSettingKeys.motorcycleAvoidTollRoads,
          ),
          avoidUnpavedRoads: settings.get(
            NavigationSettingKeys.motorcycleAvoidUnpavedRoads,
          ),
          avoidFerries: settings.get(
            NavigationSettingKeys.motorcycleAvoidFerries,
          ),
          avoidLockedRoads: settings.get(
            NavigationSettingKeys.motorcycleAvoidLockedRoads,
          ),
          routeSearchType: settings.get(
            NavigationSettingKeys.motorcycleRouteSearchType,
          ),
        ),
      ),
      TransportMode.bicycle => sdk.RouteSearchOptions.bicycle(
        sdk.BicycleRouteSearchOptions(
          avoidCarRoads: settings.get(
            NavigationSettingKeys.bicycleAvoidCarRoads,
          ),
          avoidStairways: settings.get(
            NavigationSettingKeys.bicycleAvoidStairways,
          ),
          avoidUnderpassesAndOverpasses: settings.get(
            NavigationSettingKeys.bicycleAvoidUnderpasses,
          ),
          avoidUnpavedRoads: settings.get(
            NavigationSettingKeys.bicycleAvoidUnpavedRoads,
          ),
          avoidLockedRoads: settings.get(
            NavigationSettingKeys.bicycleAvoidLockedRoads,
          ),
        ),
      ),
      TransportMode.scooter => sdk.RouteSearchOptions.scooter(
        sdk.ScooterRouteSearchOptions(
          avoidCarRoads: settings.get(
            NavigationSettingKeys.scooterAvoidCarRoads,
          ),
          avoidStairways: settings.get(
            NavigationSettingKeys.scooterAvoidStairways,
          ),
          avoidUnderpassesAndOverpasses: settings.get(
            NavigationSettingKeys.scooterAvoidUnderpasses,
          ),
          avoidUnpavedRoads: settings.get(
            NavigationSettingKeys.scooterAvoidUnpavedRoads,
          ),
          avoidLockedRoads: settings.get(
            NavigationSettingKeys.scooterAvoidLockedRoads,
          ),
        ),
      ),
      TransportMode.truck => sdk.RouteSearchOptions.truck(
        sdk.TruckRouteSearchOptions(
          car: sdk.CarRouteSearchOptions(
            avoidTollRoads: settings.get(
              NavigationSettingKeys.truckAvoidTollRoads,
            ),
            avoidUnpavedRoads: settings.get(
              NavigationSettingKeys.truckAvoidUnpavedRoads,
            ),
            avoidFerries: settings.get(
              NavigationSettingKeys.truckAvoidFerries,
            ),
            avoidLockedRoads: settings.get(
              NavigationSettingKeys.truckAvoidLockedRoads,
            ),
            routeSearchType: settings.get(
              NavigationSettingKeys.truckRouteSearchType,
            ),
          ),
          dangerousCargo: settings.get(
            NavigationSettingKeys.truckDangerousCargo,
          ),
          explosiveCargo: settings.get(
            NavigationSettingKeys.truckExplosiveCargo,
          ),
          fallbackOnCar: settings.get(
            NavigationSettingKeys.truckFallbackOnCar,
          ),
          maxPermittedMass: _truckDimension(TruckDimension.maxPermittedMass),
          actualMass: _truckDimension(TruckDimension.actualMass),
          axleLoad: _truckDimension(TruckDimension.axleLoad),
          truckHeight: _truckDimension(TruckDimension.height),
          truckWidth: _truckDimension(TruckDimension.width),
          truckLength: _truckDimension(TruckDimension.length),
        ),
      ),
    };
  }

  int _truckDimension(TruckDimension dimension) => dimension.resolve(
    navigationSettings.get(NavigationSettingKeys.truckPreset),
    navigationSettings.get(NavigationSettingKeys.truckDimension(dimension)),
  );
}
