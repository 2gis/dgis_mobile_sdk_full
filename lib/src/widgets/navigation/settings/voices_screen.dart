import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/dgis.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'section_visibility_config.dart';
import 'settings_layout_helpers.dart';
import 'settings_link.dart';
import 'settings_list_items.dart';
import 'settings_radio_group.dart';

/// Voice packages settings content, usable inside a custom settings flow.
///
/// Every row is derived from the state the native package reports through
/// [sdk.Package.infoChannel] and [sdk.Package.progressChannel]; nothing about
/// a package is cached in Dart, so a row can never contradict the package it
/// stands for.
///
/// Packages are identified by [sdk.Package.id] — the stable technical
/// identifier. [sdk.PackageInfo.name] and [sdk.PackageInfo.description] are
/// localized display strings and are only rendered as the row label and the
/// text under it.
///
/// The layout reads and writes the selected voice through [repository].
class VoicesLayout extends StatefulWidget {
  /// Storage of the user's navigation settings; holds the selected voice.
  final NavigationSettingsRepository repository;

  /// Language the voice lists are filtered by, or null to resolve the default
  /// from the navigator's default voice and the current locale.
  final String? selectedLanguage;

  /// Called when the user taps the language row.
  final VoidCallback onNavigateToLanguageSelection;

  /// Color and typography tokens, or null to resolve them from the platform
  /// brightness.
  final NavigationSettingsTheme? theme;

  /// Controls which sections of this screen are displayed.
  final SectionVisibilityConfig visibilityConfig;

  const VoicesLayout({
    required this.repository,
    required this.selectedLanguage,
    required this.onNavigateToLanguageSelection,
    this.theme,
    this.visibilityConfig = const SectionVisibilityConfig(),
    super.key,
  });

  @override
  State<VoicesLayout> createState() => _VoicesLayoutState();
}

class _VoicesLayoutState extends State<VoicesLayout> {
  late final sdk.VoiceManager _manager;
  late final StreamSubscription<List<sdk.Voice>> _rosterSubscription;

  /// State connections of every known package.
  final Map<String, StreamSubscription<sdk.PackageInfo>> _infoSubscriptions =
      {};

  /// Progress connections of the packages that are currently downloading —
  /// the only rows that render a progress ring.
  final Map<String, StreamSubscription<int>> _progressSubscriptions = {};

  List<sdk.Voice> _roster = const [];
  sdk.Voice? _defaultVoice;

