import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteObserverSingleton {
  static final RouteObserver instance = RouteObserver();
}

class RouteObserver extends NavigatorObserver {
  Future<void> storeLastVisitedRoute(String route,
      {Map<String, dynamic>? arguments}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastVisitedRoute', route);

    if (arguments != null) {
      await prefs.setString('lastVisitedRouteArgs', jsonEncode(arguments));
    } else {
      await prefs.remove('lastVisitedRouteArgs');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      storeLastVisitedRoute(route.settings.name!,
          arguments: route.settings.arguments as Map<String, dynamic>?);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      storeLastVisitedRoute(newRoute!.settings.name!,
          arguments: newRoute.settings.arguments as Map<String, dynamic>?);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
