import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../../map/themed_map_controlling_widget.dart';
import '../../map/themed_map_controlling_widget_state.dart';
import '../navigation_layout_widget.dart';
import './dashboard_controller.dart';
import './dashboard_model.dart';
import './dashboard_theme.dart';

/// A widget that displays navigation information and controls during active navigation.
///
/// This widget shows:
/// * Remaining distance to destination
/// * Estimated travel time
/// * Estimated time of arrival
///
/// When expanded, it provides additional features:
/// * Sound settings toggle for navigation instructions
/// * Route overview button
/// * Navigation end button
///
/// The widget requires:
/// * [controller] - A [DashboardController] instance to manage state and actions
/// * [onHeaderChangeSize] - Callback to handle header size changes for layout adjustments
/// This callback is used by [NavigationLayoutWidget] to measure height of dashboard
/// and layout other widgets accordingly to it. This callback is always provided in builder of
/// [NavigationLayoutWidget] and should be called with [Offset] of upmost point of this widget.
///
/// Optionally accepts:
/// * [onFinishClicked] - Custom callback invoked when user finishes route by clicking on button.
/// Default is to call controller.stopNavigation().
/// * [light]/[dark] - Custom theme configurations
///
/// Usage example:
/// ```dart
/// DashboardWidget(
///   controller: dashboardController,
///   onHeaderChangeSize: (offset) {
///     // Handle header size change
///   },
///   onFinishClicked: () {
///     // Custom navigation end handling
///   },
/// )
/// ```
///
/// This widget is typically created automatically by [NavigationLayoutWidget]
/// through its builder pattern, but can also be used independently or extended
/// for custom navigation interfaces.
///
/// See also:
/// * [DashboardController] - The controller managing this widget's state
/// * [DashboardWidgetTheme] - Theme configuration for this widget
/// * [NavigationLayoutWidget] - Parent widget that manages navigation layout
class DashboardWidget extends ThemedMapControllingWidget<DashboardWidgetTheme> {
  final DashboardController controller;
  final Function(Offset) onHeaderChangeSize;
  final Function()? onFinishClicked;

  const DashboardWidget({
    required this.controller,
    required this.onHeaderChangeSize,
    this.onFinishClicked,
    super.key,
    DashboardWidgetTheme? light,
    DashboardWidgetTheme? dark,
  }) : super(
          light: light ?? DashboardWidgetTheme.defaultLight,
          dark: dark ?? DashboardWidgetTheme.defaultDark,
        );

