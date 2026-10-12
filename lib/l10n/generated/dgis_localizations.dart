import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'dgis_localizations_en.dart';
import 'dgis_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DgisLocalizations
/// returned by `DgisLocalizations.of(context)`.
///
/// Applications need to include `DgisLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/dgis_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DgisLocalizations.localizationsDelegates,
///   supportedLocales: DgisLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the DgisLocalizations.supportedLocales
/// property.
abstract class DgisLocalizations {
  DgisLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DgisLocalizations? of(BuildContext context) {
    return Localizations.of<DgisLocalizations>(context, DgisLocalizations);
  }

  static const LocalizationsDelegate<DgisLocalizations> delegate =
      _DgisLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @dgis_route_re_search.
  ///
  /// In en, this message translates to:
  /// **'Route recalculation'**
  String get dgis_route_re_search;

  /// No description provided for @dgis_missing_gps.
  ///
  /// In en, this message translates to:
  /// **'No GPS signal received'**
  String get dgis_missing_gps;

  /// No description provided for @dgis_you_have_arrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived!'**
  String get dgis_you_have_arrived;

  /// No description provided for @dgis_better_route_has_been_found.
  ///
  /// In en, this message translates to:
  /// **'Better route has been found'**
  String get dgis_better_route_has_been_found;

  /// No description provided for @dgis_d_days.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get dgis_d_days;

  /// No description provided for @dgis_d_days_format.
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String dgis_d_days_format(num count);

  /// No description provided for @dgis_h__hours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get dgis_h__hours;

  /// No description provided for @dgis_h__hours_format.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String dgis_h__hours_format(num count);

  /// No description provided for @dgis_m__minutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get dgis_m__minutes;

  /// No description provided for @dgis_m__minutes_format.
  ///
  /// In en, this message translates to:
  /// **'{count} m'**
  String dgis_m__minutes_format(num count);

  /// No description provided for @dgis_min__minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get dgis_min__minutes;

  /// No description provided for @dgis_min__minutes_format.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String dgis_min__minutes_format(num count);

  /// No description provided for @dgis_m__meters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get dgis_m__meters;

  /// No description provided for @dgis_m__meters_format.
  ///
  /// In en, this message translates to:
  /// **'{count} m'**
  String dgis_m__meters_format(num count);

  /// No description provided for @dgis_km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get dgis_km;

  /// No description provided for @dgis_km_format.
  ///
  /// In en, this message translates to:
  /// **'{count} km'**
  String dgis_km_format(num count);

  /// No description provided for @dgis_km_per_h.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get dgis_km_per_h;

  /// No description provided for @dgis_km_per_h_format.
  ///
  /// In en, this message translates to:
  /// **'{count} km/h'**
  String dgis_km_per_h_format(num count);

  /// No description provided for @dgis_road_exit_caption.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get dgis_road_exit_caption;

  /// No description provided for @dgis_road_exit_format.
  ///
  /// In en, this message translates to:
  /// **'Exit {number}'**
  String dgis_road_exit_format(int number);

  /// No description provided for @dgis_on_foot_duration.
  ///
  /// In en, this message translates to:
  /// **'On foot {duration}'**
  String dgis_on_foot_duration(String duration);

  /// No description provided for @dgis_on_foot_distance.
  ///
  /// In en, this message translates to:
  /// **'{distance} on foot'**
  String dgis_on_foot_distance(String distance);

  /// No description provided for @dgis_route_start.
  ///
  /// In en, this message translates to:
  /// **'Route start'**
  String get dgis_route_start;

  /// No description provided for @dgis_route_finish.
  ///
  /// In en, this message translates to:
  /// **'Route finish'**
  String get dgis_route_finish;

  /// No description provided for @dgis_direct_route.
  ///
  /// In en, this message translates to:
  /// **'Direct route'**
  String get dgis_direct_route;

  /// No description provided for @dgis_no_routes_found.
  ///
  /// In en, this message translates to:
  /// **'No routes found'**
  String get dgis_no_routes_found;

  /// No description provided for @dgis_best_route.
  ///
  /// In en, this message translates to:
  /// **'Best route'**
  String get dgis_best_route;

  /// No description provided for @dgis_route_editor_start.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get dgis_route_editor_start;

  /// No description provided for @dgis_get_off_after.
  ///
  /// In en, this message translates to:
  /// **'Get off after: {after}'**
  String dgis_get_off_after(String after);

  /// No description provided for @dgis_transfers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transfers} =1{1 transfer} other{{count} transfers}}'**
  String dgis_transfers(num count);

  /// No description provided for @dgis_stops.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stops} =1{1 stop} other{{count} stops}}'**
  String dgis_stops(num count);

  /// No description provided for @dgis_stations.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stations} =1{1 station} other{{count} stations}} '**
  String dgis_stations(num count);

  /// No description provided for @dgis_public_transport_type_bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get dgis_public_transport_type_bus;

  /// No description provided for @dgis_public_transport_type_trolleybus.
  ///
  /// In en, this message translates to:
  /// **'Trolleybus'**
  String get dgis_public_transport_type_trolleybus;

