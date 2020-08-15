import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'body.dart';

import '../bottom_nav_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    //this.isLoginCheck = isLogin();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(child: Body()),
    );
  }
}
