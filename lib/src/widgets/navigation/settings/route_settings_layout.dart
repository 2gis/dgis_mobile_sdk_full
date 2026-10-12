import 'package:flutter/widgets.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import 'bicycle_route_settings_layout.dart';
import 'car_route_settings_layout.dart';
import 'motorcycle_route_settings_layout.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_divider.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'pedestrian_route_settings_layout.dart';
import 'public_transport_route_settings_layout.dart';
import 'scooter_route_settings_layout.dart';
import 'section_visibility_config.dart';
import 'settings_checkmark.dart';
import 'settings_key.dart';
import 'settings_layout_helpers.dart';
import 'settings_link.dart';
import 'settings_master_toggle.dart';
import 'settings_radio_group.dart';
import 'settings_section_header.dart';
import 'truck_route_settings_layout.dart';

/// Scrollable top-level navigation settings layout.
///
/// The layout reads and writes settings through [repository] and never touches
/// a navigation manager directly. `NavigationSettingsApplier` applies runtime
/// keys; route-search keys are read when the caller builds its next route.
class RouteSettingsLayout extends StatelessWidget {
  /// Repository used to observe and persist all route settings.
  final NavigationSettingsRepository repository;

  /// Transport section rendered inline as the layout's primary route section.
  ///
  /// Unsupported identifiers render no primary section.
  final String primarySection;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  /// Controls which settings sections are visible.
  final SectionVisibilityConfig visibilityConfig;

  /// Called when the user taps the Car route settings row.
  final VoidCallback onNavigateToCar;

  /// Called when the user taps the Pedestrian route settings row.
  final VoidCallback onNavigateToPedestrian;

  /// Called when the user taps the Bicycle route settings row.
  final VoidCallback onNavigateToBicycle;

  /// Called when the user taps the Scooter route settings row.
  final VoidCallback onNavigateToScooter;

  /// Called when the user taps the Motorcycle route settings row.
  final VoidCallback onNavigateToMotorcycle;

  /// Called when the user taps the Public transport route settings row.
  final VoidCallback onNavigateToPublicTransport;

  /// Called when the user taps the Truck route settings row.
  final VoidCallback onNavigateToTruck;

  /// Called when the user taps the Voices settings row.
  final VoidCallback onNavigateToVoices;

  /// Called when the user taps the Sounds and alerts settings row.
  final VoidCallback onNavigateToSounds;

