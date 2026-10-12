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
  String get dgis_public_transport_type_cable_car => 'Канатный трамвай';

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
  String get dgis_navi_continue_the_trip => 'Продолжить поездку';

  @override
  String get dgis_navi_indoor_navigation => 'Навигация внутри здания';

  @override
  String dgis_navi_floor(String floor) {
    return '$floor этаж';
  }

  @override
  String dgis_reviews_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзывов',
      many: '$count отзывов',
      few: '$count отзыва',
      one: '1 отзыв',
      zero: 'Нет отзывов',
    );
    return '$_temp0';
  }

  @override
  String get dgis_charging_not_active => 'Не активна';

  @override
  String get dgis_no_places_available => 'Нет свободных мест';

  @override
  String dgis_charging_available_places_all(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мест доступно',
      many: '$count мест доступно',
      few: '$count места доступно',
      one: '1 место доступно',
    );
    return '$_temp0';
  }

  @override
  String dgis_charging_available_places_count(num free, num total) {
    return '$free из $total доступно';
  }

  @override
  String dgis_entrances_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подъездов',
      many: '$count подъездов',
      few: '$count подъезда',
      one: '1 подъезд',
    );
    return '$_temp0';
  }

  @override
  String get dgis_building_porches_prefix => 'Подъезды:';

  @override
  String get dgis_apartments_suffix => 'кв.';

  @override
  String get dgis_porches => 'Подъезды';

  @override
  String get dgis_entrances => 'Входы';

  @override
  String get dgis_contacts_more => 'Ещё';

  @override
  String get dgis_write_to => 'Написать в';

  @override
  String get dgis_copy => 'Копировать';

  @override
  String get dgis_contacts_title => 'Контакты';

  @override
  String get dgis_websites_social_networks_title => 'Сайты и соцсети';

  @override
  String get dgis_navi_show_minimap => 'Показать миникарту';

  @override
  String get dgis_working_hours_24_7 => 'Круглосуточно';

  @override
  String get dgis_working_hours_daily => 'Ежедневно';

  @override
  String get dgis_working_hours_today => 'Сегодня';

  @override
  String get dgis_working_hours_schedule => 'Расписание';

  @override
  String get dgis_working_hours_closed => 'Закрыто';

  @override
  String dgis_working_hours_closed_until(String time) {
    return 'Закрыто до $time';
  }

  @override
  String get dgis_working_hours_closes_in => 'Закроется через';

  @override
  String get dgis_working_hours_opens_in => 'Откроется через';

  @override
  String get dgis_working_hours_min_short => 'мин';

  @override
  String get dgis_working_hours_tomorrow => 'завтра';

  @override
  String get dgis_working_hours_lunch => 'Обед';

  @override
  String get dgis_working_hours_break => 'Перерыв';

  @override
  String get dgis_working_hours_weekdays_label => 'Будни';

  @override
  String get dgis_working_hours_weekday_short_mon => 'Пн';

  @override
  String get dgis_working_hours_weekday_short_tue => 'Вт';

  @override
  String get dgis_working_hours_weekday_short_wed => 'Ср';

  @override
  String get dgis_working_hours_weekday_short_thu => 'Чт';

  @override
  String get dgis_working_hours_weekday_short_fri => 'Пт';

  @override
  String get dgis_working_hours_weekday_short_sat => 'Сб';

  @override
  String get dgis_working_hours_weekday_short_sun => 'Вс';

  @override
  String get dgis_working_hours_weekday_closed_to_mon => 'понедельника';

  @override
  String get dgis_working_hours_weekday_closed_to_tue => 'вторника';

  @override
  String get dgis_working_hours_weekday_closed_to_wed => 'среды';

  @override
  String get dgis_working_hours_weekday_closed_to_thu => 'четверга';

  @override
  String get dgis_working_hours_weekday_closed_to_fri => 'пятницы';

  @override
  String get dgis_working_hours_weekday_closed_to_sat => 'субботы';

  @override
  String get dgis_settings_avoid_toll_roads => 'Избегать платных дорог';

  @override
  String get dgis_settings_avoid_unpaved_roads => 'Избегать грунтовых дорог';

  @override
  String get dgis_settings_avoid_ferries => 'Избегать паромов';

  @override
  String get dgis_settings_avoid_locked_roads => 'Избегать закрытых дорог';

  @override
  String get dgis_settings_route_search_type => 'Тип маршрута';

  @override
  String get dgis_settings_route_search_type_jam => 'С учётом пробок';

  @override
  String get dgis_settings_route_search_type_jam_desc =>
      'Маршрут учитывает актуальные данные о пробках';

  @override
  String get dgis_settings_route_search_type_statistic => 'Статистический';

  @override
  String get dgis_settings_route_search_type_statistic_desc =>
      'Маршрут на основе статистики загруженности';

  @override
  String get dgis_settings_route_search_type_shortest => 'Кратчайший';

  @override
  String get dgis_settings_route_search_type_shortest_desc =>
      'Кратчайший маршрут без учёта пробок';

  @override
  String get dgis_settings_avoid_stairs => 'Избегать лестниц';

  @override
  String get dgis_settings_avoid_underpasses => 'Избегать подземных переходов';

  @override
  String get dgis_settings_use_indoor => 'Маршруты внутри зданий';

  @override
  String get dgis_settings_avoid_car_roads => 'Избегать автодорог';

  @override
  String get dgis_settings_remember_choice => 'Запомнить мой выбор';

  @override
  String get dgis_settings_transport_types => 'Типы транспорта';

  @override
  String get dgis_settings_truck_length => 'Длина, м';

  @override
  String get dgis_settings_truck_height => 'Высота, м';

  @override
  String get dgis_settings_truck_width => 'Ширина, м';

  @override
  String get dgis_settings_truck_actual_mass => 'Фактическая масса, т';

  @override
  String get dgis_settings_truck_max_permitted_mass => 'Разрешённая масса, т';

  @override
  String get dgis_settings_truck_axle_load => 'Нагрузка на ось, т';

  @override
  String get dgis_settings_truck_title => 'Грузовая навигация';

  @override
  String get dgis_settings_truck_description =>
      'Строим маршруты для грузового транспорта. Навигатор ведёт только по тем улицам, где можно ездить грузовикам. Перед поездкой укажите габариты машины, особенности груза и включите интернет.';

  @override
  String get dgis_settings_truck_section_dimensions => 'Габариты и масса';

  @override
  String get dgis_settings_truck_section_cargo => 'Особый груз';

  @override
  String get dgis_settings_truck_dangerous_cargo => 'Опасный груз';

  @override
  String get dgis_settings_truck_explosive_cargo => 'Взрывчатый груз';

  @override
  String get dgis_settings_truck_fallback_on_car =>
      'Откат на автомобильный маршрут';

  @override
  String get dgis_working_hours_weekday_closed_to_sun => 'воскресенья';

  @override
  String get dgis_settings_section_route => 'Маршрут';

  @override
  String get dgis_settings_section_car => 'Автомобиль';

  @override
  String get dgis_settings_section_map_events => 'Дорожные события';

  @override
  String get dgis_settings_section_passed_route => 'Пройденный маршрут';

  @override
  String get dgis_settings_section_pedestrian => 'Пешком';

  @override
  String get dgis_settings_section_bicycle => 'Велосипед';

  @override
  String get dgis_settings_section_scooter => 'Самокат';

  @override
  String get dgis_settings_section_motorcycle => 'Мотоцикл';

  @override
  String get dgis_settings_section_public_transport => 'Общественный транспорт';

  @override
  String get dgis_settings_section_truck => 'Грузовик';

  @override
  String get dgis_settings_section_other_navigators => 'Другие навигаторы';

  @override
  String get dgis_settings_section_sound_and_voice => 'Звук и голос';

  @override
  String get dgis_settings_suggest_better_route => 'Предлагать маршрут лучше';

  @override
  String get dgis_settings_show_alternative_routes =>
      'Показывать альтернативные маршруты';

  @override
  String get dgis_settings_rebuild_on_deviation =>
      'Перестроить маршрут при сходе';

  @override
  String get dgis_settings_callout_visualization => 'Отображение информации';

  @override
  String get dgis_settings_callout_always => 'Всегда';

  @override
  String get dgis_settings_callout_always_desc =>
      'Показывать баблы с временем и длиной, если добавлен хотя бы один маршрут';

  @override
  String get dgis_settings_callout_multiple_routes => 'Несколько маршрутов';

  @override
  String get dgis_settings_callout_multiple_routes_desc =>
      'Показывать баблы только если добавлено более одного маршрута';

  @override
  String get dgis_settings_callout_none => 'Не показывать';

  @override
  String get dgis_settings_callout_none_desc =>
      'Не показывать баблы и не рассчитывать их позиции';

  @override
  String get dgis_settings_map_events => 'Дорожные события на карте';

  @override
  String get dgis_settings_map_events_accidents => 'ДТП';

  @override
  String get dgis_settings_map_events_road_works => 'Дорожные работы';

  @override
  String get dgis_settings_map_events_cameras => 'Камеры';

  @override
  String get dgis_settings_map_events_comments => 'Сообщения на карте';

  @override
  String get dgis_settings_map_events_road_restrictions => 'Перекрытия';

  @override
  String get dgis_settings_map_events_other => 'Прочее';

  @override
  String get dgis_settings_map_events_bubbles => 'Подсказки маневров';

  @override
  String get dgis_settings_map_events_lanes_bubbles => 'Подсказки полос';

  @override
  String get dgis_settings_passed_route => 'Элементы на пройденном маршруте';

  @override
  String get dgis_settings_passed_route_start_point => 'Начальная точка';

  @override
  String get dgis_settings_passed_route_finish_point => 'Конечная точка';

  @override
  String get dgis_settings_passed_route_intermediate_points =>
      'Промежуточные точки';

  @override
  String get dgis_settings_passed_route_cameras => 'Камеры';

  @override
  String get dgis_settings_passed_route_accidents => 'ДТП';

  @override
  String get dgis_settings_passed_route_road_works => 'Дорожные работы';

  @override
  String get dgis_settings_passed_route_comments => 'Сообщения';

  @override
  String get dgis_settings_passed_route_road_restrictions => 'Перекрытия';

  @override
  String get dgis_settings_passed_route_other => 'Прочее';

  @override
  String get dgis_settings_passed_route_toll_roads => 'Платные дороги';

  @override
  String get dgis_settings_title => 'Настройки навигатора';

  @override
  String get dgis_settings_dashboard_button => 'Настройки';

  @override
  String get dgis_settings_sounds_and_alerts => 'Звуки и оповещения';

  @override
  String get dgis_settings_voices => 'Голоса';

  @override
  String get dgis_settings_voice => 'Голос';

  @override
  String get dgis_settings_voices_yours => 'Ваши голоса';

  @override
  String get dgis_settings_voices_available => 'Доступные к загрузке';

  @override
  String get dgis_settings_voices_language_selection => 'Выбор языка';

  @override
  String get dgis_settings_voices_play => 'Проиграть пример';

  @override
  String get dgis_settings_voices_delete => 'Удалить голос';

  @override
  String get dgis_settings_voices_update => 'Обновить голос';

  @override
  String get dgis_settings_voices_download => 'Загрузить голос';

  @override
  String get dgis_settings_language => 'Язык';

  @override
  String get dgis_settings_sound_section_general => 'Звуковое сопровождение';

  @override
  String get dgis_settings_sound_mode => 'Голосовые инструкции';

  @override
  String get dgis_settings_sound_mode_off => 'Выключены';

  @override
  String get dgis_settings_sound_mode_important => 'Важные';

  @override
  String get dgis_settings_sound_mode_all => 'Все события';

  @override
  String get dgis_settings_sound_mode_subtitle_off => 'Звук выключен';

  @override
  String get dgis_settings_sound_mode_subtitle_important =>
      'Камеры и дорожные события';

  @override
  String get dgis_settings_sound_mode_subtitle_all =>
      'Озвучиваются все события';

  @override
  String get dgis_settings_sound_duck_other_audio => 'Приглушать другие звуки';

  @override
  String get dgis_settings_sound_volume => 'Громкость подсказок';

  @override
  String get dgis_settings_sound_volume_min => 'Минимум';

  @override
  String get dgis_settings_sound_volume_low => 'Тихая';

  @override
  String get dgis_settings_sound_volume_standard => 'Стандарт';

  @override
  String get dgis_settings_sound_section_event_warnings =>
      'Предупреждение о событиях';

  @override
  String get dgis_settings_sound_speed_exceed => 'Превышение скорости';

  @override
  String get dgis_settings_sound_speed_exceed_description =>
      'Звуковой сигнал при нарушении скоростного режима';

  @override
  String dgis_settings_sound_speed_exceed_threshold_format(int count) {
    return 'Предупредим при превышении на $count км/ч';
  }

  @override
  String dgis_settings_sound_speed_exceed_threshold_below_format(int count) {
    return 'Предупредим о скоростном лимите за $count км/ч';
  }

  @override
  String get dgis_settings_sound_section_cameras => 'Камеры';

  @override
  String get dgis_settings_sound_cameras => 'Предупреждать о камерах';

  @override
  String get dgis_settings_sound_cameras_description =>
      'Голосовые инструкции о камерах на маршруте';

  @override
  String get dgis_settings_sound_camera_speed => 'Контроль скорости';

  @override
  String get dgis_settings_sound_camera_always => 'Озвучивать всегда';

  @override
  String get dgis_settings_sound_camera_always_description =>
      'Всегда предупреждать о камерах, даже если скорость не превышена';

  @override
  String get dgis_settings_sound_camera_stop => 'Остановка';

  @override
  String get dgis_settings_sound_camera_crossroad => 'Проезд перекрёстка';

  @override
  String get dgis_settings_sound_camera_lane => 'Контроль полосы';

  @override
  String get dgis_settings_sound_camera_marking => 'Разметка';

  @override
  String get dgis_settings_sound_section_road_events => 'Дорожные события';

  @override
  String get dgis_settings_sound_road_events => 'Озвучивать все события';

  @override
  String get dgis_settings_sound_road_events_description =>
      'Сообщать обо всём по маршруту';

  @override
  String get dgis_settings_sound_event_toll => 'Платные дороги';

  @override
  String get dgis_settings_sound_event_road_works => 'Дорожные работы';

  @override
  String get dgis_settings_sound_event_obstacle => 'Препятствия';

  @override
  String get dgis_settings_sound_event_accident => 'ДТП';

  @override
  String get dgis_settings_sound_event_instructions => 'Инструкции';

  @override
  String get dgis_settings_sound_event_route_rebuild => 'Маршрут перестроен';

  @override
  String get dgis_settings_sound_event_better_route => 'Маршрут лучше';

  @override
  String get dgis_settings_sound_event_intermediate_points =>
      'Промежуточные точки';

  @override
  String get dgis_settings_sound_event_road_subtypes => 'Подтипы дорог';

  @override
  String get dgis_settings_sound_event_no_signal => 'Потерян сигнал GPS';

  @override
  String get dgis_settings_sound_event_finish => 'Маршрут завершён';
}
