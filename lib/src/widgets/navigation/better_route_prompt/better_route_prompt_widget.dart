import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import './better_route_prompt_controller.dart';
import './better_route_prompt_model.dart';
import './better_route_prompt_theme.dart';

class BetterRoutePromptWidget
    extends ThemedMapControllingWidget<BetterRoutePromptTheme> {
  final BetterRoutePromptController controller;
  final Duration promptDuration;

  const BetterRoutePromptWidget({
    required this.controller,
    required this.promptDuration,
    super.key,
    BetterRoutePromptTheme? light,
    BetterRoutePromptTheme? dark,
  }) : super(
         dark: dark ?? BetterRoutePromptTheme.defaultDark,
         light: light ?? BetterRoutePromptTheme.defaultLight,
       );

  @override
  ThemedMapControllingWidgetState<
    BetterRoutePromptWidget,
    BetterRoutePromptTheme
  >
  createState() => _BetterRoutePromptWidgetState();

  // ignore: prefer_constructors_over_static_methods
  static BetterRoutePromptWidget defaultBuilder(
    BetterRoutePromptController controller,
    Duration propmtDuration,
  ) => BetterRoutePromptWidget(
    controller: controller,
    promptDuration: propmtDuration,
  );
}

class _BetterRoutePromptWidgetState
    extends
        ThemedMapControllingWidgetState<
          BetterRoutePromptWidget,
          BetterRoutePromptTheme
        >
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.promptDuration,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_progressController);

    _progressController
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.controller.timeoutBetterRoutePrompt();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  String _getRouteText(
    BetterRouteType type,
    int? minutes,
    DgisLocalizations localizations,
  ) {
    return switch (type) {
      BetterRouteType.winnigTime =>
        localizations.dgis_navi_better_route_found_with_time(
          minutes != null ? minutes.abs() : 0,
        ),
      BetterRouteType.losingTime =>
        localizations.dgis_navi_longer_route_found_with_time(
          minutes != null ? minutes.abs() : 0,
        ),
      BetterRouteType.sameTime => localizations.dgis_navi_route_found_same_time,
      BetterRouteType.unspecified =>
        localizations.dgis_navi_better_route_found_without_time,
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    return ValueListenableBuilder(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        return SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                flex: 27,
                child: GestureDetector(
                  onTap: widget.controller.acceptBetterRoute,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.acceptButtonColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.progressBarColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: _progressAnimation.value,
                              child: child,
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 10,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: colorScheme
                                      .acceptButtonIconColorBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'packages/$pluginName/assets/icons/navigation/dgis_best_route.svg',
                                  colorFilter: ColorFilter.mode(
                                    colorScheme.acceptButtonIconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: Text(
                                _getRouteText(
                                  state.type,
                                  state.timeWinning,
                                  localizations,
                                ),
                                style: colorScheme.acceptButtonTextStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 10,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.controller.rejectBetterRoute,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.denyButtonColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        localizations.dgis_navi_better_route_cancel,
                        style: colorScheme.denyButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}
}
