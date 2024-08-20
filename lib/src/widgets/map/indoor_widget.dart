import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../shadow_gradient.dart';

import 'map_widget_theme.dart';
import 'themed_map_controlling_widget.dart';

// Виджет для переключения этажей в здании.
// Представляет колонку с названиями этажей; активный этаж подсвечивается.
// При нажатии на название этажа переключается этажный план.
// Одновременно отображается не более 5 этажей; непоместившиеся можно прокручивать.
class IndoorWidget extends ThemedMapControllingWidget<IndoorWidgetTheme> {
  const IndoorWidget({
    IndoorWidgetTheme? light,
    IndoorWidgetTheme? dark,
    super.key,
  }) : super(
          light: light ?? defaultLightTheme,
          dark: dark ?? defaultDarkTheme,
        );

  /// Цветовая схема UI–элемента для светлого режима по умолчанию.
  static const IndoorWidgetTheme defaultLightTheme = IndoorWidgetTheme(
    surfaceColor: Color(0xffffffff),
    selectedFloorColor: Color(0xFFCDE5F9),
    floorTextColor: Color(0xFF000000),
    floorMarkColor: Color(0xFF0059D6),
  );

  /// Цветовая схема UI–элемента для темного режима по умолчанию.
  static const IndoorWidgetTheme defaultDarkTheme = IndoorWidgetTheme(
    surfaceColor: Color(0xff121212),
    selectedFloorColor: Color(0xFF16232D),
    floorTextColor: Color(0xffffffff),
    floorMarkColor: Color(0xFF0059D6),
  );

  @override
  ThemedMapControllingWidgetState<IndoorWidget, IndoorWidgetTheme> createState() => _IndoorWidgetState();
}

class _IndoorWidgetState extends ThemedMapControllingWidgetState<IndoorWidget, IndoorWidgetTheme> {
  final scrollController = ScrollController();

  static const singleElementHeight = 40.0;
  static const widgetWidth = 48.0;
  static const widgetMaxHeight = 200.0;

  final ValueNotifier<bool> showTopShadow = ValueNotifier(false);
  final ValueNotifier<bool> showBottomShadow = ValueNotifier(false);

  late sdk.IndoorControlModel model;

  ValueNotifier<int?> activeLevel = ValueNotifier(null);
  ValueNotifier<List<String>> levelNames = ValueNotifier([]);

  StreamSubscription<int?>? activeLevelSubscription;
  StreamSubscription<List<String>>? levelNamesSubscription;

  @override
  void onAttachedToMap(sdk.Map map) {
    model = sdk.IndoorControlModel(map);
    activeLevelSubscription = model.activeLevelIndexChannel.listen((idx) {
      if (idx != activeLevel.value) {
        activeLevel.value = idx;
      }
    });
    levelNamesSubscription = model.levelNamesChannel.listen((levels) {
      if (levels != levelNames.value) {
        levelNames.value = levels;
        if (levels.length > 5) {
          scrollController.addListener(updateShadows);
          updateShadows();
        } else {
          updateShadows();
          scrollController.removeListener(updateShadows);
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
      ..removeListener(updateShadows)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: widgetMaxHeight),
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: levelNames,
            builder: (context, levels, _) {
              final quantity = levels.length;

              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                height: quantity * singleElementHeight,
                width: widgetWidth,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  reverse: true,
                  itemCount: quantity,
                  itemBuilder: (context, index) {
                    return ValueListenableBuilder(
                      valueListenable: activeLevel,
                      builder: (context, level, _) {
                        final isSelected = level != null && levels[index] == levels[level];
                        return Stack(
                          children: [
                            Material(
                              type: MaterialType.transparency,
                              child: ListTile(
                                onTap: () {
                                  model.activeLevelIndex = index;
                                  scrollToShowLevel(
                                    index,
                                    singleElementHeight,
                                  );
                                },
                                contentPadding: EdgeInsets.zero,
                                textColor: theme.floorTextColor,
                                splashColor: theme.selectedFloorColor,
                                selectedColor: theme.floorTextColor,
                                selected: isSelected,
                                minTileHeight: singleElementHeight,
                                tileColor: Colors.transparent,
                                selectedTileColor: theme.selectedFloorColor,
                                title: Align(
                                  child: Text(
                                    maxLines: 1,
                                    softWrap: true,
                                    levels[index],
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            if (model.isLevelMarked(index))
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
                                      color: theme.floorMarkColor,
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
              );
            },
          ),
          // Верхняя тень, появляется если есть куда скроллить
          // за пределы текущей высоты виджеты
          ValueListenableBuilder(
            valueListenable: showTopShadow,
            builder: (context, shoudShow, _) {
              return Visibility(
                visible: shoudShow,
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
                      height: singleElementHeight,
                      color: theme.surfaceColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Нижняя тень, появляется если есть куда скроллить
          // за пределы текущей высоты виджеты
          ValueListenableBuilder(
            valueListenable: showBottomShadow,
            builder: (context, shouldShow, _) {
              return Visibility(
                visible: shouldShow,
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
                      height: singleElementHeight,
                      color: theme.surfaceColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Хелпер для скролла: делает так, чтобы выбранный этаж
  // всегда был в видимой области виджета.
  void scrollToShowLevel(int index, double elementHeight) {
    const countBeforeScroll = 5;
    final count = levelNames.value.length;

    if (count <= countBeforeScroll) {
      return;
    }

    final elementIndex = index;
    const minScrollY = 0.0;
    final maxScrollY = (count - countBeforeScroll) * elementHeight;

    final targetY = elementIndex * elementHeight;

    if (targetY - scrollController.offset < elementHeight) {
      scrollController.jumpTo(max(minScrollY, targetY - elementHeight));
    }
    if (targetY - scrollController.offset > (countBeforeScroll - 3) * elementHeight) {
      scrollController.jumpTo(
        min(maxScrollY, targetY - (countBeforeScroll - 3) * elementHeight),
      );
    }
  }

  void updateShadows() {
    if (scrollController.hasClients && scrollController.position.maxScrollExtent > 0) {
      final shouldShowAnyShadow = levelNames.value.length > 5;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      showTopShadow.value = shouldShowAnyShadow && currentScroll < maxScroll;
      showBottomShadow.value = shouldShowAnyShadow && currentScroll > 0.0;
    }
  }
}

class IndoorWidgetTheme extends MapWidgetTheme {
  final Color surfaceColor;
  final Color selectedFloorColor;
  final Color floorTextColor;
  final Color floorMarkColor;

  const IndoorWidgetTheme({
    required this.surfaceColor,
    required this.selectedFloorColor,
    required this.floorTextColor,
    required this.floorMarkColor,
  });

  @override
  IndoorWidgetTheme copyWith({
    Color? surfaceColor,
    Color? selectedFloorColor,
    Color? floorTextColor,
    Color? floorMarkColor,
  }) {
    return IndoorWidgetTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      selectedFloorColor: selectedFloorColor ?? this.selectedFloorColor,
      floorTextColor: floorTextColor ?? this.floorTextColor,
      floorMarkColor: floorMarkColor ?? this.floorMarkColor,
    );
  }
}
