import 'package:flutter/material.dart';
import 'package:flutter_task_app/screens/auth/login_screen.dart';
import 'package:flutter_task_app/screens/auth/signup_screen.dart';
import 'package:flutter_task_app/screens/chat/chat_screen.dart';
import 'package:flutter_task_app/screens/chat/user_list_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LoginScreen.route:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LoginScreen(),
      );

    case SignUpScreen.route:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SignUpScreen(),
      );
    case UserListScreen.route:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UserListScreen(),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Screen does not exist!'),
          ),
        ),
      );
  }
}
