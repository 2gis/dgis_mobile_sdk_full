import 'package:flutter/widgets.dart';

/// Height of a settings row, per the design.
const navigationSettingsRowHeight = 46.0;

/// Color palette for the navigation settings UI.
///
/// Use [defaultLight] or [defaultDark] for the standard palettes.
/// Override individual tokens via [copyWith].
@immutable
class NavigationSettingsColors {
  /// Section header text, e.g. "Маршрут".
  final Color sectionHeader;

  /// Primary label of a settings row.
  final Color settingLabel;

  /// Secondary description shown under a label.
  final Color settingDescription;

  /// Current value readout, e.g. "20 км/ч".
  final Color settingValue;

  final Color pickerValue;

  /// Accent color: active switch track, selected checkmark.
  final Color primary;

  /// Separators between rows and the inactive switch track.
  final Color divider;

  /// Unselected background of a segmented control.
  final Color segmentedTrack;

  /// Background of the selected segment of a segmented control.
  final Color segmentedSelectedBackground;

  /// Switch knob.
  final Color switchThumb;

  /// Chevron of a navigation row.
  final Color chevron;

  /// Labels and controls in the disabled state.
  final Color disabled;

  /// Background of pickers and grouped-list screens.
  final Color pickerBackground;

  /// Background of a settings section.
  final Color sectionBackground;

  /// Neutral action icons, e.g. play.
  final Color actionIcon;

  /// Play icons disabled while another voice sample is playing.
  final Color inactiveActionIcon;

  /// Voice controls.
  final Color voiceAction;

  const NavigationSettingsColors({
    required this.sectionHeader,
    required this.settingLabel,
    required this.settingDescription,
    required this.settingValue,
    required this.pickerValue,
    required this.primary,
    required this.divider,
    required this.segmentedTrack,
    required this.segmentedSelectedBackground,
    required this.switchThumb,
    required this.chevron,
    required this.disabled,
    required this.pickerBackground,
    required this.sectionBackground,
    required this.actionIcon,
    required this.inactiveActionIcon,
    required this.voiceAction,
  });

  static const defaultLight = NavigationSettingsColors(
    sectionHeader: Color(0xFF6C6C70),
    settingLabel: Color(0xFF141414),
    settingDescription: Color(0xFF898989),
    settingValue: Color(0xFF6C6C70),
    pickerValue: Color(0xFF6C6C70),
    primary: Color(0xFF1DB93C),
    divider: Color(0xFFE5E5EA),
    segmentedTrack: Color(0xFFF1F1F1),
    segmentedSelectedBackground: Color(0xFFFFFFFF),
    switchThumb: Color(0xFFFFFFFF),
    chevron: Color(0xFFC7C7CC),
    disabled: Color(0xFFC7C7CC),
    pickerBackground: Color(0xFFF2F2F7),
    sectionBackground: Color(0xFFFFFFFF),
    actionIcon: Color(0xFF6C6C70),
    inactiveActionIcon: Color(0xFFB8B8B8),
    voiceAction: Color(0xFF1BA136),
  );

  static const defaultDark = NavigationSettingsColors(
    sectionHeader: Color(0xFF8E8E93),
    settingLabel: Color(0xFFFFFFFF),
    settingDescription: Color(0xFF8E8E93),
    settingValue: Color(0xFF8E8E93),
    pickerValue: Color(0xFFC7C7CC),
    primary: Color(0xFF30D158),
    divider: Color(0xFF48484A),
    segmentedTrack: Color(0xFF2F2F2F),
    segmentedSelectedBackground: Color(0xFF4E4E4E),
    switchThumb: Color(0xFFFFFFFF),
    chevron: Color(0xFF8E8E93),
    disabled: Color(0xFF7C7C80),
    pickerBackground: Color(0xFF141414),
    sectionBackground: Color(0xFF1A1A1A),
    actionIcon: Color(0xFF8E8E93),
    inactiveActionIcon: Color(0xFF5A5A5A),
    voiceAction: Color(0xFF26C947),
  );

  NavigationSettingsColors copyWith({
    Color? sectionHeader,
    Color? settingLabel,
    Color? settingDescription,
    Color? settingValue,
    Color? pickerValue,
    Color? primary,
    Color? divider,
    Color? segmentedTrack,
    Color? segmentedSelectedBackground,
    Color? switchThumb,
    Color? chevron,
    Color? disabled,
    Color? pickerBackground,
    Color? sectionBackground,
    Color? actionIcon,
    Color? inactiveActionIcon,
    Color? voiceAction,
  }) =>
      NavigationSettingsColors(
        sectionHeader: sectionHeader ?? this.sectionHeader,
        settingLabel: settingLabel ?? this.settingLabel,
        settingDescription: settingDescription ?? this.settingDescription,
        settingValue: settingValue ?? this.settingValue,
        pickerValue: pickerValue ?? this.pickerValue,
        primary: primary ?? this.primary,
        divider: divider ?? this.divider,
        segmentedTrack: segmentedTrack ?? this.segmentedTrack,
        segmentedSelectedBackground:
            segmentedSelectedBackground ?? this.segmentedSelectedBackground,
        switchThumb: switchThumb ?? this.switchThumb,
        chevron: chevron ?? this.chevron,
        disabled: disabled ?? this.disabled,
        pickerBackground: pickerBackground ?? this.pickerBackground,
        sectionBackground: sectionBackground ?? this.sectionBackground,
        actionIcon: actionIcon ?? this.actionIcon,
        inactiveActionIcon: inactiveActionIcon ?? this.inactiveActionIcon,
        voiceAction: voiceAction ?? this.voiceAction,
      );
}

