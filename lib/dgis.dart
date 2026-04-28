// TODO: написать док коммент для библиотеки
// ignore: unnecessary_library_directive
library dgis_mobile_sdk;

export 'src/generated/class_message.dart';
export 'src/generated/dart_bindings.dart'
    hide
        ApplicationState,
        BaseCameraInternalMethods,
        BssEventsSourceClearGuard,
        ContextObserver,
        ContextTaggedPointerSnapshot,
        ContextTaggedPointersProvider,
        ContextTaggedPointersProviderInternalMethods,
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
        TouchPointState,
        calculateBearing,
        calculateDistance,
        downloadData,
        makeSystemContext,
        move,
        releaseContext,
        setupBssEventsSourceFromSdk,
        toLocaleManager;
export 'src/generated/enum_set.dart';
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
export 'src/util/stateful_channel_listenable.dart';
export 'src/widgets/common/rounded_corners.dart';
export 'src/widgets/directory/directory_object_widget/directory_object_models.dart';
export 'src/widgets/directory/directory_object_widget/directory_object_view_model.dart';
export 'src/widgets/directory/directory_object_widget/directory_object_widget.dart';
export 'src/widgets/directory/directory_object_widget/directory_object_widget_builder.dart';
export 'src/widgets/directory/directory_object_widget/directory_object_widget_theme.dart';
export 'src/widgets/directory/directory_object_widget/working_hours_factory.dart';
export 'src/widgets/directory/search.dart'
    show DgisSearchWidget, SearchResultBuilder;
export 'src/widgets/directory/search_result_item/search_result_item_builder.dart';
export 'src/widgets/directory/search_result_item/search_result_item_theme.dart';
export 'src/widgets/directory/search_result_item/search_result_item_view_model.dart';
export 'src/widgets/directory/search_result_item/search_result_item_widget.dart';
export 'src/widgets/directory/search_result_item/star_rating_widget.dart';
export 'src/widgets/directory/search_widget_color_scheme.dart';
export 'src/widgets/either.dart';
export 'src/widgets/map/base_map_state.dart' show BaseMapWidgetState;
export 'src/widgets/map/compass_widget.dart';
export 'src/widgets/map/indoor_widget.dart';
export 'src/widgets/map/map_widget.dart' show MapWidget, MapWidgetController;
export 'src/widgets/map/map_widget_color_scheme.dart';
export 'src/widgets/map/mini_map_widget.dart' show MiniMapWidget;
export 'src/widgets/map/modern/compass/modern_compass_widget.dart'
    show ModernCompassWidget;
export 'src/widgets/map/modern/indoor/indoor_widget.dart';
export 'src/widgets/map/modern/my_location/modern_my_location_controller.dart';
export 'src/widgets/map/modern/my_location/modern_my_location_model.dart';
export 'src/widgets/map/modern/my_location/modern_my_location_widget.dart';
export 'src/widgets/map/modern/my_location/modern_my_location_widget_color_scheme.dart';
export 'src/widgets/map/modern/traffic/modern_traffic_widget.dart'
    show ModernTrafficWidget;
export 'src/widgets/map/modern/zoom/modern_zoom_widget.dart'
    show ModernZoomWidget, ModernZoomWidgetColorScheme;
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
export 'src/widgets/navigation/minimap/navigation_minimap_controller.dart';
export 'src/widgets/navigation/minimap/navigation_minimap_widget.dart'
    show NavigationMiniMapWidget;
export 'src/widgets/navigation/my_location/my_location_controller.dart';
export 'src/widgets/navigation/my_location/my_location_model.dart';
export 'src/widgets/navigation/my_location/my_location_widget.dart';
export 'src/widgets/navigation/navigation_layout_widget.dart';
export 'src/widgets/navigation/navigation_map_control_theme.dart';
export 'src/widgets/navigation/parking/parking_controller.dart';
export 'src/widgets/navigation/parking/parking_model.dart';
export 'src/widgets/navigation/parking/parking_widget.dart';
export 'src/widgets/navigation/route_editor/brief_info_provider.dart';
export 'src/widgets/navigation/route_editor/route_card_builder.dart';
export 'src/widgets/navigation/route_editor/route_editor_controller.dart';
export 'src/widgets/navigation/route_editor/route_editor_theme.dart';
export 'src/widgets/navigation/route_editor/route_editor_widget.dart';
export 'src/widgets/navigation/route_editor/route_point_ui.dart';
export 'src/widgets/navigation/route_editor/route_search_point_builder.dart';
export 'src/widgets/navigation/route_editor/transport_mode.dart';
export 'src/widgets/navigation/route_editor/transport_mode_tab_builder.dart';
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
export 'src/widgets/navigation/traffic_line/traffic_line_point_event.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_point_event_type.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_segments_colors.dart';
export 'src/widgets/navigation/traffic_line/traffic_line_widget.dart';
export 'src/widgets/navigation/zoom/zoom_controller.dart';
export 'src/widgets/navigation/zoom/zoom_model.dart';
export 'src/widgets/navigation/zoom/zoom_widget.dart';
