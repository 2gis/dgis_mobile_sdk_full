import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/dgis.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'settings_key.dart';
import 'sound_mode.dart';

/// Applies persisted navigation settings to a navigation manager.
///
/// The caller owns [repository]. Call [startObserving] once to apply the
/// current values and keep runtime settings synchronized, then call [dispose]
/// before discarding the applier.
class NavigationSettingsApplier {
  final NavigationSettingsRepository repository;
  final sdk.NavigationManager navigationManager;

  final List<VoidCallback> _removeListeners = [];
  bool _isObserving = false;
  bool _isDisposed = false;

  NavigationSettingsApplier({
    required this.repository,
    required this.navigationManager,
  });

  /// Applies every persisted runtime setting immediately.
  void apply() {
    _checkNotDisposed();
    _applyRouteSettings();
    _applySoundSettings();
    _applyMapEventSettings();
    _applyCalloutVisualizationMode();
    _applyVoiceSettings();
  }

  /// Applies current values and observes subsequent repository changes.
  ///
  /// Repeated calls are ignored.
  void startObserving() {
    _checkNotDisposed();
    if (_isObserving) return;
    _isObserving = true;

    _watch(NavigationSettingKeys.rebuildOnDeviation, _applyRouteSettings);
    _watch(NavigationSettingKeys.betterRouteEnabled, _applyRouteSettings);
    _watch(NavigationSettingKeys.alternativeRoutesEnabled, _applyRouteSettings);
    _watch(
      NavigationSettingKeys.calloutVisualizationMode,
      _applyCalloutVisualizationMode,
    );

    _watch(NavigationSettingKeys.soundMode, _applySoundSettings);
    _watch(NavigationSettingKeys.soundVolume, _applySoundSettings);
    _watch(
      NavigationSettingKeys.soundSpeedExceedEnabled,
      _applySoundSettings,
    );
    _watch(
      NavigationSettingKeys.soundSpeedExceedThreshold,
      _applySoundSettings,
    );
    _watch(
      NavigationSettingKeys.soundDuckOtherAudio,
      _applySoundSettings,
    );
    _watch(
      NavigationSettingKeys.soundSpeedCameraAlways,
      _applySoundSettings,
    );
    for (final (key, _) in _soundKeyToCategory) {
      _watch(key, _applySoundSettings);
    }

    _watch(NavigationSettingKeys.mapEventsEnabled, _applyMapEventSettings);
    for (final (key, _) in _displayKeyToFlag) {
      _watch(key, _applyMapEventSettings);
    }
    _watch(
      NavigationSettingKeys.mapEventsPermanentEnabled,
      _applyMapEventSettings,
    );
    for (final (key, _) in _permanentKeyToFlag) {
      _watch(key, _applyMapEventSettings);
    }

    _watch(NavigationSettingKeys.voiceSelected, _applyVoiceSettings);
    apply();
  }

