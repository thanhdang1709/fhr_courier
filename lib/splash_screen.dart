import 'package:flutter/material.dart';
import 'screens/bottom_nav_screen.dart';
import 'config/contanst.dart';

import 'screens/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> opacity;
  AnimationController controller;

  Future<Null> isLoginCheck;

  Future<Null> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? null;
    print(userToken);
    return userToken;
  }

  @override
  void initState() {
    this.isLoginCheck = isLogin();

    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 2500), vsync: this);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      navigationPage();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void navigationPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      print('splash screen');
      print(isLoginCheck);
      if (isLoginCheck == null) {
        return new WelcomeScreen();
      } else {
        return new BottomNavScreen();
      }
    }));
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(color: transparentYellow),
        child: SafeArea(
          child: new Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Opacity(
                      opacity: opacity.value,
                      child:
                          new Image.asset('assets/images/bmt_logo_slogan.png')),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: RichText(
                //     text: TextSpan(
                //         style: TextStyle(color: Colors.black),
                //         children: [
                //           TextSpan(text: 'Powered by '),
                //           TextSpan(
                //               text: 'mal.vn',
                //               style: TextStyle(fontWeight: FontWeight.bold))
                //         ]),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
