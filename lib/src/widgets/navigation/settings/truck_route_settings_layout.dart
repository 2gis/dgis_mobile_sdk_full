import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'settings_layout_helpers.dart';
import 'settings_section_header.dart';
import 'settings_stepper_row.dart';
import 'truck_preset.dart';
import 'truck_preset_selector.dart';

/// Insets of the paragraph introducing the screen.
const _descriptionPadding = EdgeInsets.fromLTRB(32, 24, 32, 24);

/// Repository-backed truck route-search settings.
///
/// Dimensions follow the selected [TruckPreset] until the user steps one of
/// them, which stores an override for that parameter alone. Picking another
/// preset drops every override.
///
/// A runtime applier outside these route-search layouts applies persisted
/// settings when building a route.
class TruckRouteSettingsLayout extends StatelessWidget {
  /// Repository used to observe and persist truck route-search settings.
  final NavigationSettingsRepository repository;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  const TruckRouteSettingsLayout({
    required this.repository,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = resolveNavigationSettingsTheme(context, theme);
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    final numbers = NumberFormat.decimalPattern(
      Localizations.maybeLocaleOf(context)?.languageCode,
    )..maximumFractionDigits = 1;
    String format(int thousandths) => numbers.format(thousandths / 1000);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: _descriptionPadding,
          child: Text(
            localizations.dgis_settings_truck_description,
            textAlign: TextAlign.center,
            style: resolvedTheme.typography.screenDescription.copyWith(
              color: resolvedTheme.colors.settingLabel,
            ),
          ),
        ),
        NavigationSettingsSectionHeader(
          label: localizations.dgis_settings_truck_section_dimensions,
          theme: resolvedTheme,
        ),
        observeNavigationSetting<TruckPreset>(
          repository: repository,
          key: NavigationSettingKeys.truckPreset,
          builder: (context, preset, child) => NavigationSettingsSection(
            theme: resolvedTheme,
            children: [
              TruckPresetSelector(
                selected: preset,
                onChanged: (selected) => _selectPreset(preset, selected),
                captionBuilder: (preset) => format(truckPresetMass(preset)),
                theme: resolvedTheme,
              ),
              for (final dimension in TruckDimension.values)
                _dimension(
                  dimension: dimension,
                  preset: preset,
                  label: _label(dimension, localizations),
                  format: format,
                  theme: resolvedTheme,
                ),
            ],
          ),
        ),
        NavigationSettingsSectionHeader(
          label: localizations.dgis_settings_truck_section_cargo,
          theme: resolvedTheme,
        ),
        NavigationSettingsSection(
          theme: resolvedTheme,
          children: [
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.truckDangerousCargo,
              label: localizations.dgis_settings_truck_dangerous_cargo,
              theme: resolvedTheme,
            ),
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.truckExplosiveCargo,
              label: localizations.dgis_settings_truck_explosive_cargo,
              theme: resolvedTheme,
            ),
          ],
        ),
        NavigationSettingsSectionHeader(
          label: localizations.dgis_settings_section_route,
          theme: resolvedTheme,
        ),
        NavigationSettingsSection(
          theme: resolvedTheme,
          children: [
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.truckFallbackOnCar,
              label: localizations.dgis_settings_truck_fallback_on_car,
              theme: resolvedTheme,
            ),
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.truckAvoidTollRoads,
              label: localizations.dgis_settings_avoid_toll_roads,
              theme: resolvedTheme,
            ),
            observeNavigationToggle(
              repository: repository,
              key: NavigationSettingKeys.truckAvoidUnpavedRoads,
              label: localizations.dgis_settings_avoid_unpaved_roads,
              theme: resolvedTheme,
            ),
          ],
        ),
      ],
    );
  }

  void _selectPreset(TruckPreset current, TruckPreset selected) {
    if (selected == current) {
      return;
    }

    setNavigationSetting(
      repository,
      NavigationSettingKeys.truckPreset,
      selected,
    );
    for (final dimension in TruckDimension.values) {
      setNavigationSetting(
        repository,
        NavigationSettingKeys.truckDimension(dimension),
        null,
      );
    }
  }

  Widget _dimension({
    required TruckDimension dimension,
    required TruckPreset preset,
    required String label,
    required String Function(int thousandths) format,
    required NavigationSettingsTheme theme,
  }) {
    final key = NavigationSettingKeys.truckDimension(dimension);

    return observeNavigationSetting<int?>(
      repository: repository,
      key: key,
      builder: (context, override, child) {
        final value = dimension.resolve(preset, override);

        return NavigationSettingsStepperRow(
          label: label,
          value: format(value),
          onDecrement: value > TruckDimension.minValue
              ? () => setNavigationSetting(
                    repository,
                    key,
                    dimension.stepped(value, -1),
                  )
              : null,
          onIncrement: value < dimension.maxValue
              ? () => setNavigationSetting(
                    repository,
                    key,
                    dimension.stepped(value, 1),
                  )
              : null,
          theme: theme,
        );
      },
    );
  }

  String _label(TruckDimension dimension, DgisLocalizations localizations) =>
      switch (dimension) {
        TruckDimension.length => localizations.dgis_settings_truck_length,
        TruckDimension.height => localizations.dgis_settings_truck_height,
        TruckDimension.width => localizations.dgis_settings_truck_width,
        TruckDimension.actualMass =>
          localizations.dgis_settings_truck_actual_mass,
        TruckDimension.maxPermittedMass =>
          localizations.dgis_settings_truck_max_permitted_mass,
        TruckDimension.axleLoad => localizations.dgis_settings_truck_axle_load,
      };
}
