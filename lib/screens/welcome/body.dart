import 'dart:convert';

import 'package:flutter/material.dart';
import '../../screens/guest_field_screen.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/palette.dart';
import '../auth/signin_screen.dart';
import 'rounded_button.dart';
import '../auth/signup_screen.dart';
import 'background.dart';
import 'package:http/http.dart' as http;

// Future _getInfoCase() async {
//   var url = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/cv19/report';
//   try {
//     var response = await http.get(url);
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     if (200 == response.statusCode) {
//       Map<String, dynamic> map = json.decode(response.body);
//       return map['code'];
//     }

//     if (400 == response.statusCode) {}
//   } catch (e) {
//     print(e);
//   }
// }

class Body extends StatelessWidget {
  Widget build(BuildContext context) {
    // This size provice us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    return Background(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Welcome to\n FHR COURIER',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold)),
              ]),
        ),
        Image.asset(
          "assets/images/bmt_logo_slogan.png",
          height: size.height * 0.4,
        ),
        RoundedButton(
            text: "ĐĂNG NHẬP",
            color: Colors.blue[300],
            press: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return SignInScreen();
                },
              ));
            }),
        // SizedBox(height: 10),
        // RoundedButton(
        //   text: "ĐĂNG KÝ",
        //   color: Colors.cyan,
        //   press: () {
        //     Navigator.push(context, MaterialPageRoute(
        //       builder: (context) {
        //         return SignUpScreen();
        //       },
        //     ));
        //   },
        // ),
        // SizedBox(height: 10),
        // RoundedButton(
        //   text: "KHÁCH HÀNG",
        //   color: Palette.primaryColor,
        //   press: () {
        //     Navigator.push(context, MaterialPageRoute(
        //       builder: (context) {
        //         return GuestFieldScreen();
        //       },
        //     ));
        //   },
        // ),
      ],
    ));
  }
}
