import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../common/formatted_measure.dart';
import '../../common/measure_size.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import './maneuver_controller.dart';
import './maneuver_model.dart';
import './maneuver_theme.dart';

class ManeuverWidget extends ThemedMapControllingWidget<ManeuverWidgetTheme> {
  final ManeuverController controller;

  const ManeuverWidget({
    required this.controller,
    ManeuverWidgetTheme? light,
    ManeuverWidgetTheme? dark,
    super.key,
  }) : super(
          light: light ?? ManeuverWidgetTheme.defaultLight,
          dark: dark ?? ManeuverWidgetTheme.defaultDark,
        );

  // ignore: prefer_constructors_over_static_methods
  static ManeuverWidget defaultBuilder(ManeuverController controller) =>
      ManeuverWidget(
        controller: controller,
      );
  @override
  ThemedMapControllingWidgetState<ManeuverWidget, ManeuverWidgetTheme>
      createState() => _ManeuverWidgetState();
}

class _ManeuverWidgetState extends ThemedMapControllingWidgetState<
    ManeuverWidget, ManeuverWidgetTheme> {
  final ValueNotifier<double> _mainManeuverHeight = ValueNotifier(0);

  @override
  void onAttachedToMap(sdk.Map map) {}

  Widget _additionalManeuverWidget(
    AdditionalManeuverModel model,
    DgisLocalizations localizations,
  ) {
    return switch (model) {
      ManeuverWithIcon() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.dgis_navi_maneuver_next,
              style: colorScheme.additionalManeuverTheme.textStyle,
            ),
            const Spacer(),
            if (model.icon != null)
              Transform.scale(
                scaleX: model.icon!.$2 ? -1 : 1,
                child: SvgPicture.asset(
                  model.icon!.$1,
                  width: colorScheme.additionalManeuverTheme.iconSize.width,
                  height: colorScheme.additionalManeuverTheme.iconSize.height,
                ),
              ),
            const Spacer(),
          ],
        ),
      ExitName() => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            model.exitName,
            style: colorScheme.additionalManeuverTheme.textStyle,
          ),
        ),
      ExitNumber() => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            localizations.dgis_navi_maneuver_exit_number(model.exitNumber),
            style: colorScheme.additionalManeuverTheme.textStyle,
          ),
        )
    };
  }

  @override
  void onDetachedFromMap() {}

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    return ValueListenableBuilder(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        final maneuverDistance = state.maneuverDistance;
        final maneuverIcon = state.maneuverIcon;
        final roadName = state.roadName;
        final additionalManeuver = state.additionalManeuver;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Additional maneuver (bottom)
            if (additionalManeuver != null)
              ValueListenableBuilder(
                valueListenable: _mainManeuverHeight,
                child: Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: _additionalManeuverWidget(
                    additionalManeuver,
                    localizations,
                  ),
                ),
                builder: (context, height, child) {
                  final additionaManeuverHeight = height +
                      colorScheme.additionalManeuverTheme.containerHeight;
                  return Container(
                    constraints: BoxConstraints(
                      minHeight: additionaManeuverHeight,
                      maxWidth: 107,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.additionalManeuverTheme.surfaceColor,
                      boxShadow: colorScheme.additionalManeuverTheme.shadows,
                      borderRadius: BorderRadius.circular(
                        colorScheme
                            .additionalManeuverTheme.containerBorderRadius,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: child,
                  );
                },
              ),

            // Main maneuver (top)
            MeasureSize(
              onChange: (size) {
                _mainManeuverHeight.value = size.height;
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: colorScheme.mainManeuverTheme.maxWidth,
                  minWidth: colorScheme.mainManeuverTheme.minWidth,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.mainManeuverTheme.surfaceColor,
                  boxShadow: colorScheme.mainManeuverTheme.shadows,
                  borderRadius: BorderRadius.circular(
                    colorScheme.mainManeuverTheme.borderRadius,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (maneuverIcon != null)
                          Transform.scale(
                            scaleX: maneuverIcon.$2 ? -1 : 1,
                            child: SvgPicture.asset(
                              maneuverIcon.$1,
                              fit: BoxFit.scaleDown,
                              width: colorScheme.mainManeuverTheme.iconSize,
                              height: colorScheme.mainManeuverTheme.iconSize,
                            ),
                          )
                        else
                          SizedBox(
                            width: colorScheme.mainManeuverTheme.iconSize,
                            height: colorScheme.mainManeuverTheme.iconSize,
                          ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (maneuverDistance != null)
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: metersToFormattedMeasure(
                                          maneuverDistance,
                                          localizations,
                                        ).value,
                                        style: colorScheme.mainManeuverTheme
                                            .maneuverDistanceTextStyle,
                                      ),
                                      TextSpan(
                                        text: metersToFormattedMeasure(
                                          maneuverDistance,
                                          localizations,
                                        ).unit,
                                        style: colorScheme.mainManeuverTheme
                                            .maneuverDistanceUnitTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (roadName != null && roadName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final words = roadName.split(' ');
                              final firstWord = words.first;
                              final remainingWords = words.skip(1).join(' ');

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstWord,
                                    style: colorScheme
                                        .mainManeuverTheme.roadNameTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (remainingWords.isNotEmpty)
                                    Text(
                                      remainingWords,
                                      style: colorScheme
                                          .mainManeuverTheme.roadNameTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