  /// No description provided for @dgis_public_transport_type_tram.
  ///
  /// In en, this message translates to:
  /// **'Tram'**
  String get dgis_public_transport_type_tram;

  /// No description provided for @dgis_public_transport_type_shuttle_bus.
  ///
  /// In en, this message translates to:
  /// **'Shuttle bus'**
  String get dgis_public_transport_type_shuttle_bus;

  /// No description provided for @dgis_public_transport_type_metro.
  ///
  /// In en, this message translates to:
  /// **'Metro'**
  String get dgis_public_transport_type_metro;

  /// No description provided for @dgis_public_transport_type_suburban_train.
  ///
  /// In en, this message translates to:
  /// **'Suburban train'**
  String get dgis_public_transport_type_suburban_train;

  /// No description provided for @dgis_public_transport_type_funicular_railway.
  ///
  /// In en, this message translates to:
  /// **'Funicular'**
  String get dgis_public_transport_type_funicular_railway;

  /// No description provided for @dgis_public_transport_type_monorail.
  ///
  /// In en, this message translates to:
  /// **'Monorail'**
  String get dgis_public_transport_type_monorail;

  /// No description provided for @dgis_public_transport_type_waterway.
  ///
  /// In en, this message translates to:
  /// **'Water transport'**
  String get dgis_public_transport_type_waterway;

  /// No description provided for @dgis_public_transport_type_cable_car.
  ///
  /// In en, this message translates to:
  /// **'Cable car'**
  String get dgis_public_transport_type_cable_car;

  /// No description provided for @dgis_public_transport_type_speed_tram.
  ///
  /// In en, this message translates to:
  /// **'Speed tram'**
  String get dgis_public_transport_type_speed_tram;

  /// No description provided for @dgis_public_transport_type_premetro.
  ///
  /// In en, this message translates to:
  /// **'Metrotram'**
  String get dgis_public_transport_type_premetro;

  /// No description provided for @dgis_public_transport_type_light_metro.
  ///
  /// In en, this message translates to:
  /// **'Light metro'**
  String get dgis_public_transport_type_light_metro;

  /// No description provided for @dgis_public_transport_type_aeroexpress.
  ///
  /// In en, this message translates to:
  /// **'Aeroexpress'**
  String get dgis_public_transport_type_aeroexpress;

  /// No description provided for @dgis_public_transport_type_mcc.
  ///
  /// In en, this message translates to:
  /// **'MCC'**
  String get dgis_public_transport_type_mcc;

  /// No description provided for @dgis_public_transport_type_mcd.
  ///
  /// In en, this message translates to:
  /// **'MCD'**
  String get dgis_public_transport_type_mcd;

  /// No description provided for @dgis_navi_arrival.
  ///
  /// In en, this message translates to:
  /// **'arrival'**
  String get dgis_navi_arrival;

  /// No description provided for @dgis_navi_sound_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Sound settings'**
  String get dgis_navi_sound_settings_title;

  /// No description provided for @dgis_navi_sound_settings_subtitle_on.
  ///
  /// In en, this message translates to:
  /// **'Maneuvers turned on'**
  String get dgis_navi_sound_settings_subtitle_on;

  /// No description provided for @dgis_navi_sound_settings_subtitle_off.
  ///
  /// In en, this message translates to:
  /// **'Maneuvers turned off'**
  String get dgis_navi_sound_settings_subtitle_off;

  /// No description provided for @dgis_navi_parking_lots_on_the_map.
  ///
  /// In en, this message translates to:
  /// **'Parking lots on the map'**
  String get dgis_navi_parking_lots_on_the_map;

  /// No description provided for @dgis_navi_traffic_jams_on_the_road.
  ///
  /// In en, this message translates to:
  /// **'Traffic jams on the roads'**
  String get dgis_navi_traffic_jams_on_the_road;

  /// No description provided for @dgis_navi_end_the_trip.
  ///
  /// In en, this message translates to:
  /// **'End the trip'**
  String get dgis_navi_end_the_trip;

  /// No description provided for @dgis_navi_alert_has_been_added.
  ///
  /// In en, this message translates to:
  /// **'Alert has been added'**
  String get dgis_navi_alert_has_been_added;

  /// No description provided for @dgis_navi_failed_to_add_alert.
  ///
  /// In en, this message translates to:
  /// **'Failed to add alert'**
  String get dgis_navi_failed_to_add_alert;

  /// No description provided for @dgis_navi_better_route_found_with_time.
  ///
  /// In en, this message translates to:
  /// **'Found a route\n{minutes} min faster'**
  String dgis_navi_better_route_found_with_time(num minutes);

  /// No description provided for @dgis_navi_longer_route_found_with_time.
  ///
  /// In en, this message translates to:
  /// **'Found a route\n{minutes} min longer'**
  String dgis_navi_longer_route_found_with_time(num minutes);

  /// No description provided for @dgis_navi_route_found_same_time.
  ///
  /// In en, this message translates to:
  /// **'Found a route.\nSame time'**
  String get dgis_navi_route_found_same_time;

