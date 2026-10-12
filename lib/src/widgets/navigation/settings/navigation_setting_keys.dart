import 'package:meta/meta.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import 'settings_key.dart';
import 'sound_mode.dart';
import 'truck_preset.dart';

abstract final class NavigationSettingKeys {
  // Route (car)
  static const carAvoidTollRoads =
      BoolSettingsKey('route.car.avoid_toll_roads', false);
  static const carAvoidUnpavedRoads =
      BoolSettingsKey('route.car.avoid_unpaved_roads', false);
  static const carAvoidFerries =
      BoolSettingsKey('route.car.avoid_ferries', false);
  static const carAvoidLockedRoads =
      BoolSettingsKey('route.car.avoid_locked_roads', true);
  static const carRouteSearchType = EnumSettingsKey<sdk.RouteSearchType>(
    'route.car.route_search_type',
    sdk.RouteSearchType.jam,
    sdk.RouteSearchType.values,
  );
  static const calloutVisualizationMode =
      EnumSettingsKey<sdk.CalloutVisualizationMode>(
    'route.callout_visualization_mode',
    sdk.CalloutVisualizationMode.multipleRoutes,
    sdk.CalloutVisualizationMode.values,
  );

  // Route (pedestrian)
  static const pedestrianAvoidStairways =
      BoolSettingsKey('route.pedestrian.avoid_stairways', false);
  static const pedestrianAvoidUnderpasses =
      BoolSettingsKey('route.pedestrian.avoid_underpasses', false);
  static const pedestrianUseIndoor =
      BoolSettingsKey('route.pedestrian.use_indoor', true);
  static const pedestrianAvoidUnpavedRoads =
      BoolSettingsKey('route.pedestrian.avoid_unpaved_roads', false);

  // Route (bicycle)
  static const bicycleAvoidCarRoads =
      BoolSettingsKey('route.bicycle.avoid_car_roads', false);
  static const bicycleAvoidStairways =
      BoolSettingsKey('route.bicycle.avoid_stairways', false);
  static const bicycleAvoidUnderpasses =
      BoolSettingsKey('route.bicycle.avoid_underpasses', false);
  static const bicycleAvoidUnpavedRoads =
      BoolSettingsKey('route.bicycle.avoid_unpaved_roads', false);

  // Route (scooter)
  static const scooterAvoidCarRoads =
      BoolSettingsKey('route.scooter.avoid_car_roads', true);
  static const scooterAvoidStairways =
      BoolSettingsKey('route.scooter.avoid_stairways', true);
  static const scooterAvoidUnderpasses =
      BoolSettingsKey('route.scooter.avoid_underpasses', true);
  static const scooterAvoidUnpavedRoads =
      BoolSettingsKey('route.scooter.avoid_unpaved_roads', true);

  // Route (motorcycle)
  static const motorcycleAvoidTollRoads =
      BoolSettingsKey('route.motorcycle.avoid_toll_roads', false);
  static const motorcycleAvoidUnpavedRoads =
      BoolSettingsKey('route.motorcycle.avoid_unpaved_roads', false);
  static const motorcycleAvoidFerries =
      BoolSettingsKey('route.motorcycle.avoid_ferries', false);
  static const motorcycleAvoidLockedRoads =
      BoolSettingsKey('route.motorcycle.avoid_locked_roads', true);
  static const motorcycleRouteSearchType = EnumSettingsKey<sdk.RouteSearchType>(
    'route.motorcycle.route_search_type',
    sdk.RouteSearchType.jam,
    sdk.RouteSearchType.values,
  );

  // Route (truck)
  static const truckPreset = EnumSettingsKey<TruckPreset>(
    'route.truck.preset',
    TruckPreset.small,
    TruckPreset.values,
  );
  static const truckLength = NullableIntSettingsKey('route.truck.length');
  static const truckHeight = NullableIntSettingsKey('route.truck.height');
  static const truckWidth = NullableIntSettingsKey('route.truck.width');
  static const truckActualMass =
      NullableIntSettingsKey('route.truck.actual_mass');
  static const truckMaxPermittedMass =
      NullableIntSettingsKey('route.truck.max_permitted_mass');
  static const truckAxleLoad = NullableIntSettingsKey('route.truck.axle_load');
  static const truckDangerousCargo =
      BoolSettingsKey('route.truck.dangerous_cargo', false);
  static const truckExplosiveCargo =
      BoolSettingsKey('route.truck.explosive_cargo', false);
  static const truckFallbackOnCar =
      BoolSettingsKey('route.truck.fallback_on_car', false);
  static const truckAvoidTollRoads =
      BoolSettingsKey('route.truck.avoid_toll_roads', false);
  static const truckAvoidUnpavedRoads =
      BoolSettingsKey('route.truck.avoid_unpaved_roads', false);

  @internal
  static NullableIntSettingsKey truckDimension(TruckDimension dimension) =>
      switch (dimension) {
        TruckDimension.length => truckLength,
        TruckDimension.height => truckHeight,
        TruckDimension.width => truckWidth,
        TruckDimension.actualMass => truckActualMass,
        TruckDimension.maxPermittedMass => truckMaxPermittedMass,
        TruckDimension.axleLoad => truckAxleLoad,
      };

  // Route (public transport)
  static const ptTransportTypes = EnumSetSettingsKey<sdk.PublicTransportType>(
    'route.public_transport.transport_types',
    {...sdk.PublicTransportType.values},
    sdk.PublicTransportType.values,
  );

