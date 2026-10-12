import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show DefaultMaterialLocalizations, MaterialLocalizations, TimeOfDay;

import 'navigation_settings_text_scope.dart';
import 'navigation_settings_theme.dart';

const _wheelHeight = 220.0;

DateTime _toWholeMinute(DateTime moment) =>
    moment.copyWith(second: 0, millisecond: 0, microsecond: 0);

/// Row that opens a wheel picker for a date and time.
///
/// The selected value is formatted with the host's [MaterialLocalizations].
/// If the host has no Material localization delegate, the control falls back
/// to English through [DefaultMaterialLocalizations].
/// The row renders the short date followed by time on a 24-hour clock,
/// matching the wheel regardless of the locale's AM/PM preference.
///
/// ```dart
/// NavigationSettingsDateTimePicker(
///   label: 'Time of departure',
///   value: departure,
///   onChanged: (value) => setState(() => departure = value),
///   theme: theme,
///   nullLabel: 'Now',
///   confirmLabel: 'Confirm',
///   resetLabel: 'Reset',
/// )
/// ```
class NavigationSettingsDateTimePicker extends StatelessWidget {
  /// Descriptive text shown on the left of the row.
  final String label;

  /// Currently chosen moment, or null when nothing is set.
  final DateTime? value;

  /// Called with the confirmed moment, or null when the user resets.
  final ValueChanged<DateTime?> onChanged;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Shown in place of the value while [value] is null.
  final String nullLabel;

  /// Label of the button that commits the wheel selection.
  final String confirmLabel;

  /// Label of the button that returns the value to null.
  final String resetLabel;

  /// When false the row is visually dimmed and the wheel cannot be opened.
  final bool enabled;

  /// Whether the wheel is pushed onto the root navigator.
  ///
  /// - **false** keeps the sheet inside the navigator this row was built in.
  ///   Safer for an embedded control, since a settings screen may live in a
  ///   nested navigator — a tab, or the host app's own flow — and a root-level
  ///   route would escape it. Required for the widget previews, whose sheet
  ///   would otherwise be pushed outside the preview.
  /// - **true** is the usual behaviour for a modal: the sheet covers the whole
  ///   app, including any surrounding tab or nav bar. Set this when the
  ///   settings screen is presented full-screen and the sheet should cover it.
  final bool useRootNavigator;

  const NavigationSettingsDateTimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.nullLabel,
    required this.confirmLabel,
    required this.resetLabel,
    this.enabled = true,
    this.useRootNavigator = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final materialLocalizations = Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) ??
        const DefaultMaterialLocalizations();
    final current = value;
    final valueText = current == null
        ? nullLabel
        : _formatDateTime(materialLocalizations, current);
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          onTap: enabled ? () => _openWheel(context) : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: theme.typography.settingLabel.copyWith(
                      color: enabled ? colors.settingLabel : colors.disabled,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      valueText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.typography.settingValue.copyWith(
                        color: enabled ? colors.pickerValue : colors.disabled,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(
    MaterialLocalizations localizations,
    DateTime value,
  ) =>
      '${localizations.formatShortDate(value)}, '
      '${localizations.formatTimeOfDay(
        TimeOfDay.fromDateTime(value),
        alwaysUse24HourFormat: true,
      )}';

  Future<void> _openWheel(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (context) => _DateTimeWheelSheet(
        title: label,
        initial: _toWholeMinute(value ?? DateTime.now()),
        theme: theme,
        confirmLabel: confirmLabel,
        resetLabel: resetLabel,
        onConfirm: onChanged,
        onReset: () => onChanged(null),
      ),
    );
  }
}

class _DateTimeWheelSheet extends StatefulWidget {
  final String title;
  final DateTime initial;
  final NavigationSettingsTheme theme;
  final String confirmLabel;
  final String resetLabel;
  final ValueChanged<DateTime> onConfirm;
  final VoidCallback onReset;

  const _DateTimeWheelSheet({
    required this.title,
    required this.initial,
    required this.theme,
    required this.confirmLabel,
    required this.resetLabel,
    required this.onConfirm,
    required this.onReset,
  });

  @override
  State<_DateTimeWheelSheet> createState() => _DateTimeWheelSheetState();
}

class _DateTimeWheelSheetState extends State<_DateTimeWheelSheet> {
  late DateTime _pending = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colors;
    return navigationSettingsTextScope(
      theme: theme,
      child: ColoredBox(
        color: colors.pickerBackground,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _SheetButton(
                      label: widget.resetLabel,
                      theme: theme,
                      color: colors.primary,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onReset();
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: theme.typography.settingLabel.copyWith(
                          color: colors.settingLabel,
                        ),
                      ),
                    ),
                    _SheetButton(
                      label: widget.confirmLabel,
                      theme: theme,
                      color: colors.primary,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onConfirm(_pending);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: _wheelHeight,
                child: CupertinoDatePicker(
                  initialDateTime: widget.initial,
                  use24hFormat: true,
                  onDateTimeChanged: (value) => _pending = value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color color;
  final NavigationSettingsTheme theme;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: theme.typography.actionLabel.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