  /// No description provided for @dgis_navi_better_route_found_without_time.
  ///
  /// In en, this message translates to:
  /// **'There is a better route'**
  String get dgis_navi_better_route_found_without_time;

  /// No description provided for @dgis_navi_better_route_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dgis_navi_better_route_cancel;

  /// No description provided for @dgis_navi_route_re_search.
  ///
  /// In en, this message translates to:
  /// **'Updating the route'**
  String get dgis_navi_route_re_search;

  /// No description provided for @dgis_navi_missing_gps.
  ///
  /// In en, this message translates to:
  /// **'GPS signal lost'**
  String get dgis_navi_missing_gps;

  /// No description provided for @dgis_navi_maneuver_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get dgis_navi_maneuver_next;

  /// No description provided for @dgis_navi_maneuver_exit_named.
  ///
  /// In en, this message translates to:
  /// **'Exit {name}'**
  String dgis_navi_maneuver_exit_named(String name);

  /// No description provided for @dgis_navi_maneuver_exit_number.
  ///
  /// In en, this message translates to:
  /// **'Exit {number}'**
  String dgis_navi_maneuver_exit_number(num number);

  /// No description provided for @dgis_navi_parking.
  ///
  /// In en, this message translates to:
  /// **'Parking lots'**
  String get dgis_navi_parking;

  /// No description provided for @dgis_navi_finish.
  ///
  /// In en, this message translates to:
  /// **'You have arrived!'**
  String get dgis_navi_finish;

  /// No description provided for @dgis_navi_freeroam_ride_management.
  ///
  /// In en, this message translates to:
  /// **'Manage the trip'**
  String get dgis_navi_freeroam_ride_management;

  /// No description provided for @dgis_navi_view_route.
  ///
  /// In en, this message translates to:
  /// **'View route'**
  String get dgis_navi_view_route;

  /// No description provided for @dgis_navi_continue_the_trip.
  ///
  /// In en, this message translates to:
  /// **'Continue the trip'**
  String get dgis_navi_continue_the_trip;

  /// No description provided for @dgis_navi_indoor_navigation.
  ///
  /// In en, this message translates to:
  /// **'Indoor navigation'**
  String get dgis_navi_indoor_navigation;

  /// No description provided for @dgis_navi_floor.
  ///
  /// In en, this message translates to:
  /// **'{floor} floor'**
  String dgis_navi_floor(String floor);

  /// No description provided for @dgis_reviews_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}'**
  String dgis_reviews_count(num count);

  /// No description provided for @dgis_charging_not_active.
  ///
  /// In en, this message translates to:
  /// **'Not active'**
  String get dgis_charging_not_active;

  /// No description provided for @dgis_no_places_available.
  ///
  /// In en, this message translates to:
  /// **'No places available'**
  String get dgis_no_places_available;

  /// No description provided for @dgis_charging_available_places_all.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place available} other{{count} places available}}'**
  String dgis_charging_available_places_all(num count);

  /// No description provided for @dgis_charging_available_places_count.
  ///
  /// In en, this message translates to:
  /// **'{free} of {total} available'**
  String dgis_charging_available_places_count(num free, num total);

  /// No description provided for @dgis_entrances_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entrance} other{{count} entrances}}'**
  String dgis_entrances_count(num count);

  /// No description provided for @dgis_building_porches_prefix.
  ///
  /// In en, this message translates to:
  /// **'Entrances:'**
  String get dgis_building_porches_prefix;

  /// No description provided for @dgis_apartments_suffix.
  ///
  /// In en, this message translates to:
  /// **'apt.'**
  String get dgis_apartments_suffix;

  /// No description provided for @dgis_porches.
  ///
  /// In en, this message translates to:
  /// **'Porches'**
  String get dgis_porches;

  /// No description provided for @dgis_entrances.
  ///
  /// In en, this message translates to:
  /// **'Entrances'**
  String get dgis_entrances;

  /// No description provided for @dgis_contacts_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get dgis_contacts_more;

  /// No description provided for @dgis_write_to.
  ///
  /// In en, this message translates to:
  /// **'Write to'**
  String get dgis_write_to;

  /// No description provided for @dgis_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get dgis_copy;

  /// No description provided for @dgis_contacts_title.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get dgis_contacts_title;

  /// No description provided for @dgis_websites_social_networks_title.
  ///
  /// In en, this message translates to:
  /// **'Websites and social networks'**
  String get dgis_websites_social_networks_title;

  /// No description provided for @dgis_navi_show_minimap.
  ///
  /// In en, this message translates to:
  /// **'Show minimap'**
  String get dgis_navi_show_minimap;

  /// No description provided for @dgis_working_hours_24_7.
  ///
  /// In en, this message translates to:
  /// **'Open 24/7'**
  String get dgis_working_hours_24_7;

  /// No description provided for @dgis_working_hours_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dgis_working_hours_daily;

  /// No description provided for @dgis_working_hours_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dgis_working_hours_today;

  /// No description provided for @dgis_working_hours_schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get dgis_working_hours_schedule;

