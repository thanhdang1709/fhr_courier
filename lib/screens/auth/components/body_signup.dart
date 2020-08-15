import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../screens/guest_field_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../signin_screen.dart';
import '../signup_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'background_signup.dart';

class Body extends StatefulWidget {
  const Body({
    Key key,
  }) : super(key: key);
  _BodyState createState() => _BodyState();
}

@override
class _BodyState extends State<Body> {
  bool _obscureText;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final fullnameController = TextEditingController();
  final passwordController = TextEditingController();
  String _email;
  String _phone;
  String _fullname;
  String _password;
  bool _isButtonDisabled;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    fullnameController.dispose();
    _obscureText = false;
    super.dispose();
  }

  @override
  void initState() {
    _isButtonDisabled = false;
    _obscureText = false;
    this._email;
    this._phone;
    this._fullname;
    this._password;
    super.initState();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final Color kPrimary = Colors.blue[100];

    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          // bottom: size.height * 0.5, top: size.height * 0.2),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "ĐĂNG KÝ",
                  style: TextStyle(
                      color: Colors.blue[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Image.asset(
                  "assets/images/signup.png",
                  width: size.width * 0.3,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 1),
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller: fullnameController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                      }
                    },
                    onChanged: (value) {
                      this._fullname = fullnameController.text;
                    },
                    decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: "Họ và tên",
                        border: InputBorder.none),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 3),
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller: phoneController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 10) {
                        return 'Vui lòng điền thông tin (tối thiểu 10 ký tự)';
                      }
                    },
                    onChanged: (value) {
                      this._phone = phoneController.text;
                    },
                    autocorrect: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        icon: Icon(Icons.phone_android),
                        labelText: "Số điện thoại",
                        border: InputBorder.none),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 3),
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                      }
                    },
                    onChanged: (value) {
                      this._email = emailController.text;
                    },
                    decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: "Email",
                        border: InputBorder.none),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 3),
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 6) {
                        return 'Vui lòng điền thông tin (tối thiểu 6 ký tự)';
                      }
                    },
                    onChanged: (value) {
                      this._password = passwordController.text;
                    },
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: "Mật khẩu",
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
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _addMember(_fullname, _phone, _email, _password)
                                .then((res) {
                              if (res['code'] == false) {
                                _showAlert(res['message'], Colors.red);
                              }
                              if (res['code'] == 200) {
                                _showAlert(res['message'], Colors.green);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SignInScreen()));
                              }
                              new CircularProgressIndicator();
                            });
                          }
                        },
                        child: Text(
                          "ĐĂNG KÝ",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Bạn đã có tài khoản?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return SignInScreen();
                          }));
                        },
                        child: Text(
                          " ĐĂNG NHẬP",
                          style: TextStyle(
                              color: Colors.blue[500],
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x12FFF7), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return GuestFieldScreen();
                          }));
                        },
                        child: Text(
                          "Khai báo y tế dành cho khách",
                          style: TextStyle(
                              color: Colors.blue[500],
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _addMember(fullname, phone, email, password) async {
    var url = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/member/add';
    try {
      Map<String, dynamic> body = {
        "fullname": fullname,
        "phone": phone,
        "email": email,
        "password": password
      };
      print(body);
      var response = await http.post(url, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = json.decode(response.body);
        return map;
      }
      if (400 == response.statusCode) {
        Fluttertoast.showToast(
            msg: "Tạo tài khoản không thành công, xin thử lại",
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
}
