import 'package:flutter/material.dart';

class NavigationService{
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  BuildContext? get appContext => navigationKey.currentContext;

  static final NavigationService _instance = NavigationService._private();
  static NavigationService get instance => _instance;
  NavigationService._private();

  pushReplacementNamed(
      String routeName, {
        Object? arguments,
      }) async {
    return navigationKey.currentState?.pushReplacementNamed(routeName,arguments: arguments);
  }

  pushNamed(
      String routeName, {
        Object? arguments,
      }) async {
    return navigationKey.currentState?.pushNamed(routeName,arguments: arguments);
  }


  void pop(){
    return navigationKey.currentState?.pop();
  }

  void showSnackBar({
    required String msg,
  }) {
    if(appContext == null){
      return;
    }
    ScaffoldMessenger.of(appContext!).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }

}