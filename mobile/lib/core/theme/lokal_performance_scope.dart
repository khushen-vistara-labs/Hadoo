import 'package:flutter/widgets.dart';

/// Rendering budget shared by all routes, including older non-Riverpod widgets.
/// Keeps interaction transitions, but removes continuous/decorative GPU work.
class LokalPerformanceScope extends InheritedWidget {
  const LokalPerformanceScope({
    super.key,
    required this.enabled,
    required super.child,
  });
  final bool enabled;
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LokalPerformanceScope>()
          ?.enabled ??
      false;
  @override
  bool updateShouldNotify(LokalPerformanceScope oldWidget) =>
      enabled != oldWidget.enabled;
}
