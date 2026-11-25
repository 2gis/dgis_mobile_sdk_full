import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../l10n/generated/dgis_localizations.dart';
import '../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import './finish_route_controller.dart';
import './finish_route_theme.dart';

class FinishRouteWidget
    extends ThemedMapControllingWidget<FinishRouteWidgetTheme> {
  final FinishRouteController controller;
  final VoidCallback? onFinishClicked;
  final bool shouldShowParkingButton;
  const FinishRouteWidget({
    required this.controller,
    this.onFinishClicked,
    this.shouldShowParkingButton = true,
    FinishRouteWidgetTheme? light,
    FinishRouteWidgetTheme? dark,
    super.key,
  }) : super(
         dark: dark ?? FinishRouteWidgetTheme.defaultDark,
         light: light ?? FinishRouteWidgetTheme.defaultLight,
       );

  // ignore: prefer_constructors_over_static_methods
  static FinishRouteWidget defaultBuilder(FinishRouteController controller) =>
      FinishRouteWidget(controller: controller);

  @override
  ThemedMapControllingWidgetState<FinishRouteWidget, FinishRouteWidgetTheme>
  createState() => _FinishRouteWidgetState();
}

class _FinishRouteWidgetState
    extends
        ThemedMapControllingWidgetState<
          FinishRouteWidget,
          FinishRouteWidgetTheme
        >
    with SingleTickerProviderStateMixin {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  final contentKey = GlobalKey();

  final minExtendedSize = .1;
  double maxExtendedSize = .36;

  final _animationDuration = const Duration(milliseconds: 300);

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkIfExpanded);

    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _animation =
        Tween<double>(
          begin: minExtendedSize,
          end: maxExtendedSize,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );

    _animation.addListener(() {
      _controller.jumpTo(_animation.value);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureContent();
      _animationController.forward();
    });
  }

  void _checkIfExpanded() {
    isExpanded.value = _controller.size == maxExtendedSize;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_checkIfExpanded)
      ..dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _measureContent() {
    final renderBox =
        contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final contentHeight = renderBox.size.height;
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        maxExtendedSize = (contentHeight / screenHeight).clamp(
          minExtendedSize,
          0.9,
        );

        _animation =
            Tween<double>(
              begin: minExtendedSize,
              end: maxExtendedSize,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: minExtendedSize,
      minChildSize: minExtendedSize,
      maxChildSize: maxExtendedSize,
      snap: true,
      snapSizes: [minExtendedSize, maxExtendedSize],
      builder: (context, scrollController) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: scrollController,
        child: Column(
          key: contentKey,
          children: [
            Container(
              height: 145,
              decoration: BoxDecoration(
                color: colorScheme.surfaceColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(colorScheme.borderRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  localizations.dgis_navi_finish,
                                  style: colorScheme.arrivalPhraseTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isExpanded,
                          builder: (context, isExpanded, _) => AnimatedSwitcher(
                            duration: _animationDuration,
                            child: isExpanded
                                ? SvgPicture.asset(
                                    'packages/$pluginName/assets/icons/navigation/dgis_finish_flag.svg',
                                    width: colorScheme.iconSize.width,
                                    height: colorScheme.iconSize.height,
                                  )
                                : SizedBox.fromSize(
                                    size: colorScheme.iconSize,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: isExpanded,
                      builder: (context, isExpanded, _) {
                        return AnimatedSwitcher(
                          reverseDuration: _animationDuration,
                          duration: _animationDuration,
                          child: isExpanded && widget.shouldShowParkingButton
                              ? GestureDetector(
                                  onTap: widget
                                      .controller
                                      .toggleParkingsVisibility,
                                  child: ValueListenableBuilder(
                                    valueListenable: widget.controller.state,
                                    builder: (context, state, _) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: state.isParkingEnabled
                                              ? colorScheme
                                                    .activeButtonSurfaceColor
                                              : colorScheme
                                                    .inactiveButtonSurfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              'packages/$pluginName/assets/icons/dgis_parking.svg',
                                              colorFilter: ColorFilter.mode(
                                                state.isParkingEnabled
                                                    ? colorScheme
                                                          .activeIconColor
                                                    : colorScheme
                                                          .inactiveIconColor,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            Text(
                                              localizations.dgis_navi_parking,
                                              style: state.isParkingEnabled
                                                  ? colorScheme
                                                        .activeButtonsTextStyle
                                                  : colorScheme
                                                        .inactiveButtonsTextStyle,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: colorScheme.surfaceColorSecondary,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 42,
                  left: 24,
                  right: 24,
                  top: 8,
                ),
                child: GestureDetector(
                  onTap:
                      widget.onFinishClicked ??
                      widget.controller.stopNavigation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.buttonNegativeSurfaceColor,
                      borderRadius: BorderRadius.circular(
                        colorScheme.buttonBorderRadius,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Center(
                      child: Text(
                        localizations.dgis_navi_end_the_trip,
                        style: colorScheme.finishButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}
}
