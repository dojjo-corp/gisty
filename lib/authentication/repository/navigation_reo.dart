import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigationService? _instance;

  static NavigationService get instance {
    _instance ??= NavigationService();
    return _instance!;
  }

  NavigatorState get navigator => navigatorKey.currentState!;

  // Custom method for navigating to a named route.
  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }
}
