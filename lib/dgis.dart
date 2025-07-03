// TODO: написать док коммент для библиотеки
// ignore: unnecessary_library_directive
library dgis_mobile_sdk;

export 'src/generated/dart_bindings.dart'
    hide
        ApplicationState,
        BaseCameraInternalMethods,
        ImageLoader,
        LocaleChangeNotifier,
        MapBuilder,
        MapGestureRecognizer,
        MapInternalMethods,
        MapRenderer,
        MapSurfaceProvider,
        ModelDataLoader,
        PlatformLocaleManager,
        ProductType,
        calculateBearing,
        calculateDistance,
        createImage,
        createModelData,
        downloadData,
        makeSystemContext,
        move,
        toLocaleManager;
export 'src/generated/native_exception.dart';
export 'src/platform/coordinates/geo_point.dart';
export 'src/platform/coordinates/geo_point_with_elevation.dart';
export 'src/platform/dgis.dart';
export 'src/platform/map/image_loader.dart';
export 'src/platform/map/map_appearance.dart';
export 'src/platform/map/map_options.dart';
export 'src/platform/map/map_theme.dart';
export 'src/platform/map/model_loader.dart';
export 'src/platform/map/touch_events_observer.dart';
export 'src/widgets/common/rounded_corners.dart';
export 'src/widgets/directory/search.dart'
    show DgisSearchWidget, SearchResultBuilder;
export 'src/widgets/directory/search_widget_color_scheme.dart';
export 'src/widgets/either.dart';
export 'src/widgets/map/base_map_state.dart' show BaseMapWidgetState;
export 'src/widgets/map/compass_widget.dart';
export 'src/widgets/map/indoor_widget.dart';
export 'src/widgets/map/map_widget.dart' show MapWidget, MapWidgetController;
export 'src/widgets/map/map_widget_color_scheme.dart';
export 'src/widgets/map/my_location_widget.dart';
export 'src/widgets/map/themed_map_controlling_widget.dart';
export 'src/widgets/map/themed_map_controlling_widget_state.dart';
export 'src/widgets/map/traffic_widget.dart';
export 'src/widgets/map/zoom_widget.dart'
    show ZoomWidget, ZoomWidgetColorScheme;
export 'src/widgets/widget_shadows.dart';
export 'src/widgets/navigation/better_route_prompt/better_route_prompt_controller.dart';
export 'src/widgets/navigation/better_route_prompt/better_route_prompt_model.dart';
export 'src/widgets/navigation/better_route_prompt/better_route_prompt_theme.dart';
export 'src/widgets/navigation/better_route_prompt/better_route_prompt_widget.dart';
export 'src/widgets/navigation/compass/compass_controller.dart';
export 'src/widgets/navigation/compass/compass_model.dart';
export 'src/widgets/navigation/compass/compass_theme.dart';
export 'src/widgets/navigation/compass/compass_widget.dart';
export 'src/widgets/navigation/dashboard/dashboard_controller.dart';
export 'src/widgets/navigation/dashboard/dashboard_model.dart';
export 'src/widgets/navigation/dashboard/dashboard_theme.dart';
export 'src/widgets/navigation/dashboard/dashboard_widget.dart';
export 'src/widgets/navigation/extensions.dart';
export 'src/widgets/navigation/finish_route/finish_route_controller.dart';
export 'src/widgets/navigation/finish_route/finish_route_model.dart';
export 'src/widgets/navigation/finish_route/finish_route_theme.dart';
export 'src/widgets/navigation/finish_route/finish_route_widget.dart';
export 'src/widgets/navigation/maneuvers/maneuver_controller.dart';
export 'src/widgets/navigation/maneuvers/maneuver_model.dart';
export 'src/widgets/navigation/maneuvers/maneuver_theme.dart';
export 'src/widgets/navigation/maneuvers/maneuver_widget.dart';
export 'src/widgets/navigation/my_location/my_location_controller.dart';
export 'src/widgets/navigation/my_location/my_location_model.dart';
export 'src/widgets/navigation/my_location/my_location_widget.dart';
export 'src/widgets/navigation/navigation_layout_widget.dart';
export 'src/widgets/navigation/navigation_map_control_theme.dart';
export 'src/widgets/navigation/parking/parking_controller.dart';
export 'src/widgets/navigation/parking/parking_model.dart';
export 'src/widgets/navigation/parking/parking_widget.dart';
export 'src/widgets/navigation/speed_limit/camera_progress_theme.dart';
export 'src/widgets/navigation/speed_limit/speed_limit_controller.dart';
export 'src/widgets/navigation/speed_limit/speed_limit_model.dart';
export 'src/widgets/navigation/speed_limit/speed_limit_theme.dart';
export 'src/widgets/navigation/speed_limit/speed_limit_widget.dart';
export 'src/widgets/navigation/speed_limit/speed_limit_widget_theme.dart';
export 'src/widgets/navigation/speed_limit/speedometer_theme.dart';
export 'src/widgets/navigation/traffic/traffic_controller.dart';
export 'src/widgets/navigation/traffic/traffic_model.dart';
export 'src/widgets/navigation/traffic/traffic_widget.dart';
export 'src/widgets/navigation/traffic/traffic_widget_theme.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_color_scheme.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_controller.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_model.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_segments_colors.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_widget.dart';
export 'src/widgets/navigation/zoom/zoom_controller.dart';
export 'src/widgets/navigation/zoom/zoom_model.dart';
export 'src/widgets/navigation/zoom/zoom_widget.dart';
