import 'package:tadhkir_app/features/home_screen.dart';
import 'package:tadhkir_app/features/second_features/contact_screen.dart';
import 'package:tadhkir_app/features/second_features/test.dart';
import 'package:flutter/material.dart';

class RouteName {
  static String khomeScreen = '/';
  static String ktest = '/test';
  static String kcontact = '/contact';
}

class AppRoute {
  static Route<dynamic> routeApp(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(builder: (ctx) => const HomeScreen());
      // case '/test':
      //   return MaterialPageRoute(
      //     builder: (ctx) => ContactPickerDialog(),
      //   );
      case '/contact':
        return MaterialPageRoute(
          builder: (ctx) => const ContactScreen(),
          settings: RouteSettings(arguments: routeSettings.arguments),
        );
      default:
        return MaterialPageRoute(builder: (ctx) => const HomeScreen());
    }
  }
}
