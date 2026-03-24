import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import './directory_object_models.dart';

/// Factory for creating [WorkingHoursData] from SDK data.
///
/// Uses [sdk.WorkStatus] for status and schedule display,
/// and [sdk.OpeningHours] for building the full weekly schedule.
class WorkingHoursFactory {
  static const _daysInWeek = 7;
  static const _minutesInHour = 60;
  static const _minutesInDay = 24 * 60;
  static const _criticalCloseMinutes = 15;

  final DgisLocalizations _localizations;

  WorkingHoursFactory(this._localizations);

  /// Creates [WorkingHoursData] from SDK data.
  ///
  /// [openingHours] - Weekly opening hours for building the full schedule.
  /// [workStatus] - Current work status with pre-computed display hints.
  WorkingHoursData? make(
    sdk.OpeningHours? openingHours,
    sdk.WorkStatus? workStatus,
  ) {
    if (openingHours == null || workStatus == null) return null;

    if (openingHours.isOpen24x7) {
      return WorkingHoursData(
        shortTitle: '',
        alertLevel: WorkingHoursAlertLevel.low,
        mediumTitle:
            workStatus.scheduleHint ?? _localizations.dgis_working_hours_24_7,
        full: [
          WorkingHoursFullRow(
            days: _localizations.dgis_working_hours_daily,
            title: _localizations.dgis_working_hours_24_7,
          ),
        ],
        scheduleLabel: _localizations.dgis_working_hours_schedule,
        isUniformDaily: true,
        isOpenSoon: false,
        isOpen24x7: true,
      );
    }

    var shortTitle = '';
    var alertLevel = WorkingHoursAlertLevel.low;
    var isOpenSoon = false;

    workStatus.openStatus.match(
      opened: (_) {},
      openingSoon: (openingSoon) {
        shortTitle = workStatus.openStatusHint;
        isOpenSoon = true;
        alertLevel =
            openingSoon.timeUntilOpen.inMinutes <= _criticalCloseMinutes
                ? WorkingHoursAlertLevel.high
                : WorkingHoursAlertLevel.medium;
      },
      closingSoon: (closingSoon) {
        shortTitle = workStatus.openStatusHint;
        alertLevel =
            closingSoon.timeUntilClose.inMinutes <= _criticalCloseMinutes
                ? WorkingHoursAlertLevel.high
                : WorkingHoursAlertLevel.medium;
      },
      closed: (_) {
        shortTitle = workStatus.openStatusHint;
        alertLevel = WorkingHoursAlertLevel.high;
      },
    );

    final parsedSchedule = _parseWeekIntervals(openingHours);
    final isUniformDaily = _isUniformDaily(parsedSchedule.openingsByDay);

    String mediumTitle;
    if (workStatus.openStatus.isClosingSoon) {
      mediumTitle = workStatus.openStatusHint;
    } else if (workStatus.openStatus.isClosed && !isUniformDaily) {
      mediumTitle = workStatus.openStatusHint;
    } else {
      mediumTitle = workStatus.scheduleHint ?? workStatus.openStatusHint;
    }

    return WorkingHoursData(
      shortTitle: shortTitle,
      alertLevel: alertLevel,
      mediumTitle: mediumTitle,
      mediumSubtitle: workStatus.breakHint,
      full: _buildFullSchedule(parsedSchedule),
      scheduleLabel: _localizations.dgis_working_hours_schedule,
      isUniformDaily: isUniformDaily,
      isOpenSoon: isOpenSoon,
      isOpen24x7: false,
    );
  }

