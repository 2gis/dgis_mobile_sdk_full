import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/dgis.dart';
import '../../../util/plugin_name.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_divider.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'section_visibility_config.dart';
import 'settings_checkmark.dart';
import 'settings_key.dart';
import 'settings_layout_helpers.dart';
import 'settings_link.dart';
import 'settings_master_toggle.dart';
import 'settings_section_header.dart';
import 'settings_segmented_control.dart';
import 'settings_slider.dart';
import 'settings_toggle.dart';
import 'sound_mode.dart';

/// Prompt volume presets offered by the volume control, lowest first.
const _volumeMin = 15;
const _volumeLow = 45;
const _volumeStandard = 100;

const _volumePresets = <int>[_volumeMin, _volumeLow, _volumeStandard];

/// Speed warning threshold range, in km/h above the speed limit.
const _minThresholdKph = -15;
const _maxThresholdKph = 35;

/// Speed cameras share a single row: instant and average measurements.
const _speedCameraKeys = <BoolSettingsKey>[
  NavigationSettingKeys.soundMaxSpeedCameras,
  NavigationSettingKeys.soundAverageSpeedCameras,
];

/// Every camera category behind the cameras master switch.
const _cameraKeys = <BoolSettingsKey>[
  ..._speedCameraKeys,
  NavigationSettingKeys.soundNoStoppingControlCameras,
  NavigationSettingKeys.soundCrossroadCameras,
  NavigationSettingKeys.soundLaneCameras,
  NavigationSettingKeys.soundRoadMarkingCameras,
];

/// Categories [SoundMode.important] keeps announcing besides the cameras.
const _importantEventKeys = <BoolSettingsKey>[
  NavigationSettingKeys.soundAccidents,
  NavigationSettingKeys.soundRoadWorks,
  NavigationSettingKeys.soundObstacles,
];

/// Categories [SoundMode.important] silences.
const _optionalKeys = <BoolSettingsKey>[
  NavigationSettingKeys.soundInstructions,
  NavigationSettingKeys.soundRouteRebuild,
  NavigationSettingKeys.soundBetterRoute,
  NavigationSettingKeys.soundIntermediatePoints,
  NavigationSettingKeys.soundRoadSubtypes,
  NavigationSettingKeys.soundLostLocation,
  NavigationSettingKeys.soundRouteEnd,
  NavigationSettingKeys.soundTolls,
];

/// Every category [SoundMode.all] switches on.
const _allCategoryKeys = <BoolSettingsKey>[
  ..._cameraKeys,
  ..._importantEventKeys,
  ..._optionalKeys,
];

/// Every road event category behind the road events master switch.
const _roadEventKeys = <BoolSettingsKey>[
  NavigationSettingKeys.soundTolls,
  NavigationSettingKeys.soundRoadWorks,
  NavigationSettingKeys.soundObstacles,
  NavigationSettingKeys.soundAccidents,
  NavigationSettingKeys.soundInstructions,
  NavigationSettingKeys.soundRouteRebuild,
  NavigationSettingKeys.soundBetterRoute,
  NavigationSettingKeys.soundIntermediatePoints,
  NavigationSettingKeys.soundRoadSubtypes,
  NavigationSettingKeys.soundLostLocation,
  NavigationSettingKeys.soundRouteEnd,
];

/// Sounds and alerts settings content, usable inside a custom settings flow.
///
/// The layout reads and writes settings through [repository] and never touches
/// a navigation manager directly. `NavigationSettingsApplier` mirrors the
/// runtime values onto the navigation manager.
///
/// Four sections are rendered: sound guidance, event warnings, cameras and
/// road events. The last three are hidden while [SoundMode.muted] is selected,
/// and the general section keeps only the mode control in that state.
///
/// [SectionVisibilityConfig.sectionSounds] hides the whole screen;
/// the per-section identifiers hide individual sections.
class SoundSettingsLayout extends StatelessWidget {
  /// Repository used to observe and persist all sound settings.
  final NavigationSettingsRepository repository;

  /// Controls which settings sections are visible.
  final SectionVisibilityConfig visibilityConfig;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  /// Called when the user taps the Voices row.
  final VoidCallback onNavigateToVoices;