  /// No description provided for @dgis_working_hours_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dgis_working_hours_closed;

  /// No description provided for @dgis_working_hours_closed_until.
  ///
  /// In en, this message translates to:
  /// **'Closed until {time}'**
  String dgis_working_hours_closed_until(String time);

  /// No description provided for @dgis_working_hours_closes_in.
  ///
  /// In en, this message translates to:
  /// **'Closes in'**
  String get dgis_working_hours_closes_in;

  /// No description provided for @dgis_working_hours_opens_in.
  ///
  /// In en, this message translates to:
  /// **'Opens in'**
  String get dgis_working_hours_opens_in;

  /// No description provided for @dgis_working_hours_min_short.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get dgis_working_hours_min_short;

  /// No description provided for @dgis_working_hours_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get dgis_working_hours_tomorrow;

  /// No description provided for @dgis_working_hours_lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get dgis_working_hours_lunch;

  /// No description provided for @dgis_working_hours_break.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get dgis_working_hours_break;

  /// No description provided for @dgis_working_hours_weekdays_label.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get dgis_working_hours_weekdays_label;

  /// No description provided for @dgis_working_hours_weekday_short_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dgis_working_hours_weekday_short_mon;

  /// No description provided for @dgis_working_hours_weekday_short_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dgis_working_hours_weekday_short_tue;

  /// No description provided for @dgis_working_hours_weekday_short_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dgis_working_hours_weekday_short_wed;

  /// No description provided for @dgis_working_hours_weekday_short_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dgis_working_hours_weekday_short_thu;

  /// No description provided for @dgis_working_hours_weekday_short_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dgis_working_hours_weekday_short_fri;

  /// No description provided for @dgis_working_hours_weekday_short_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dgis_working_hours_weekday_short_sat;

  /// No description provided for @dgis_working_hours_weekday_short_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dgis_working_hours_weekday_short_sun;

  /// No description provided for @dgis_working_hours_weekday_closed_to_mon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dgis_working_hours_weekday_closed_to_mon;

  /// No description provided for @dgis_working_hours_weekday_closed_to_tue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dgis_working_hours_weekday_closed_to_tue;

  /// No description provided for @dgis_working_hours_weekday_closed_to_wed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dgis_working_hours_weekday_closed_to_wed;

  /// No description provided for @dgis_working_hours_weekday_closed_to_thu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dgis_working_hours_weekday_closed_to_thu;

  /// No description provided for @dgis_working_hours_weekday_closed_to_fri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dgis_working_hours_weekday_closed_to_fri;

  /// No description provided for @dgis_working_hours_weekday_closed_to_sat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get dgis_working_hours_weekday_closed_to_sat;

  /// No description provided for @dgis_settings_avoid_toll_roads.
  ///
  /// In en, this message translates to:
  /// **'Avoid toll roads'**
  String get dgis_settings_avoid_toll_roads;

  /// No description provided for @dgis_settings_avoid_unpaved_roads.
  ///
  /// In en, this message translates to:
  /// **'Avoid unpaved roads'**
  String get dgis_settings_avoid_unpaved_roads;

  /// No description provided for @dgis_settings_avoid_ferries.
  ///
  /// In en, this message translates to:
  /// **'Avoid ferries'**
  String get dgis_settings_avoid_ferries;

  /// No description provided for @dgis_settings_avoid_locked_roads.
  ///
  /// In en, this message translates to:
  /// **'Avoid locked roads'**
  String get dgis_settings_avoid_locked_roads;

  /// No description provided for @dgis_settings_route_search_type.
  ///
  /// In en, this message translates to:
  /// **'Route type'**
  String get dgis_settings_route_search_type;

  /// No description provided for @dgis_settings_route_search_type_jam.
  ///
  /// In en, this message translates to:
  /// **'With traffic'**
  String get dgis_settings_route_search_type_jam;

  /// No description provided for @dgis_settings_route_search_type_jam_desc.
  ///
  /// In en, this message translates to:
  /// **'Route considers current traffic data'**
  String get dgis_settings_route_search_type_jam_desc;

  /// No description provided for @dgis_settings_route_search_type_statistic.
  ///
  /// In en, this message translates to:
  /// **'Statistical'**
  String get dgis_settings_route_search_type_statistic;

  /// No description provided for @dgis_settings_route_search_type_statistic_desc.
  ///
  /// In en, this message translates to:
  /// **'Route based on traffic statistics'**
  String get dgis_settings_route_search_type_statistic_desc;

  /// No description provided for @dgis_settings_route_search_type_shortest.
  ///
  /// In en, this message translates to:
  /// **'Shortest'**
  String get dgis_settings_route_search_type_shortest;

  /// No description provided for @dgis_settings_route_search_type_shortest_desc.
  ///
  /// In en, this message translates to:
  /// **'Shortest route ignoring traffic'**
  String get dgis_settings_route_search_type_shortest_desc;

  /// No description provided for @dgis_settings_avoid_stairs.
  ///
  /// In en, this message translates to:
  /// **'Avoid stairs'**
  String get dgis_settings_avoid_stairs;

