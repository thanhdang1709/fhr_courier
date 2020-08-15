import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../bottom_nav_screen.dart';
import '../../bottom_nav_screen.dart';
import '../signup_screen.dart';
import 'background_login.dart';
import 'package:http/http.dart' as http;

import 'package:flare_flutter/flare_actor.dart';

class Body extends StatefulWidget {
  const Body({
    Key key,
  }) : super(key: key);
  _LoginFormState createState() => _LoginFormState();
}

@override
class _LoginFormState extends State<Body> {
  bool _obscureText;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _username;
  String _password;

  String animationType = "idle";
  final passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _obscureText = false;
    super.dispose();
  }

  @override
  void initState() {
    _obscureText = true;

    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        setState(() {
          animationType = "test";
        });
      } else {
        setState(() {
          animationType = "idle";
        });
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Form(
        key: _formKey,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "ĐĂNG NHẬP",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                Center(
                  child: Container(
                      height: 200,
                      width: 200,
                      child: CircleAvatar(
                        child: ClipOval(
                          child: new FlareActor(
                            "assets/teddy_test.flr",
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: animationType,
                          ),
                        ),
                        backgroundColor: Colors.white,
                      )),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(25)),
                  child: TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Vui lòng điền thông tin';
                      }
                    },
                    onChanged: (value) {
                      this._username = emailController.text;
                    },
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: "Nhập email hoặc sđt",
                        border: InputBorder.none),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(25)),
                  child: TextFormField(
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Vui lòng điền thông tin';
                      }
                    },
                    onChanged: (value) {
                      this._password = passwordController.text;
                    },
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      hintText: "Nhập mật khẩu",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FlatButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                        color: Colors.blue[500],
                        onPressed: () async {
                          //print(emailController.text);
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              animationType = 'success';
                            });

                            _login(this._username, this._password)
                                .then((data) async {
                              if (data['code'] == 200) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    "user_token", data['data']);
                                await prefs.setString(
                                    "user_data", this._username);
                                _showAlert(
                                    'Đăng nhập thành công', Colors.green);
                                Future.delayed(new Duration(milliseconds: 1000),
                                    () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            BottomNavScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                });
                              }
                              if (data['code'] == 401) {
                                setState(() {
                                  animationType = 'fail';
                                });
                                _showAlert(data['message'], Colors.red);
                              }
                            });
                            //return showDialog(
                            //  context: context,
                            //  builder: (context) {
                            //    return AlertDialog(
                            //      //content: Text('Tài khoản ${emailController.text} không hợp lệ!'),
                            //      content: Text('Đăng nhập thành công!'),
                            //    );
                            //  },
                            //);
                          } else {
                            setState(() {
                              animationType = 'fail';
                            });
                          }
                        },
                        child: Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(vertical: 15),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //       Text("Bạn chưa có tài khoản?"),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.push(context,
                //               MaterialPageRoute(builder: (context) {
                //             return SignUpScreen();
                //           }));
                //         },
                //         child: Text(
                //           " Đăng ký",
                //           style: TextStyle(
                //               color: Colors.blue[500],
                //               fontWeight: FontWeight.bold),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _login(_usernameController, _passwordController) async {
    var url = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/member/login';
    try {
      Map<String, dynamic> body = {
        'username': _usernameController,
        'password': _passwordController
      };
      print(body);
      var response = await http.post(url, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      //_alertAndRedirect();
      if (200 == response.statusCode) {
        //_alertAndRedirect();
        Map<String, dynamic> map = json.decode(response.body);
        return map;
        //print(map['data']['access_token']);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => BottomNavScreen())).then(
            (value) => Fluttertoast.showToast(
                msg: "Đăng nhập thành công",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0));

        //return response.body;
      }
      if (400 == response.statusCode) {
        Fluttertoast.showToast(
            msg: "Đăng nhập không thành công, xin thử lại",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print(e);
    }
  }

  _showAlert(text, color) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  _alertAndRedirect() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => BottomNavScreen())).then(
        (value) => Fluttertoast.showToast(
            msg: "Đăng nhập thành công",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0));
  }
}
