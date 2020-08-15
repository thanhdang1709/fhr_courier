import 'dart:convert';

import 'package:flutter/material.dart';
import '../config/palette.dart';
import '../screens/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

class CustomeDrawer extends StatelessWidget {
  String username = "Hello";
  bool _isLoading = true;
  Future getInfo() async {
    var url = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/member/profile';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? null;
    try {
      var response = await http.get(url, headers: {"Authorization": userToken});
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = json.decode(response.body);
        //print(map['data']['fullname']);
        this._isLoading = false;
        return map['data']['fullname'];
      }
      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
  }

  //String usename = checkIsLogin();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
          future: getInfo(),
          // ignore: missing_return
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //print(snapshot.data);
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      height: 100,
                      child: DrawerHeader(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          snapshot.data,
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                          color: Palette.primaryColor,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Đăng xuất'),
                      onTap: () async {
                        _logout().then((_) => {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          WelcomeScreen())).then((value) =>
                                  Fluttertoast.showToast(
                                      msg: "Đăng xuất thành công",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0))
                            });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)));
              }
            }
          }),
    );
  }

  _logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove("user_data");
    await pref.remove("user_token");
  }
}