  /// No description provided for @dgis_settings_avoid_underpasses.
  ///
  /// In en, this message translates to:
  /// **'Avoid underpasses'**
  String get dgis_settings_avoid_underpasses;

  /// No description provided for @dgis_settings_use_indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor routing'**
  String get dgis_settings_use_indoor;

  /// No description provided for @dgis_settings_avoid_car_roads.
  ///
  /// In en, this message translates to:
  /// **'Avoid car roads'**
  String get dgis_settings_avoid_car_roads;

  /// No description provided for @dgis_settings_remember_choice.
  ///
  /// In en, this message translates to:
  /// **'Remember my choice'**
  String get dgis_settings_remember_choice;

  /// No description provided for @dgis_settings_transport_types.
  ///
  /// In en, this message translates to:
  /// **'Transport types'**
  String get dgis_settings_transport_types;

  /// No description provided for @dgis_settings_truck_length.
  ///
  /// In en, this message translates to:
  /// **'Length, m'**
  String get dgis_settings_truck_length;

  /// No description provided for @dgis_settings_truck_height.
  ///
  /// In en, this message translates to:
  /// **'Height, m'**
  String get dgis_settings_truck_height;

  /// No description provided for @dgis_settings_truck_width.
  ///
  /// In en, this message translates to:
  /// **'Width, m'**
  String get dgis_settings_truck_width;

  /// No description provided for @dgis_settings_truck_actual_mass.
  ///
  /// In en, this message translates to:
  /// **'Actual mass, t'**
  String get dgis_settings_truck_actual_mass;

  /// No description provided for @dgis_settings_truck_max_permitted_mass.
  ///
  /// In en, this message translates to:
  /// **'Max permitted mass, t'**
  String get dgis_settings_truck_max_permitted_mass;

  /// No description provided for @dgis_settings_truck_axle_load.
  ///
  /// In en, this message translates to:
  /// **'Axle load, t'**
  String get dgis_settings_truck_axle_load;

  /// No description provided for @dgis_settings_truck_title.
  ///
  /// In en, this message translates to:
  /// **'Cargo navigation'**
  String get dgis_settings_truck_title;

  /// No description provided for @dgis_settings_truck_description.
  ///
  /// In en, this message translates to:
  /// **'Creating routes for cargo navigation. The navigator directs you only to the streets, where cargo traffic is allowed. Before the trip, specify the vehicle dimensions, cargo particulars and enable the Internet connection.'**
  String get dgis_settings_truck_description;

  /// No description provided for @dgis_settings_truck_section_dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions and weight'**
  String get dgis_settings_truck_section_dimensions;

  /// No description provided for @dgis_settings_truck_section_cargo.
  ///
  /// In en, this message translates to:
  /// **'Special cargo'**
  String get dgis_settings_truck_section_cargo;

  /// No description provided for @dgis_settings_truck_dangerous_cargo.
  ///
  /// In en, this message translates to:
  /// **'Hazardous cargo'**
  String get dgis_settings_truck_dangerous_cargo;

  /// No description provided for @dgis_settings_truck_explosive_cargo.
  ///
  /// In en, this message translates to:
  /// **'Explosive cargo'**
  String get dgis_settings_truck_explosive_cargo;

  /// No description provided for @dgis_settings_truck_fallback_on_car.
  ///
  /// In en, this message translates to:
  /// **'Fallback on car route'**
  String get dgis_settings_truck_fallback_on_car;

  /// No description provided for @dgis_working_hours_weekday_closed_to_sun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get dgis_working_hours_weekday_closed_to_sun;

  /// No description provided for @dgis_settings_section_route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get dgis_settings_section_route;

  /// No description provided for @dgis_settings_section_car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get dgis_settings_section_car;

  /// No description provided for @dgis_settings_section_map_events.
  ///
  /// In en, this message translates to:
  /// **'Map events'**
  String get dgis_settings_section_map_events;

  /// No description provided for @dgis_settings_section_passed_route.
  ///
  /// In en, this message translates to:
  /// **'Passed route display'**
  String get dgis_settings_section_passed_route;

  /// No description provided for @dgis_settings_section_pedestrian.
  ///
  /// In en, this message translates to:
  /// **'Pedestrian'**
  String get dgis_settings_section_pedestrian;

  /// No description provided for @dgis_settings_section_bicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get dgis_settings_section_bicycle;

  /// No description provided for @dgis_settings_section_scooter.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get dgis_settings_section_scooter;

  /// No description provided for @dgis_settings_section_motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get dgis_settings_section_motorcycle;

  /// No description provided for @dgis_settings_section_public_transport.
  ///
  /// In en, this message translates to:
  /// **'Public transport'**
  String get dgis_settings_section_public_transport;

  /// No description provided for @dgis_settings_section_truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get dgis_settings_section_truck;

  /// No description provided for @dgis_settings_section_other_navigators.
  ///
  /// In en, this message translates to:
  /// **'Other navigators'**
  String get dgis_settings_section_other_navigators;