  // ignore: prefer_constructors_over_static_methods
  static DashboardWidget defaultBuilder(
    DashboardController controller,
    Function(Offset) onHeaderChangeSize,
  ) =>
      DashboardWidget(
        controller: controller,
        onHeaderChangeSize: onHeaderChangeSize,
      );
  @override
  ThemedMapControllingWidgetState<DashboardWidget, DashboardWidgetTheme>
      createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends ThemedMapControllingWidgetState<
    DashboardWidget, DashboardWidgetTheme> with SingleTickerProviderStateMixin {
  final headerGlobalKey = GlobalKey();
  final fullHeightHeaderFlobalKey = GlobalKey();

  final OverlayPortalController _overlayController = OverlayPortalController();

  double _dragStartY = 0;
  bool _isDragging = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final _dateFormat = DateFormat('HH:mm');
  final double _headerSize = 60;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final box =
            headerGlobalKey.currentContext?.findRenderObject() as RenderBox?;
        final position = box?.localToGlobal(Offset.zero);

        if (position != null) {
          widget.onHeaderChangeSize.call(position);
        }
      }
    });

    super.initState();
  }

  void _toggleOverlay() {
    setState(() {
      if (_overlayController.isShowing) {
        _animationController.reverse().then((_) {
          _overlayController.hide();
        });
      } else {
        _overlayController.show();
        _animationController.forward();
      }
    });
  }

  @override
  void onAttachedToMap(sdk.Map map) {}

  @override
  void onDetachedFromMap() {}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildHeader(
    BuildContext context,
    BorderRadius borderRadius,
    DgisLocalizations localizations,
    Key key,
    DashboardModel model,
  ) {
    final distance = widget.controller.formatDistance(localizations);
    final duration = widget.controller.formatDuration(localizations);
    final arrivalTime = widget.controller.formatArrivalTime(_dateFormat);

    return GestureDetector(
      onVerticalDragStart: (details) {
        _isDragging = true;
        _dragStartY = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        if (!_isDragging) return;

        final delta = _dragStartY - details.globalPosition.dy;
        final screenHeight = MediaQuery.of(context).size.height * 0.35;

        final dragPercent = (delta / screenHeight).clamp(-1.0, 1.0);

        if (_overlayController.isShowing) {
          if (dragPercent < 0) {
            _animationController.value = 1.0 + dragPercent;
          }
        } else {
          if (dragPercent > 0) {
            _animationController.value = dragPercent;
          }
          if (dragPercent > 0.3) {
            final velocity = details.primaryDelta?.abs() ?? 0;
            final duration =
                velocity > 0 ? (2000 / velocity).clamp(30, 1000).toInt() : 300;
            _isDragging = false; // Stop processing drag
            _overlayController.show();
            _animationController.animateTo(
              1,
              duration: Duration(milliseconds: duration),
              curve: Curves.easeOut,
            );
          }
        }
      },
      onVerticalDragEnd: (details) {
        _isDragging = false;

        final velocity = details.primaryVelocity ?? 0;
        const velocityThreshold = 300.0;

        setState(() {
          if (velocity.abs() > velocityThreshold) {
            if (velocity > 0) {
              _animationController.reverse().then((_) {
                _overlayController.hide();
              });
            } else {
              _overlayController.show();
              _animationController.forward();
            }
          } else {
            if (_animationController.value > 0.5) {
              _overlayController.show();
              _animationController.forward();
            } else {
              _animationController.reverse().then((_) {
                _overlayController.hide();
              });
            }
          }
        });
      },
      child: Container(
        height: _headerSize,
        key: key,
        decoration: BoxDecoration(
          color: colorScheme.surfaceColor,
          boxShadow: colorScheme.shadows,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        child: Row(
          children: [
            SizedBox(
              width: colorScheme.buttonSize,
              height: colorScheme.buttonSize,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      duration.value,
                      style: colorScheme.valueTextStyle,
                    ),
                    Text(
                      duration.unit,
                      style: colorScheme.unitTextStyle,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 12,
                ),
                Column(
                  children: [
                    Text(
                      arrivalTime,
                      style: colorScheme.valueTextStyle,
                    ),
                    Text(
                      localizations.dgis_navi_arrival,
                      style: colorScheme.unitTextStyle,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 12,
                ),
                Column(
                  children: [
                    Text(
                      distance.value,
                      style: colorScheme.valueTextStyle,
                    ),
                    Text(
                      distance.unit,
                      style: colorScheme.unitTextStyle,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleOverlay,
              child: Container(
                width: colorScheme.buttonSize,
                height: colorScheme.buttonSize,
                decoration: BoxDecoration(
                  color: colorScheme.buttonSurfaceColor,
                  borderRadius: BorderRadius.circular(
                    colorScheme.buttonBorderRadius,
                  ),
                ),
                child: SvgPicture.asset(
                  'packages/$pluginName/assets/icons/navigation/dgis_menu.svg',
                  fit: BoxFit.none,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    colorScheme.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    DgisLocalizations localizations,
    DashboardModel model,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildHeader(
          context,
          BorderRadius.only(
            topLeft: Radius.circular(colorScheme.borderRadius),
            topRight: Radius.circular(colorScheme.borderRadius),
          ),
          localizations,
          fullHeightHeaderFlobalKey,
          model,
        ),
        ColoredBox(
          color: colorScheme.surfaceColor,
          child: Column(
            children: [
              Divider(
                color: colorScheme.buttonSurfaceColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: GestureDetector(
                  onTap: widget.controller.toggleSounds,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.buttonSurfaceColor,
                      borderRadius: BorderRadius.circular(
                        colorScheme.buttonBorderRadius,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.dgis_navi_sound_settings_title,
                              style: colorScheme.menuButtonTextStyle,
                            ),
                            Text(
                              model.soundsEnabled
                                  ? localizations
                                      .dgis_navi_sound_settings_subtitle_on
                                  : localizations
                                      .dgis_navi_sound_settings_subtitle_off,
                              style: colorScheme.menuButtonSubTextStyle,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: model.soundsEnabled
                                ? colorScheme.buttonPositiveSurfaceColor
                                : colorScheme.buttonNegativeSurfaceColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: SvgPicture.asset(
                            'packages/$pluginName/assets/icons/navigation/dgis_sound.svg',
                            fit: BoxFit.none,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              colorScheme.soundIconColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: GestureDetector(
                  onTap: widget.controller.showRoute,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.buttonSurfaceColor,
                      borderRadius: BorderRadius.circular(
                        colorScheme.buttonBorderRadius,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'packages/$pluginName/assets/icons/navigation/dgis_route.svg',
                          fit: BoxFit.none,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            colorScheme.iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          localizations.dgis_navi_view_route,
                          style: colorScheme.menuButtonTextStyle,
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          'packages/$pluginName/assets/icons/navigation/dgis_chevron.svg',
                          fit: BoxFit.none,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            colorScheme.iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: widget.onFinishClicked ??
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
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _toggleOverlay,
                child: Container(
                  color: colorScheme.expandedShadowColor,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ValueListenableBuilder(
                    valueListenable: widget.controller.state,
                    builder: (context, value, _) {
                      return _buildFull(context, localizations, value);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -1),
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation),
                child: child,
              ),
            );
          },
          child: ValueListenableBuilder(
            valueListenable: widget.controller.state,
            builder: (context, value, _) {
              return _buildHeader(
                context,
                BorderRadius.all(Radius.circular(colorScheme.borderRadius)),
                localizations,
                headerGlobalKey,
                value,
              );
            },
          ),
        ),
      ),
    );
  }
}