/// Default of [NavigationSettingsTypography.screenDescription].
const _screenDescription = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w400,
  height: 22 / 17,
);

/// Default of [NavigationSettingsTypography.screenTitle].
const _screenTitle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 20 / 16,
  letterSpacing: -0.24,
);

/// Text styles for the navigation settings UI.
///
/// Styles carry size and weight only — color comes from
/// [NavigationSettingsColors] so that a single style can render in both the
/// enabled and disabled state. Override individual tokens via [copyWith].
@immutable
class NavigationSettingsTypography {
  /// Section header, e.g. "Маршрут".
  final TextStyle sectionHeader;

  /// Primary label of a settings row.
  final TextStyle settingLabel;

  /// Secondary description shown under a label.
  final TextStyle settingDescription;

  /// Centred paragraph that introduces a settings screen.
  final TextStyle screenDescription;

  /// Title of a settings screen in the navigation bar.
  final TextStyle screenTitle;

  /// Current value readout, e.g. "20 км/ч".
  final TextStyle settingValue;

  /// Text of an action button.
  final TextStyle actionLabel;

  /// Label of an option inside a radio group.
  final TextStyle radioOptionLabel;

  /// Description of an option inside a radio group.
  final TextStyle radioOptionDescription;

  /// Label of a segment inside a segmented control.
  final TextStyle segmentedLabel;

  const NavigationSettingsTypography({
    required this.sectionHeader,
    required this.settingLabel,
    required this.settingDescription,
    required this.settingValue,
    required this.actionLabel,
    required this.radioOptionLabel,
    required this.segmentedLabel,
    required this.radioOptionDescription,
    this.screenDescription = _screenDescription,
    this.screenTitle = _screenTitle,
  });

  static const defaults = NavigationSettingsTypography(
    sectionHeader: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      letterSpacing: 0,
    ),
    settingLabel: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 20 / 16,
      letterSpacing: -0.24,
    ),
    settingDescription: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 18 / 14,
      letterSpacing: -0.28,
    ),
    settingValue: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    actionLabel: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    radioOptionLabel: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    segmentedLabel: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    radioOptionDescription:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  );

  NavigationSettingsTypography copyWith({
    TextStyle? sectionHeader,
    TextStyle? settingLabel,
    TextStyle? settingDescription,
    TextStyle? settingValue,
    TextStyle? actionLabel,
    TextStyle? radioOptionLabel,
    TextStyle? segmentedLabel,
    TextStyle? screenDescription,
    TextStyle? screenTitle,
    TextStyle? radioOptionDescription,
  }) =>
      NavigationSettingsTypography(
        sectionHeader: sectionHeader ?? this.sectionHeader,
        settingLabel: settingLabel ?? this.settingLabel,
        settingDescription: settingDescription ?? this.settingDescription,
        screenDescription: screenDescription ?? this.screenDescription,
        screenTitle: screenTitle ?? this.screenTitle,
        settingValue: settingValue ?? this.settingValue,
        actionLabel: actionLabel ?? this.actionLabel,
        segmentedLabel: segmentedLabel ?? this.segmentedLabel,
        radioOptionLabel: radioOptionLabel ?? this.radioOptionLabel,
        radioOptionDescription:
            radioOptionDescription ?? this.radioOptionDescription,
      );
}

/// Theme bundle for the navigation settings UI.
///
/// Passed explicitly to every settings control — the controls read no
/// ambient theme, so they render identically in an app, a test and a widget
/// preview.
@immutable
class NavigationSettingsTheme {
  final NavigationSettingsColors colors;
  final NavigationSettingsTypography typography;

  const NavigationSettingsTheme({
    required this.colors,
    required this.typography,
  });

  static const defaultLight = NavigationSettingsTheme(
    colors: NavigationSettingsColors.defaultLight,
    typography: NavigationSettingsTypography.defaults,
  );

  static const defaultDark = NavigationSettingsTheme(
    colors: NavigationSettingsColors.defaultDark,
    typography: NavigationSettingsTypography.defaults,
  );

  NavigationSettingsTheme copyWith({
    NavigationSettingsColors? colors,
    NavigationSettingsTypography? typography,
  }) =>
      NavigationSettingsTheme(
        colors: colors ?? this.colors,
        typography: typography ?? this.typography,
      );
}
