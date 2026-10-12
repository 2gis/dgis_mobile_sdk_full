// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'dgis_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DgisLocalizationsEn extends DgisLocalizations {
  DgisLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dgis_route_re_search => 'Route recalculation';

  @override
  String get dgis_missing_gps => 'No GPS signal received';

  @override
  String get dgis_you_have_arrived => 'You have arrived!';

  @override
  String get dgis_better_route_has_been_found => 'Better route has been found';

  @override
  String get dgis_d_days => 'd';

  @override
  String dgis_d_days_format(num count) {
    return '$count d';
  }

  @override
  String get dgis_h__hours => 'h';

  @override
  String dgis_h__hours_format(num count) {
    return '$count h';
  }

  @override
  String get dgis_m__minutes => 'm';

  @override
  String dgis_m__minutes_format(num count) {
    return '$count m';
  }

  @override
  String get dgis_min__minutes => 'min';

  @override
  String dgis_min__minutes_format(num count) {
    return '$count min';
  }

  @override
  String get dgis_m__meters => 'm';

  @override
  String dgis_m__meters_format(num count) {
    return '$count m';
  }

  @override
  String get dgis_km => 'km';

  @override
  String dgis_km_format(num count) {
    return '$count km';
  }

  @override
  String get dgis_km_per_h => 'km/h';

  @override
  String dgis_km_per_h_format(num count) {
    return '$count km/h';
  }

  @override
  String get dgis_road_exit_caption => 'Exit';

  @override
  String dgis_road_exit_format(int number) {
    return 'Exit $number';
  }

  @override
  String dgis_on_foot_duration(String duration) {
    return 'On foot $duration';
  }

  @override
  String dgis_on_foot_distance(String distance) {
    return '$distance on foot';
  }

  @override
  String get dgis_route_start => 'Route start';

  @override
  String get dgis_route_finish => 'Route finish';

  @override
  String get dgis_direct_route => 'Direct route';

  @override
  String get dgis_no_routes_found => 'No routes found';

  @override
  String get dgis_best_route => 'Best route';

  @override
  String get dgis_route_editor_start => 'Go!';

  @override
  String dgis_get_off_after(String after) {
    return 'Get off after: $after';
  }

  @override
  String dgis_transfers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfers',
      one: '1 transfer',
      zero: 'No transfers',
    );
    return '$_temp0';
  }

  @override
  String dgis_stops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
      zero: 'No stops',
    );
    return '$_temp0';
  }

  @override
  String dgis_stations(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations',
      one: '1 station',
      zero: 'No stations',
    );
    return '$_temp0 ';
  }

  @override
  String get dgis_public_transport_type_bus => 'Bus';

  @override
  String get dgis_public_transport_type_trolleybus => 'Trolleybus';

  @override
  String get dgis_public_transport_type_tram => 'Tram';

  @override
  String get dgis_public_transport_type_shuttle_bus => 'Shuttle bus';

  @override
  String get dgis_public_transport_type_metro => 'Metro';

  @override
  String get dgis_public_transport_type_suburban_train => 'Suburban train';

  @override
  String get dgis_public_transport_type_funicular_railway => 'Funicular';

  @override
  String get dgis_public_transport_type_monorail => 'Monorail';

  @override
  String get dgis_public_transport_type_waterway => 'Water transport';

  @override
  String get dgis_public_transport_type_cable_car => 'Cable car';

  @override
  String get dgis_public_transport_type_speed_tram => 'Speed tram';

  @override
  String get dgis_public_transport_type_premetro => 'Metrotram';

  @override
  String get dgis_public_transport_type_light_metro => 'Light metro';

  @override
  String get dgis_public_transport_type_aeroexpress => 'Aeroexpress';

  @override
  String get dgis_public_transport_type_mcc => 'MCC';

  @override
  String get dgis_public_transport_type_mcd => 'MCD';

  @override
  String get dgis_navi_arrival => 'arrival';

  @override
  String get dgis_navi_sound_settings_title => 'Sound settings';

  @override
  String get dgis_navi_sound_settings_subtitle_on => 'Maneuvers turned on';

  @override
  String get dgis_navi_sound_settings_subtitle_off => 'Maneuvers turned off';

  @override
  String get dgis_navi_parking_lots_on_the_map => 'Parking lots on the map';

  @override
  String get dgis_navi_traffic_jams_on_the_road => 'Traffic jams on the roads';

  @override
  String get dgis_navi_end_the_trip => 'End the trip';

  @override
  String get dgis_navi_alert_has_been_added => 'Alert has been added';

  @override
  String get dgis_navi_failed_to_add_alert => 'Failed to add alert';

  @override
  String dgis_navi_better_route_found_with_time(num minutes) {
    return 'Found a route\n$minutes min faster';
  }

  @override
  String dgis_navi_longer_route_found_with_time(num minutes) {
    return 'Found a route\n$minutes min longer';
  }

  @override
  String get dgis_navi_route_found_same_time => 'Found a route.\nSame time';

  @override
  String get dgis_navi_better_route_found_without_time =>
      'There is a better route';

  @override
  String get dgis_navi_better_route_cancel => 'Cancel';

  @override
  String get dgis_navi_route_re_search => 'Updating the route';

  @override
  String get dgis_navi_missing_gps => 'GPS signal lost';

  @override
  String get dgis_navi_maneuver_next => 'Next';

  @override
  String dgis_navi_maneuver_exit_named(String name) {
    return 'Exit $name';
  }

  @override
  String dgis_navi_maneuver_exit_number(num number) {
    return 'Exit $number';
  }

  @override
  String get dgis_navi_parking => 'Parking lots';

  @override
  String get dgis_navi_finish => 'You have arrived!';

  @override
  String get dgis_navi_freeroam_ride_management => 'Manage the trip';

  @override
  String get dgis_navi_view_route => 'View route';

  @override
  String get dgis_navi_continue_the_trip => 'Continue the trip';

  @override
  String get dgis_navi_indoor_navigation => 'Indoor navigation';

  @override
  String dgis_navi_floor(String floor) {
    return '$floor floor';
  }

  @override
  String dgis_reviews_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get dgis_charging_not_active => 'Not active';

  @override
  String get dgis_no_places_available => 'No places available';

  @override
  String dgis_charging_available_places_all(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places available',
      one: '1 place available',
    );
    return '$_temp0';
  }

  @override
  String dgis_charging_available_places_count(num free, num total) {
    return '$free of $total available';
  }

  @override
  String dgis_entrances_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrances',
      one: '1 entrance',
    );
    return '$_temp0';
  }

  @override
  String get dgis_building_porches_prefix => 'Entrances:';

  @override
  String get dgis_apartments_suffix => 'apt.';

  @override
  String get dgis_porches => 'Porches';

  @override
  String get dgis_entrances => 'Entrances';

  @override
  String get dgis_contacts_more => 'More';

  @override
  String get dgis_write_to => 'Write to';

  @override
  String get dgis_copy => 'Copy';

  @override
  String get dgis_contacts_title => 'Contacts';

  @override
  String get dgis_websites_social_networks_title =>
      'Websites and social networks';

  @override
  String get dgis_navi_show_minimap => 'Show minimap';

  @override
  String get dgis_working_hours_24_7 => 'Open 24/7';

  @override
  String get dgis_working_hours_daily => 'Daily';

  @override
  String get dgis_working_hours_today => 'Today';

  @override
  String get dgis_working_hours_schedule => 'Schedule';

  @override
  String get dgis_working_hours_closed => 'Closed';

  @override
  String dgis_working_hours_closed_until(String time) {
    return 'Closed until $time';
  }

  @override
  String get dgis_working_hours_closes_in => 'Closes in';

  @override
  String get dgis_working_hours_opens_in => 'Opens in';

  @override
  String get dgis_working_hours_min_short => 'min';

  @override
  String get dgis_working_hours_tomorrow => 'tomorrow';

  @override
  String get dgis_working_hours_lunch => 'Lunch';

  @override
  String get dgis_working_hours_break => 'Break';

  @override
  String get dgis_working_hours_weekdays_label => 'Weekdays';

  @override
  String get dgis_working_hours_weekday_short_mon => 'Mon';

  @override
  String get dgis_working_hours_weekday_short_tue => 'Tue';

  @override
  String get dgis_working_hours_weekday_short_wed => 'Wed';

  @override
  String get dgis_working_hours_weekday_short_thu => 'Thu';

  @override
  String get dgis_working_hours_weekday_short_fri => 'Fri';

  @override
  String get dgis_working_hours_weekday_short_sat => 'Sat';

  @override
  String get dgis_working_hours_weekday_short_sun => 'Sun';

  @override
  String get dgis_working_hours_weekday_closed_to_mon => 'Monday';

  @override
  String get dgis_working_hours_weekday_closed_to_tue => 'Tuesday';

  @override
  String get dgis_working_hours_weekday_closed_to_wed => 'Wednesday';

  @override
  String get dgis_working_hours_weekday_closed_to_thu => 'Thursday';

  @override
  String get dgis_working_hours_weekday_closed_to_fri => 'Friday';

  @override
  String get dgis_working_hours_weekday_closed_to_sat => 'Saturday';

  @override
  String get dgis_settings_avoid_toll_roads => 'Avoid toll roads';

  @override
  String get dgis_settings_avoid_unpaved_roads => 'Avoid unpaved roads';

  @override
  String get dgis_settings_avoid_ferries => 'Avoid ferries';

  @override
  String get dgis_settings_avoid_locked_roads => 'Avoid locked roads';

  @override
  String get dgis_settings_route_search_type => 'Route type';

  @override
  String get dgis_settings_route_search_type_jam => 'With traffic';

  @override
  String get dgis_settings_route_search_type_jam_desc =>
      'Route considers current traffic data';

  @override
  String get dgis_settings_route_search_type_statistic => 'Statistical';

  @override
  String get dgis_settings_route_search_type_statistic_desc =>
      'Route based on traffic statistics';

  @override
  String get dgis_settings_route_search_type_shortest => 'Shortest';

  @override
  String get dgis_settings_route_search_type_shortest_desc =>
      'Shortest route ignoring traffic';

  @override
  String get dgis_settings_avoid_stairs => 'Avoid stairs';

  @override
  String get dgis_settings_avoid_underpasses => 'Avoid underpasses';

  @override
  String get dgis_settings_use_indoor => 'Indoor routing';

  @override
  String get dgis_settings_avoid_car_roads => 'Avoid car roads';

  @override
  String get dgis_settings_remember_choice => 'Remember my choice';

  @override
  String get dgis_settings_transport_types => 'Transport types';

  @override
  String get dgis_settings_truck_length => 'Length, m';

  @override
  String get dgis_settings_truck_height => 'Height, m';

  @override
  String get dgis_settings_truck_width => 'Width, m';

  @override
  String get dgis_settings_truck_actual_mass => 'Actual mass, t';

  @override
  String get dgis_settings_truck_max_permitted_mass => 'Max permitted mass, t';

  @override
  String get dgis_settings_truck_axle_load => 'Axle load, t';

  @override
  String get dgis_settings_truck_title => 'Cargo navigation';

  @override
  String get dgis_settings_truck_description =>
      'Creating routes for cargo navigation. The navigator directs you only to the streets, where cargo traffic is allowed. Before the trip, specify the vehicle dimensions, cargo particulars and enable the Internet connection.';

  @override
  String get dgis_settings_truck_section_dimensions => 'Dimensions and weight';

  @override
  String get dgis_settings_truck_section_cargo => 'Special cargo';

  @override
  String get dgis_settings_truck_dangerous_cargo => 'Hazardous cargo';

  @override
  String get dgis_settings_truck_explosive_cargo => 'Explosive cargo';

  @override
  String get dgis_settings_truck_fallback_on_car => 'Fallback on car route';

  @override
  String get dgis_working_hours_weekday_closed_to_sun => 'Sunday';

  @override
  String get dgis_settings_section_route => 'Route';

  @override
  String get dgis_settings_section_car => 'Car';

  @override
  String get dgis_settings_section_map_events => 'Map events';

  @override
  String get dgis_settings_section_passed_route => 'Passed route display';

  @override
  String get dgis_settings_section_pedestrian => 'Pedestrian';

  @override
  String get dgis_settings_section_bicycle => 'Bicycle';

  @override
  String get dgis_settings_section_scooter => 'Scooter';

  @override
  String get dgis_settings_section_motorcycle => 'Motorcycle';

  @override
  String get dgis_settings_section_public_transport => 'Public transport';

  @override
  String get dgis_settings_section_truck => 'Truck';

  @override
  String get dgis_settings_section_other_navigators => 'Other navigators';

  @override
  String get dgis_settings_section_sound_and_voice => 'Sound and voice';

  @override
  String get dgis_settings_suggest_better_route => 'Suggest better route';

  @override
  String get dgis_settings_show_alternative_routes => 'Show alternative routes';

  @override
  String get dgis_settings_rebuild_on_deviation => 'Rebuild route on deviation';

  @override
  String get dgis_settings_callout_visualization => 'Route info display';

  @override
  String get dgis_settings_callout_always => 'Always';

  @override
  String get dgis_settings_callout_always_desc =>
      'Show callouts with time and distance when at least one route is present';

  @override
  String get dgis_settings_callout_multiple_routes => 'Multiple routes';

  @override
  String get dgis_settings_callout_multiple_routes_desc =>
      'Show callouts only when more than one route is present';

  @override
  String get dgis_settings_callout_none => 'Never';

  @override
  String get dgis_settings_callout_none_desc =>
      'Do not show callouts and do not calculate their positions';

  @override
  String get dgis_settings_map_events => 'Map events';

  @override
  String get dgis_settings_map_events_accidents => 'Accidents';

  @override
  String get dgis_settings_map_events_road_works => 'Road works';

  @override
  String get dgis_settings_map_events_cameras => 'Cameras';

  @override
  String get dgis_settings_map_events_comments => 'Messages on map';

  @override
  String get dgis_settings_map_events_road_restrictions => 'Road closures';

  @override
  String get dgis_settings_map_events_other => 'Other';

  @override
  String get dgis_settings_map_events_bubbles => 'Maneuver bubbles';

  @override
  String get dgis_settings_map_events_lanes_bubbles => 'Lane bubbles';

  @override
  String get dgis_settings_passed_route => 'Passed route items';

  @override
  String get dgis_settings_passed_route_start_point => 'Start point';

  @override
  String get dgis_settings_passed_route_finish_point => 'Finish point';

  @override
  String get dgis_settings_passed_route_intermediate_points =>
      'Intermediate points';

  @override
  String get dgis_settings_passed_route_cameras => 'Cameras';

  @override
  String get dgis_settings_passed_route_accidents => 'Accidents';

  @override
  String get dgis_settings_passed_route_road_works => 'Road works';

  @override
  String get dgis_settings_passed_route_comments => 'Messages';

  @override
  String get dgis_settings_passed_route_road_restrictions => 'Road closures';

  @override
  String get dgis_settings_passed_route_other => 'Other';

  @override
  String get dgis_settings_passed_route_toll_roads => 'Toll roads';

  @override
  String get dgis_settings_title => 'Navigation settings';

  @override
  String get dgis_settings_dashboard_button => 'Settings';

  @override
  String get dgis_settings_sounds_and_alerts => 'Sounds and alerts';

  @override
  String get dgis_settings_voices => 'Voices';

  @override
  String get dgis_settings_voice => 'Voice';

  @override
  String get dgis_settings_voices_yours => 'Your voices';

  @override
  String get dgis_settings_voices_available => 'Available to download';

  @override
  String get dgis_settings_voices_language_selection => 'Language selection';

  @override
  String get dgis_settings_voices_play => 'Play sample';

  @override
  String get dgis_settings_voices_delete => 'Delete voice';

  @override
  String get dgis_settings_voices_update => 'Update voice';

  @override
  String get dgis_settings_voices_download => 'Download voice';

  @override
  String get dgis_settings_language => 'Language';

  @override
  String get dgis_settings_sound_section_general => 'Sound guidance';

  @override
  String get dgis_settings_sound_mode => 'Voice instructions';

  @override
  String get dgis_settings_sound_mode_off => 'Off';

  @override
  String get dgis_settings_sound_mode_important => 'Important';

  @override
  String get dgis_settings_sound_mode_all => 'All events';

  @override
  String get dgis_settings_sound_mode_subtitle_off => 'Sound is off';

  @override
  String get dgis_settings_sound_mode_subtitle_important =>
      'Cameras and road events';

  @override
  String get dgis_settings_sound_mode_subtitle_all =>
      'All events are announced';

  @override
  String get dgis_settings_sound_duck_other_audio => 'Lower other sounds';

  @override
  String get dgis_settings_sound_volume => 'Prompt volume';

  @override
  String get dgis_settings_sound_volume_min => 'Minimum';

  @override
  String get dgis_settings_sound_volume_low => 'Quiet';

  @override
  String get dgis_settings_sound_volume_standard => 'Standard';

  @override
  String get dgis_settings_sound_section_event_warnings => 'Event warnings';

  @override
  String get dgis_settings_sound_speed_exceed => 'Speeding';

  @override
  String get dgis_settings_sound_speed_exceed_description =>
      'Sound alert when the speed limit is broken';

  @override
  String dgis_settings_sound_speed_exceed_threshold_format(int count) {
    return 'Warn me when exceeding by $count km/h';
  }

  @override
  String dgis_settings_sound_speed_exceed_threshold_below_format(int count) {
    return 'Warn me $count km/h before the limit';
  }

  @override
  String get dgis_settings_sound_section_cameras => 'Cameras';

  @override
  String get dgis_settings_sound_cameras => 'Warn about cameras';

  @override
  String get dgis_settings_sound_cameras_description =>
      'Voice announcements about cameras on the route';

  @override
  String get dgis_settings_sound_camera_speed => 'Speed control';

  @override
  String get dgis_settings_sound_camera_always => 'Always announce';

  @override
  String get dgis_settings_sound_camera_always_description =>
      'Always warn about cameras, even when the speed limit is not broken';

  @override
  String get dgis_settings_sound_camera_stop => 'Stopping';

  @override
  String get dgis_settings_sound_camera_crossroad => 'Crossroad passage';

  @override
  String get dgis_settings_sound_camera_lane => 'Lane control';

  @override
  String get dgis_settings_sound_camera_marking => 'Road marking';

  @override
  String get dgis_settings_sound_section_road_events => 'Road events';

  @override
  String get dgis_settings_sound_road_events => 'Announce all events';

  @override
  String get dgis_settings_sound_road_events_description =>
      'Report everything along the route';

  @override
  String get dgis_settings_sound_event_toll => 'Toll roads';

  @override
  String get dgis_settings_sound_event_road_works => 'Road works';

  @override
  String get dgis_settings_sound_event_obstacle => 'Obstacles';

  @override
  String get dgis_settings_sound_event_accident => 'Accidents';

  @override
  String get dgis_settings_sound_event_instructions => 'Instructions';

  @override
  String get dgis_settings_sound_event_route_rebuild => 'Route rebuilt';

  @override
  String get dgis_settings_sound_event_better_route => 'Better route';

  @override
  String get dgis_settings_sound_event_intermediate_points =>
      'Intermediate points';

  @override
  String get dgis_settings_sound_event_road_subtypes => 'Road subtypes';

  @override
  String get dgis_settings_sound_event_no_signal => 'GPS signal lost';

  @override
  String get dgis_settings_sound_event_finish => 'Route finished';
}
