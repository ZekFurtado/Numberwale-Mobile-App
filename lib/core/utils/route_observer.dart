import 'package:flutter/material.dart';

/// App-wide route observer. Lets pages react via [RouteAware] when they're
/// popped back into view (e.g. refreshing the cart after returning from
/// checkout) instead of only on their first build.
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