  /// Sample the user started, and the run it belongs to: a sample cannot be
  /// stopped, so a completion only clears the state of its own run.
  int _playbackGeneration = 0;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _manager = sdk.VoiceManager.instance(DGis().context);
    _roster = _manager.voicesChannel.value;
    _defaultVoice = _manager.defaultVoice;
    _rosterSubscription = _manager.voicesChannel.listen(_onRoster);
    _syncSubscriptions();
  }

  @override
  void dispose() {
    unawaited(_rosterSubscription.cancel());
    for (final subscription in _infoSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _infoSubscriptions.clear();
    for (final subscription in _progressSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _progressSubscriptions.clear();
    // A running sample is left alone: native has no way to stop it.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = resolveNavigationSettingsTheme(context, widget.theme);
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final rows = _rows();
    final language = _resolveVoiceLanguage(
      explicit: widget.selectedLanguage,
      rows: rows,
      defaultVoice: _defaultVoice,
      locale: Localizations.maybeLocaleOf(context),
    );

    return ValueListenableBuilder<String?>(
      valueListenable:
          widget.repository.observe(NavigationSettingKeys.voiceSelected),
      builder: (context, selectedId, _) => _buildContent(
        theme: theme,
        localizations: localizations,
        rows: rows,
        language: language,
        effectiveSelectedId: selectedId ?? _defaultVoice?.id,
      ),
    );
  }

  Widget _buildContent({
    required NavigationSettingsTheme theme,
    required DgisLocalizations localizations,
    required List<_VoiceRow> rows,
    required String? language,
    required String? effectiveSelectedId,
  }) {
    final visibleRows = language == null
        ? rows
        : rows.where((row) => row.language == language).toList();
    final downloaded = visibleRows.where((row) => row.downloaded).toList();
    final available = visibleRows.where((row) => !row.downloaded).toList();
    final visibility = widget.visibilityConfig;
    final sections = <Widget>[];

    if (downloaded.isNotEmpty &&
        visibility.isVisible(SectionVisibilityConfig.sectionDownloadedVoices)) {
      sections.add(
        _VoicesSection(
          label: localizations.dgis_settings_voices_yours,
          theme: theme,
          children: [
            for (final row in downloaded)
              _downloadedRow(
                row: row,
                theme: theme,
                effectiveSelectedId: effectiveSelectedId,
                downloadedCount: downloaded.length,
                language: language,
                allRows: rows,
              ),
          ],
        ),
      );
    }

    if (available.isNotEmpty &&
        visibility.isVisible(SectionVisibilityConfig.sectionAvailableVoices)) {
      sections.add(
        _VoicesSection(
          label: localizations.dgis_settings_voices_available,
          theme: theme,
          children: [
            for (final row in available) _availableRow(row: row, theme: theme),
          ],
        ),
      );
    }

    if (visibility.isVisible(SectionVisibilityConfig.sectionLanguagePicker)) {
      sections.add(
        _VoicesSection(
          label: localizations.dgis_settings_voices_language_selection,
          theme: theme,
          children: [
            NavigationSettingsLink(
              label: localizations.dgis_settings_language,
              subtitle: language == null ? null : _voiceLanguageLabel(language),
              onTap: widget.onNavigateToLanguageSelection,
              theme: theme,
            ),
          ],
        ),
      );
    }

    return ColoredBox(
      color: theme.colors.pickerBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sections,
        ),
      ),
    );
  }

  Widget _downloadedRow({
    required _VoiceRow row,
    required NavigationSettingsTheme theme,
    required String? effectiveSelectedId,
    required int downloadedCount,
    required String? language,
    required List<_VoiceRow> allRows,
  }) {
    final deletable = !row.preinstalled && downloadedCount > 1;
    final playing = row.id == _playingId;
    // Disable playback while a sample runs.
    final blocked = _playingId != null;
    return NavigationSettingsSelectableListItem(
      label: row.name,
      subtitle: row.description,
      selected: row.id == effectiveSelectedId,
      // Update incompatible voices before selecting them.
      onTap: row.downloading
          ? () {}
          : row.needsUpdate
              ? () => _install(row)
              : () => _select(row),
      onPlay: blocked ? null : () => _play(row),
      playing: playing,
      needsUpdate: row.needsUpdate,
      downloadProgress: row.downloading ? row.progress : null,
      onDelete: row.downloading
          ? null
          : row.needsUpdate
              ? () => _install(row)
              : deletable
                  ? () => _uninstall(
                        row,
                        language: language,
                        allRows: allRows,
                        downloadedCount: downloadedCount,
                        effectiveSelectedId: effectiveSelectedId,
                      )
                  : null,
      theme: theme,
    );
  }

  Widget _availableRow({
    required _VoiceRow row,
    required NavigationSettingsTheme theme,
  }) {
    final playing = row.id == _playingId;
    final blocked = _playingId != null;
    return NavigationSettingsDownloadableListItem(
      label: row.name,
      subtitle: row.description,
      onPlay: blocked ? null : () => _play(row),
      playing: playing,
      onDownload: row.downloading ? null : () => _install(row),
      downloadProgress: row.downloading ? row.progress : null,
      theme: theme,
    );
  }

  List<_VoiceRow> _rows() => [for (final voice in _roster) _VoiceRow.of(voice)];

  void _select(_VoiceRow row) {
    setNavigationSetting(
      widget.repository,
      NavigationSettingKeys.voiceSelected,
      row.id,
    );
    _play(row);
  }

  /// Native playback cannot be stopped, so samples are serialized.
  void _play(_VoiceRow row) {
    if (_playingId != null) return;
    final generation = ++_playbackGeneration;
    setState(() => _playingId = row.id);
    unawaited(
      row.voice.playWelcome().value.then<void>(
        (_) => _finishPlayback(generation),
        onError: (Object error, StackTrace stackTrace) {
          _finishPlayback(generation);
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              context: ErrorDescription('while playing a voice sample'),
            ),
          );
        },
      ),
    );
  }

  void _finishPlayback(int generation) {
    if (!mounted || generation != _playbackGeneration) return;
    setState(() => _playingId = null);
  }

  void _install(_VoiceRow row) {
    row.voice.install();
    _watchProgress(row.voice);
  }

  void _uninstall(
    _VoiceRow row, {
    required String? language,
    required List<_VoiceRow> allRows,
    required int downloadedCount,
    required String? effectiveSelectedId,
  }) {
    if (row.preinstalled || downloadedCount <= 1) return;
    if (effectiveSelectedId == row.id) {
      final preferredRows = language == null
          ? allRows
          : allRows.where((candidate) => candidate.language == language);
      final candidates =
          language == null ? allRows : [...preferredRows, ...allRows];
      final replacement = candidates.firstWhereOrNull(
        (candidate) =>
            candidate.downloaded &&
            !candidate.needsUpdate &&
            candidate.id != row.id,
      );
      setNavigationSetting(
        widget.repository,
        NavigationSettingKeys.voiceSelected,
        replacement?.id,
      );
    }
    row.voice.uninstall();
  }

  void _onRoster(List<sdk.Voice> voices) {
    if (!mounted) return;
    final defaultVoice = _manager.defaultVoice;
    setState(() {
      _roster = voices;
      _defaultVoice = defaultVoice;
    });
    _syncSubscriptions();
  }

  /// Synchronizes package state subscriptions.
  void _syncSubscriptions() {
    final known = <String, sdk.Voice>{};
    final downloading = <String, sdk.Voice>{};
    for (final voice in _roster) {
      final id = voice.id;
      known[id] = voice;
      if (_isPackageInFlight(voice.info)) downloading[id] = voice;
    }
    for (final id in _infoSubscriptions.keys.toList()) {
      if (!known.containsKey(id)) {
        unawaited(_infoSubscriptions.remove(id)?.cancel());
      }
    }
    for (final id in _progressSubscriptions.keys.toList()) {
      if (!downloading.containsKey(id)) {
        unawaited(_progressSubscriptions.remove(id)?.cancel());
      }
    }
    for (final entry in known.entries) {
      if (_infoSubscriptions.containsKey(entry.key)) continue;
      final voice = entry.value;
      _infoSubscriptions[entry.key] = voice.infoChannel.listen(
        (info) => _onPackageInfo(voice, info),
      );
    }
    for (final entry in downloading.entries) {
      if (_progressSubscriptions.containsKey(entry.key)) continue;
      _watchProgress(entry.value);
    }
  }

  void _onPackageInfo(sdk.Voice voice, sdk.PackageInfo info) {
    if (!mounted) return;
    final id = voice.id;
    if (_isPackageInFlight(info)) {
      if (!_progressSubscriptions.containsKey(id)) _watchProgress(voice);
    } else {
      unawaited(_progressSubscriptions.remove(id)?.cancel());
    }
    setState(() {});
  }

  void _watchProgress(sdk.Voice voice) {
    final id = voice.id;
    unawaited(_progressSubscriptions.remove(id)?.cancel());
    _progressSubscriptions[id] = voice.progressChannel.listen((_) {
      if (mounted) setState(() {});
    });
  }
}

