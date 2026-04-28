import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../generated/dart_bindings.dart' as sdk;
import '../../../../platform/bss_events_source.dart';
import '../../../../platform/dgis.dart';
import '../../../../util/plugin_name.dart';
import '../../../shadow_gradient.dart';

import '../../map_widget_color_scheme.dart';
import '../../themed_map_controlling_widget.dart';
import '../../themed_map_controlling_widget_state.dart';

// Widget for switching floors in a building.
// Displays a column of floor names; the active floor is highlighted.
// Tapping a floor name switches the floor plan.
// A non-scrollable roof button is displayed at the top.
// Up to 5 floors are visible at once; the rest can be scrolled.
class ModernIndoorWidget
    extends ThemedMapControllingWidget<ModernIndoorWidgetColorScheme> {
  /// Determines whether the roof button is displayed.
  /// If [showRoof] == false, the roof button is hidden
  /// and the maximum number of visible floors increases to 5.
  final bool showRoof;

  const ModernIndoorWidget({
    ModernIndoorWidgetColorScheme? light,
    ModernIndoorWidgetColorScheme? dark,
    this.showRoof = true,
    super.key,
  }) : super(
          light: light ?? defaultLightColorScheme,
          dark: dark ?? defaultDarkColorScheme,
        );

  /// Default color scheme for light mode.
  static const ModernIndoorWidgetColorScheme defaultLightColorScheme =
      ModernIndoorWidgetColorScheme(
    surfaceColor: Color(0xffffffff),
    selectedFloorColor: Color(0x17141414),
    floorTextColor: Color(0xFF898989),
    selectedFloorTextColor: Color(0xFF141414),
    floorMarkColor: Color(0xFF0059D6),
    separatorColor: Color(0x4D898989),
  );

  /// Default color scheme for dark mode.
  static const ModernIndoorWidgetColorScheme defaultDarkColorScheme =
      ModernIndoorWidgetColorScheme(
    surfaceColor: Color(0xff141414),
    selectedFloorColor: Color(0x17FFFFFF),
    floorTextColor: Color(0xFF898989),
    selectedFloorTextColor: Color(0xffffffff),
    floorMarkColor: Color(0xFF057DDF),
    separatorColor: Color(0x4D898989),
  );

  @override
  ThemedMapControllingWidgetState<ModernIndoorWidget,
          ModernIndoorWidgetColorScheme>
      createState() => _ModernIndoorWidgetState();
}

