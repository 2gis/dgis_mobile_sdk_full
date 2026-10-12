import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../util/plugin_name.dart';
import 'navigation_settings_theme.dart';
import 'settings_progress_indicator.dart';

const _leadingWidth = 48.0;
const _iconSize = 24.0;
const _tapTargetSize = 48.0;
const _stopSize = 6.0;
const _subtitleGap = 2.0;
const _subtitleRowTopPadding = 10.0;
const _subtitleRowBottomPadding = 12.0;
const _stopRadius = 1.0;

void _ignoreTap() {}

String _asset(String name) =>
    'packages/$pluginName/assets/icons/navigation/$name.svg';

Color _playColor(
  NavigationSettingsColors colors, {
  required bool playing,
  required VoidCallback? onPlay,
}) =>
    playing
        ? colors.voiceAction
        : onPlay == null
            ? colors.inactiveActionIcon
            : colors.actionIcon;

Widget _buildDownloadProgress({
  required NavigationSettingsTheme theme,
  required NavigationSettingsColors colors,
  required int progress,
}) =>
    SizedBox.square(
      dimension: _tapTargetSize,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            NavigationSettingsProgressIndicator(
              progress: progress,
              theme: theme,
              color: colors.voiceAction,
            ),
            _StopGlyph(color: colors.voiceAction),
          ],
        ),
      ),
    );

/// Row for an installed voice.
///
/// Leading play button; trailing selection checkmark plus one action —
/// progress while an update is in flight, otherwise the update or delete
/// button. An optional [subtitle] carries the package description and may run
/// over several lines.
class NavigationSettingsSelectableListItem extends StatelessWidget {
  /// Primary text of the row.
  final String label;

  /// Whether this row shows the selection checkmark.
  final bool selected;

  /// Called when the user taps the row.
  final VoidCallback onTap;

  /// Called when the user taps the play button. Null renders a disabled play
  /// target whose taps do not fall through to the row selection action.
  final VoidCallback? onPlay;

  /// Whether the voice sample represented by this row is playing.
  final bool playing;

  /// Whether the installed package is incompatible or has an update.
  ///
  /// Renders the download/update action in place of the delete button. The
  /// action is wired to [onDelete]; with a null [onDelete] it renders as an
  /// inactive glyph and swallows taps.
  final bool needsUpdate;

  /// Update/installation progress 0-100, or null when nothing is in flight.
  /// While non-null it replaces the delete and update actions with the
  /// progress ring and its stop control.
  final int? downloadProgress;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Secondary text shown under [label], or null to hide. Wraps over as many
  /// lines as it needs.
  final String? subtitle;

  /// Called when the user taps the delete button — or the update button when
  /// [needsUpdate] is true. Null leaves the update action inactive when
  /// [needsUpdate] is true and hides the delete action otherwise.
  final VoidCallback? onDelete;

  /// Replaces the default selection checkmark.
  ///
  /// Sizing and color are left to the caller. The row still decides when it
  /// is shown, so a custom glyph is hidden while [selected] is false.
  final Widget? checkIcon;

  /// Replaces the default delete glyph.
  ///
  /// Sizing and color are left to the caller; the tap target around it is
  /// unchanged. Not shown while [needsUpdate] or [downloadProgress] is set.
  final Widget? deleteIcon;

  const NavigationSettingsSelectableListItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    this.onPlay,
    this.playing = false,
    this.needsUpdate = false,
    this.downloadProgress,
    this.subtitle,
    this.onDelete,
    this.checkIcon,
    this.deleteIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final onDelete = this.onDelete;
    final onPlay = this.onPlay;
    final playColor = _playColor(colors, playing: playing, onPlay: onPlay);
    return _ListItemRow(
      label: label,
      subtitle: subtitle,
      onTap: onTap,
      selected: selected,
      theme: theme,
      leading: _ActionButton(
        asset: 'dgis_play_new_button',
        color: playColor,
        onTap: onPlay,
        label: localizations.dgis_settings_voices_play,
      ),
      trailingActions: [
        if (selected)
          SizedBox.square(
            dimension: _tapTargetSize,
            child: Center(
              child: checkIcon ??
                  _Glyph(asset: 'dgis_check', color: colors.voiceAction),
            ),
          ),
        if (downloadProgress != null)
          _buildDownloadProgress(
            theme: theme,
            colors: colors,
            progress: downloadProgress!,
          )
        else if (needsUpdate)
          _ActionButton(
            asset: 'dgis_arrow_down',
            color: onDelete != null
                ? colors.voiceAction
                : colors.inactiveActionIcon,
            onTap: onDelete,
            label: localizations.dgis_settings_voices_update,
          )
        else if (onDelete != null)
          _ActionButton(
            asset: 'dgis_trash',
            color: colors.actionIcon,
            onTap: onDelete,
            label: localizations.dgis_settings_voices_delete,
            icon: deleteIcon,
          ),
      ],
    );
  }
}

/// Row for a voice that can be downloaded.
///
/// Leading play button; trailing download button, replaced by a progress
/// indicator with a stop glyph while [downloadProgress] is non-null. An
/// optional [subtitle] carries the package description and may run over
/// several lines.
class NavigationSettingsDownloadableListItem extends StatelessWidget {
  /// Primary text of the row.
  final String label;

