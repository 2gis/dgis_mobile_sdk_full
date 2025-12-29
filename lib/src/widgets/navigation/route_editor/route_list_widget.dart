import 'package:flutter/material.dart';

import '../../../../../l10n/generated/dgis_localizations.dart';
import '../../../../../l10n/generated/dgis_localizations_en.dart';
import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/stateful_channel_listenable.dart';
import './route_card_builder.dart';
import './route_editor_controller.dart';
import './route_editor_theme.dart';
import 'route_editor_scroll_physics.dart';

class RouteListWidget extends StatefulWidget {
  final RouteEditorController controller;
  final RouteCardTheme cardTheme;
  final TextStyle emptyTextStyle;
  final RouteCardBuilder routeCardBuilder;
  final void Function(sdk.TrafficRoute route)? onStartNavigation;
  final void Function(int index)? onRouteTapped;
  final double expandProgress;
  final double collapsedCardHeight;
  final double expandedCardHeight;
  final double horizontalPadding;
  final double cardWidth;
  final double cardSpacing;

  const RouteListWidget({
    required this.controller,
    required this.cardTheme,
    required this.emptyTextStyle,
    required this.routeCardBuilder,
    required this.expandProgress,
    this.onStartNavigation,
    this.onRouteTapped,
    this.collapsedCardHeight = 100,
    this.expandedCardHeight = 100,
    this.horizontalPadding = 16,
    this.cardWidth = 340,
    this.cardSpacing = 8,
    super.key,
  });

  @override
  State<RouteListWidget> createState() => RouteListWidgetState();
}

class RouteListWidgetState extends State<RouteListWidget> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final Map<int, GlobalKey> _routeCardKeys = {};

  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onHorizontalScroll);
  }

  @override
  void dispose() {
    _horizontalScrollController
      ..removeListener(_onHorizontalScroll)
      ..dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onHorizontalScroll() {
    if (_isScrollingProgrammatically) return;
    if (!_horizontalScrollController.hasClients) return;

    int? closestIndex;
    var minDistance = double.infinity;

    for (final entry in _routeCardKeys.entries) {
      final itemContext = entry.value.currentContext;
      if (itemContext == null) continue;

      final renderBox = itemContext.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final itemPosition = renderBox.localToGlobal(Offset.zero);
      final distance = (itemPosition.dx - widget.horizontalPadding).abs();

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = entry.key;
      }
    }

    if (closestIndex == null) return;

    final currentActiveIndex =
        widget.controller.routeEditor.activeRouteIndexChannel.value?.value;

    if (currentActiveIndex != closestIndex) {
      widget.controller.setActiveRouteIndex(closestIndex);
    }
  }

  void scrollToRouteCard(int index) {
    if (widget.expandProgress < 0.5) {
      _scrollToHorizontalCard(index);
    } else {
      _scrollToVerticalCard(index);
    }
  }

  void _scrollToHorizontalCard(int index) {
    if (!_horizontalScrollController.hasClients) return;

    final itemContext = _routeCardKeys[index]?.currentContext;
    if (itemContext == null) return;

    final renderBox = itemContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _isScrollingProgrammatically = true;

    final itemPosition = renderBox.localToGlobal(Offset.zero);
    final currentScrollOffset = _horizontalScrollController.offset;

    final targetScrollOffset =
        currentScrollOffset + itemPosition.dx - widget.horizontalPadding;

    _horizontalScrollController
        .animateTo(
          targetScrollOffset.clamp(
            0.0,
            _horizontalScrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) => _isScrollingProgrammatically = false);
  }

  void _scrollToVerticalCard(int index) {
    if (!_verticalScrollController.hasClients) return;

    final targetOffset =
        index * (widget.expandedCardHeight + widget.cardSpacing);

    _verticalScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _verticalScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return ValueListenableBuilder<sdk.RouteEditorRoutesInfo?>(
      valueListenable:
          widget.controller.routeEditor.routesInfoChannel.asValueListenable(),
      builder: (context, routesInfo, _) {
        if (routesInfo == null || routesInfo.routes.isEmpty) {
          return Center(
            child: Text(
              localizations.dgis_no_routes_found,
              style: widget.emptyTextStyle,
            ),
          );
        }

        for (var i = 0; i < routesInfo.routes.length; i++) {
          _routeCardKeys.putIfAbsent(i, GlobalKey.new);
        }

        final horizontalOpacity = 1.0 - widget.expandProgress;
        final verticalOpacity = widget.expandProgress;

        return Stack(
          children: [
            Opacity(
              opacity: horizontalOpacity,
              child: IgnorePointer(
                ignoring: widget.expandProgress > 0.5,
                child: _buildHorizontalList(routesInfo),
              ),
            ),
            Opacity(
              opacity: verticalOpacity,
              child: IgnorePointer(
                ignoring: widget.expandProgress <= 0.5,
                child: _buildVerticalList(routesInfo),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHorizontalList(sdk.RouteEditorRoutesInfo routesInfo) {
    return SizedBox(
      height: widget.collapsedCardHeight,
      child: ListView.separated(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        itemCount: routesInfo.routes.length,
        separatorBuilder: (_, __) => SizedBox(width: widget.cardSpacing),
        physics: RouteEditorScrollPhysics(
          elementWidth: widget.cardWidth,
          elementPadding: widget.cardSpacing,
        ),
        itemBuilder: (context, index) {
          return KeyedSubtree(
            key: _routeCardKeys[index],
            child: SizedBox(
              width: widget.cardWidth,
              child: GestureDetector(
                onTap: () {
                  widget.controller.setActiveRouteIndex(index);
                  widget.onRouteTapped?.call(index);
                },
                child: widget.routeCardBuilder.build(
                  routesInfo.routes[index],
                  () {
                    widget.onStartNavigation?.call(routesInfo.routes[index]);
                  },
                  index,
                  widget.controller,
                  widget.cardTheme,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList(sdk.RouteEditorRoutesInfo routesInfo) {
    return ListView.separated(
      controller: _verticalScrollController,
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      itemCount: routesInfo.routes.length,
      separatorBuilder: (_, __) => SizedBox(height: widget.cardSpacing),
      itemBuilder: (context, index) {
        return SizedBox(
          height: widget.expandedCardHeight,
          child: GestureDetector(
            onTap: () {
              widget.controller.setActiveRouteIndex(index);
              widget.onRouteTapped?.call(index);
            },
            child: widget.routeCardBuilder.build(
              routesInfo.routes[index],
              () {
                widget.onStartNavigation?.call(routesInfo.routes[index]);
              },
              index,
              widget.controller,
              widget.cardTheme,
            ),
          ),
        );
      },
    );
  }
}
