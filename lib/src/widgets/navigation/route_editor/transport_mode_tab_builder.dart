import 'package:flutter/material.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../../../l10n/generated/dgis_localizations_en.dart';
import './brief_info_provider.dart';
import './route_editor_controller.dart';
import './route_editor_theme.dart';
import 'transport_mode.dart';

abstract class TransportModeTabBuilder {
  Widget build(
    TransportMode transportType,
    RouteEditorController controller,
    RouteTabTheme theme,
  );
}

class DefaultTransportModeTabBuilder implements TransportModeTabBuilder {
  const DefaultTransportModeTabBuilder();

  @override
  Widget build(
    TransportMode transportType,
    RouteEditorController controller,
    RouteTabTheme theme,
  ) {
    return _DefaultTransportModeTab(
      transportType: transportType,
      controller: controller,
      theme: theme,
    );
  }
}

class _DefaultTransportModeTab extends StatelessWidget {
  final TransportMode transportType;
  final RouteEditorController controller;
  final RouteTabTheme theme;

  const _DefaultTransportModeTab({
    required this.transportType,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return ValueListenableBuilder<TransportMode?>(
      valueListenable: controller.activeTransportMode,
      builder: (context, activeType, _) {
        final isActive = activeType == transportType;
        final icon = transportType.toIcon();

        return ValueListenableBuilder<Map<TransportMode, BriefInfo?>>(
          valueListenable: controller.briefInfoProvider,
          builder: (context, briefInfoMap, _) {
            final briefInfo = briefInfoMap[transportType];

            return GestureDetector(
              onTap: () {
                controller.setActiveTransportMode(transportType);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.activeBackgroundColor
                      : theme.inactiveBackgroundColor,
                  border: Border.all(
                    color:
                        isActive ? theme.activeBorderColor : Colors.transparent,
                    width: theme.activeBorderWidth,
                  ),
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                  boxShadow: isActive ? theme.activeShadow : null,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 24,
                      child: OverflowBox(
                        maxHeight: 24,
                        maxWidth: 24,
                        child: Icon(
                          icon,
                          size: 24,
                          color: isActive
                              ? theme.activeIconColor
                              : theme.inactiveIconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTimeText(briefInfo, isActive, localizations),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(
    Duration duration,
    DgisLocalizations localizations,
  ) {
    final minutes = duration.inMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours';
      }
      return '${hours}h $remainingMinutes';
    }
    return '$minutes';
  }

  Widget _buildTimeText(
    BriefInfo? briefInfo,
    bool isActive,
    DgisLocalizations localizations,
  ) {
    if (briefInfo == null) {
      return Text(
        '...',
        style: isActive ? theme.activeTextStyle : theme.inactiveTextStyle,
      );
    }

    final timeValue = _formatDuration(briefInfo.duration, localizations);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timeValue,
          style: isActive ? theme.activeTextStyle : theme.inactiveTextStyle,
        ),
        const SizedBox(width: 2),
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(
            localizations
                .dgis_min__minutes_format(0)
                .replaceAll('0', '')
                .trim(),
            style: isActive
                ? theme.activeUnitTextStyle
                : theme.inactiveUnitTextStyle,
          ),
        ),
      ],
    );
  }
}
