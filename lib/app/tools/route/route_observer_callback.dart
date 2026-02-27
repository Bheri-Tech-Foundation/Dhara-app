
import 'package:flutter/widgets.dart';

class RouteObserverWithCallback extends NavigatorObserver {
  final Function(Route<dynamic>, Route<dynamic>?) onRouteChanged;
  // final Function(String path)? onTabsPathNotified;

  RouteObserverWithCallback( {required this.onRouteChanged});

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    onRouteChanged(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    
    onRouteChanged(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    
    onRouteChanged(newRoute!, oldRoute);
  }



  
}