class _ModernIndoorWidgetState extends ThemedMapControllingWidgetState<
    ModernIndoorWidget, ModernIndoorWidgetColorScheme> {
  final scrollController = ScrollController();

  static const singleElementHeight = 44.0;
  static const widgetWidth = 44.0;
  static const fadeHeight = 34.0;
  static const _maxVisibleLevelsWithRoof = 4;
  static const _maxVisibleLevelsWithoutRoof = 5;

  int get maxVisibleLevels => widget.showRoof
      ? _maxVisibleLevelsWithRoof
      : _maxVisibleLevelsWithoutRoof;

  final ValueNotifier<bool> showTopShadow = ValueNotifier(false);
  final ValueNotifier<bool> showBottomShadow = ValueNotifier(false);

  late sdk.IndoorControlModel model;

  ValueNotifier<int?> activeLevel = ValueNotifier(null);
  ValueNotifier<List<String>> levelNames = ValueNotifier([]);

  StreamSubscription<int?>? activeLevelSubscription;
  StreamSubscription<List<String>>? levelNamesSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    // ignore: unused_local_variable
    final guard = sdk.setupBssEventsSourceFromSdk(DGis().context);
    model = sdk.IndoorControlModel(map);
    activeLevelSubscription = model.activeLevelIndexChannel.listen((idx) {
      if (idx != activeLevel.value) {
        activeLevel.value = idx;
        if (idx != null) {
          centerFloorInScrollView(idx, animated: true);
        } else if (!widget.showRoof) {
          // If the roof is hidden and the active level is reset,
          // center on the first floor.
          centerFloorInScrollView(0, animated: true);
        }
      }
    });
    levelNamesSubscription = model.levelNamesChannel.listen((levels) {
      if (levels != levelNames.value) {
        levelNames.value = levels;
        if (levels.length > maxVisibleLevels) {
          scrollController.addListener(updateFadeVisibility);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final activeLevelIdx = model.activeLevelIndex;
            if (activeLevelIdx != null) {
              centerFloorInScrollView(activeLevelIdx, animated: false);
            } else if (!widget.showRoof) {
              // If the roof is hidden and there is no active level,
              // center on the first floor (index 0).
              centerFloorInScrollView(0, animated: false);
            }
            updateFadeVisibility();
          });
        } else {
          scrollController.removeListener(updateFadeVisibility);
          showTopShadow.value = false;
          showBottomShadow.value = false;
        }
      }
    });
  }

  @override
  void onDetachedFromMap() {
    activeLevelSubscription?.cancel();
    levelNamesSubscription?.cancel();
    activeLevelSubscription = null;
    levelNamesSubscription = null;
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(updateFadeVisibility)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: levelNames,
      builder: (context, levels, _) {
        if (levels.isEmpty || (levels.length < 2 && !widget.showRoof)) {
          return const SizedBox.shrink();
        }

        final numberOfVisibleLevels = min(levels.length, maxVisibleLevels);
        final levelsListHeight = numberOfVisibleLevels * singleElementHeight;
        final roofHeight = widget.showRoof ? singleElementHeight : 0.0;
        final totalHeight = roofHeight + levelsListHeight;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Color(0x0A000000),
                spreadRadius: 0.5,
              ),
            ],
          ),
          width: widgetWidth,
          height: totalHeight,
          child: Column(
            children: [
              if (widget.showRoof) _buildRoofButton(),
              Expanded(
                child: _buildLevelsList(levels),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Roof button. When the roof is selected, activeLevelIndex == null.
  Widget _buildRoofButton() {
    final dividerWidth = 1.0 / MediaQuery.devicePixelRatioOf(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          withBssEventsSourceFromSdk(() => model.activeLevelIndex = null);
        },
        splashColor: colorScheme.selectedFloorColor,
        child: ValueListenableBuilder(
          valueListenable: activeLevel,
          builder: (context, level, _) {
            final isRoofSelected = level == null;
            return Container(
              width: widgetWidth,
              height: singleElementHeight,
              decoration: BoxDecoration(
                color: isRoofSelected
                    ? colorScheme.selectedFloorColor
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.separatorColor,
                    width: dividerWidth,
                  ),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'packages/$pluginName/assets/icons/dgis_roof.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isRoofSelected
                        ? colorScheme.selectedFloorTextColor
                        : colorScheme.floorTextColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Scrollable list of floors with fade overlays.
  Widget _buildLevelsList(List<String> levels) {
    final reversedLevels = levels.reversed.toList();
    final quantity = reversedLevels.length;
    final dividerWidth = 1.0 / MediaQuery.devicePixelRatioOf(context);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              _snapToNearestFloor();
            }
            return false;
          },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            itemCount: quantity,
            padding: EdgeInsets.zero,
            itemBuilder: (context, reversedIndex) {
              final index = levels.length - 1 - reversedIndex;
              return ValueListenableBuilder(
                valueListenable: activeLevel,
                builder: (context, level, _) {
                  final isSelected =
                      level != null && levels[index] == levels[level];
                  final isLastBottom = reversedIndex == quantity - 1;
                  return Stack(
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () {
                            withBssEventsSourceFromSdk(
                              () => model.activeLevelIndex = index,
                            );
                            centerFloorInScrollView(index, animated: true);
                          },
                          splashColor: colorScheme.selectedFloorColor,
                          child: Container(
                            width: widgetWidth,
                            height: singleElementHeight,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.selectedFloorColor
                                  : Colors.transparent,
                              border: isLastBottom
                                  ? null
                                  : Border(
                                      bottom: BorderSide(
                                        color: colorScheme.separatorColor,
                                        width: dividerWidth,
                                      ),
                                    ),
                              borderRadius: isLastBottom
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                levels[index],
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 22 / 16,
                                  letterSpacing: -0.24,
                                  color: isSelected
                                      ? colorScheme.selectedFloorTextColor
                                      : colorScheme.floorTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (withBssEventsSourceFromSdk(
                        () => model.isLevelMarked(index),
                      ))
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              right: 8,
                            ),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.floorMarkColor,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Top fade overlay (gradient from background color to transparent).
        ValueListenableBuilder(
          valueListenable: showTopShadow,
          child: Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: ShadowGradient(
                stops: 20,
                startOpacity: 0.9,
                endOpacity: 0.1,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                height: fadeHeight,
                color: colorScheme.surfaceColor,
              ),
            ),
          ),
          builder: (context, shouldShow, child) {
            if (!shouldShow) return const SizedBox.shrink();
            return child!;
          },
        ),
        // Bottom fade overlay (gradient from transparent to background color).
        ValueListenableBuilder(
          valueListenable: showBottomShadow,
          child: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: ShadowGradient(
                stops: 20,
                startOpacity: 0.9,
                endOpacity: 0.1,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                height: fadeHeight,
                color: colorScheme.surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          builder: (context, shouldShow, child) {
            if (!shouldShow) return const SizedBox.shrink();
            return child!;
          },
        ),
      ],
    );
  }

  /// Centers the floor with the given original [index] in the visible scroll area.
  void centerFloorInScrollView(int index, {required bool animated}) {
    if (!scrollController.hasClients) return;

    final count = levelNames.value.length;
    if (count <= maxVisibleLevels) return;

    final reversedIndex = count - 1 - index;

    final scrollViewHeight = min(count, maxVisibleLevels) * singleElementHeight;
    final targetOffsetY =
        reversedIndex * singleElementHeight - scrollViewHeight * 0.5;
    final maxOffsetY = scrollController.position.maxScrollExtent;
    final clampedOffsetY = targetOffsetY.clamp(0.0, maxOffsetY);

    if (animated) {
      scrollController.animateTo(
        clampedOffsetY,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      scrollController.jumpTo(clampedOffsetY);
    }
  }

  /// Snaps the scroll position to the nearest floor after dragging ends.
  void _snapToNearestFloor() {
    if (!scrollController.hasClients) return;

    final count = levelNames.value.length;
    if (count <= maxVisibleLevels) return;

    final scrollViewHeight = min(count, maxVisibleLevels) * singleElementHeight;
    final halfScrollViewHeight = scrollViewHeight * 0.5;
    const halfFloorHeight = singleElementHeight * 0.5;
    final currentOffset = scrollController.offset;
    final centerY = currentOffset + halfScrollViewHeight;

    final targetReversedIndex =
        (centerY / singleElementHeight).floor().clamp(0, count - 1);
    final floorTopY = targetReversedIndex * singleElementHeight;

    final targetOriginalIndex = count - 1 - targetReversedIndex;
    final currentActiveIndex = activeLevel.value;

    var guidedCenterY = centerY;

    if (currentActiveIndex != null &&
        targetOriginalIndex == currentActiveIndex) {
      // Attempting to switch to the already active floor.
      // Using golden ratio logic (31%/69%).
      // 0.31 and 0.19 are solutions of the system of equations:
      //   x + y = 0.5
      //   x / y = 1.62 (golden ratio)
      if (centerY < floorTopY + 0.31 * singleElementHeight) {
        // One floor up.
        guidedCenterY = floorTopY - halfFloorHeight;
      } else if (centerY > floorTopY + 0.69 * singleElementHeight) {
        // One floor down.
        guidedCenterY = floorTopY + 3.0 * halfFloorHeight;
      } else {
        // Stay in place.
        guidedCenterY = floorTopY + halfFloorHeight;
      }
    } else {
      // Switching to a new floor.
      // When a fixed floor (roof) is present, the scrollView displays
      // an odd number of floors — need to adjust by half a floor.
      final fixedFloorOffset = widget.showRoof ? singleElementHeight / 2 : 0.0;
      guidedCenterY = floorTopY + halfFloorHeight + fixedFloorOffset;
    }

    final guidedOffset = guidedCenterY - halfScrollViewHeight;
    final maxOffset = scrollController.position.maxScrollExtent;
    final clampedOffset = guidedOffset.clamp(0.0, maxOffset);

    scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  /// Updates fade overlay visibility based on the scroll position.
  void updateFadeVisibility() {
    if (!scrollController.hasClients) return;

    final offset = scrollController.offset;
    final contentHeight = scrollController.position.maxScrollExtent +
        scrollController.position.viewportDimension;
    final viewportHeight = scrollController.position.viewportDimension;

    showTopShadow.value = offset > 0;
    showBottomShadow.value = offset + viewportHeight < contentHeight;
  }
}

class ModernIndoorWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final Color selectedFloorColor;
  final Color floorTextColor;
  final Color selectedFloorTextColor;
  final Color floorMarkColor;
  final Color separatorColor;

  const ModernIndoorWidgetColorScheme({
    required this.surfaceColor,
    required this.selectedFloorColor,
    required this.floorTextColor,
    required this.selectedFloorTextColor,
    required this.floorMarkColor,
    required this.separatorColor,
  });

  @override
  ModernIndoorWidgetColorScheme copyWith({
    Color? surfaceColor,
    Color? selectedFloorColor,
    Color? floorTextColor,
    Color? selectedFloorTextColor,
    Color? floorMarkColor,
    Color? separatorColor,
  }) {
    return ModernIndoorWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      selectedFloorColor: selectedFloorColor ?? this.selectedFloorColor,
      floorTextColor: floorTextColor ?? this.floorTextColor,
      selectedFloorTextColor:
          selectedFloorTextColor ?? this.selectedFloorTextColor,
      floorMarkColor: floorMarkColor ?? this.floorMarkColor,
      separatorColor: separatorColor ?? this.separatorColor,
    );
  }
}