  /// No description provided for @dgis_settings_section_sound_and_voice.
  ///
  /// In en, this message translates to:
  /// **'Sound and voice'**
  String get dgis_settings_section_sound_and_voice;

  /// No description provided for @dgis_settings_suggest_better_route.
  ///
  /// In en, this message translates to:
  /// **'Suggest better route'**
  String get dgis_settings_suggest_better_route;

  /// No description provided for @dgis_settings_show_alternative_routes.
  ///
  /// In en, this message translates to:
  /// **'Show alternative routes'**
  String get dgis_settings_show_alternative_routes;

  /// No description provided for @dgis_settings_rebuild_on_deviation.
  ///
  /// In en, this message translates to:
  /// **'Rebuild route on deviation'**
  String get dgis_settings_rebuild_on_deviation;

  /// No description provided for @dgis_settings_callout_visualization.
  ///
  /// In en, this message translates to:
  /// **'Route info display'**
  String get dgis_settings_callout_visualization;

  /// No description provided for @dgis_settings_callout_always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get dgis_settings_callout_always;

  /// No description provided for @dgis_settings_callout_always_desc.
  ///
  /// In en, this message translates to:
  /// **'Show callouts with time and distance when at least one route is present'**
  String get dgis_settings_callout_always_desc;

  /// No description provided for @dgis_settings_callout_multiple_routes.
  ///
  /// In en, this message translates to:
  /// **'Multiple routes'**
  String get dgis_settings_callout_multiple_routes;

  /// No description provided for @dgis_settings_callout_multiple_routes_desc.
  ///
  /// In en, this message translates to:
  /// **'Show callouts only when more than one route is present'**
  String get dgis_settings_callout_multiple_routes_desc;

  /// No description provided for @dgis_settings_callout_none.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get dgis_settings_callout_none;

  /// No description provided for @dgis_settings_callout_none_desc.
  ///
  /// In en, this message translates to:
  /// **'Do not show callouts and do not calculate their positions'**
  String get dgis_settings_callout_none_desc;

  /// No description provided for @dgis_settings_map_events.
  ///
  /// In en, this message translates to:
  /// **'Map events'**
  String get dgis_settings_map_events;

  /// No description provided for @dgis_settings_map_events_accidents.
  ///
  /// In en, this message translates to:
  /// **'Accidents'**
  String get dgis_settings_map_events_accidents;

  /// No description provided for @dgis_settings_map_events_road_works.
  ///
  /// In en, this message translates to:
  /// **'Road works'**
  String get dgis_settings_map_events_road_works;

  /// No description provided for @dgis_settings_map_events_cameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get dgis_settings_map_events_cameras;

  /// No description provided for @dgis_settings_map_events_comments.
  ///
  /// In en, this message translates to:
  /// **'Messages on map'**
  String get dgis_settings_map_events_comments;

  /// No description provided for @dgis_settings_map_events_road_restrictions.
  ///
  /// In en, this message translates to:
  /// **'Road closures'**
  String get dgis_settings_map_events_road_restrictions;

  /// No description provided for @dgis_settings_map_events_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dgis_settings_map_events_other;

  /// No description provided for @dgis_settings_map_events_bubbles.
  ///
  /// In en, this message translates to:
  /// **'Maneuver bubbles'**
  String get dgis_settings_map_events_bubbles;

  /// No description provided for @dgis_settings_map_events_lanes_bubbles.
  ///
  /// In en, this message translates to:
  /// **'Lane bubbles'**
  String get dgis_settings_map_events_lanes_bubbles;

  /// No description provided for @dgis_settings_passed_route.
  ///
  /// In en, this message translates to:
  /// **'Passed route items'**
  String get dgis_settings_passed_route;

  /// No description provided for @dgis_settings_passed_route_start_point.
  ///
  /// In en, this message translates to:
  /// **'Start point'**
  String get dgis_settings_passed_route_start_point;

  /// No description provided for @dgis_settings_passed_route_finish_point.
  ///
  /// In en, this message translates to:
  /// **'Finish point'**
  String get dgis_settings_passed_route_finish_point;

  /// No description provided for @dgis_settings_passed_route_intermediate_points.
  ///
  /// In en, this message translates to:
  /// **'Intermediate points'**
  String get dgis_settings_passed_route_intermediate_points;

  /// No description provided for @dgis_settings_passed_route_cameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get dgis_settings_passed_route_cameras;

  /// No description provided for @dgis_settings_passed_route_accidents.
  ///
  /// In en, this message translates to:
  /// **'Accidents'**
  String get dgis_settings_passed_route_accidents;

  /// No description provided for @dgis_settings_passed_route_road_works.
  ///
  /// In en, this message translates to:
  /// **'Road works'**
  String get dgis_settings_passed_route_road_works;

  /// No description provided for @dgis_settings_passed_route_comments.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get dgis_settings_passed_route_comments;

  /// No description provided for @dgis_settings_passed_route_road_restrictions.
  ///
  /// In en, this message translates to:
  /// **'Road closures'**
  String get dgis_settings_passed_route_road_restrictions;

