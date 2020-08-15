import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/city.dart';
import '../screens/welcome/welcome_screen.dart';
import '../widgets/network_sensity.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart' as http;
import '../config/palette.dart';
import '../services/city_service.dart';
import '../data/data.dart';
import '../services/city_service.dart';

import 'package:http/http.dart' as http;

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

const baseUrl = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/';

class GuestFieldScreen extends StatefulWidget {
  @override
  _GuestFieldScreenState createState() => _GuestFieldScreenState();
}

class _GuestFieldScreenState extends State<GuestFieldScreen> {
  // List<City> _cities = _listCities().map((data) => City.fromJson(data)).toList();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _fromDate;
  DateTime _toDate;

  final positionController = TextEditingController();
  final descriptionController = TextEditingController();
  final nearbyController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();

  final format = DateFormat("yyyy-MM-dd HH:mm");

  String _position;
  String _description;
  String _nearby;
  String _fullname;
  String _phone;

  bool _isDontSubmit;

  String _city;
  String _district;

  List<Map> districts;

  Color colorTextField = Colors.white;
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xff1CD8D2), Color(0xff93EDC7)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    //this.get_cities = CityService.getListCities() as List;

    this.districts = [
      {"id": 0, "name": "<New>"},
    ];
    this._fromDate;
    this._toDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //List<DropdownMenuItem<String>> items = [];
    //Size sizeBottom = MediaQuery.of(context).viewInsets.bottom;
    return NetworkSensitive(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_toDate != null && _fromDate != null) {
              if (_city != null && _district != null) {
                if (_formKey.currentState.validate()) {
                  Map<String, dynamic> body = {
                    "from_datetime": _fromDate.toString(),
                    "to_datetime": _toDate.toString(),
                    "location": positionController.text,
                    "activities": descriptionController.text,
                    "related_persons": nearbyController.text,
                    "fullname": fullnameController.text,
                    "phone": phoneController.text
                  };
                  addFieldFormGuest(body, _city, _district).then((res) {
                    if (res['code'] == 200) {
                      Fluttertoast.showToast(
                          msg: "Đăng ký khai báo thành công",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0);

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  WelcomeScreen()));
                    } else {
                      Fluttertoast.showToast(
                          msg: res['message'],
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    showInSnackBar(res['message']);
                  });
                }
              } else {
                showInSnackBar("Vui lòng nhập Tỉnh/TP");
              }
            } else {
              showInSnackBar("Vui lòng ngày đến và ngày đi");
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.lightBlueAccent,
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          // title: Text("FORM KHAI BÁO"),
          title: Text(
            "KHAI BÁO Y TẾ DÀNH CHO\n KHÁCH HÀNG",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              //foreground: Paint()..shader = linearGradient
            ),
          ),
          backgroundColor: Palette.primaryColor,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: size.width * 0.01),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(5)),
                                  child: BasicDateField(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.height * 0.01),
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: size.width * 0.01),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: BasicTimeField("fromDate"),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: size.width * 0.008),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: BasicTimeField("toDate"),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 3),
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: fullnameController,
                            decoration: InputDecoration(
                                icon: Icon(Icons.text_format),
                                hintText: "Họ và tên",
                                border: InputBorder.none),
                            validator: (value) {
                              if (value.isEmpty || value.length < 5) {
                                return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 3),
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: phoneController,
                            autocorrect: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                icon: Icon(Icons.phone_android),
                                hintText: "Số điện thoại",
                                border: InputBorder.none),
                            validator: (value) {
                              if (value.isEmpty || value.length < 10) {
                                return 'Vui lòng điền thông tin (tối thiểu 10 ký tự)';
                              }
                              return null;
                            },
                          ),
                        ),
                        FutureBuilder<List<dynamic>>(
                            future: CityService.getListCities(),
                            builder: (BuildContext context, snapshot) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 3),
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 10),
                                width: size.width * 0.95,
                                decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(10)),
                                child: SearchableDropdown.single(
                                  items: provinces.map((Map value) {
                                    return new DropdownMenuItem<String>(
                                      value: value['id'].toString() +
                                          "_" +
                                          value['city_name'],
                                      child: new Text(
                                          value['city_name'].toString()),
                                    );
                                  }).toList(),
                                  //isCaseSensitiveSearch: true,
                                  value: "x",
                                  hint: "Chọn tỉnh/TP",
                                  searchHint: "Tìm tỉnh/TP",
                                  onChanged: (value) {
                                    if (value == null) {
                                      //print(value);
                                      value = 1;
                                    } else {
                                      value = value.split("_")[0];
                                    }
                                    setState(() {
                                      this._city = value;
                                      this.districts = [];
                                    });
                                    _getListDisctrict(value);
                                    // print(this.districts);
                                    // print("chay toi day luon");
                                    // setState(() {
                                    //   this.districts = ['Hello'];
                                    // });
                                  },
                                  displayClearIcon:
                                      this.districts.isNotEmpty ? false : true,
                                  isExpanded: true,
                                ),
                              );
                            }),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 3),
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            width: size.width * 0.95,
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10)),
                            child: SearchableDropdown.single(
                              items: districts.map((Map value) {
                                return new DropdownMenuItem<String>(
                                  value: value['id'].toString() +
                                      "_" +
                                      value['district_name'].toString(),
                                  child: new Text(
                                      value['district_name'].toString()),
                                );
                              }).toList(),
                              dialogBox: true,
                              //readOnly: true,
                              value: "x",
                              hint: "Chọn quận/huyện",
                              searchHint: "Tìm quận/huyện",
                              onChanged: (value) {
                                if (value == null) {
                                  //print(value);
                                  value = 0;
                                } else {
                                  value = value.split("_")[0];
                                }
                                this._district = value;
                                print(value);
                              },
                              displayClearIcon: false,
                              isExpanded: true,
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 3),
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                              controller: positionController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.add_location),
                                  hintText: "Địa điểm",
                                  border: InputBorder.none),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                                }
                                return null;
                              }),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 3),
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.note),
                                  hintText: "Nội dung",
                                  border: InputBorder.none),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                                }
                                return null;
                              }),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 3),
                          padding:
                              EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                              controller: nearbyController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.supervised_user_circle),
                                  hintText: "Người tiếp xúc",
                                  border: InputBorder.none),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                                }
                                return null;
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getListDisctrict(value) async {
    print("in async");
    await CityService.getListDistrict(value).then((res) {
      print(res['data'].map((v) {
        setState(() {
          this.districts.add(v);
        });
        return v;
      }));
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget BasicDateField() {
    final format = DateFormat("dd-MM-yyyy");
    return Column(children: <Widget>[
      Text(
        'Chọn ngày',
        style: TextStyle(fontSize: 15),
      ),
      DateTimeField(
        decoration: InputDecoration(border: InputBorder.none),
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: new DateTime.now());

          // if (picked != null && picked != selectedDate) selectDate(picked);
        },
        onChanged: (date) {
          setState(() {
            if (date != null) {
              this._fromDate = date;
              this._toDate = date;
            } else {
              this._fromDate = null;
              this._toDate = null;
            }
          });
          print(this._fromDate);
        },
      ),
    ]);
  }

  Widget BasicTimeField(String type) {
    final format = DateFormat("HH:mm");
    return Column(children: <Widget>[
      Text(type == 'fromDate' ? 'Chọn thời gian đến' : 'Chọn thời gian đi',
          style: TextStyle(fontSize: 15)),
      DateTimeField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.blue[100],
          border: InputBorder.none,
        ),
        format: format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
          // return DateTimeField.combine(this._fromDate, time);
        },
        onChanged: (time) {
          print(time);
          setState(() {
            if (time != null) {
              TimeOfDay t = TimeOfDay.fromDateTime(time);

              if (type == "fromDate") {
                this._fromDate = new DateTime(this._fromDate.year,
                    this._fromDate.month, this._fromDate.day, t.hour, t.minute);
                print(this._fromDate);
              } else {
                this._toDate = new DateTime(this._toDate.year,
                    this._toDate.month, this._toDate.day, t.hour, t.minute);
                print(this._toDate);
              }
              if (this._fromDate.hour > this._toDate.hour) {
                showSnackBar("Vui lòng chọn giờ đến phải nhỏ hơn giờ đi.");
                this._isDontSubmit = false;
                return;
              } else {
                this._isDontSubmit = true;
                return;
              }
            }
          });
        },
      ),
    ]);
  }

  static Future addFieldFormGuest(body, city, district) async {
    var url = '${baseUrl}tracking/guest';
    body["city_id"] = city.toString();
    body["district_id"] = district;
    print(body);
    try {
      var response = await http.post(url, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = json.decode(response.body);
        print(map);
        return map;
      }
      if (400 == response.statusCode) {
        // Fluttertoast.showToast(
        //     msg: "Tạo tài khoản không thành công, xin thử lại",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.TOP,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget showSnackBar(text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
