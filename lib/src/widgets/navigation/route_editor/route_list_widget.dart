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
  final ScrollController verticalScrollController;
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
    required this.verticalScrollController,
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
  late final ScrollController _horizontalScrollController = ScrollController();
  late StatefulChannelValueListenable<sdk.RouteEditorRoutesInfo>
  _listenableRoutesValue;

  /// A flag that blocks manual scrolling while automating scrolling
  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();

    _horizontalScrollController.addListener(_onHorizontalScroll);
    _listenableRoutesValue = widget.controller.routeEditor.routesInfoChannel
        .asValueListenable();
  }

  @override
  void didUpdateWidget(covariant RouteListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller) return;
    _listenableRoutesValue = widget.controller.routeEditor.routesInfoChannel
        .asValueListenable();
  }

  @override
  void dispose() {
    _horizontalScrollController
      ..removeListener(_onHorizontalScroll)
      ..dispose();
    super.dispose();
  }

  /// Calculates the width of the route card and the distance between them to
  /// determine scroll distance value
  void _onHorizontalScroll() {
    if (_isScrollingProgrammatically ||
        !_horizontalScrollController.hasClients) {
      return;
    }

    final routesCount = _listenableRoutesValue.value.routes.length;
    if (routesCount == 0) return;

    final itemExtent = widget.cardWidth + widget.cardSpacing;
    if (itemExtent <= 0) return;

    // We are looking for the nearest card in size and take it index
    final closestIndex = (_horizontalScrollController.offset / itemExtent)
        .round()
        .clamp(0, routesCount - 1);

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

  Future<void> _scrollToHorizontalCard(int index) async {
    if (!_horizontalScrollController.hasClients) return;

    try {
      _isScrollingProgrammatically = true;

      // Since we know the size of the card, we can scroll based on its size
      final targetScrollOffset =
          index * (widget.cardWidth + widget.cardSpacing);

      await _horizontalScrollController.animateTo(
        targetScrollOffset.clamp(
          0.0,
          _horizontalScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      _isScrollingProgrammatically = false;
    }
  }

  void _scrollToVerticalCard(int index) {
    final controller = widget.verticalScrollController;
    if (!controller.hasClients) return;

    final targetOffset =
        index * (widget.expandedCardHeight + widget.cardSpacing);

    controller.animateTo(
      targetOffset.clamp(0.0, controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        DgisLocalizations.of(context) ?? DgisLocalizationsEn();

    return ValueListenableBuilder<sdk.RouteEditorRoutesInfo>(
      valueListenable: _listenableRoutesValue,
      builder: (context, routesInfo, _) {
        if (routesInfo.routes.isEmpty) {
          return Center(
            child: Text(
              localizations.dgis_no_routes_found,
              style: widget.emptyTextStyle,
            ),
          );
        }

        final horizontalOpacity = 1.0 - widget.expandProgress;
        final verticalOpacity = widget.expandProgress;

        return Stack(
          children: [
            Opacity(
              opacity: horizontalOpacity,
              child: IgnorePointer(
                ignoring: widget.expandProgress > 0.5,
                child: _HorizontalCardListView(
                  routesInfo: routesInfo,
                  horizontalScrollController: _horizontalScrollController,
                  horizontalPadding: widget.horizontalPadding,
                  collapsedCardHeight: widget.collapsedCardHeight,
                  cardWidth: widget.cardWidth,
                  cardSpacing: widget.cardSpacing,
                  onPressCard: (index) {
                    widget.controller.setActiveRouteIndex(index);
                    widget.onRouteTapped?.call(index);
                  },
                  listChild: (context, index) {
                    return widget.routeCardBuilder.build(
                      routesInfo.routes[index],
                      () {
                        widget.onStartNavigation?.call(
                          routesInfo.routes[index],
                        );
                      },
                      index,
                      widget.controller,
                      widget.cardTheme,
                    );
                  },
                ),
              ),
            ),
            Opacity(
              opacity: verticalOpacity,
              child: IgnorePointer(
                ignoring: widget.expandProgress <= 0.5,
                child: _VerticalCardListView(
                  routesInfo: routesInfo,
                  expandedCardHeight: widget.expandedCardHeight,
                  cardSpacing: widget.cardSpacing,
                  horizontalPadding: widget.horizontalPadding,
                  onPressCard: (index) {
                    widget.controller.setActiveRouteIndex(index);
                    widget.onRouteTapped?.call(index);
                  },
                  listChild: (context, index) {
                    return widget.routeCardBuilder.build(
                      routesInfo.routes[index],
                      () {
                        widget.onStartNavigation?.call(
                          routesInfo.routes[index],
                        );
                      },
                      index,
                      widget.controller,
                      widget.cardTheme,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VerticalCardListView extends StatelessWidget {
  const _VerticalCardListView({
    required this.routesInfo,
    required this.expandedCardHeight,
    required this.horizontalPadding,
    required this.cardSpacing,
    required this.onPressCard,
    required this.listChild,
  });

  final sdk.RouteEditorRoutesInfo routesInfo;
  final double expandedCardHeight;
  final double horizontalPadding;
  final double cardSpacing;
  final ValueChanged<int> onPressCard;
  final Widget Function(BuildContext context, int index) listChild;

  @override
  Widget build(BuildContext context) {
    final length = routesInfo.routes.length;
    final allCardsHeight = expandedCardHeight * length;
    final allCardsSpacing = length > 1 ? cardSpacing * (length - 1) : 0.0;

    return SizedBox(
      height: allCardsHeight + allCardsSpacing,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: length,
        separatorBuilder: (_, _) => SizedBox(height: cardSpacing),
        itemBuilder: (context, index) {
          return SizedBox(
            height: expandedCardHeight,
            child: GestureDetector(
              onTap: () => onPressCard(index),
              child: listChild(context, index),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalCardListView extends StatelessWidget {
  const _HorizontalCardListView({
    required this.routesInfo,
    required this.horizontalScrollController,
    required this.horizontalPadding,
    required this.collapsedCardHeight,
    required this.cardWidth,
    required this.cardSpacing,
    required this.onPressCard,
    required this.listChild,
  });

  final sdk.RouteEditorRoutesInfo routesInfo;
  final ScrollController horizontalScrollController;
  final double horizontalPadding;
  final double collapsedCardHeight;
  final double cardWidth;
  final double cardSpacing;
  final ValueChanged<int> onPressCard;
  final Widget Function(BuildContext context, int index) listChild;

  @override
  Widget build(BuildContext context) {
    final length = routesInfo.routes.length;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final cardWidth = length == 1
        ? screenWidth - (horizontalPadding * 2)
        : this.cardWidth;

    return SizedBox(
      height: collapsedCardHeight,
      child: ListView.separated(
        primary: false,
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: length,
        separatorBuilder: (_, _) => SizedBox(width: cardSpacing),
        physics: RouteEditorScrollPhysics(
          elementWidth: this.cardWidth,
          elementPadding: cardSpacing,
        ),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: GestureDetector(
              onTap: () => onPressCard(index),
              child: listChild(context, index),
            ),
          );
        },
      ),
    );
  }
}