  /// Stops observing repository changes.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    for (final removeListener in _removeListeners) {
      removeListener();
    }
    _removeListeners.clear();
    _isObserving = false;
  }

  void _watch<T>(SettingsKey<T> key, VoidCallback applySetting) {
    final listenable = repository.observe(key);
    void listener() => applySetting();
    listenable.addListener(listener);
    _removeListeners.add(() => listenable.removeListener(listener));
  }

  void _applyRouteSettings() {
    navigationManager.routeRebuilder.enabled =
        repository.get(NavigationSettingKeys.rebuildOnDeviation);
    navigationManager.alternativeRoutesProviderSettings
      ..betterRouteEnabled =
          repository.get(NavigationSettingKeys.betterRouteEnabled)
      ..alternativeRoutesEnabled =
          repository.get(NavigationSettingKeys.alternativeRoutesEnabled);
  }

  void _applyCalloutVisualizationMode() {
    navigationManager.routeSourceSettings.calloutVisualizationMode =
        repository.get(NavigationSettingKeys.calloutVisualizationMode);
  }

  void _applySoundSettings() {
    final audioSettings = sdk.AudioSettings.get(DGis().context);
    if (audioSettings != null) {
      audioSettings
        ..mute =
            repository.get(NavigationSettingKeys.soundMode) == SoundMode.muted
        ..volume = repository.get(NavigationSettingKeys.soundVolume)
        ..audioFocusPolicy =
            repository.get(NavigationSettingKeys.soundDuckOtherAudio)
                ? sdk.AudioFocusPolicy.duck
                : sdk.AudioFocusPolicy.ignore;
    }

    final categories = navigationManager
        .soundNotificationSettings.enabledSoundCategories
        .toMutableEnumSet();
    for (final (key, category) in _soundKeyToCategory) {
      if (repository.get(key)) {
        categories.add(category);
      } else {
        categories.remove(category);
      }
    }
    navigationManager.soundNotificationSettings.enabledSoundCategories =
        categories.toEnumSet();

    navigationManager.exceedSpeedLimitSettings
      ..exceedSpeedNotificationEnabled =
          repository.get(NavigationSettingKeys.soundSpeedExceedEnabled)
      ..allowableSpeedExcess =
          repository.get(NavigationSettingKeys.soundSpeedExceedThreshold);

    navigationManager.soundNotificationSettings.speedCameraNotification =
        repository.get(NavigationSettingKeys.soundSpeedCameraAlways)
            ? sdk.SpeedCameraNotification.always
            : sdk.SpeedCameraNotification.withSpeedLimitExceeded;
  }

  void _applyMapEventSettings() {
    final routeMapSettings = navigationManager.routeMapSettings;
    final displayFlags =
        routeMapSettings.onRouteDisplayFlags.toMutableEnumSet();
    final displayEnabled =
        repository.get(NavigationSettingKeys.mapEventsEnabled);
    for (final (key, flag) in _displayKeyToFlag) {
      if (displayEnabled && repository.get(key)) {
        displayFlags.add(flag);
      } else {
        displayFlags.remove(flag);
      }
    }
    routeMapSettings.onRouteDisplayFlags = displayFlags.toEnumSet();

    final permanentFlags =
        routeMapSettings.onRoutePermanentDisplayFlags.toMutableEnumSet();
    final permanentEnabled =
        repository.get(NavigationSettingKeys.mapEventsPermanentEnabled);
    for (final (key, flag) in _permanentKeyToFlag) {
      if (permanentEnabled && repository.get(key)) {
        permanentFlags.add(flag);
      } else {
        permanentFlags.remove(flag);
      }
    }
    routeMapSettings.onRoutePermanentDisplayFlags = permanentFlags.toEnumSet();
  }

  void _applyVoiceSettings() {
    final voiceManager = sdk.VoiceManager.instance(DGis().context);
    final selectedVoiceId = repository.get(NavigationSettingKeys.voiceSelected);
    final savedVoice = selectedVoiceId == null
        ? null
        : voiceManager.voices
            .firstWhereOrNull((voice) => voice.id == selectedVoiceId);
    final usableVoice =
        savedVoice != null && _isUsable(savedVoice) ? savedVoice : null;
    navigationManager.voiceSelector.voice =
        (usableVoice ?? voiceManager.defaultVoice)?.navigationVoice;
    if (savedVoice != null && !savedVoice.info.installed) {
      unawaited(repository.set(NavigationSettingKeys.voiceSelected, null));
    }
  }

  /// Setting voice throws unless all of these hold.
  static bool _isUsable(sdk.Voice voice) {
    final info = voice.info;
    return info.installed && !info.incomplete && info.compatible;
  }

  void _checkNotDisposed() {
    if (_isDisposed) {
      throw StateError('NavigationSettingsApplier was used after dispose().');
    }
  }
}

