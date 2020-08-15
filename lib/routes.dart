import 'package:flutter/cupertino.dart';
import 'screens/bottom_nav_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import './splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Null> isLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userToken = prefs.getString('user_token') ?? null;
  print(userToken);
  return userToken;
}

var isLoginCheck = isLogin();

final routes = {
  '/signin': (BuildContext context) => new SignUpScreen(),
  '/signup': (BuildContext context) => new SignInScreen(),
  '/home': (BuildContext context) => new BottomNavScreen(),
  '/': (BuildContext context) => SplashScreen(),
};