/// Language selection content for the voices settings flow.
class VoicesLanguageLayout extends StatefulWidget {
  /// Language chosen by the user, or null to resolve the default from the
  /// navigator's default voice and the current locale.
  final String? selectedLanguage;

  /// Called with the language the user picked.
  final ValueChanged<String> onLanguageSelected;

  /// Color and typography tokens, or null to resolve them from the platform
  /// brightness.
  final NavigationSettingsTheme? theme;

  const VoicesLanguageLayout({
    required this.selectedLanguage,
    required this.onLanguageSelected,
    this.theme,
    super.key,
  });

  @override
  State<VoicesLanguageLayout> createState() => _VoicesLanguageLayoutState();
}

class _VoicesLanguageLayoutState extends State<VoicesLanguageLayout> {
  late final sdk.VoiceManager _manager;
  late final StreamSubscription<List<sdk.Voice>> _rosterSubscription;
  List<sdk.Voice> _roster = const [];
  sdk.Voice? _defaultVoice;

  @override
  void initState() {
    super.initState();
    _manager = sdk.VoiceManager.instance(DGis().context);
    _roster = _manager.voicesChannel.value;
    _defaultVoice = _manager.defaultVoice;
    _rosterSubscription = _manager.voicesChannel.listen((voices) {
      if (!mounted) return;
      final defaultVoice = _manager.defaultVoice;
      setState(() {
        _roster = voices;
        _defaultVoice = defaultVoice;
      });
    });
  }