final _soundKeyToCategory = <(BoolSettingsKey, sdk.SoundCategory)>[
  (
    NavigationSettingKeys.soundCrossroadCameras,
    sdk.SoundCategory.crossroadCameras
  ),
  (NavigationSettingKeys.soundLaneCameras, sdk.SoundCategory.laneCameras),
  (
    NavigationSettingKeys.soundNoStoppingControlCameras,
    sdk.SoundCategory.noStoppingControlCameras,
  ),
  (
    NavigationSettingKeys.soundRoadMarkingCameras,
    sdk.SoundCategory.roadMarkingCameras,
  ),
  (
    NavigationSettingKeys.soundAverageSpeedCameras,
    sdk.SoundCategory.averageSpeedCameras,
  ),
  (
    NavigationSettingKeys.soundMaxSpeedCameras,
    sdk.SoundCategory.maxSpeedCameras
  ),
  (NavigationSettingKeys.soundAccidents, sdk.SoundCategory.accidents),
  (NavigationSettingKeys.soundRoadWorks, sdk.SoundCategory.roadWorks),
  (NavigationSettingKeys.soundTolls, sdk.SoundCategory.tolls),
  (
    NavigationSettingKeys.soundExceedSpeedLimits,
    sdk.SoundCategory.exceedSpeedLimits,
  ),
  (
    NavigationSettingKeys.soundIntermediatePoints,
    sdk.SoundCategory.intermediatePoints,
  ),
  (NavigationSettingKeys.soundRouteRebuild, sdk.SoundCategory.routeRebuild),
  (NavigationSettingKeys.soundInstructions, sdk.SoundCategory.instructions),
  (NavigationSettingKeys.soundObstacles, sdk.SoundCategory.obstacles),
  (NavigationSettingKeys.soundRoadSubtypes, sdk.SoundCategory.roadSubtypes),
  (NavigationSettingKeys.soundLostLocation, sdk.SoundCategory.lostLocation),
  (NavigationSettingKeys.soundRouteEnd, sdk.SoundCategory.routeEnd),
  (NavigationSettingKeys.soundBetterRoute, sdk.SoundCategory.betterRoute),
];

final _displayKeyToFlag = <(BoolSettingsKey, sdk.RouteMapObjectDisplayFlag)>[
  (
    NavigationSettingKeys.mapEventsCameras,
    sdk.RouteMapObjectDisplayFlag.cameras
  ),
  (
    NavigationSettingKeys.mapEventsAccidents,
    sdk.RouteMapObjectDisplayFlag.accidents,
  ),
  (
    NavigationSettingKeys.mapEventsRoadWorks,
    sdk.RouteMapObjectDisplayFlag.roadWorks,
  ),
  (
    NavigationSettingKeys.mapEventsComments,
    sdk.RouteMapObjectDisplayFlag.comments,
  ),
  (
    NavigationSettingKeys.mapEventsRoadRestrictions,
    sdk.RouteMapObjectDisplayFlag.roadRestrictions,
  ),
  (
    NavigationSettingKeys.mapEventsOtherEvents,
    sdk.RouteMapObjectDisplayFlag.otherEvents,
  ),
  (
    NavigationSettingKeys.mapEventsBubbles,
    sdk.RouteMapObjectDisplayFlag.bubbles
  ),
  (
    NavigationSettingKeys.mapEventsLanesBubbles,
    sdk.RouteMapObjectDisplayFlag.lanesBubbles,
  ),
];

final _permanentKeyToFlag =
    <(BoolSettingsKey, sdk.RouteMapObjectPermanentDisplayFlag)>[
  (
    NavigationSettingKeys.mapEventsPermanentStartPoint,
    sdk.RouteMapObjectPermanentDisplayFlag.startPoint,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentFinishPoint,
    sdk.RouteMapObjectPermanentDisplayFlag.finishPoint,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentIntermediatePoints,
    sdk.RouteMapObjectPermanentDisplayFlag.intermediatePoints,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentCameras,
    sdk.RouteMapObjectPermanentDisplayFlag.cameras,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentAccidents,
    sdk.RouteMapObjectPermanentDisplayFlag.accidents,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentRoadWorks,
    sdk.RouteMapObjectPermanentDisplayFlag.roadWorks,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentComments,
    sdk.RouteMapObjectPermanentDisplayFlag.comments,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentRoadRestrictions,
    sdk.RouteMapObjectPermanentDisplayFlag.roadRestrictions,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentOtherEvents,
    sdk.RouteMapObjectPermanentDisplayFlag.otherEvents,
  ),
  (
    NavigationSettingKeys.mapEventsPermanentTollRoads,
    sdk.RouteMapObjectPermanentDisplayFlag.tollRoads,
  ),
];