  /// No description provided for @dgis_settings_passed_route_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dgis_settings_passed_route_other;

  /// No description provided for @dgis_settings_passed_route_toll_roads.
  ///
  /// In en, this message translates to:
  /// **'Toll roads'**
  String get dgis_settings_passed_route_toll_roads;

  /// No description provided for @dgis_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Navigation settings'**
  String get dgis_settings_title;

  /// No description provided for @dgis_settings_dashboard_button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dgis_settings_dashboard_button;

  /// No description provided for @dgis_settings_sounds_and_alerts.
  ///
  /// In en, this message translates to:
  /// **'Sounds and alerts'**
  String get dgis_settings_sounds_and_alerts;

  /// No description provided for @dgis_settings_voices.
  ///
  /// In en, this message translates to:
  /// **'Voices'**
  String get dgis_settings_voices;

  /// No description provided for @dgis_settings_voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get dgis_settings_voice;

  /// No description provided for @dgis_settings_voices_yours.
  ///
  /// In en, this message translates to:
  /// **'Your voices'**
  String get dgis_settings_voices_yours;

  /// No description provided for @dgis_settings_voices_available.
  ///
  /// In en, this message translates to:
  /// **'Available to download'**
  String get dgis_settings_voices_available;

  /// No description provided for @dgis_settings_voices_language_selection.
  ///
  /// In en, this message translates to:
  /// **'Language selection'**
  String get dgis_settings_voices_language_selection;

  /// No description provided for @dgis_settings_voices_play.
  ///
  /// In en, this message translates to:
  /// **'Play sample'**
  String get dgis_settings_voices_play;

  /// No description provided for @dgis_settings_voices_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete voice'**
  String get dgis_settings_voices_delete;

  /// No description provided for @dgis_settings_voices_update.
  ///
  /// In en, this message translates to:
  /// **'Update voice'**
  String get dgis_settings_voices_update;

  /// No description provided for @dgis_settings_voices_download.
  ///
  /// In en, this message translates to:
  /// **'Download voice'**
  String get dgis_settings_voices_download;

  /// No description provided for @dgis_settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get dgis_settings_language;

  /// No description provided for @dgis_settings_sound_section_general.
  ///
  /// In en, this message translates to:
  /// **'Sound guidance'**
  String get dgis_settings_sound_section_general;

  /// No description provided for @dgis_settings_sound_mode.
  ///
  /// In en, this message translates to:
  /// **'Voice instructions'**
  String get dgis_settings_sound_mode;

  /// No description provided for @dgis_settings_sound_mode_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get dgis_settings_sound_mode_off;

  /// No description provided for @dgis_settings_sound_mode_important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get dgis_settings_sound_mode_important;

  /// No description provided for @dgis_settings_sound_mode_all.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get dgis_settings_sound_mode_all;

  /// No description provided for @dgis_settings_sound_mode_subtitle_off.
  ///
  /// In en, this message translates to:
  /// **'Sound is off'**
  String get dgis_settings_sound_mode_subtitle_off;

  /// No description provided for @dgis_settings_sound_mode_subtitle_important.
  ///
  /// In en, this message translates to:
  /// **'Cameras and road events'**
  String get dgis_settings_sound_mode_subtitle_important;

  /// No description provided for @dgis_settings_sound_mode_subtitle_all.
  ///
  /// In en, this message translates to:
  /// **'All events are announced'**
  String get dgis_settings_sound_mode_subtitle_all;

  /// No description provided for @dgis_settings_sound_duck_other_audio.
  ///
  /// In en, this message translates to:
  /// **'Lower other sounds'**
  String get dgis_settings_sound_duck_other_audio;

  /// No description provided for @dgis_settings_sound_volume.
  ///
  /// In en, this message translates to:
  /// **'Prompt volume'**
  String get dgis_settings_sound_volume;

  /// No description provided for @dgis_settings_sound_volume_min.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get dgis_settings_sound_volume_min;

  /// No description provided for @dgis_settings_sound_volume_low.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get dgis_settings_sound_volume_low;

  /// No description provided for @dgis_settings_sound_volume_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get dgis_settings_sound_volume_standard;

  /// No description provided for @dgis_settings_sound_section_event_warnings.
  ///
  /// In en, this message translates to:
  /// **'Event warnings'**
  String get dgis_settings_sound_section_event_warnings;

  /// No description provided for @dgis_settings_sound_speed_exceed.
  ///
  /// In en, this message translates to:
  /// **'Speeding'**
  String get dgis_settings_sound_speed_exceed;

  /// No description provided for @dgis_settings_sound_speed_exceed_description.
  ///
  /// In en, this message translates to:
  /// **'Sound alert when the speed limit is broken'**
  String get dgis_settings_sound_speed_exceed_description;

  /// No description provided for @dgis_settings_sound_speed_exceed_threshold_format.
  ///
  /// In en, this message translates to:
  /// **'Warn me when exceeding by {count} km/h'**
  String dgis_settings_sound_speed_exceed_threshold_format(int count);