  _ParsedWeekSchedule _parseWeekIntervals(sdk.OpeningHours? openingHours) {
    if (openingHours == null) {
      return _ParsedWeekSchedule(
        openingsByDay: List.generate(_daysInWeek, (_) => []),
        closingsByDay: List.generate(_daysInWeek, (_) => []),
      );
    }

    final weekOpeningHours = openingHours.weekOpeningHours;
    final weekClosingHours = openingHours.weekClosingHours;
    final daysAvailable = weekOpeningHours.length.clamp(0, _daysInWeek);

    final openingsByDay = <List<_OpeningInterval>>[];
    final closingsByDay = <List<_ClosingInterval>>[];

    for (var i = 0; i < daysAvailable; i++) {
      final openings = <_OpeningInterval>[];
      for (final interval in weekOpeningHours[i]) {
        final startMinutes = _minutesFromHoursAndMinutes(
          interval.startTime.time.hours,
          interval.startTime.time.minutes,
        );
        final endMinutes = _minutesFromHoursAndMinutes(
          interval.finishTime.time.hours,
          interval.finishTime.time.minutes,
        );
        openings.add(
          _OpeningInterval(
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            wrapsToNextDay: endMinutes <= startMinutes,
          ),
        );
      }
      openings.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
      openingsByDay.add(openings);

      final closings = <_ClosingInterval>[];
      if (i < weekClosingHours.length) {
        for (final closing in weekClosingHours[i]) {
          final startMinutes = _minutesFromHoursAndMinutes(
            closing.interval.startTime.time.hours,
            closing.interval.startTime.time.minutes,
          );
          final endMinutes = _minutesFromHoursAndMinutes(
            closing.interval.finishTime.time.hours,
            closing.interval.finishTime.time.minutes,
          );
          closings.add(
            _ClosingInterval(
              startMinutes: startMinutes,
              endMinutes: endMinutes,
              reason: closing.reason,
            ),
          );
        }
      }
      closings.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
      closingsByDay.add(closings);
    }

    for (var i = daysAvailable; i < _daysInWeek; i++) {
      openingsByDay.add([]);
      closingsByDay.add([]);
    }

    return _ParsedWeekSchedule(
      openingsByDay: openingsByDay,
      closingsByDay: closingsByDay,
    );
  }

  String _patternKey(List<_OpeningInterval> day) {
    if (day.isEmpty) return '_closed_';
    return day
        .map(
          (e) =>
              '${e.startMinutes}-${e.endMinutes}${e.wrapsToNextDay ? "w" : ""}',
        )
        .join(';');
  }

  bool _isUniformDaily(List<List<_OpeningInterval>> displayByDay) {
    if (displayByDay.isEmpty) return false;
    final dailyPatternKey = _patternKey(displayByDay[0]);
    return dailyPatternKey != '_closed_' &&
        displayByDay
            .skip(1)
            .every((day) => _patternKey(day) == dailyPatternKey);
  }

