import 'package:flutter/foundation.dart';

import 'navigation_settings_repository.dart';
import 'navigation_settings_theme.dart';
import 'section_visibility_config.dart';

/// Navigation settings configuration for `NavigationLayoutWidget`.
///
/// The default instance disables the feature: the dashboard shows no settings
/// row and nothing is applied to the navigation manager.
///
/// [repository] and [onSettingsClick] are independent:
///
/// - [repository] persists settings and keeps the runtime ones synchronized
///   with the navigation manager. It also backs the built-in settings flow.
/// - [onSettingsClick] replaces the built-in flow with the host app's own UI.
///   The settings row then appears even without a [repository], and
///   [theme], [sectionVisibility] and [primarySection] have no effect.
@immutable
class NavigationSettingsOptions {
  /// Repository read and written by the settings UI and the runtime applier.
  ///
  /// The caller retains ownership and must dispose it after the layout widget
  /// is removed.
  final NavigationSettingsRepository? repository;

  /// Replaces the built-in settings flow with a host-provided screen.
  final VoidCallback? onSettingsClick;

  /// Visual override for the built-in settings flow.
  final NavigationSettingsTheme? theme;

  /// Sections visible in the built-in settings flow.
  final SectionVisibilityConfig sectionVisibility;

  /// Transport section displayed inline on the root settings screen.
  final String primarySection;

  const NavigationSettingsOptions({
    this.repository,
    this.onSettingsClick,
    this.theme,
    this.sectionVisibility = const SectionVisibilityConfig(),
    this.primarySection = SectionVisibilityConfig.sectionCarRoute,
  });
}
