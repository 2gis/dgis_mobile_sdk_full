import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import '../settings/navigation_settings_options.dart';
import '../settings/settings_flow.dart';
import './route_card_builder.dart';
import './route_editor_controller.dart';
import './route_editor_theme.dart';
import './route_list_widget.dart';
import './route_point_ui.dart';
import './route_search_point_builder.dart';
import 'transport_mode.dart';
import 'transport_mode_tab_builder.dart';

/// Widget for displaying and managing route editing interface as a fullscreen overlay.
///
/// This widget provides a complete UI for route editing including:
/// * Route points display (start and finish)
/// * Routes list with horizontal/vertical modes
/// * Transport type selection tabs
/// * Expandable/collapsible panel with snapping
/// * Navigation start and close actions
class RouteEditorWidget extends StatefulWidget {
  /// Controller for managing route editor state and actions.
  final RouteEditorController controller;

  /// {@macro navigation_settings_options}
  final NavigationSettingsOptions? navigationSettings;

  /// Callback invoked when the user starts navigation with a route.
  final void Function(sdk.TrafficRoute route)? onStartNavigation;

  /// Callback invoked when layout mounted.
  final void Function(double height)? onInitLayout;

  /// Callback invoked when the user closes the route editor.
  final VoidCallback? onClose;

  /// Callback invoked when the user swaps route points.
  final VoidCallback? onSwapCallback;

  /// Callback invoked when the panel is collapsed with its height.
  ///
  /// This callback is also called once during widget initialization
  /// to provide the initial collapsed height.
  final void Function(double height)? onCollapsed;

  /// Callback invoked when the panel is in mid height.
  final void Function(double height)? onMidCollapsed;

  /// Callback invoked when the panel is expanded with its height.
  final void Function(double height)? onExpanded;

  /// Callback invoked whenever the screen-edge insets occupied by the panel
  /// change.
  ///
  /// The panel reserves space at the bottom in portrait and at the start edge
  /// in landscape. Consumers can apply these insets to keep overlay controls
  /// and map camera framing clear of the panel without having to know the
  /// current orientation or the panel's size themselves. Also called once
  /// during initialization.
  final void Function(EdgeInsets insets)? onReservedInsetsChanged;

  /// Builder for route search point views.
  final RouteSearchPointBuilder routeSearchPointBuilder;

  /// Builder for route cards.
  final RouteCardBuilder routeCardBuilder;

  /// Builder for transport type selection tabs.
  final TransportModeTabBuilder transportTypeTabBuilder;

  /// Theme for the route editor widget.
  final RouteEditorViewTheme theme;

  /// Padding from the top of the container when expanded.
  final double topPadding;

  const RouteEditorWidget({
    required this.controller,
    required this.theme,
    this.navigationSettings,
    this.onStartNavigation,
    this.onInitLayout,
    this.onClose,
    this.onSwapCallback,
    this.onCollapsed,
    this.onMidCollapsed,
    this.onExpanded,
    this.onReservedInsetsChanged,
    this.topPadding = 8,
    RouteSearchPointBuilder? routeSearchPointBuilder,
    RouteCardBuilder? routeCardBuilder,
    TransportModeTabBuilder? transportTypeTabBuilder,
    super.key,
  }) : routeSearchPointBuilder =
           routeSearchPointBuilder ?? const DefaultRouteSearchPointBuilder(),
       routeCardBuilder = routeCardBuilder ?? const DefaultRouteCardBuilder(),
       transportTypeTabBuilder =
           transportTypeTabBuilder ?? const DefaultTransportModeTabBuilder();

  @override
  State<RouteEditorWidget> createState() => _RouteEditorWidgetState();
}