  List<WorkingHoursFullRow> _buildFullSchedule(
    _ParsedWeekSchedule schedule,
  ) {
    final dayNames = [
      _localizations.dgis_working_hours_weekday_short_mon,
      _localizations.dgis_working_hours_weekday_short_tue,
      _localizations.dgis_working_hours_weekday_short_wed,
      _localizations.dgis_working_hours_weekday_short_thu,
      _localizations.dgis_working_hours_weekday_short_fri,
      _localizations.dgis_working_hours_weekday_short_sat,
      _localizations.dgis_working_hours_weekday_short_sun,
    ];

    final openingsByDay = schedule.openingsByDay;
    final closingsByDay = schedule.closingsByDay;

    final groups = <_DayGroup>[];
    var currentGroup = _DayGroup(
      startDayIndex: 0,
      endDayIndex: 0,
      patternKey: _patternKey(openingsByDay[0]),
    );

    for (var dayIndex = 1; dayIndex < _daysInWeek; dayIndex++) {
      final key = _patternKey(openingsByDay[dayIndex]);
      if (key == currentGroup.patternKey) {
        currentGroup = _DayGroup(
          startDayIndex: currentGroup.startDayIndex,
          endDayIndex: dayIndex,
          patternKey: currentGroup.patternKey,
        );
      } else {
        groups.add(currentGroup);
        currentGroup = _DayGroup(
          startDayIndex: dayIndex,
          endDayIndex: dayIndex,
          patternKey: key,
        );
      }
    }
    groups.add(currentGroup);

    String daysTitle(int start, int end) {
      if (start == end) return dayNames[start];
      if (end == start + 1) return '${dayNames[start]}, ${dayNames[end]}';
      return '${dayNames[start]}–${dayNames[end]}';
    }

    final fullRows = <WorkingHoursFullRow>[];
    for (final group in groups) {
      var titleDays = daysTitle(group.startDayIndex, group.endDayIndex);

      if (group.startDayIndex == 0 &&
          group.endDayIndex == 4 &&
          group.patternKey != '_closed_') {
        titleDays = _localizations.dgis_working_hours_weekdays_label;
      }

      if (group.patternKey == '_closed_') {
        fullRows.add(
          WorkingHoursFullRow(
            days: titleDays,
            title: _localizations.dgis_working_hours_closed,
          ),
        );
        continue;
      }

      final groupOpenings = openingsByDay[group.startDayIndex];
      if (groupOpenings.isEmpty) {
        fullRows.add(
          WorkingHoursFullRow(
            days: titleDays,
            title: _localizations.dgis_working_hours_closed,
          ),
        );
        continue;
      }

      final firstInterval = groupOpenings.first;
      final lastInterval = groupOpenings.last;
      final workSpan =
          '${_formatTime(firstInterval.startMinutes)}–${_formatTime(lastInterval.endMinutes)}';

      final dayClosings = closingsByDay[group.startDayIndex];
      final gaps = dayClosings
          .where((c) => c.reason != sdk.ClosedReason.workTime)
          .map((closing) {
        final breakLabel = switch (closing.reason) {
          sdk.ClosedReason.lunch => _localizations.dgis_working_hours_lunch,
          sdk.ClosedReason.break_ => _localizations.dgis_working_hours_break,
          sdk.ClosedReason.workTime => '',
        };
        return '$breakLabel ${_formatTime(closing.startMinutes)}–${_formatTime(closing.endMinutes)}';
      }).toList();

      fullRows.add(
        WorkingHoursFullRow(
          days: titleDays,
          title: workSpan,
          subtitle: gaps.isEmpty ? null : gaps.join(', '),
        ),
      );
    }

    return fullRows;
  }

  int _minutesFromHoursAndMinutes(int hours, int minutes) {
    return hours * _minutesInHour + minutes;
  }

  String _formatTime(int minutes) {
    final normalized =
        ((minutes % _minutesInDay) + _minutesInDay) % _minutesInDay;
    final hours = normalized ~/ _minutesInHour;
    final mins = normalized % _minutesInHour;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}

/// Internal week schedule representation.
class _ParsedWeekSchedule {
  final List<List<_OpeningInterval>> openingsByDay;
  final List<List<_ClosingInterval>> closingsByDay;

  const _ParsedWeekSchedule({
    required this.openingsByDay,
    required this.closingsByDay,
  });
}

/// Internal opening interval representation.
class _OpeningInterval {
  final int startMinutes;
  final int endMinutes;
  final bool wrapsToNextDay;

  const _OpeningInterval({
    required this.startMinutes,
    required this.endMinutes,
    required this.wrapsToNextDay,
  });
}

/// Internal closing interval representation.
class _ClosingInterval {
  final int startMinutes;
  final int endMinutes;
  final sdk.ClosedReason reason;

  const _ClosingInterval({
    required this.startMinutes,
    required this.endMinutes,
    required this.reason,
  });
}

/// Internal day group for schedule display.
class _DayGroup {
  final int startDayIndex;
  final int endDayIndex;
  final String patternKey;

  const _DayGroup({
    required this.startDayIndex,
    required this.endDayIndex,
    required this.patternKey,
  });
}
