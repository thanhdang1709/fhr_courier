import 'package:flutter/material.dart';
import '../config/palette.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/filter_history_screen.dart';
import '../screens/screens.dart';
import '../screens/welcome/welcome_screen.dart';
import '../widgets/drawer.dart';
import '../widgets/network_sensity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List _screens = [
    StatsScreen(),
    HomeScreen(),
    FieldScreen(),
    // HistoryScreen(),
    ShowcaseHistoryTimeline(),
  ];
  int _currentIndex = 0;

  Future<Null> checkIsLogin() async {
    String _token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("user_token");
    if (_token != "" && _token != null) {
      print("alreay login.");
      //your home page is loaded
    } else {
      //replace it with the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => new WelcomeScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bạn muốn thoát khỏi ứng dụng?'),
            content: Text('Vui lòng xác nhận!!'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return NetworkSensitive(
      child: Scaffold(
        drawer: CustomeDrawer(),
        body: WillPopScope(
            child: _screens[_currentIndex], onWillPop: _onBackPressed),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Palette.primaryColor,
          elevation: 0.0,
          items: [
            Icons.home,
            Icons.insert_chart,
            Icons.note_add,
            Icons.event_note
            //Icons.info
          ]
              .asMap()
              .map((key, value) => MapEntry(
                    key,
                    BottomNavigationBarItem(
                      title: Text(''),
                      icon: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: _currentIndex == key
                              ? Colors.blue[600]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Icon(value),
                      ),
                    ),
                  ))
              .values
              .toList(),
        ),
      ),
    );
  }
}
