
import 'package:flutter/widgets.dart';

class RouteChangeNotifier extends ChangeNotifier {
  String? currentRoute;

  String? currentTab;
  void updateRoute(String routeName) {
    currentRoute = routeName;
    notifyListeners();
  }

    void updateTab(String tabName) {

    currentTab = tabName;
    notifyListeners();
  }
}