  /// Whether [ptTransportTypes] changes are saved to storage.
  ///
  /// When false, a change lives only as long as the settings repository
  /// instance, and a new instance starts from the default rather than the
  /// saved choice.
  static const ptRememberChoice =
      BoolSettingsKey('route.public_transport.remember_choice', true);

  // Route (general)
  static const betterRouteEnabled =
      BoolSettingsKey('route.better_route_enabled', true);
  static const alternativeRoutesEnabled =
      BoolSettingsKey('route.alternative_routes_enabled', true);
  static const rebuildOnDeviation =
      BoolSettingsKey('route.rebuild_on_deviation', true);

  // Sound (general)
  static const soundMode = EnumSettingsKey<SoundMode>(
    'sound.mode',
    SoundMode.all,
    SoundMode.values,
  );
  static const soundVolume = IntSettingsKey('sound.volume', 100);
  static const soundSpeedExceedEnabled =
      BoolSettingsKey('sound.speed_exceed_enabled', true);
  static const soundSpeedExceedThreshold =
      DoubleSettingsKey('sound.speed_exceed_threshold', 0);
  static const soundDuckOtherAudio =
      BoolSettingsKey('sound.duck_other_audio', true);
  static const soundSpeedCameraAlways =
      BoolSettingsKey('sound.speed_camera_always', false);

  // Sound (per SoundCategory)
  static const soundCrossroadCameras =
      BoolSettingsKey('sound.crossroad_cameras', true);
  static const soundLaneCameras = BoolSettingsKey('sound.lane_cameras', true);
  static const soundNoStoppingControlCameras =
      BoolSettingsKey('sound.no_stopping_control_cameras', true);
  static const soundRoadMarkingCameras =
      BoolSettingsKey('sound.road_marking_cameras', true);
  static const soundAverageSpeedCameras =
      BoolSettingsKey('sound.average_speed_cameras', true);
  static const soundMaxSpeedCameras =
      BoolSettingsKey('sound.max_speed_cameras', true);
  static const soundAccidents = BoolSettingsKey('sound.accidents', true);
  static const soundRoadWorks = BoolSettingsKey('sound.road_works', true);
  static const soundTolls = BoolSettingsKey('sound.tolls', true);
  static const soundExceedSpeedLimits =
      BoolSettingsKey('sound.exceed_speed_limits', true);
  static const soundIntermediatePoints =
      BoolSettingsKey('sound.intermediate_points', true);
  static const soundRouteRebuild = BoolSettingsKey('sound.route_rebuild', true);
  static const soundInstructions = BoolSettingsKey('sound.instructions', true);
  static const soundObstacles = BoolSettingsKey('sound.obstacles', true);
  static const soundRoadSubtypes = BoolSettingsKey('sound.road_subtypes', true);
  static const soundLostLocation = BoolSettingsKey('sound.lost_location', true);
  static const soundRouteEnd = BoolSettingsKey('sound.route_end', true);
  static const soundBetterRoute = BoolSettingsKey('sound.better_route', true);

  // Map events — on-route display flags
  static const mapEventsEnabled = BoolSettingsKey('map_events.enabled', true);
  static const mapEventsCameras = BoolSettingsKey('map_events.cameras', true);
  static const mapEventsAccidents =
      BoolSettingsKey('map_events.accidents', true);
  static const mapEventsRoadWorks =
      BoolSettingsKey('map_events.road_works', true);
  static const mapEventsComments = BoolSettingsKey('map_events.comments', true);
  static const mapEventsRoadRestrictions =
      BoolSettingsKey('map_events.road_restrictions', true);
  static const mapEventsOtherEvents =
      BoolSettingsKey('map_events.other_events', true);
  static const mapEventsBubbles = BoolSettingsKey('map_events.bubbles', true);
  static const mapEventsLanesBubbles =
      BoolSettingsKey('map_events.lanes_bubbles', true);

  // Map events — permanent display flags (passed route)
  static const mapEventsPermanentEnabled =
      BoolSettingsKey('map_events.permanent.enabled', false);
  static const mapEventsPermanentStartPoint =
      BoolSettingsKey('map_events.permanent.start_point', true);
  static const mapEventsPermanentFinishPoint =
      BoolSettingsKey('map_events.permanent.finish_point', true);
  static const mapEventsPermanentIntermediatePoints =
      BoolSettingsKey('map_events.permanent.intermediate_points', true);
  static const mapEventsPermanentCameras =
      BoolSettingsKey('map_events.permanent.cameras', true);
  static const mapEventsPermanentAccidents =
      BoolSettingsKey('map_events.permanent.accidents', true);
  static const mapEventsPermanentRoadWorks =
      BoolSettingsKey('map_events.permanent.road_works', true);
  static const mapEventsPermanentComments =
      BoolSettingsKey('map_events.permanent.comments', true);
  static const mapEventsPermanentRoadRestrictions =
      BoolSettingsKey('map_events.permanent.road_restrictions', true);
  static const mapEventsPermanentOtherEvents =
      BoolSettingsKey('map_events.permanent.other_events', true);
  static const mapEventsPermanentTollRoads =
      BoolSettingsKey('map_events.permanent.toll_roads', true);

  // Voice
  static const voiceSelected = NullableStringSettingsKey('voice.selected');
}