  /// No description provided for @dgis_settings_sound_speed_exceed_threshold_below_format.
  ///
  /// In en, this message translates to:
  /// **'Warn me {count} km/h before the limit'**
  String dgis_settings_sound_speed_exceed_threshold_below_format(int count);

  /// No description provided for @dgis_settings_sound_section_cameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get dgis_settings_sound_section_cameras;

  /// No description provided for @dgis_settings_sound_cameras.
  ///
  /// In en, this message translates to:
  /// **'Warn about cameras'**
  String get dgis_settings_sound_cameras;

  /// No description provided for @dgis_settings_sound_cameras_description.
  ///
  /// In en, this message translates to:
  /// **'Voice announcements about cameras on the route'**
  String get dgis_settings_sound_cameras_description;

  /// No description provided for @dgis_settings_sound_camera_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed control'**
  String get dgis_settings_sound_camera_speed;

  /// No description provided for @dgis_settings_sound_camera_always.
  ///
  /// In en, this message translates to:
  /// **'Always announce'**
  String get dgis_settings_sound_camera_always;

  /// No description provided for @dgis_settings_sound_camera_always_description.
  ///
  /// In en, this message translates to:
  /// **'Always warn about cameras, even when the speed limit is not broken'**
  String get dgis_settings_sound_camera_always_description;

  /// No description provided for @dgis_settings_sound_camera_stop.
  ///
  /// In en, this message translates to:
  /// **'Stopping'**
  String get dgis_settings_sound_camera_stop;

  /// No description provided for @dgis_settings_sound_camera_crossroad.
  ///
  /// In en, this message translates to:
  /// **'Crossroad passage'**
  String get dgis_settings_sound_camera_crossroad;

  /// No description provided for @dgis_settings_sound_camera_lane.
  ///
  /// In en, this message translates to:
  /// **'Lane control'**
  String get dgis_settings_sound_camera_lane;

  /// No description provided for @dgis_settings_sound_camera_marking.
  ///
  /// In en, this message translates to:
  /// **'Road marking'**
  String get dgis_settings_sound_camera_marking;

  /// No description provided for @dgis_settings_sound_section_road_events.
  ///
  /// In en, this message translates to:
  /// **'Road events'**
  String get dgis_settings_sound_section_road_events;

  /// No description provided for @dgis_settings_sound_road_events.
  ///
  /// In en, this message translates to:
  /// **'Announce all events'**
  String get dgis_settings_sound_road_events;

  /// No description provided for @dgis_settings_sound_road_events_description.
  ///
  /// In en, this message translates to:
  /// **'Report everything along the route'**
  String get dgis_settings_sound_road_events_description;

  /// No description provided for @dgis_settings_sound_event_toll.
  ///
  /// In en, this message translates to:
  /// **'Toll roads'**
  String get dgis_settings_sound_event_toll;

  /// No description provided for @dgis_settings_sound_event_road_works.
  ///
  /// In en, this message translates to:
  /// **'Road works'**
  String get dgis_settings_sound_event_road_works;

  /// No description provided for @dgis_settings_sound_event_obstacle.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get dgis_settings_sound_event_obstacle;

  /// No description provided for @dgis_settings_sound_event_accident.
  ///
  /// In en, this message translates to:
  /// **'Accidents'**
  String get dgis_settings_sound_event_accident;

  /// No description provided for @dgis_settings_sound_event_instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get dgis_settings_sound_event_instructions;

  /// No description provided for @dgis_settings_sound_event_route_rebuild.
  ///
  /// In en, this message translates to:
  /// **'Route rebuilt'**
  String get dgis_settings_sound_event_route_rebuild;

  /// No description provided for @dgis_settings_sound_event_better_route.
  ///
  /// In en, this message translates to:
  /// **'Better route'**
  String get dgis_settings_sound_event_better_route;

  /// No description provided for @dgis_settings_sound_event_intermediate_points.
  ///
  /// In en, this message translates to:
  /// **'Intermediate points'**
  String get dgis_settings_sound_event_intermediate_points;

  /// No description provided for @dgis_settings_sound_event_road_subtypes.
  ///
  /// In en, this message translates to:
  /// **'Road subtypes'**
  String get dgis_settings_sound_event_road_subtypes;

  /// No description provided for @dgis_settings_sound_event_no_signal.
  ///
  /// In en, this message translates to:
  /// **'GPS signal lost'**
  String get dgis_settings_sound_event_no_signal;

  /// No description provided for @dgis_settings_sound_event_finish.
  ///
  /// In en, this message translates to:
  /// **'Route finished'**
  String get dgis_settings_sound_event_finish;
}

class _DgisLocalizationsDelegate
    extends LocalizationsDelegate<DgisLocalizations> {
  const _DgisLocalizationsDelegate();

  @override
  Future<DgisLocalizations> load(Locale locale) {
    return SynchronousFuture<DgisLocalizations>(
        lookupDgisLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_DgisLocalizationsDelegate old) => false;
}

DgisLocalizations lookupDgisLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return DgisLocalizationsEn();
    case 'ru':
      return DgisLocalizationsRu();
  }

  throw FlutterError(
      'DgisLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
