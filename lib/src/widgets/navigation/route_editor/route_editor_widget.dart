import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
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

  /// Callback invoked when the user starts navigation with a route.
  final void Function(sdk.TrafficRoute route)? onStartNavigation;

  /// Callback invoked when the user closes the route editor.
  final VoidCallback? onClose;

  /// Callback invoked when the user swaps route points.
  final VoidCallback? onSwapCallback;

  /// Callback invoked when the panel is collapsed with its height.
  ///
  /// This callback is also called once during widget initialization
  /// to provide the initial collapsed height.
  final void Function(double height)? onCollapsed;

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
    this.onStartNavigation,
    this.onClose,
    this.onSwapCallback,
    this.onCollapsed,
    this.onExpanded,
    this.onReservedInsetsChanged,
    this.topPadding = 16,
    RouteSearchPointBuilder? routeSearchPointBuilder,
    RouteCardBuilder? routeCardBuilder,
    TransportModeTabBuilder? transportTypeTabBuilder,
    super.key,
  })  : routeSearchPointBuilder =
            routeSearchPointBuilder ?? const DefaultRouteSearchPointBuilder(),
        routeCardBuilder = routeCardBuilder ?? const DefaultRouteCardBuilder(),
        transportTypeTabBuilder =
            transportTypeTabBuilder ?? const DefaultTransportModeTabBuilder();

  @override
  State<RouteEditorWidget> createState() => _RouteEditorWidgetState();
}