  /// Called when the user taps the play button. Null renders a disabled play
  /// target.
  final VoidCallback? onPlay;

  /// Whether the voice sample represented by this row is playing.
  final bool playing;

  /// Color and typography tokens.
  final NavigationSettingsTheme theme;

  /// Secondary text shown under [label], or null to hide. Wraps over as many
  /// lines as it needs.
  final String? subtitle;

  /// Called when the user taps the download button; null hides the button.
  final VoidCallback? onDownload;

  /// Download progress 0–100; when non-null it replaces the download button.
  final int? downloadProgress;

  /// Replaces the default play glyph.
  ///
  /// Sizing and color are left to the caller; the tap target around it is
  /// unchanged.
  final Widget? playIcon;

  /// Replaces the default download glyph.
  ///
  /// Sizing and color are left to the caller; the tap target around it is
  /// unchanged. Not shown while [downloadProgress] is non-null.
  final Widget? downloadIcon;

  const NavigationSettingsDownloadableListItem({
    required this.label,
    required this.theme,
    this.onPlay,
    this.playing = false,
    this.subtitle,
    this.onDownload,
    this.downloadProgress,
    this.playIcon,
    this.downloadIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final onPlay = this.onPlay;
    final playColor = _playColor(colors, playing: playing, onPlay: onPlay);
    final trailing = _buildTrailing(colors, localizations);
    return _ListItemRow(
      label: label,
      subtitle: subtitle,
      theme: theme,
      leading: _ActionButton(
        asset: 'dgis_play_new_button',
        color: playColor,
        onTap: onPlay,
        label: localizations.dgis_settings_voices_play,
        icon: playIcon,
      ),
      trailingActions: [
        if (trailing != null) trailing,
      ],
    );
  }

  Widget? _buildTrailing(
    NavigationSettingsColors colors,
    DgisLocalizations localizations,
  ) {
    final progress = downloadProgress;
    if (progress != null) {
      return _buildDownloadProgress(
        theme: theme,
        colors: colors,
        progress: progress,
      );
    }

    final onDownload = this.onDownload;
    if (onDownload == null) {
      return null;
    }

    return _ActionButton(
      asset: 'dgis_arrow_down',
      color: colors.voiceAction,
      onTap: onDownload,
      label: localizations.dgis_settings_voices_download,
      icon: downloadIcon,
    );
  }
}

/// Row skeleton shared by both rows above.
class _ListItemRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool selected;
  final NavigationSettingsTheme theme;
  final Widget? leading;
  final List<Widget> trailingActions;

  const _ListItemRow({
    required this.label,
    required this.theme,
    this.subtitle,
    this.onTap,
    this.selected = false,
    this.leading,
    this.trailingActions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final subtitleText = subtitle;
    final onTap = this.onTap;

    Widget labelArea = MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.settingLabel.copyWith(
              color: colors.settingLabel,
            ),
          ),
          if (subtitleText != null) ...[
            const SizedBox(height: _subtitleGap),
            // A description can run over several lines; the row grows with it
            // and the leading and trailing icons stay centered on the block.
            Text(
              subtitleText,
              style: theme.typography.settingDescription.copyWith(
                color: colors.settingDescription,
              ),
            ),
          ],
        ],
      ),
    );
    // Trailing actions retain individual semantics.
    if (onTap != null) {
      labelArea = Semantics(
        selected: selected,
        button: true,
        onTap: onTap,
        child: labelArea,
      );
    }

    return GestureDetector(
      onTap: onTap,
      excludeFromSemantics: true,
      behavior: HitTestBehavior.opaque,
      // Icons stay centered on the title-plus-description block, however many
      // lines the description takes.
      child: Row(
        children: [
          SizedBox.square(
            dimension: _leadingWidth,
            child: Center(child: leading ?? const SizedBox.shrink()),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                top: subtitleText != null ? _subtitleRowTopPadding : 0,
                bottom: subtitleText != null ? _subtitleRowBottomPadding : 0,
              ),
              child: labelArea,
            ),
          ),
          ...trailingActions,
        ],
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  final String asset;
  final Color color;

  const _Glyph({required this.asset, required this.color});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        _asset(asset),
        width: _iconSize,
        height: _iconSize,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

class _StopGlyph extends StatelessWidget {
  final Color color;

  const _StopGlyph({required this.color});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_stopRadius),
        ),
        child: const SizedBox.square(dimension: _stopSize),
      );
}

class _ActionButton extends StatelessWidget {
  /// Built-in glyph asset.
  final String? asset;
  final Color color;
  final VoidCallback? onTap;

  /// Accessible name of the action.
  final String label;

  /// Custom glyph.
  final Widget? icon;

  const _ActionButton({
    required this.color,
    required this.onTap,
    required this.label,
    this.asset,
    this.icon,
  }) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final asset = this.asset;
    return Semantics(
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      label: label,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: onTap ?? _ignoreTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: _tapTargetSize,
          child: Center(
            child: icon ??
                (asset == null ? null : _Glyph(asset: asset, color: color)),
          ),
        ),
      ),
    );
  }
}
