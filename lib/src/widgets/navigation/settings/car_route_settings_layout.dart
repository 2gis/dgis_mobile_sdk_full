import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'settings_layout_helpers.dart';
import 'settings_radio_group.dart';
import 'settings_section_header.dart';

/// Repository-backed car route-search settings.
///
/// A runtime applier outside these route-search layouts applies persisted
/// settings when building a route.
class CarRouteSettingsLayout extends StatelessWidget {
  /// Repository used to observe and persist car route-search settings.
  final NavigationSettingsRepository repository;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  const CarRouteSettingsLayout({
    required this.repository,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = resolveNavigationSettingsTheme(context, theme);
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavigationSettingsSection(
          theme: resolvedTheme,
          children: [
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.carAvoidTollRoads,
              label: localizations.dgis_settings_avoid_toll_roads,
              theme: resolvedTheme,
            ),
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.carAvoidUnpavedRoads,
              label: localizations.dgis_settings_avoid_unpaved_roads,
              theme: resolvedTheme,
            ),
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.carAvoidFerries,
              label: localizations.dgis_settings_avoid_ferries,
              theme: resolvedTheme,
            ),
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.carAvoidLockedRoads,
              label: localizations.dgis_settings_avoid_locked_roads,
              theme: resolvedTheme,
            ),
          ],
        ),
        NavigationSettingsSectionHeader(
          label: localizations.dgis_settings_route_search_type,
          theme: resolvedTheme,
        ),
        NavigationSettingsSection(
          theme: resolvedTheme,
          children: [
            observeNavigationSetting(
              repository: repository,
              key: NavigationSettingKeys.carRouteSearchType,
              builder: (context, value, child) =>
                  NavigationSettingsRadioGroup<sdk.RouteSearchType>(
                options: [
                  NavigationSettingsRadioOption(
                    value: sdk.RouteSearchType.jam,
                    label: localizations.dgis_settings_route_search_type_jam,
                    description:
                        localizations.dgis_settings_route_search_type_jam_desc,
                  ),
                  NavigationSettingsRadioOption(
                    value: sdk.RouteSearchType.statistic,
                    label:
                        localizations.dgis_settings_route_search_type_statistic,
                    description: localizations
                        .dgis_settings_route_search_type_statistic_desc,
                  ),
                  NavigationSettingsRadioOption(
                    value: sdk.RouteSearchType.shortest,
                    label:
                        localizations.dgis_settings_route_search_type_shortest,
                    description: localizations
                        .dgis_settings_route_search_type_shortest_desc,
                  ),
                ],
                selected: value,
                onChanged: (value) => setNavigationSetting(
                  repository,
                  NavigationSettingKeys.carRouteSearchType,
                  value,
                ),
                theme: resolvedTheme,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
