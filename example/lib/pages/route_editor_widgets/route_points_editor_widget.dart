import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'route_points_editor_theme.dart';

class RoutePointsEditorWidget extends StatefulWidget {
  final sdk.RouteEditorController controller;
  final RoutePointsEditorTheme theme;
  final String? routeDuration;
  final VoidCallback onCancel;
  final void Function(int index) onPointTap;
  final VoidCallback onAddStop;
  final VoidCallback? onPointDeleted;

  const RoutePointsEditorWidget({
    required this.controller,
    required this.theme,
    required this.onCancel,
    required this.onPointTap,
    required this.onAddStop,
    this.routeDuration,
    this.onPointDeleted,
    super.key,
  });

  @override
  State<RoutePointsEditorWidget> createState() =>
      _RoutePointsEditorWidgetState();
}

class _RoutePointsEditorWidgetState extends State<RoutePointsEditorWidget> {
  List<sdk.RoutePointUI> _points = [];

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.controller.routePoints.value);
    widget.controller.routePoints.addListener(_onPointsChanged);
  }

  @override
  void dispose() {
    widget.controller.routePoints.removeListener(_onPointsChanged);
    super.dispose();
  }

  void _onPointsChanged() {
    setState(() {
      _points = List.from(widget.controller.routePoints.value);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    var adjustedNewIndex = newIndex;
    setState(() {
      if (adjustedNewIndex > oldIndex) {
        adjustedNewIndex -= 1;
      }
      final item = _points.removeAt(oldIndex);
      _points.insert(adjustedNewIndex, item);
    });
    if (_points.length >= 2) {
      widget.controller.setRoutePoints(_points);
      widget.onPointDeleted?.call();
    }
  }

  void _deletePoint(int index) {
    if (_points.length <= 2) return;

    setState(() {
      _points.removeAt(index);
    });
    widget.controller.setRoutePoints(_points);
    widget.onPointDeleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            Flexible(
              child: _buildPointsList(),
            ),
            _buildAddStopButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      height: 16,
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: widget.theme.handleColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const cancelText = 'Cancel';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onCancel,
            child: Text(
              cancelText,
              style: widget.theme.cancelButtonTextStyle,
            ),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Route',
                style: widget.theme.headerTitleTextStyle,
              ),
              if (widget.routeDuration != null)
                Text(
                  widget.routeDuration!,
                  style: widget.theme.headerSubtitleTextStyle,
                ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: _measureTextWidth(
              cancelText,
              widget.theme.cancelButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  Widget _buildPointsList() {
    final canDelete = _points.length > 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndicatorsColumn(),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: _points.length,
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 4,
                    color: widget.theme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final point = _points[index];
                  final isLast = index == _points.length - 1;

                  return _buildPointItem(
                    key: ValueKey('point_$index'),
                    point: point,
                    index: index,
                    isLast: isLast,
                    canDelete: canDelete,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsColumn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _points.length; i++) ...[
              _buildIndicatorItem(i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorItem(int index) {
    final isFirst = index == 0;
    final isLast = index == _points.length - 1;
    final isIntermediate = !isFirst && !isLast;

    return SizedBox(
      height: 48,
      child: Column(
        children: [
          if (!isFirst)
            Expanded(
              child: Container(
                width: 2,
                color: widget.theme.routeLineColor,
              ),
            )
          else
            const Spacer(),
          _buildPointCircle(isFirst, isLast, isIntermediate),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: widget.theme.routeLineColor,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPointItem({
    required Key key,
    required sdk.RoutePointUI point,
    required int index,
    required bool isLast,
    required bool canDelete,
  }) {
    return SizedBox(
      key: key,
      height: 48,
      child: GestureDetector(
        onTap: () => widget.onPointTap(index),
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: widget.theme.dividerColor,
                      width: 0.5,
                    ),
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    point.label,
                    style: widget.theme.pointLabelTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: () => _deletePoint(index),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: widget.theme.deleteButtonColor,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.drag_handle,
                    size: 20,
                    color: widget.theme.dragHandleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointCircle(bool isFirst, bool isLast, bool isIntermediate) {
    if (isFirst) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.theme.startPointColor,
            width: 3.5,
          ),
        ),
      );
    } else if (isIntermediate) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: widget.theme.intermediatePointColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.theme.finishPointColor,
            width: 3.5,
          ),
        ),
      );
    }
  }

  Widget _buildAddStopButton() {
    return GestureDetector(
      onTap: widget.onAddStop,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.theme.addStopIconColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: widget.theme.addStopIconColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add stop',
              style: widget.theme.addStopTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
