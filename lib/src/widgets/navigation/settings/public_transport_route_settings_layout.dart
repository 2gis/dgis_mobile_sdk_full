import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import 'navigation_setting_keys.dart';
import 'navigation_settings_repository.dart';
import 'navigation_settings_section.dart';
import 'navigation_settings_theme.dart';
import 'settings_layout_helpers.dart';
import 'settings_multi_select.dart';
import 'settings_section_header.dart';

final Set<sdk.PublicTransportType> _allTransportTypes =
    Set.unmodifiable(sdk.PublicTransportType.values);

/// Repository-backed public-transport route-search settings.
///
/// A runtime applier outside these route-search layouts applies persisted
/// settings when building a route.
class PublicTransportRouteSettingsLayout extends StatefulWidget {
  /// Repository used to observe and persist public-transport route settings.
  final NavigationSettingsRepository repository;

  /// Optional visual override for the settings controls.
  final NavigationSettingsTheme? theme;

  const PublicTransportRouteSettingsLayout({
    required this.repository,
    this.theme,
    super.key,
  });

  @override
  State<PublicTransportRouteSettingsLayout> createState() =>
      _PublicTransportRouteSettingsLayoutState();
}

class _PublicTransportRouteSettingsLayoutState
    extends State<PublicTransportRouteSettingsLayout> {
  var _showAllTransportTypesSelected = false;

  @override
  void didUpdateWidget(PublicTransportRouteSettingsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _showAllTransportTypesSelected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    final resolvedTheme = resolveNavigationSettingsTheme(context, widget.theme);
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
              key: NavigationSettingKeys.ptRememberChoice,
              label: localizations.dgis_settings_remember_choice,
              theme: resolvedTheme,
            ),
          ],
        ),
        NavigationSettingsSectionHeader(
          label: localizations.dgis_settings_transport_types,
          theme: resolvedTheme,
        ),
        NavigationSettingsSection(
          theme: resolvedTheme,
          children: [
            observeNavigationSetting(
              repository: repository,
              key: NavigationSettingKeys.ptTransportTypes,
              builder: (context, value, child) {
                final selected = _isAllTransportTypes(value) &&
                        !_showAllTransportTypesSelected
                    ? const <sdk.PublicTransportType>{}
                    : value;
                return NavigationSettingsMultiSelect<sdk.PublicTransportType>(
                  options: _transportTypeOptions(
                    localizations,
                    resolvedTheme.colors.inactiveActionIcon,
                  ),
                  selected: selected,
                  onChanged: (value) {
                    _showAllTransportTypesSelected =
                        _isAllTransportTypes(value);
                    setNavigationSetting(
                      repository,
                      NavigationSettingKeys.ptTransportTypes,
                      value.isEmpty ? _allTransportTypes : value,
                    );
                  },
                  theme: resolvedTheme,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

bool _isAllTransportTypes(Set<sdk.PublicTransportType> value) =>
    value.length == _allTransportTypes.length &&
    value.containsAll(_allTransportTypes);

List<NavigationSettingsMultiSelectOption<sdk.PublicTransportType>>
    _transportTypeOptions(
  DgisLocalizations localizations,
  Color iconColor,
) =>
        [
          _transportTypeOption(
            sdk.PublicTransportType.bus,
            localizations.dgis_public_transport_type_bus,
            'bus',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.trolleybus,
            localizations.dgis_public_transport_type_trolleybus,
            'trolleybus',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.tram,
            localizations.dgis_public_transport_type_tram,
            'tram',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.shuttleBus,
            localizations.dgis_public_transport_type_shuttle_bus,
            'minibus',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.metro,
            localizations.dgis_public_transport_type_metro,
            'metro',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.suburbanTrain,
            localizations.dgis_public_transport_type_suburban_train,
            'train',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.funicularRailway,
            localizations.dgis_public_transport_type_funicular_railway,
            'funicular',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.monorail,
            localizations.dgis_public_transport_type_monorail,
            'monorail',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.waterwayTransport,
            localizations.dgis_public_transport_type_waterway,
            'ship',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.cableCar,
            localizations.dgis_public_transport_type_cable_car,
            'aerial_lift',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.speedTram,
            localizations.dgis_public_transport_type_speed_tram,
            'light_rail',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.premetro,
            localizations.dgis_public_transport_type_premetro,
            'light_rail',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.lightMetro,
            localizations.dgis_public_transport_type_light_metro,
            'light_rail',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.aeroexpress,
            localizations.dgis_public_transport_type_aeroexpress,
            'aeroexpress',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.moscowCentralRing,
            localizations.dgis_public_transport_type_mcc,
            'mcc',
            iconColor,
          ),
          _transportTypeOption(
            sdk.PublicTransportType.moscowCentralDiameters,
            localizations.dgis_public_transport_type_mcd,
            'mcd',
            iconColor,
          ),
        ];

NavigationSettingsMultiSelectOption<sdk.PublicTransportType>
    _transportTypeOption(
  sdk.PublicTransportType value,
  String label,
  String icon,
  Color iconColor,
) =>
        NavigationSettingsMultiSelectOption(
          value: value,
          label: label,
          icon: SvgPicture.asset(
            'packages/$pluginName/assets/icons/navigation/public_transport/'
            'dgis_transport_types_$icon.svg',
            width: 24,
            height: 24,
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        );