  @override
  void dispose() {
    unawaited(_rosterSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = resolveNavigationSettingsTheme(context, widget.theme);
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final rows = [for (final voice in _roster) _VoiceRow.of(voice)];
    final languages = _voiceLanguagesOf(rows);
    final selected = _resolveVoiceLanguage(
      explicit: widget.selectedLanguage,
      rows: rows,
      defaultVoice: _defaultVoice,
      locale: Localizations.maybeLocaleOf(context),
    );

    return ColoredBox(
      color: theme.colors.pickerBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: NavigationSettingsSection(
              theme: theme,
              bottomDivider: false,
              children: [
                if (selected != null)
                  NavigationSettingsRadioGroup<String>(
                    label: localizations.dgis_settings_language,
                    selected: selected,
                    onChanged: widget.onLanguageSelected,
                    theme: theme,
                    options: [
                      for (final language in languages)
                        NavigationSettingsRadioOption(
                          value: language,
                          label: _voiceLanguageLabel(language),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Whether an installation or an update of the package is running.
///
/// [sdk.PackageInfo.incomplete] only covers a package that has no complete
/// version yet, so an update of a complete package is recognized by
/// [sdk.PackageUpdateStatus.inProgress].
bool _isPackageInFlight(sdk.PackageInfo info) =>
    info.error == null &&
    (info.updateStatus == sdk.PackageUpdateStatus.inProgress ||
        (info.installed && info.incomplete));

/// State of a single voice package, read from the package itself.
@immutable
class _VoiceRow {
  final sdk.Voice voice;

  /// Stable technical identifier of the package.
  final String id;

  /// Localized package name, shown as the row label.
  final String name;

  /// Localized package description shown under the name, or null when the
  /// package reports none. May be long enough to wrap.
  final String? description;

  /// Language code reported by the package.
  final String language;

  /// Ready to be used: fully installed data that this SDK version can read.
  final bool downloaded;

  /// An installation or an update of this package is running.
  final bool downloading;

  /// Installation progress in percent, 0-100.
  final int progress;

  /// Shipped with the application and therefore not removable.
  final bool preinstalled;

  /// Installed data this SDK version cannot use, or data with a newer version
  /// on the server. Such a package has to be updated before it can voice the
  /// navigation.
  final bool needsUpdate;

  const _VoiceRow({
    required this.voice,
    required this.id,
    required this.name,
    required this.description,
    required this.language,
    required this.downloaded,
    required this.downloading,
    required this.progress,
    required this.preinstalled,
    required this.needsUpdate,
  });

  /// Creates current state for [voice].
  factory _VoiceRow.of(sdk.Voice voice) {
    final info = voice.info;
    final language = voice.language;
    final complete = info.installed && !info.incomplete;
    final description = info.description.trim();
    return _VoiceRow(
      voice: voice,
      id: voice.id,
      name: info.name,
      description: description.isEmpty ? null : description,
      language: language,
      downloaded: complete,
      downloading: _isPackageInFlight(info),
      progress: voice.progress,
      preinstalled: info.preinstalled,
      needsUpdate: complete && (!info.compatible || info.hasUpdate),
    );
  }
}

/// Sorted unique languages.
List<String> _voiceLanguagesOf(Iterable<_VoiceRow> rows) =>
    rows.map((row) => row.language).toSet().toList()..sort();

/// Resolves selected, default, locale, then first available language.
String? _resolveVoiceLanguage({
  required String? explicit,
  required List<_VoiceRow> rows,
  required sdk.Voice? defaultVoice,
  required Locale? locale,
}) {
  final languages = _voiceLanguagesOf(rows);
  if (explicit != null && languages.contains(explicit)) return explicit;
  final defaultId = defaultVoice?.id;
  final defaultLanguage =
      rows.firstWhereOrNull((row) => row.id == defaultId)?.language;
  if (defaultLanguage != null) return defaultLanguage;
  final localeLanguage = locale?.languageCode;
  if (localeLanguage != null && languages.contains(localeLanguage)) {
    return localeLanguage;
  }
  return languages.firstOrNull;
}

/// Endonym for an ISO 639-1 language code.
String _voiceLanguageLabel(String language) => switch (language.toLowerCase()) {
      'ar' => 'العربية',
      'hy' => 'Հայերեն',
      'az' => 'Azərbaycanca',
      'en' => 'English',
      'ka' => 'ქართული',
      'kk' => 'Қазақ',
      'ky' => 'Кыргызча',
      'ru' => 'Русский',
      'tg' => 'Тоҷикӣ',
      'uk' => 'Українська',
      'uz' => 'O‘zbekcha',
      'zh' => '中文',
      _ => language,
    };

class _VoicesSection extends StatelessWidget {
  final String label;
  final NavigationSettingsTheme theme;
  final List<Widget> children;

  const _VoicesSection({
    required this.label,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                label.toUpperCase(),
                style: theme.typography.sectionHeader.copyWith(
                  color: theme.colors.sectionHeader,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: NavigationSettingsSection(
                theme: theme,
                bottomDivider: false,
                children: children,
              ),
            ),
          ),
        ],
      );
}
