import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'settings_layout_helpers.dart';

/// Repository-backed bicycle route-search settings.
///
/// A runtime applier outside these route-search layouts applies persisted
/// settings when building a route.
class BicycleRouteSettingsLayout extends StatelessWidget {
  /// Repository used to observe and persist bicycle route-search settings.
  final NavigationSettingsRepository repository;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  const BicycleRouteSettingsLayout({
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
          key: NavigationSettingKeys.bicycleAvoidCarRoads,
          label: localizations.dgis_settings_avoid_car_roads,
          theme: resolvedTheme,
        ),
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.bicycleAvoidStairways,
          label: localizations.dgis_settings_avoid_stairs,
          theme: resolvedTheme,
        ),
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.bicycleAvoidUnderpasses,
          label: localizations.dgis_settings_avoid_underpasses,
          theme: resolvedTheme,
        ),
        observeNavigationToggle(
          repository: repository,
          key: NavigationSettingKeys.bicycleAvoidUnpavedRoads,
          label: localizations.dgis_settings_avoid_unpaved_roads,
          theme: resolvedTheme,
        ),
      ],
    );
  }
}