class _RouteEditorWidgetState extends State<RouteEditorWidget>
    with SingleTickerProviderStateMixin {
  double get _landscapePanelWidth =>
      widget.theme.cardWidth + widget.theme.horizontalPadding * 2;

  static const double _landscapeMinStartInset = 44;

  final ScrollController _tabScrollController = ScrollController();
  final Map<TransportMode, GlobalKey> _tabKeys = {};
  final GlobalKey<RouteListWidgetState> _routeListKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();

  late AnimationController _expandController;

  StreamSubscription<sdk.RouteIndex?>? _activeRouteIndexSubscription;

  double _collapsedHeight = 0;
  double _expandedHeight = 0;
  double _containerHeight = 0;
  double _headerHeight = 0;

  bool _isLandscape = false;
  double _panelWidth = 0;
  double _startInset = 0;
  EdgeInsets _reportedInsets = EdgeInsets.zero;
  double _dragStartPosition = 0;
  double _dragStartProgress = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandController.addListener(_onExpandProgressChanged);

    widget.controller.activeTransportMode
        .addListener(_onActiveTransportModeChanged);

    widget.controller.routePoints.addListener(_onRoutePointsChanged);

    _activeRouteIndexSubscription = widget
        .controller.routeEditor.activeRouteIndexChannel
        .listen(_onActiveRouteIndexChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeights();
      widget.onCollapsed?.call(_collapsedHeight);
    });
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
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    _collapsedHeight = theme.handleHeight +
        _headerHeight +
        theme.routeListVerticalPadding * 2 +
        theme.routeListHeight +
        theme.tabBarHeight +
        theme.bottomPadding +
        bottomSafeArea;

    if (_containerHeight > 0) {
      _expandedHeight = _containerHeight - widget.topPadding;
    }
  }

  /// Reports the screen-edge insets the panel occupies, reserving space at the
  /// start edge in landscape and at the bottom in portrait. Uses the collapsed
  /// height so the reservation stays stable while the panel is expanded.
  void _reportReservedInsets() {
    final insets = _isLandscape
        ? EdgeInsets.only(left: _startInset + _panelWidth)
        : EdgeInsets.only(bottom: _collapsedHeight);
    if (insets != _reportedInsets) {
      _reportedInsets = insets;
      widget.onReservedInsetsChanged?.call(insets);
    }
  }

  @override
  void didUpdateWidget(RouteEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.activeTransportMode
          .removeListener(_onActiveTransportModeChanged);
      oldWidget.controller.routePoints.removeListener(_onRoutePointsChanged);

      widget.controller.activeTransportMode
          .addListener(_onActiveTransportModeChanged);
      widget.controller.routePoints.addListener(_onRoutePointsChanged);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _calculateHeights();
        widget.onCollapsed?.call(_collapsedHeight);
      });
    }
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
    widget.controller.activeTransportMode
        .removeListener(_onActiveTransportModeChanged);
    widget.controller.routePoints.removeListener(_onRoutePointsChanged);
    _activeRouteIndexSubscription?.cancel();
    _expandController
      ..removeListener(_onExpandProgressChanged)
      ..dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _onExpandProgressChanged() {
    setState(() {});
  }

  void _onRoutePointsChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final previousCollapsedHeight = _collapsedHeight;
      _calculateHeights();
      if (previousCollapsedHeight != _collapsedHeight) {
        setState(() {});
        widget.onCollapsed?.call(_collapsedHeight);
      }
    });
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
    final screenCenter = screenWidth / 2;

    final targetScrollOffset =
        currentScrollOffset + (itemCenter - screenCenter);

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
      if (mounted) {
        _routeListKey.currentState?.scrollToRouteCard(routeIndex.value);
      }
    });
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartPosition = details.globalPosition.dy;
    _dragStartProgress = _expandController.value;
    _expandController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final dragDelta = _dragStartPosition - details.globalPosition.dy;
    final totalDragRange = _expandedHeight - _collapsedHeight;
    final progressDelta = dragDelta / totalDragRange;
    final newProgress = (_dragStartProgress + progressDelta).clamp(0.0, 1.0);

    _expandController.value = newProgress;
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    _snapToNearestState(details.velocity.pixelsPerSecond.dy);
  }

  void _snapToNearestState(double velocity) {
    final currentProgress = _expandController.value;

    bool shouldExpand;
    if (velocity.abs() > 500) {
      shouldExpand = velocity < 0;
    } else {
      shouldExpand = currentProgress > 0.5;
    }

    if (shouldExpand) {
      _expand();
    } else {
      _collapse();
    }
  }

  void _expand() {
    _expandController
        .animateTo(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) => widget.onExpanded?.call(_expandedHeight));
  }

  void _collapse({bool scrollToActiveCard = false}) {
    _expandController
        .animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    )
        .then((_) {
      widget.onCollapsed?.call(_collapsedHeight);
      if (scrollToActiveCard) {
        final activeIndex =
            widget.controller.routeEditor.activeRouteIndexChannel.value?.value;
        if (activeIndex != null) {
          _routeListKey.currentState?.scrollToRouteCard(activeIndex);
        }
      }
    });
  }

  void _onRouteTapped(int index) {
    if (_expandController.value > 0) {
      _collapse(scrollToActiveCard: true);
    }
  }

  double get _currentHeight {
    if (_collapsedHeight == 0) {
      _calculateHeights();
    }
    if (_expandedHeight == 0) {
      return _collapsedHeight;
    }
    return _collapsedHeight +
        (_expandedHeight - _collapsedHeight) * _expandController.value;
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        _isLandscape = mediaQuery.orientation == Orientation.landscape;
        _startInset = _isLandscape
            ? math.max(mediaQuery.padding.left, _landscapeMinStartInset)
            : 0;
        _panelWidth = _isLandscape
            ? math.min(_landscapePanelWidth, constraints.maxWidth - _startInset)
            : constraints.maxWidth;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_containerHeight != constraints.maxHeight) {
            _containerHeight = constraints.maxHeight;
            _calculateHeights();
          }
          _reportReservedInsets();
        });

        return Align(
          alignment:
              _isLandscape ? Alignment.bottomLeft : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(left: _startInset),
            child: SizedBox(
              width: _isLandscape ? _panelWidth : null,
              height: _currentHeight,
              child: GestureDetector(
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.theme.backgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      _buildHandle(),
                      KeyedSubtree(
                        key: _headerKey,
                        child: _buildHeader(localizations),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: widget.theme.routeListVerticalPadding,
                          ),
                          child: RouteListWidget(
                            key: _routeListKey,
                            controller: widget.controller,
                            cardTheme: widget.theme.cardTheme,
                            emptyTextStyle: widget.theme.finishLabelTextStyle,
                            routeCardBuilder: widget.routeCardBuilder,
                            expandProgress: _expandController.value,
                            onStartNavigation: widget.onStartNavigation,
                            onRouteTapped: _onRouteTapped,
                            collapsedCardHeight: widget.theme.routeListHeight,
                            horizontalPadding: widget.theme.horizontalPadding,
                            cardWidth: widget.theme.cardWidth,
                            cardSpacing: widget.theme.cardSpacing,
                          ),
                        ),
                      ),
                      _buildTabBar(),
                      SizedBox(
                        height: widget.theme.bottomPadding +
                            MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () {
        if (_expandController.value < 0.5) {
          _expand();
        } else {
          _collapse();
        }
      },
      child: Container(
        height: widget.theme.handleHeight,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.theme.routeLineColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DgisLocalizations localizations) {
    return ValueListenableBuilder<List<RoutePointUI>>(
      valueListenable: widget.controller.routePoints,
      builder: (context, points, _) {
        if (points.length < 2) return const SizedBox.shrink();

        final startPoint = points.first;
        final finishPoint = points.last;

        final startLabel = widget.routeSearchPointBuilder.buildStartPointView(
          startPoint,
          widget.controller,
          widget.theme,
        );

        final finishLabel = widget.routeSearchPointBuilder.buildFinishPointView(
          finishPoint,
          widget.controller,
          widget.theme,
        );

        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: widget.theme.horizontalPadding),
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
                            color: widget.theme.startPointColor,
                            width: 3.5,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 10,
                      decoration: BoxDecoration(
                        color: widget.theme.routeLineColor,
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
                            color: widget.theme.finishPointColor,
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
                        style: widget.theme.startLabelTextStyle,
                        child: startLabel,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 1),
                      child: DefaultTextStyle(
                        style: widget.theme.finishLabelTextStyle,
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
                    color: widget.theme.headerButtonBackground,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.swap_vert,
                    color: widget.theme.headerButtonColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => {
                  widget.controller.routePoints.value = [],
                  widget.onClose?.call(),
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: widget.theme.headerButtonBackground,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: widget.theme.headerButtonColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return ValueListenableBuilder<List<RoutePointUI>>(
      valueListenable: widget.controller.routePoints,
      builder: (context, routePoints, _) {
        if (widget.controller.availableTransportModes.isEmpty) {
          return const SizedBox.shrink();
        }

        for (final type in widget.controller.availableTransportModes) {
          _tabKeys.putIfAbsent(type, GlobalKey.new);
        }

        return SizedBox(
          height: widget.theme.tabBarHeight,
          child: ListView.separated(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: widget.theme.horizontalPadding,
            ),
            itemCount: widget.controller.availableTransportModes.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: widget.theme.cardSpacing),
            itemBuilder: (_, index) {
              final transportType =
                  widget.controller.availableTransportModes[index];

              return KeyedSubtree(
                key: _tabKeys[transportType],
                child: widget.transportTypeTabBuilder.build(
                  transportType,
                  widget.controller,
                  widget.theme.tabTheme,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _reverseRoutePoints() {
    final points = widget.controller.routePoints.value;
    if (points.length >= 2) {
      final reversed = points.reversed.toList();
      widget.controller.setRoutePoints(reversed);
      widget.onSwapCallback?.call();
    }
  }
}