  /// Creates a layout with an inline [primarySection] and transport link actions.
  const RouteSettingsLayout({
    required this.repository,
    required this.primarySection,
    required this.onNavigateToCar,
    required this.onNavigateToPedestrian,
    required this.onNavigateToBicycle,
    required this.onNavigateToScooter,
    required this.onNavigateToMotorcycle,
    required this.onNavigateToPublicTransport,
    required this.onNavigateToTruck,
    required this.onNavigateToSounds,
    required this.onNavigateToVoices,
    this.theme,
    this.visibilityConfig = const SectionVisibilityConfig(),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = resolveNavigationSettingsTheme(context, theme);
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    final primary = visibilityConfig.isVisible(primarySection)
        ? _primaryRouteSection(
            primarySection,
            localizations,
            resolvedTheme,
          )
        : null;
    final otherNavigators = _otherNavigators(localizations, resolvedTheme);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (visibilityConfig
                  .isVisible(SectionVisibilityConfig.sectionVoices) ||
              visibilityConfig
                  .isVisible(SectionVisibilityConfig.sectionSounds)) ...[
            NavigationSettingsSectionHeader(
              label: localizations.dgis_settings_section_sound_and_voice,
              theme: resolvedTheme,
            ),
            NavigationSettingsSection(
              theme: resolvedTheme,
              children: [
                if (visibilityConfig
                    .isVisible(SectionVisibilityConfig.sectionVoices))
                  NavigationSettingsLink(
                    label: localizations.dgis_settings_voices,
                    onTap: onNavigateToVoices,
                    theme: resolvedTheme,
                  ),
                if (visibilityConfig.isVisible(
                  SectionVisibilityConfig.sectionSounds,
                ))
                  NavigationSettingsLink(
                    label: localizations.dgis_settings_sounds_and_alerts,
                    onTap: onNavigateToSounds,
                    theme: resolvedTheme,
                  ),
              ],
            ),
          ],
          if (visibilityConfig.isVisible(
            SectionVisibilityConfig.sectionGeneralRoute,
          )) ...[
            NavigationSettingsSectionHeader(
              label: localizations.dgis_settings_section_route,
              theme: resolvedTheme,
            ),
            NavigationSettingsSection(
              theme: resolvedTheme,
              children: [
                observeNavigationToggle(
                  repository: repository,
                  key: NavigationSettingKeys.betterRouteEnabled,
                  label: localizations.dgis_settings_suggest_better_route,
                  theme: resolvedTheme,
                ),
                observeNavigationToggle(
                  repository: repository,
                  key: NavigationSettingKeys.alternativeRoutesEnabled,
                  label: localizations.dgis_settings_show_alternative_routes,
                  theme: resolvedTheme,
                ),
                observeNavigationToggle(
                  repository: repository,
                  key: NavigationSettingKeys.rebuildOnDeviation,
                  label: localizations.dgis_settings_rebuild_on_deviation,
                  theme: resolvedTheme,
                ),
              ],
            ),
          ],
          if (primary != null) primary,
          if (visibilityConfig.isVisible(
            SectionVisibilityConfig.sectionCalloutVisualization,
          )) ...[
            NavigationSettingsSectionHeader(
              label: localizations.dgis_settings_callout_visualization,
              theme: resolvedTheme,
            ),
            NavigationSettingsSection(
              theme: resolvedTheme,
              children: [
                observeNavigationSetting(
                  repository: repository,
                  key: NavigationSettingKeys.calloutVisualizationMode,
                  builder: (context, value, child) =>
                      NavigationSettingsRadioGroup<
                          sdk.CalloutVisualizationMode>(
                    options: [
                      NavigationSettingsRadioOption(
                        value: sdk.CalloutVisualizationMode.always,
                        label: localizations.dgis_settings_callout_always,
                        description:
                            localizations.dgis_settings_callout_always_desc,
                      ),
                      NavigationSettingsRadioOption(
                        value: sdk.CalloutVisualizationMode.multipleRoutes,
                        label:
                            localizations.dgis_settings_callout_multiple_routes,
                        description: localizations
                            .dgis_settings_callout_multiple_routes_desc,
                      ),
                      NavigationSettingsRadioOption(
                        value: sdk.CalloutVisualizationMode.none,
                        label: localizations.dgis_settings_callout_none,
                        description:
                            localizations.dgis_settings_callout_none_desc,
                      ),
                    ],
                    selected: value,
                    onChanged: (value) => setNavigationSetting(
                      repository,
                      NavigationSettingKeys.calloutVisualizationMode,
                      value,
                    ),
                    theme: resolvedTheme,
                  ),
                ),
              ],
            ),
          ],
          if (otherNavigators.isNotEmpty) ...[
            NavigationSettingsSectionHeader(
              label: localizations.dgis_settings_section_other_navigators,
              theme: resolvedTheme,
            ),
            NavigationSettingsSection(
              theme: resolvedTheme,
              children: otherNavigators,
            ),
          ],
          if (visibilityConfig.isVisible(
            SectionVisibilityConfig.sectionMapEvents,
          )) ...[
            NavigationSettingsSectionHeader(
              label: localizations.dgis_settings_section_map_events,
              theme: resolvedTheme,
            ),
            NavigationSettingsSection(
              theme: resolvedTheme,
              children: [
                _mapEventsSection(localizations, resolvedTheme),
              ],
            ),
          ],
          if (visibilityConfig.isVisible(
            SectionVisibilityConfig.sectionPassedRoute,
          )) ...[
            NavigationSettingsSectionHeader(
              label: localizations.dgis_settings_section_passed_route,
              theme: resolvedTheme,
            ),
            NavigationSettingsSection(
              theme: resolvedTheme,
              children: [
                _passedRouteSection(localizations, resolvedTheme),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _mapEventsSection(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      observeNavigationSetting(
        repository: repository,
        key: NavigationSettingKeys.mapEventsEnabled,
        builder: (context, value, child) => NavigationSettingsMasterToggle(
          label: localizations.dgis_settings_map_events,
          value: value,
          onChanged: (value) => setNavigationSetting(
            repository,
            NavigationSettingKeys.mapEventsEnabled,
            value,
          ),
          theme: theme,
          builder: (context, enabled) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _checkmarkGroup(
              enabled: enabled,
              theme: theme,
              settings: [
                (
                  NavigationSettingKeys.mapEventsAccidents,
                  localizations.dgis_settings_map_events_accidents,
                ),
                (
                  NavigationSettingKeys.mapEventsRoadWorks,
                  localizations.dgis_settings_map_events_road_works,
                ),
                (
                  NavigationSettingKeys.mapEventsCameras,
                  localizations.dgis_settings_map_events_cameras,
                ),
                (
                  NavigationSettingKeys.mapEventsComments,
                  localizations.dgis_settings_map_events_comments,
                ),
                (
                  NavigationSettingKeys.mapEventsRoadRestrictions,
                  localizations.dgis_settings_map_events_road_restrictions,
                ),
                (
                  NavigationSettingKeys.mapEventsOtherEvents,
                  localizations.dgis_settings_map_events_other,
                ),
                (
                  NavigationSettingKeys.mapEventsBubbles,
                  localizations.dgis_settings_map_events_bubbles,
                ),
                (
                  NavigationSettingKeys.mapEventsLanesBubbles,
                  localizations.dgis_settings_map_events_lanes_bubbles,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _passedRouteSection(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      observeNavigationSetting(
        repository: repository,
        key: NavigationSettingKeys.mapEventsPermanentEnabled,
        builder: (context, value, child) => NavigationSettingsMasterToggle(
          label: localizations.dgis_settings_passed_route,
          value: value,
          onChanged: (value) => setNavigationSetting(
            repository,
            NavigationSettingKeys.mapEventsPermanentEnabled,
            value,
          ),
          theme: theme,
          builder: (context, enabled) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _checkmarkGroup(
              enabled: enabled,
              theme: theme,
              settings: [
                (
                  NavigationSettingKeys.mapEventsPermanentStartPoint,
                  localizations.dgis_settings_passed_route_start_point,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentFinishPoint,
                  localizations.dgis_settings_passed_route_finish_point,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentIntermediatePoints,
                  localizations.dgis_settings_passed_route_intermediate_points,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentCameras,
                  localizations.dgis_settings_passed_route_cameras,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentAccidents,
                  localizations.dgis_settings_passed_route_accidents,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentRoadWorks,
                  localizations.dgis_settings_passed_route_road_works,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentComments,
                  localizations.dgis_settings_passed_route_comments,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentRoadRestrictions,
                  localizations.dgis_settings_passed_route_road_restrictions,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentOtherEvents,
                  localizations.dgis_settings_passed_route_other,
                ),
                (
                  NavigationSettingKeys.mapEventsPermanentTollRoads,
                  localizations.dgis_settings_passed_route_toll_roads,
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> _checkmarkGroup({
    required bool enabled,
    required NavigationSettingsTheme theme,
    required List<(BoolSettingsKey, String)> settings,
  }) {
    final children = <Widget>[];
    for (var index = 0; index < settings.length; index++) {
      final setting = settings[index];
      children
        ..add(NavigationSettingsDivider(theme: theme))
        ..add(
          observeNavigationSetting(
            repository: repository,
            key: setting.$1,
            builder: (context, value, child) => NavigationSettingsCheckmark(
              label: setting.$2,
              value: value,
              onChanged: (value) =>
                  setNavigationSetting(repository, setting.$1, value),
              theme: theme,
              enabled: enabled,
            ),
          ),
        );
    }
    return children;
  }

  Widget? _primaryRouteSection(
    String section,
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) =>
      switch (section) {
        SectionVisibilityConfig.sectionCarRoute => _primarySection(
            localizations.dgis_settings_section_car,
            CarRouteSettingsLayout(repository: repository, theme: theme),
            theme,
          ),
        SectionVisibilityConfig.sectionPedestrian => _primarySection(
            localizations.dgis_settings_section_pedestrian,
            PedestrianRouteSettingsLayout(repository: repository, theme: theme),
            theme,
          ),
        SectionVisibilityConfig.sectionBicycle => _primarySection(
            localizations.dgis_settings_section_bicycle,
            BicycleRouteSettingsLayout(repository: repository, theme: theme),
            theme,
          ),
        SectionVisibilityConfig.sectionScooter => _primarySection(
            localizations.dgis_settings_section_scooter,
            ScooterRouteSettingsLayout(repository: repository, theme: theme),
            theme,
          ),
        SectionVisibilityConfig.sectionMotorcycle => _primarySection(
            localizations.dgis_settings_section_motorcycle,
            MotorcycleRouteSettingsLayout(repository: repository, theme: theme),
            theme,
          ),
        SectionVisibilityConfig.sectionPublicTransport => _primarySection(
            localizations.dgis_settings_section_public_transport,
            PublicTransportRouteSettingsLayout(
              repository: repository,
              theme: theme,
            ),
            theme,
          ),
        SectionVisibilityConfig.sectionTruck => _primarySection(
            localizations.dgis_settings_section_truck,
            TruckRouteSettingsLayout(repository: repository, theme: theme),
            theme,
          ),
        _ => null,
      };

  Widget _primarySection(
    String label,
    Widget content,
    NavigationSettingsTheme theme,
  ) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationSettingsSectionHeader(label: label, theme: theme),
          content,
        ],
      );

  List<Widget> _otherNavigators(
    DgisLocalizations localizations,
    NavigationSettingsTheme theme,
  ) {
    final navigators = <Widget>[];

    void add({
      required String section,
      required String label,
      required VoidCallback onTap,
    }) {
      if (section != primarySection && visibilityConfig.isVisible(section)) {
        navigators.add(
          NavigationSettingsLink(
            label: label,
            onTap: onTap,
            theme: theme,
          ),
        );
      }
    }

    add(
      section: SectionVisibilityConfig.sectionCarRoute,
      label: localizations.dgis_settings_section_car,
      onTap: onNavigateToCar,
    );
    add(
      section: SectionVisibilityConfig.sectionMotorcycle,
      label: localizations.dgis_settings_section_motorcycle,
      onTap: onNavigateToMotorcycle,
    );
    add(
      section: SectionVisibilityConfig.sectionPublicTransport,
      label: localizations.dgis_settings_section_public_transport,
      onTap: onNavigateToPublicTransport,
    );
    add(
      section: SectionVisibilityConfig.sectionPedestrian,
      label: localizations.dgis_settings_section_pedestrian,
      onTap: onNavigateToPedestrian,
    );
    add(
      section: SectionVisibilityConfig.sectionBicycle,
      label: localizations.dgis_settings_section_bicycle,
      onTap: onNavigateToBicycle,
    );
    add(
      section: SectionVisibilityConfig.sectionScooter,
      label: localizations.dgis_settings_section_scooter,
      onTap: onNavigateToScooter,
    );
    add(
      section: SectionVisibilityConfig.sectionTruck,
      label: localizations.dgis_settings_section_truck,
      onTap: onNavigateToTruck,
    );

    return navigators;
  }
}
