import 'package:dgis_mobile_sdk_full/src/widgets/routing/route_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../util/format_duration.dart';
import '../../util/plugin_name.dart';
import '../map/map_widget_theme.dart';
import '../map/themed_map_controlling_widget.dart';

class RouteTypeTab {
  final String icon;
  final Duration duration;

  final sdk.RouteSearchOptions options;

  const RouteTypeTab({
    required this.icon,
    required this.duration,
    required this.options,
  });
}

class RoutesListModel {
  final List<sdk.TrafficRoute> routes;
  final List<RouteTypeTab> tabs;

  final String startLabel;
  final String finishLabel;

  RoutesListModel({
    required this.routes,
    required this.tabs,
    required this.startLabel,
    required this.finishLabel,
  });

  RoutesListModel copyWith({
    List<sdk.TrafficRoute>? routes,
    List<RouteTypeTab>? tabs,
    String? startLabel,
    String? finishLabel,
  }) {
    return RoutesListModel(
      routes: routes ?? this.routes,
      tabs: tabs ?? this.tabs,
      startLabel: startLabel ?? this.startLabel,
      finishLabel: finishLabel ?? this.finishLabel,
    );
  }
}

class RoutesListWidget extends ThemedMapControllingWidget<RoutesListWidgetTheme> {
  final sdk.RouteSearchOptions selectedOptions;

  final RoutesListModel model;
  final ValueChanged<sdk.RouteSearchOptions> onTabChanged;
  final VoidCallback onSwapPoints;
  final Widget Function(sdk.TrafficRoute, RouteCardTheme) itemBuilder;

  const RoutesListWidget({
    super.key,
    required this.model,
    required this.selectedOptions,
    required this.onTabChanged,
    required this.itemBuilder,
    required this.onSwapPoints,
    RoutesListWidgetTheme? light,
    RoutesListWidgetTheme? dark,
  }) : super(
          light: light ?? RoutesListWidgetTheme.defaultLight,
          dark: dark ?? RoutesListWidgetTheme.defaultDark,
        );

  @override
  ThemedMapControllingWidgetState<RoutesListWidget, RoutesListWidgetTheme> createState() => _RoutesListWidgetState();
}

class _RoutesListWidgetState extends ThemedMapControllingWidgetState<RoutesListWidget, RoutesListWidgetTheme> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 4,
                        ),
                        Padding(
                          padding: EdgeInsets.all(2),
                          child: SvgPicture.asset(
                            'packages/$pluginName/assets/icons/dgis_bullet.svg',
                            colorFilter: ColorFilter.mode(
                              theme.startPointColor,
                              BlendMode.srcATop,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 10,
                          decoration: BoxDecoration(
                            color: theme.routeLineColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(2),
                          child: SvgPicture.asset(
                            'packages/$pluginName/assets/icons/dgis_bullet.svg',
                            colorFilter: ColorFilter.mode(
                              theme.finishPointColor,
                              BlendMode.srcATop,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 1),
                          child: Text(
                            widget.model.startLabel,
                            style: theme.startLabelTextStyle,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 1),
                          child: Text(
                            widget.model.finishLabel,
                            style: theme.finishLabelTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: widget.onSwapPoints,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.headerButtonBackground,
                      ),
                      padding: EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        'packages/$pluginName/assets/icons/dgis_swap_points.svg',
                        colorFilter: ColorFilter.mode(
                          theme.headerButtonColor,
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView.separated(
                  itemBuilder: (context, index) => widget.itemBuilder(
                    widget.model.routes[index],
                    theme.cardTheme,
                  ),
                  separatorBuilder: (context, index) => SizedBox(
                    height: 16,
                  ),
                  itemCount: widget.model.routes.length,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: SizedBox(
                height: 36,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: widget.model.tabs
                      .map((tab) => _RouteTypeTab(
                            tab: tab,
                            theme: theme,
                            isActive: tab.options == widget.selectedOptions,
                            onTabChanged: widget.onTabChanged,
                          ))
                      .toList(),
                ),
              ),
            )
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

class _RouteTypeTab extends StatelessWidget {
  const _RouteTypeTab({
    required this.tab,
    required this.theme,
    required this.onTabChanged,
    required this.isActive,
  });

  final RouteTypeTab tab;
  final bool isActive;
  final ValueChanged<sdk.RouteSearchOptions> onTabChanged;
  final RoutesListWidgetTheme theme;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          letterSpacing: 0,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive ? theme.activeTabBackground : Colors.transparent,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 10,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                tab.icon,
                colorFilter: ColorFilter.mode(
                  isActive ? theme.activeTabIconColor : theme.inactiveTabIconColor,
                  BlendMode.srcATop,
                ),
              ),
              if (tab.duration != Duration.zero)
                SizedBox(
                  width: 6,
                ),
              Text(
                formatDuration(tab.duration),
                style: isActive ? theme.activeTabTextStyle : theme.inactiveTabTextStyle,
              )
            ],
          ),
        ),
      ),
      onPressed: () => onTabChanged(tab.options),
    );
  }
}

