// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'dgis_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class DgisLocalizationsRu extends DgisLocalizations {
  DgisLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get dgis_route_re_search => 'Перестроение маршрута';

  @override
  String get dgis_missing_gps => 'Отсутствует сигнал GPS';

  @override
  String get dgis_you_have_arrived => 'Вы на месте!';

  @override
  String get dgis_better_route_has_been_found => 'Найден маршрут лучше';

  @override
  String get dgis_d_days => 'д';

  @override
  String dgis_d_days_format(num count) {
    return '$count д';
  }

  @override
  String get dgis_h__hours => 'ч';

  @override
  String dgis_h__hours_format(num count) {
    return '$count ч';
  }

  @override
  String get dgis_m__minutes => 'м';

  @override
  String dgis_m__minutes_format(num count) {
    return '$count м';
  }

  @override
  String get dgis_min__minutes => 'мин';

  @override
  String dgis_min__minutes_format(num count) {
    return '$count мин';
  }

  @override
  String get dgis_m__meters => 'м';

  @override
  String dgis_m__meters_format(num count) {
    return '$count м';
  }

  @override
  String get dgis_km => 'км';

  @override
  String dgis_km_format(num count) {
    return '$count км';
  }

  @override
  String get dgis_km_per_h => 'км/ч';

  @override
  String dgis_km_per_h_format(num count) {
    return '$count км/ч';
  }

  @override
  String get dgis_road_exit_caption => 'Съезд';

  @override
  String dgis_road_exit_format(int number) {
    return '$number-й съезд';
  }

  @override
  String dgis_on_foot_duration(String duration) {
    return 'Пешком $duration';
  }

  @override
  String dgis_on_foot_distance(String distance) {
    return 'Пешком $distance';
  }

  @override
  String get dgis_route_start => 'Начало маршрута';

  @override
  String get dgis_route_finish => 'Конец маршрута';

  @override
  String get dgis_direct_route => 'Без остановок';

  @override
  String get dgis_no_routes_found => 'Маршруты не найдены';

  @override
  String get dgis_best_route => 'Лучший маршрут';

  @override
  String get dgis_route_editor_start => 'В путь';

  @override
  String dgis_get_off_after(String after) {
    return 'Выходите после: $after';
  }

  @override
  String dgis_transfers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пересадок',
      many: '$count пересадок',
      few: '$count пересадки',
      one: '1 пересадка',
    );
    return '$_temp0';
  }

  @override
  String dgis_stops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count остановок',
      many: '$count остановок',
      few: '$count остановки',
      one: '1 остановка',
    );
    return '$_temp0';
  }

  @override
  String dgis_stations(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count станций',
      many: '$count станций',
      few: '$countстанции',
      one: '1 станция',
    );
    return '$_temp0';
  }

  @override
  String get dgis_public_transport_type_bus => 'Автобус';

  @override
  String get dgis_public_transport_type_trolleybus => 'Троллейбус';

  @override
  String get dgis_public_transport_type_tram => 'Трамвай';

  @override
  String get dgis_public_transport_type_shuttle_bus => 'Маршрутка';

  @override
  String get dgis_public_transport_type_metro => 'Метро';

  @override
  String get dgis_public_transport_type_suburban_train => 'Электричка';

  @override
  String get dgis_public_transport_type_funicular_railway => 'Фуникулёр';

  @override
  String get dgis_public_transport_type_monorail => 'Монорельс';

  @override
  String get dgis_public_transport_type_waterway => 'Водный транспорт';

  @override
  String get dgis_public_transport_type_cable_car => 'Канатная дорога';

  @override
  String get dgis_public_transport_type_speed_tram => 'Скоростной трамвай';

  @override
  String get dgis_public_transport_type_premetro => 'Метротрам';

  @override
  String get dgis_public_transport_type_light_metro => 'Лёгкое метро';

  @override
  String get dgis_public_transport_type_aeroexpress => 'Аэроэкспресс';

  @override
  String get dgis_public_transport_type_mcc => 'МЦК';

  @override
  String get dgis_public_transport_type_mcd => 'МЦД';

  @override
  String get dgis_navi_arrival => 'прибытие';

  @override
  String get dgis_navi_sound_settings_title => 'Настройка звука';

  @override
  String get dgis_navi_sound_settings_subtitle_on => 'Маневры включены';

  @override
  String get dgis_navi_sound_settings_subtitle_off => 'Маневры выключены';

  @override
  String get dgis_navi_parking_lots_on_the_map => 'Парковки на карте';

  @override
  String get dgis_navi_traffic_jams_on_the_road => 'Пробки на дорогах';

  @override
  String get dgis_navi_end_the_trip => 'Завершить поездку';

  @override
  String get dgis_navi_alert_has_been_added => 'Событие добавлено';

  @override
  String get dgis_navi_failed_to_add_alert => 'Не удалось добавить событие';

  @override
  String dgis_navi_better_route_found_with_time(num minutes) {
    return 'Найден маршрут\nна $minutes мин быстрее';
  }

  @override
  String dgis_navi_longer_route_found_with_time(num minutes) {
    return 'Найден маршрут\nна $minutes мин дольше';
  }

  @override
  String get dgis_navi_route_found_same_time => 'Найден маршрут.\nТо же время';

  @override
  String get dgis_navi_better_route_found_without_time => 'Есть маршрут лучше';

  @override
  String get dgis_navi_better_route_cancel => 'Отмена';

  @override
  String get dgis_navi_route_re_search => 'Перестроение маршрута';

  @override
  String get dgis_navi_missing_gps => 'Потерян сигнал GPS';

  @override
  String get dgis_navi_maneuver_next => 'Затем';

  @override
  String dgis_navi_maneuver_exit_named(String name) {
    return 'Съезд $name';
  }

  @override
  String dgis_navi_maneuver_exit_number(num number) {
    return '$number-й съезд';
  }

  @override
  String get dgis_navi_parking => 'Парковки';

  @override
  String get dgis_navi_finish => 'Вы на месте!';

  @override
  String get dgis_navi_freeroam_ride_management => 'Управление поездкой';

  @override
  String get dgis_navi_view_route => 'Просмотр маршрута';

  @override
  String get dgis_navi_show_minimap => 'Показать миникарту';

  @override
  String get dgis_navi_continue_the_trip => 'Продолжить поездку';

  @override
  String get dgis_navi_indoor_navigation => 'Навигация внутри здания';

  @override
  String dgis_navi_floor(String floor) {
    return '$floor этаж';
  }
}
