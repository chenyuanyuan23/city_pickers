import 'package:flutter/material.dart';
import 'picker_popup_route.dart';

class InheritRouteWidget extends InheritedWidget {
  final CityPickerRoute? router;

  const InheritRouteWidget({super.key, required this.router, required super.child});

  static InheritRouteWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritRouteWidget>();
  }

  @override
  bool updateShouldNotify(InheritRouteWidget oldWidget) {
    return oldWidget.router != router;
  }
}
