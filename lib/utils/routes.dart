import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/admin_page.dart';
import '../screens/main_screen.dart';
import '../screens/welcome_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      main: (context) => MainScreen(),
      admin: (context) => AdminPage(),
    };
  }
}
