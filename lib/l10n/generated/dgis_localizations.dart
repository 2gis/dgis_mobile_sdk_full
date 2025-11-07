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
  /// **'Funicular railway'**
  String get dgis_public_transport_type_funicular_railway;

  /// No description provided for @dgis_public_transport_type_monorail.
  ///
  /// In en, this message translates to:
  /// **'Monorail'**
  String get dgis_public_transport_type_monorail;

  /// No description provided for @dgis_public_transport_type_waterway.
  ///
  /// In en, this message translates to:
  /// **'Waterway transport'**
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
  /// **'Premetro'**
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