class RoutesListWidgetTheme extends MapWidgetTheme {
  const RoutesListWidgetTheme({
    required this.backgroundColor,
    required this.cardTheme,
    required this.inactiveTabIconColor,
    required this.inactiveTabTextStyle,
    required this.activeTabIconColor,
    required this.activeTabBackground,
    required this.activeTabTextStyle,
    required this.headerButtonBackground,
    required this.headerButtonColor,
    required this.startLabelTextStyle,
    required this.startPointColor,
    required this.finishLabelTextStyle,
    required this.finishPointColor,
    required this.routeLineColor,
  });

  final Color backgroundColor;
  final RouteCardTheme cardTheme;

  final Color inactiveTabIconColor;
  final TextStyle inactiveTabTextStyle;

  final Color activeTabIconColor;
  final Color activeTabBackground;
  final TextStyle activeTabTextStyle;

  final Color headerButtonBackground;
  final Color headerButtonColor;

  final TextStyle startLabelTextStyle;
  final Color startPointColor;

  final TextStyle finishLabelTextStyle;
  final Color finishPointColor;

  final Color routeLineColor;

  static const defaultLight = RoutesListWidgetTheme(
    backgroundColor: Color(0xFFF1F1F1),
    cardTheme: RouteCardTheme.defaultLight,
    inactiveTabIconColor: Color(0xFF898989),
    inactiveTabTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 14,
      height: 1.3,
    ),
    activeTabIconColor: Color(0xFF141414),
    activeTabBackground: Color(0xFFFFFFFF),
    activeTabTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 14,
      height: 1.3,
    ),
    headerButtonBackground: Color(0x0F141414),
    headerButtonColor: Color(0xFF5A5A5A),
    startLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    startPointColor: Color(0xFF1BA136),
    finishLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 15,
      height: 1.3,
    ),
    finishPointColor: Color(0xFF0059D6),
    routeLineColor: Color(0xFF5A5A5A),
  );
  static const defaultDark = RoutesListWidgetTheme(
    backgroundColor: Color(0xFF141414),
    cardTheme: RouteCardTheme.defaultDark,
    inactiveTabIconColor: Color(0xFF898989),
    inactiveTabTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 14,
      height: 1.3,
    ),
    activeTabIconColor: Color(0xFFFFFFFF),
    activeTabBackground: Color(0x2BFFFFFF),
    activeTabTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      height: 1.3,
    ),
    headerButtonBackground: Color(0x0FFFFFFF),
    headerButtonColor: Color(0xFFB8B8B8),
    startLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    startPointColor: Color(0xFF26C947),
    finishLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    finishPointColor: Color(0xFF3588FD),
    routeLineColor: Color(0xFFB8B8B8),
  );

  @override
  RoutesListWidgetTheme copyWith({
    Color? backgroundColor,
    RouteCardTheme? cardTheme,
    Color? inactiveTabIconColor,
    TextStyle? inactiveTabTextStyle,
    Color? activeTabIconColor,
    Color? activeTabBackground,
    TextStyle? activeTabTextStyle,
    Color? headerButtonBackground,
    Color? headerButtonColor,
    TextStyle? startLabelTextStyle,
    Color? startPointColor,
    TextStyle? finishLabelTextStyle,
    Color? finishPointColor,
    Color? routeLineColor,
  }) {
    return RoutesListWidgetTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardTheme: cardTheme ?? this.cardTheme,
      inactiveTabIconColor: inactiveTabIconColor ?? this.inactiveTabIconColor,
      inactiveTabTextStyle: inactiveTabTextStyle ?? this.inactiveTabTextStyle,
      activeTabIconColor: activeTabIconColor ?? this.activeTabIconColor,
      activeTabBackground: activeTabBackground ?? this.activeTabBackground,
      activeTabTextStyle: activeTabTextStyle ?? this.activeTabTextStyle,
      headerButtonBackground: headerButtonBackground ?? this.headerButtonBackground,
      headerButtonColor: headerButtonColor ?? this.headerButtonColor,
      startLabelTextStyle: startLabelTextStyle ?? this.startLabelTextStyle,
      startPointColor: startPointColor ?? this.startPointColor,
      finishLabelTextStyle: finishLabelTextStyle ?? this.finishLabelTextStyle,
      finishPointColor: finishPointColor ?? this.finishPointColor,
      routeLineColor: routeLineColor ?? this.routeLineColor,
    );
  }
}
