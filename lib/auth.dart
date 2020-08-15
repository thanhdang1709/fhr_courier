import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import './models/user.dart';

class AuthModel {
  bool _stayLoggedIn = true;
  User _user;

  Future<bool> login({
    @required String username,
    @required String password,
  }) async {
    String _username = username;
    String _password = password;

    // TODO: API LOGIN CODE HERE
    await Future.delayed(Duration(seconds: 3));
    print("Logging In => $_username, $_password");

    SharedPreferences.getInstance().then((prefs) {
      var _save = json.encode(_user.toJson());
      print("Data: $_save");
      prefs.setString("user_data", _save);
    });
  }

  // static _isLogin() {}
}
