import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'settings_layout_helpers.dart';

/// Repository-backed motorcycle route-search settings.
///
/// This layout intentionally does not expose motorcycle route type. A runtime
/// applier outside these route-search layouts applies persisted settings when
/// building a route.
class MotorcycleRouteSettingsLayout extends StatelessWidget {
  /// Repository used to observe and persist motorcycle route-search settings.
  final NavigationSettingsRepository repository;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  const MotorcycleRouteSettingsLayout({
    required this.repository,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = resolveNavigationSettingsTheme(context, theme);
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return NavigationSettingsSection(
      theme: resolvedTheme,
      children: [
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.motorcycleAvoidTollRoads,
          label: localizations.dgis_settings_avoid_toll_roads,
          theme: resolvedTheme,
        ),
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.motorcycleAvoidUnpavedRoads,
          label: localizations.dgis_settings_avoid_unpaved_roads,
          theme: resolvedTheme,
        ),
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.motorcycleAvoidFerries,
          label: localizations.dgis_settings_avoid_ferries,
          theme: resolvedTheme,
        ),
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.motorcycleAvoidLockedRoads,
          label: localizations.dgis_settings_avoid_locked_roads,
          theme: resolvedTheme,
        ),
      ],
    );
  }
}