  /// Creates a sounds and alerts layout with a Voices link action.
  const SoundSettingsLayout({
    required this.repository,
    required this.onNavigateToVoices,
    this.visibilityConfig = const SectionVisibilityConfig(),
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // The screen itself can be hidden as a whole; nothing is built then.
    if (!visibilityConfig.isVisible(SectionVisibilityConfig.sectionSounds)) {
      return const SizedBox.shrink();
    }

    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final resolvedTheme = resolveNavigationSettingsTheme(context, theme);

    return SingleChildScrollView(
      // The whole screen follows the mode: muting hides every later section.
      child: observeNavigationSetting<SoundMode>(
        repository: repository,
        key: NavigationSettingKeys.soundMode,
        builder: (context, mode, child) {
          final muted = mode == SoundMode.muted;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (visibilityConfig.isVisible(
                SectionVisibilityConfig.sectionSoundGeneral,
              ))
                _generalSection(localizations, resolvedTheme, mode),
              if (!muted &&
                  visibilityConfig.isVisible(
                    SectionVisibilityConfig.sectionEventWarnings,
                  ))
                _eventWarningsSection(localizations, resolvedTheme),
              if (!muted &&
                  visibilityConfig.isVisible(
                    SectionVisibilityConfig.sectionCameras,
                  ))
                _camerasSection(localizations, resolvedTheme),
              if (!muted &&
                  visibilityConfig.isVisible(
                    SectionVisibilityConfig.sectionRoadEvents,
                  ))
                _roadEventsSection(localizations, resolvedTheme),
            ],
          );
        },
      ),
    );
  }

  Widget _generalSection(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
    SoundMode mode,
  ) {
    final children = <Widget>[
      NavigationSettingsSegmentedControl<SoundMode>(
        label: localizations.dgis_settings_sound_mode,
        subtitle: _modeSubtitle(localizations, mode),
        selected: mode,
        options: [
          NavigationSettingsSegmentedOption(
            value: SoundMode.muted,
            label: localizations.dgis_settings_sound_mode_off,
          ),
          NavigationSettingsSegmentedOption(
            value: SoundMode.important,
            label: localizations.dgis_settings_sound_mode_important,
          ),
          NavigationSettingsSegmentedOption(
            value: SoundMode.all,
            label: localizations.dgis_settings_sound_mode_all,
          ),
        ],
        onChanged: _selectMode,
        theme: theme,
      ),
    ];

    if (mode != SoundMode.muted) {
      if (visibilityConfig.isVisible(SectionVisibilityConfig.sectionVoices)) {
        children.add(
          _VoiceLink(
            repository: repository,
            label: localizations.dgis_settings_voice,
            onTap: onNavigateToVoices,
            theme: theme,
          ),
        );
      }

      children
        ..add(
          observeNavigationSetting<bool>(
            repository: repository,
            key: NavigationSettingKeys.soundDuckOtherAudio,
            builder: (context, value, child) => NavigationSettingsToggle(
              label: localizations.dgis_settings_sound_duck_other_audio,
              value: value,
              onChanged: (value) => setNavigationSetting(
                repository,
                NavigationSettingKeys.soundDuckOtherAudio,
                value,
              ),
              theme: theme,
            ),
          ),
        )
        ..add(
          observeNavigationSetting<int>(
            repository: repository,
            key: NavigationSettingKeys.soundVolume,
            builder: (context, volume, child) =>
                NavigationSettingsSegmentedControl<int>(
              label: localizations.dgis_settings_sound_volume,
              selected: _nearestVolume(volume),
              options: [
                for (final preset in _volumePresets)
                  NavigationSettingsSegmentedOption(
                    value: preset,
                    label: _volumeLabel(localizations, preset),
                  ),
              ],
              onChanged: (value) => setNavigationSetting(
                repository,
                NavigationSettingKeys.soundVolume,
                value,
              ),
              theme: theme,
            ),
          ),
        );
    }

    return _SoundSection(
      label: localizations.dgis_settings_sound_section_general,
      theme: theme,
      children: children,
    );
  }

  Widget _eventWarningsSection(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      observeNavigationSetting<bool>(
        repository: repository,
        key: NavigationSettingKeys.soundSpeedExceedEnabled,
        builder: (context, enabled, child) => _SoundSection(
          label: localizations.dgis_settings_sound_section_event_warnings,
          theme: theme,
          children: [
            NavigationSettingsToggle(
              label: localizations.dgis_settings_sound_speed_exceed,
              description:
                  localizations.dgis_settings_sound_speed_exceed_description,
              value: enabled,
              onChanged: _setSpeedExceed,
              theme: theme,
            ),
            // The threshold only matters while speed warnings are on.
            if (enabled) _speedExceedThreshold(localizations, theme),
          ],
        ),
      );

  Widget _speedExceedThreshold(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      observeNavigationSetting<double>(
        repository: repository,
        key: NavigationSettingKeys.soundSpeedExceedThreshold,
        builder: (context, threshold, child) {
          final kph = _toKph(threshold);
          final unit = localizations.dgis_km_per_h;
          final label = kph < 0
              ? localizations
                  .dgis_settings_sound_speed_exceed_threshold_below_format(-kph)
              : localizations
                  .dgis_settings_sound_speed_exceed_threshold_format(kph);

          return NavigationSettingsSlider(
            label: label,
            value: kph,
            onChanged: (value) => setNavigationSetting(
              repository,
              NavigationSettingKeys.soundSpeedExceedThreshold,
              value / 3.6,
            ),
            min: _minThresholdKph,
            max: _maxThresholdKph,
            unit: unit,
            theme: theme,
            // The label already carries the value.
            showValue: false,
            minLabel: '$_minThresholdKph $unit',
            maxLabel: '+$_maxThresholdKph $unit',
          );
        },
      );

  Widget _camerasSection(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      _ObservedBools(
        repository: repository,
        keys: _cameraKeys,
        builder: (context, values) => _SoundSection(
          label: localizations.dgis_settings_sound_section_cameras,
          theme: theme,
          children: [
            NavigationSettingsMasterToggle(
              label: localizations.dgis_settings_sound_cameras,
              description:
                  localizations.dgis_settings_sound_cameras_description,
              value: _anyTrue(values),
              onChanged: (value) => _writeAll(_cameraKeys, value),
              theme: theme,
              // The gated rows are hidden, not dimmed: with the master off
              // the whole group leaves the tree, dividers included.
              builder: (context, enabled) {
                if (!enabled) {
                  return const SizedBox.shrink();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NavigationSettingsDivider(theme: theme),
                    NavigationSettingsCheckmark(
                      label: localizations.dgis_settings_sound_camera_speed,
                      value: _speedCamerasOn(values),
                      onChanged: (value) => _writeAll(_speedCameraKeys, value),
                      theme: theme,
                      leading: _soundIcon('dgis_sound_camera_speed'),
                    ),
                    // The always-announce row only exists while speed cameras
                    // themselves are announced.
                    if (_speedCamerasOn(values)) ...[
                      NavigationSettingsDivider(theme: theme),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: observeNavigationSetting<bool>(
                          repository: repository,
                          key: NavigationSettingKeys.soundSpeedCameraAlways,
                          builder: (context, value, child) =>
                              NavigationSettingsToggle(
                            label:
                                localizations.dgis_settings_sound_camera_always,
                            description: localizations
                                .dgis_settings_sound_camera_always_description,
                            value: value,
                            onChanged: (value) => setNavigationSetting(
                              repository,
                              NavigationSettingKeys.soundSpeedCameraAlways,
                              value,
                            ),
                            theme: theme,
                          ),
                        ),
                      ),
                    ],
                    for (final (key, icon, label) in [
                      (
                        NavigationSettingKeys.soundNoStoppingControlCameras,
                        'dgis_sound_camera_stop',
                        localizations.dgis_settings_sound_camera_stop,
                      ),
                      (
                        NavigationSettingKeys.soundCrossroadCameras,
                        'dgis_sound_camera_crossroad',
                        localizations.dgis_settings_sound_camera_crossroad,
                      ),
                      (
                        NavigationSettingKeys.soundLaneCameras,
                        'dgis_sound_camera_lane',
                        localizations.dgis_settings_sound_camera_lane,
                      ),
                      (
                        NavigationSettingKeys.soundRoadMarkingCameras,
                        'dgis_sound_camera_marking',
                        localizations.dgis_settings_sound_camera_marking,
                      ),
                    ]) ...[
                      NavigationSettingsDivider(theme: theme),
                      _categoryCheckmark(
                        label: label,
                        icon: icon,
                        key: key,
                        values: values,
                        theme: theme,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      );

  Widget _roadEventsSection(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      _ObservedBools(
        repository: repository,
        keys: _roadEventKeys,
        builder: (context, values) => _SoundSection(
          label: localizations.dgis_settings_sound_section_road_events,
          theme: theme,
          children: [
            NavigationSettingsMasterToggle(
              label: localizations.dgis_settings_sound_road_events,
              description:
                  localizations.dgis_settings_sound_road_events_description,
              value: _allTrue(values),
              onChanged: (value) => _writeAll(_roadEventKeys, value),
              theme: theme,
              // The rows are always rendered and always interactive; the
              // master only mirrors them.
              builder: (context, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (key, icon, label) in [
                    (
                      NavigationSettingKeys.soundTolls,
                      'dgis_sound_event_toll',
                      localizations.dgis_settings_sound_event_toll,
                    ),
                    (
                      NavigationSettingKeys.soundRoadWorks,
                      'dgis_sound_event_road_works',
                      localizations.dgis_settings_sound_event_road_works,
                    ),
                    (
                      NavigationSettingKeys.soundObstacles,
                      'dgis_sound_event_obstacle',
                      localizations.dgis_settings_sound_event_obstacle,
                    ),
                    (
                      NavigationSettingKeys.soundAccidents,
                      'dgis_sound_event_accident',
                      localizations.dgis_settings_sound_event_accident,
                    ),
                    (
                      NavigationSettingKeys.soundInstructions,
                      'dgis_sound_event_other',
                      localizations.dgis_settings_sound_event_instructions,
                    ),
                    (
                      NavigationSettingKeys.soundRouteRebuild,
                      'dgis_sound_event_other',
                      localizations.dgis_settings_sound_event_route_rebuild,
                    ),
                    (
                      NavigationSettingKeys.soundBetterRoute,
                      'dgis_sound_event_other',
                      localizations.dgis_settings_sound_event_better_route,
                    ),
                    (
                      NavigationSettingKeys.soundIntermediatePoints,
                      'dgis_sound_event_other',
                      localizations
                          .dgis_settings_sound_event_intermediate_points,
                    ),
                    (
                      NavigationSettingKeys.soundRoadSubtypes,
                      'dgis_sound_event_other',
                      localizations.dgis_settings_sound_event_road_subtypes,
                    ),
                    (
                      NavigationSettingKeys.soundLostLocation,
                      'dgis_sound_event_no_signal',
                      localizations.dgis_settings_sound_event_no_signal,
                    ),
                    (
                      NavigationSettingKeys.soundRouteEnd,
                      'dgis_sound_event_finish',
                      localizations.dgis_settings_sound_event_finish,
                    ),
                  ]) ...[
                    NavigationSettingsDivider(theme: theme),
                    _categoryCheckmark(
                      label: label,
                      icon: icon,
                      key: key,
                      values: values,
                      theme: theme,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  /// Checkmark row for one category key, always interactive.
  Widget _categoryCheckmark({
    required String label,
    required String icon,
    required BoolSettingsKey key,
    required Map<BoolSettingsKey, bool> values,
    required NavigationSettingsTheme theme,
  }) =>
      NavigationSettingsCheckmark(
        label: label,
        value: values[key] ?? false,
        onChanged: (value) => setNavigationSetting(repository, key, value),
        theme: theme,
        leading: _soundIcon(icon),
      );

  /// Applies [mode] and the category set that belongs to it.
  ///
  /// Muting is expressed by the mode alone, so it never rewrites categories.
  void _selectMode(SoundMode mode) {
    setNavigationSetting(repository, NavigationSettingKeys.soundMode, mode);

    switch (mode) {
      case SoundMode.muted:
        break;
      case SoundMode.important:
        _writeAll(_optionalKeys, false);
        _writeAll(_cameraKeys, true);
        _writeAll(_importantEventKeys, true);
        _setSpeedExceed(true);
      case SoundMode.all:
        _writeAll(_allCategoryKeys, true);
        _setSpeedExceed(true);
    }
  }

  /// Speed warnings and the speed-limit category share one switch.
  void _setSpeedExceed(bool value) {
    setNavigationSetting(
      repository,
      NavigationSettingKeys.soundSpeedExceedEnabled,
      value,
    );
    setNavigationSetting(
      repository,
      NavigationSettingKeys.soundExceedSpeedLimits,
      value,
    );
  }

  void _writeAll(List<BoolSettingsKey> keys, bool value) {
    for (final key in keys) {
      setNavigationSetting(repository, key, value);
    }
  }
}

/// Section header plus the rows below it.
class _SoundSection extends StatelessWidget {
  final String label;
  final NavigationSettingsTheme theme;
  final List<Widget> children;

  const _SoundSection({
    required this.label,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationSettingsSectionHeader(label: label, theme: theme),
          NavigationSettingsSection(theme: theme, children: children),
        ],
      );
}

/// Voice row showing the name of the voice prompts are spoken with.
///
/// Without a stored choice the navigator speaks with the default voice, so
/// its name is shown instead. The name is hidden while the voice is unknown.
class _VoiceLink extends StatefulWidget {
  final NavigationSettingsRepository repository;
  final String label;
  final VoidCallback onTap;
  final NavigationSettingsTheme theme;

  const _VoiceLink({
    required this.repository,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_VoiceLink> createState() => _VoiceLinkState();
}

class _VoiceLinkState extends State<_VoiceLink> {
  late final sdk.VoiceManager _manager;
  late final StreamSubscription<List<sdk.Voice>> _rosterSubscription;
  late List<sdk.Voice> _roster;

  @override
  void initState() {
    super.initState();
    _manager = sdk.VoiceManager.instance(DGis().context);
    _roster = _manager.voicesChannel.value;
    _rosterSubscription = _manager.voicesChannel.listen((voices) {
      if (!mounted) return;
      setState(() => _roster = voices);
    });
  }

  @override
  void dispose() {
    unawaited(_rosterSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
        valueListenable:
            widget.repository.observe(NavigationSettingKeys.voiceSelected),
        builder: (context, selectedId, _) {
          final id = selectedId ?? _manager.defaultVoice?.id;
          final voice = _roster.firstWhereOrNull((voice) => voice.id == id);
          return NavigationSettingsLink(
            label: widget.label,
            subtitle: voice?.info.name,
            onTap: widget.onTap,
            theme: widget.theme,
          );
        },
      );
}

/// Observes every key of a group and rebuilds the rows with all values at once.
///
/// Master rows derive their state from the whole category set, so the group is
/// watched through one merged listenable: the repository memoises a notifier
/// per key, and a single builder reads the current values back out of it.
class _ObservedBools extends StatefulWidget {
  final NavigationSettingsRepository repository;
  final List<BoolSettingsKey> keys;
  final Widget Function(BuildContext context, Map<BoolSettingsKey, bool> values)
      builder;

  const _ObservedBools({
    required this.repository,
    required this.keys,
    required this.builder,
  });

  @override
  State<_ObservedBools> createState() => _ObservedBoolsState();
}

class _ObservedBoolsState extends State<_ObservedBools> {
  late Listenable _group = _mergeKeys();

  @override
  void didUpdateWidget(_ObservedBools oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        !listEquals(oldWidget.keys, widget.keys)) {
      _group = _mergeKeys();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _group,
        builder: (context, child) => widget.builder(context, {
          for (final key in widget.keys) key: widget.repository.get(key),
        }),
      );

  Listenable _mergeKeys() => Listenable.merge([
        for (final key in widget.keys) widget.repository.observe(key),
      ]);
}

/// Whether at least one value in [values] is true.
bool _anyTrue(Map<BoolSettingsKey, bool> values) =>
    values.values.any((value) => value);

/// Whether every value in [values] is true.
bool _allTrue(Map<BoolSettingsKey, bool> values) =>
    values.values.every((value) => value);

bool _speedCamerasOn(Map<BoolSettingsKey, bool> values) =>
    _speedCameraKeys.any((key) => values[key] ?? false);

/// Stored m/s value as whole km/h.
int _toKph(double metersPerSecond) => (metersPerSecond * 3.6).round();

/// Preset nearest to [volume]; ties keep the lower preset.
int _nearestVolume(int volume) {
  var nearest = _volumePresets.first;
  for (final preset in _volumePresets.skip(1)) {
    if ((preset - volume).abs() < (nearest - volume).abs()) {
      nearest = preset;
    }
  }
  return nearest;
}

String _modeSubtitle(DgisLocalizations localizations, SoundMode mode) =>
    switch (mode) {
      SoundMode.muted => localizations.dgis_settings_sound_mode_subtitle_off,
      SoundMode.important =>
        localizations.dgis_settings_sound_mode_subtitle_important,
      SoundMode.all => localizations.dgis_settings_sound_mode_subtitle_all,
    };

String _volumeLabel(DgisLocalizations localizations, int preset) =>
    switch (preset) {
      _volumeMin => localizations.dgis_settings_sound_volume_min,
      _volumeLow => localizations.dgis_settings_sound_volume_low,
      _ => localizations.dgis_settings_sound_volume_standard,
    };

/// Category icon, shown as-is without the row colour.
Widget _soundIcon(String name) => SvgPicture.asset(
      'packages/$pluginName/assets/icons/navigation/settings/$name.svg',
      width: 24,
      height: 24,
      fit: BoxFit.scaleDown,
    );
