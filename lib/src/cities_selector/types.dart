import 'package:flutter/material.dart';

typedef CityItemWidgetBuilder = Widget Function(BuildContext context);

/// Called to build IndexBar.
typedef IndexBarBuilder = Widget Function(BuildContext context, List<String> tags);

/// Called to build index hint.
typedef IndexHintBuilder = Widget Function(BuildContext context, String hint);
