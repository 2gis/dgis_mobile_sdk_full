import 'package:flutter/widgets.dart';

class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(context, child, details) {
    return child;
  }
}