class _RouteEditorWidgetState extends State<RouteEditorWidget>
    with SingleTickerProviderStateMixin {
  final ScrollController _tabScrollController = ScrollController();
  final ScrollController _routesVerticalController = ScrollController();
  final Map<TransportMode, GlobalKey> _tabKeys = {};
  final GlobalKey<RouteListWidgetState> _routeListKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();

  late AnimationController _expandController;

  StreamSubscription<sdk.RouteIndex?>? _activeRouteIndexSubscription;

  /// Minimum snap height
  double _minHeight = 0;

  /// Middle snap height
  double _midHeight = 0;

  /// Maximum snap height
  double _maxHeight = 0;

  double _containerHeight = 0;
  double _headerHeight = 0;

  bool _isLandscape = false;

  /// Left snap padding
  double _startInset = 0;
  EdgeInsets _reportedInsets = EdgeInsets.zero;
  double _dragStartPosition = 0;
  double _dragStartProgress = 0;
  bool _isDragging = false;
  bool _prevIsLandscapeState = false;

  static const _parametersBoxHeight = 68.0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandController.addListener(_onExpandProgressChanged);

    _routesVerticalController.addListener(_verticalScrollListener);

    widget.controller.activeTransportMode.addListener(
      _onActiveTransportModeChanged,
    );

    widget.controller.routePoints.addListener(_onRoutePointsChanged);

    _initActiveRouteIndexSubscription();

    _onTransportModesChanged();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeights();
      widget.onCollapsed?.call(_minHeight);
      widget.onInitLayout?.call(_minHeight);

      // Even after the first frame has been mounted, there is still no way to
      // collapse the shap. So we need [Future.delayed] to wait
      Future.delayed(Duration.zero, () {
        if (!mounted) return;

        _animateToProgress(_isLandscape ? 1 : _midProgress);
      });
    });
  }

  void _verticalScrollListener() {
    if (!_routesVerticalController.hasClients ||
        _isLandscape ||
        _expandController.isAnimating) {
      return;
    }

    // When user overclocks, the current snap is collapsed to the
    // middle position. In this case, it's triggered after 15 pixels
    final position = _routesVerticalController.position;
    if (position.pixels < position.minScrollExtent) {
      final pullDistance = position.minScrollExtent - position.pixels;
      if (pullDistance > 15) _animateToProgress(_midProgress);
    }
  }

  void _measureComponents() {
    final headerBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;

    if (headerBox != null) {
      _headerHeight = headerBox.size.height;
    }
  }

  void _calculateHeights() {
    _measureComponents();

    final theme = widget.theme;
    final mediaQuery = MediaQuery.of(context);
    final bottomSafeArea = mediaQuery.padding.bottom;

    // Destination height
    _minHeight =
        theme.handleHeight +
        _headerHeight +
        _parametersBoxHeight +
        theme.routeListVerticalPadding +
        theme.tabBarHeight +
        theme.bottomPadding +
        bottomSafeArea;

    // Route card height
    _midHeight =
        theme.handleHeight +
        _headerHeight +
        _parametersBoxHeight +
        theme.routeListVerticalPadding * 2 +
        theme.routeListHeight +
        theme.tabBarHeight +
        theme.bottomPadding +
        bottomSafeArea;

    // Max height
    if (_containerHeight > 0) {
      _maxHeight = _containerHeight - widget.topPadding;
    }
  }

  /// Route card height
  double get _midProgress {
    if (_maxHeight <= _minHeight) return 0.5;

    return ((_midHeight - _minHeight) / (_maxHeight - _minHeight)).clamp(
      0.0,
      1.0,
    );
  }

  double get _routesListExpandProgress {
    final mid = _midProgress;
    final current = _expandController.value;
    if (current <= mid || mid >= 1.0) return 0;

    return ((current - mid) / (1.0 - mid)).clamp(0.0, 1.0);
  }

  double get _currentHeight {
    if (_minHeight == 0) _calculateHeights();

    if (_maxHeight == 0) return _minHeight;

    // Checking current height
    return _minHeight + (_maxHeight - _minHeight) * _expandController.value;
  }

  /// Reports the screen-edge insets the panel occupies, reserving space at the
  /// start edge in landscape and at the bottom in portrait. Uses the collapsed
  /// height so the reservation stays stable while the panel is expanded.
  void _reportReservedInsets(double panelWidth) {
    final insets = _isLandscape
        ? EdgeInsets.only(left: _startInset + panelWidth)
        : EdgeInsets.only(bottom: _minHeight + _parametersBoxHeight);
    if (insets != _reportedInsets) {
      _reportedInsets = insets;
      widget.onReservedInsetsChanged?.call(insets);
    }
  }

  @override
  void didUpdateWidget(RouteEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.activeTransportMode.removeListener(
        _onActiveTransportModeChanged,
      );
      oldWidget.controller.routePoints.removeListener(_onRoutePointsChanged);

      widget.controller.activeTransportMode.addListener(
        _onActiveTransportModeChanged,
      );
      widget.controller.routePoints.addListener(_onRoutePointsChanged);

      _onTransportModesChanged();

      _initActiveRouteIndexSubscription();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _calculateHeights();
        widget.onCollapsed?.call(_minHeight);
      });
    }

    _calculateHeights();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _calculateHeights();
    });
  }

  @override
  void dispose() {
    widget.controller.activeTransportMode.removeListener(
      _onActiveTransportModeChanged,
    );
    widget.controller.routePoints.removeListener(_onRoutePointsChanged);
    _activeRouteIndexSubscription?.cancel();
    _activeRouteIndexSubscription = null;
    _expandController
      ..removeListener(_onExpandProgressChanged)
      ..dispose();
    _tabScrollController.dispose();
    _routesVerticalController.removeListener(_verticalScrollListener);
    _routesVerticalController.dispose();
    super.dispose();
  }

  void _initActiveRouteIndexSubscription() {
    _activeRouteIndexSubscription?.cancel();
    _activeRouteIndexSubscription = null;

    _activeRouteIndexSubscription = widget
        .controller
        .routeEditor
        .activeRouteIndexChannel
        .listen(_onActiveRouteIndexChanged);
  }

  void _onExpandProgressChanged() {
    setState(() {});
  }

  void _onRoutePointsChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final previousCollapsedHeight = _minHeight;
      _calculateHeights();
      if (previousCollapsedHeight != _minHeight) {
        setState(() {});
        widget.onCollapsed?.call(_minHeight);
      }

      _onTransportModesChanged();
    });
  }

  void _onTransportModesChanged() {
    for (final type in widget.controller.availableTransportModes) {
      _tabKeys.putIfAbsent(type, GlobalKey.new);
    }
  }

  void _onActiveTransportModeChanged() {
    final activeType = widget.controller.activeTransportMode.value;
    if (activeType == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter(activeType);
    });
  }

  void _scrollToCenter(TransportMode activeType) {
    if (!_tabScrollController.hasClients) return;

    final itemContext = _tabKeys[activeType]?.currentContext;
    if (itemContext == null) return;

    final renderBox = itemContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final itemPosition = renderBox.localToGlobal(Offset.zero);
    final itemWidth = renderBox.size.width;
    final screenWidth = MediaQuery.of(context).size.width;

    final currentScrollOffset = _tabScrollController.offset;
    final itemCenter = itemPosition.dx + (itemWidth / 2);
    final panelWidth = _isLandscape ? screenWidth / 2.5 : screenWidth;
    final panelCenter = _startInset + (panelWidth / 2);
    final targetScrollOffset = currentScrollOffset + (itemCenter - panelCenter);

    _tabScrollController.animateTo(
      targetScrollOffset.clamp(
        0.0,
        _tabScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onActiveRouteIndexChanged(sdk.RouteIndex? routeIndex) {
    if (routeIndex == null) return;

    Future.microtask(() {
      if (mounted) _scrollToActiveCard(index: routeIndex.value);
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (_isLandscape) return;

    _isDragging = true;
    _dragStartPosition = details.globalPosition.dy;
    _dragStartProgress = _expandController.value;
    _expandController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _isLandscape || _maxHeight == _minHeight) return;

    final dragDelta = _dragStartPosition - details.globalPosition.dy;
    final totalDragRange = _maxHeight - _minHeight;
    final progressDelta = dragDelta / totalDragRange;
    final newProgress = (_dragStartProgress + progressDelta).clamp(0.0, 1.0);

    _expandController.value = newProgress;
  }

  void _snapToNearestState(double velocity) {
    final currentProgress = _expandController.value;
    final midProgress = _midProgress;
    double targetProgress;

    if (velocity.abs() > 500) {
      if (velocity < 0) {
        targetProgress = currentProgress < midProgress ? midProgress : 1.0;
      } else {
        targetProgress = currentProgress > midProgress ? midProgress : 0.0;
      }
    } else {
      final distToMin = currentProgress;
      final distToMid = (currentProgress - midProgress).abs();
      final distToMax = 1.0 - currentProgress;

      if (distToMin <= distToMid && distToMin <= distToMax) {
        targetProgress = 0.0;
      } else if (distToMid <= distToMin && distToMid <= distToMax) {
        targetProgress = midProgress;
      } else {
        targetProgress = 1.0;
      }
    }

    _animateToProgress(targetProgress);
  }

  Future<void> _animateToProgress(
    double targetProgress, {
    bool scrollToActiveCard = false,
  }) async {
    await _expandController.animateTo(
      targetProgress,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (!mounted) return;

    if (targetProgress < 1.0 && _routesVerticalController.hasClients) {
      _routesVerticalController.jumpTo(0);
    }

    if (targetProgress == 0.0) {
      widget.onCollapsed?.call(_minHeight);
    } else if (targetProgress == _midProgress) {
      widget.onMidCollapsed?.call(_midHeight);
    } else if (targetProgress == 1.0) {
      widget.onExpanded?.call(_maxHeight);
    }

    if (scrollToActiveCard) _scrollToActiveCard();
  }

  void _scrollToActiveCard({int? index}) {
    final activeIndex =
        index ??
        widget.controller.routeEditor.activeRouteIndexChannel.value?.value;
    if (activeIndex != null) {
      _routeListKey.currentState?.scrollToRouteCard(activeIndex);
    }
  }

  void _expand() => _animateToProgress(1);

  void _collapse({bool scrollToActiveCard = false}) =>
      _animateToProgress(0, scrollToActiveCard: scrollToActiveCard);

  void _onDragEnd(DragEndDetails details) {
    if (_isLandscape) return;

    _isDragging = false;
    _snapToNearestState(details.velocity.pixelsPerSecond.dy);
  }

  void _onRouteTapped(int index) {
    if (_expandController.value == 1 && !_isLandscape) {
      _animateToProgress(_midProgress, scrollToActiveCard: true);
    }
  }

  double get _parametersButtonProgress {
    final mid = _midProgress;
    // If the midpoint is equal to the maximum or incorrect, the button is
    // visible in its initial state.
    if (mid >= 1.0 || mid <= 0.0) return 1;

    final current = _expandController.value;

    // If the snap is located between minHeight and midHeight, the button is
    // fully visible
    if (current <= mid) return 1;

    // If the snap rises above midHeight, gradually reduce opacity from 1.0 to
    // 0.0
    final progressAboveMid = (current - mid) / (1.0 - mid);
    return (1.0 - progressAboveMid).clamp(0.0, 1.0);
  }

  double get _innerParametersButtonProgress {
    if (_isLandscape) return 1;

    final mid = _midProgress;
    if (mid >= 1.0) return 0;

    final current = _expandController.value;
    if (current <= mid) return 0;

    return ((current - mid) / (1.0 - mid)).clamp(0.0, 1.0);
  }

  /// Determines physical location of the front camera in landscape orientation
  /// and gets actual insets
  double _getStartInsets(BuildContext context) {
    if (!_isLandscape) return 0;

    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    if (Platform.isAndroid) {
      // Check if there is a camera block in the horizontal orientation on the
      // left side
      return padding.left > 0 ? padding.left : 8;
    } else if (Platform.isIOS) {
      // And also on iOS
      final isLeftSide = mediaQuery.viewPadding.top == 0;

      return isLeftSide ? mediaQuery.viewPadding.left : 8;
    }

    return 0;
  }

  /// Determines physical location of the front camera in landscape orientation
  /// and gets actual padding
  double _getTopPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    if (Platform.isIOS && _isLandscape) {
      // Check if there is a camera block in the horizontal orientation on the
      // left side on iOS
      final isLeftSide = mediaQuery.viewPadding.top == 0;

      return isLeftSide ? padding.bottom : padding.top;
    }

    return padding.top + widget.topPadding;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final controller = widget.controller;
    final navigationSettings = widget.navigationSettings;
    final repository = navigationSettings?.repository;
    final onSettingsClick = navigationSettings?.onSettingsClick;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        _isLandscape = mediaQuery.orientation == Orientation.landscape;
        _startInset = _getStartInsets(context);

        final screenWidth = mediaQuery.size.width;
        final panelWidth = _isLandscape ? screenWidth / 2.5 : screenWidth;
        if (_containerHeight != constraints.maxHeight) {
          _containerHeight = constraints.maxHeight;
          _calculateHeights();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (_prevIsLandscapeState != _isLandscape) {
            _prevIsLandscapeState = _isLandscape;
            _expandController.value = !_isLandscape ? _midProgress : 1.0;
          }

          _reportReservedInsets(panelWidth);
        });

        return Align(
          alignment: _isLandscape
              ? Alignment.bottomLeft
              : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: _startInset,
              top: _getTopPadding(context),
            ),
            child: SizedBox(
              width: panelWidth,
              height: _currentHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRect(
                    child: Align(
                      heightFactor: _parametersButtonProgress,
                      child: Opacity(
                        opacity: _parametersButtonProgress,
                        child: SizedBox(
                          height: _parametersBoxHeight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                if (!_isLandscape &&
                                    ((repository != null &&
                                            navigationSettings != null) ||
                                        onSettingsClick != null))
                                  ParametersButtonView(
                                    boxColor: theme.buttonPrimaryColor,
                                    iconColor: theme.iconColor,
                                    onTap:
                                        onSettingsClick ??
                                        () {
                                          if (repository == null ||
                                              navigationSettings == null) {
                                            return;
                                          }

                                          showNavigationSettingsFlow(
                                            context: context,
                                            repository: repository,
                                            primarySection: navigationSettings
                                                .primarySection,
                                            visibilityConfig: navigationSettings
                                                .sectionVisibility,
                                            theme: navigationSettings.theme,
                                          );
                                        },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onVerticalDragStart: _onDragStart,
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: _onDragEnd,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HandleView(
                              theme: theme,
                              controllerValue: _expandController.value,
                              expand: _expand,
                              collapse: _collapse,
                            ),
                            KeyedSubtree(
                              key: _headerKey,
                              child: _HeaderView(
                                controller: widget.controller,
                                theme: theme,
                                routeSearchPointBuilder:
                                    widget.routeSearchPointBuilder,
                                onSwapCallback: widget.onSwapCallback,
                                onClose: widget.onClose,
                              ),
                            ),
                            Expanded(
                              child: CustomScrollView(
                                controller: _routesVerticalController,
                                physics:
                                    !_isLandscape &&
                                        _expandController.value <= _midProgress
                                    ? const NeverScrollableScrollPhysics()
                                    : const BouncingScrollPhysics(),
                                slivers: [
                                  if ((repository != null &&
                                          navigationSettings != null) ||
                                      onSettingsClick != null)
                                    SliverToBoxAdapter(
                                      child: ClipRect(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          heightFactor:
                                              _innerParametersButtonProgress,
                                          child: Opacity(
                                            opacity:
                                                _innerParametersButtonProgress,
                                            child: ParametersButtonView(
                                              boxColor:
                                                  theme.headerButtonBackground,
                                              iconColor: theme.iconColor,
                                              onTap:
                                                  onSettingsClick ??
                                                  () {
                                                    if (repository == null ||
                                                        navigationSettings ==
                                                            null) {
                                                      return;
                                                    }

                                                    showNavigationSettingsFlow(
                                                      context: context,
                                                      repository: repository,
                                                      primarySection:
                                                          navigationSettings
                                                              .primarySection,
                                                      visibilityConfig:
                                                          navigationSettings
                                                              .sectionVisibility,
                                                      theme: navigationSettings
                                                          .theme,
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: theme.routeListVerticalPadding,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: RouteListWidget(
                                        key: _routeListKey,
                                        controller: controller,
                                        verticalScrollController:
                                            _routesVerticalController,
                                        cardTheme: theme.cardTheme,
                                        emptyTextStyle:
                                            theme.finishLabelTextStyle,
                                        routeCardBuilder:
                                            widget.routeCardBuilder,
                                        expandProgress:
                                            _routesListExpandProgress,
                                        onStartNavigation:
                                            widget.onStartNavigation,
                                        onRouteTapped: _onRouteTapped,
                                        collapsedCardHeight:
                                            theme.routeListHeight,
                                        horizontalPadding:
                                            theme.horizontalPadding,
                                        cardWidth: theme.cardWidth,
                                        cardSpacing: theme.cardSpacing,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _TabBarView(
                              controller: controller,
                              tabScrollController: _tabScrollController,
                              tabKeys: _tabKeys,
                              theme: theme,
                              transportTypeTabBuilder:
                                  widget.transportTypeTabBuilder,
                            ),
                            SizedBox(
                              height:
                                  theme.bottomPadding +
                                  mediaQuery.padding.bottom,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderView extends StatelessWidget {
  const _HeaderView({
    required this.controller,
    required this.theme,
    required this.routeSearchPointBuilder,
    required this.onSwapCallback,
    required this.onClose,
  });

  final RouteEditorController controller;
  final RouteEditorViewTheme theme;
  final RouteSearchPointBuilder routeSearchPointBuilder;
  final VoidCallback? onSwapCallback;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RoutePointUI>>(
      valueListenable: controller.routePoints,
      builder: (context, points, _) {
        if (points.length < 2) return const SizedBox.shrink();

        final startPoint = points.first;
        final finishPoint = points.last;

        final startLabel = routeSearchPointBuilder.buildStartPointView(
          startPoint,
          controller,
          theme,
        );

        final finishLabel = routeSearchPointBuilder.buildFinishPointView(
          finishPoint,
          controller,
          theme,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.horizontalPadding,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.startPointColor,
                            width: 3.5,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.routeLineColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.finishPointColor,
                            width: 3.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 1),
                      child: DefaultTextStyle(
                        style: theme.startLabelTextStyle,
                        child: startLabel,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 1),
                      child: DefaultTextStyle(
                        style: theme.finishLabelTextStyle,
                        child: finishLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _reverseRoutePoints,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.headerButtonBackground,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'packages/$pluginName/assets/icons/dgis_swap_vert.svg',
                    colorFilter: ColorFilter.mode(
                      theme.iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  controller.routePoints.value = [];
                  onClose?.call();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.headerButtonBackground,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: theme.iconColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reverseRoutePoints() {
    final points = controller.routePoints.value;
    if (points.length >= 2) {
      final reversed = points.reversed.toList();
      controller.setRoutePoints(reversed);
      onSwapCallback?.call();
    }
  }
}

class ParametersButtonView extends StatelessWidget {
  const ParametersButtonView({
    required this.boxColor,
    required this.iconColor,
    required this.onTap,
    super.key,
    this.margin = const EdgeInsets.only(left: 16, top: 16),
  });

  final Color boxColor;
  final Color iconColor;
  final VoidCallback onTap;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 14,
            ),
            child: SvgPicture.asset(
              'packages/$pluginName/assets/icons/dgis_parameters.svg',
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HandleView extends StatelessWidget {
  const _HandleView({
    required this.theme,
    required this.controllerValue,
    required this.expand,
    required this.collapse,
  });

  final RouteEditorViewTheme theme;
  final double controllerValue;
  final VoidCallback expand;
  final VoidCallback collapse;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controllerValue < 0.5) {
          expand();
        } else {
          collapse();
        }
      },
      child: Container(
        height: theme.handleHeight,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.routeLineColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarView extends StatelessWidget {
  const _TabBarView({
    required this.controller,
    required this.tabScrollController,
    required this.tabKeys,
    required this.theme,
    required this.transportTypeTabBuilder,
  });

  final RouteEditorController controller;
  final ScrollController tabScrollController;
  final Map<TransportMode, GlobalKey<State<StatefulWidget>>> tabKeys;
  final RouteEditorViewTheme theme;
  final TransportModeTabBuilder transportTypeTabBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RoutePointUI>>(
      valueListenable: controller.routePoints,
      builder: (context, routePoints, _) {
        if (controller.availableTransportModes.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: theme.tabBarHeight,
          child: ListView.separated(
            controller: tabScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: theme.horizontalPadding),
            itemCount: controller.availableTransportModes.length,
            separatorBuilder: (_, _) {
              return SizedBox(width: theme.cardSpacing);
            },
            itemBuilder: (_, index) {
              final transportType = controller.availableTransportModes[index];

              return KeyedSubtree(
                key: tabKeys[transportType],
                child: transportTypeTabBuilder.build(
                  transportType,
                  controller,
                  theme.tabTheme,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
