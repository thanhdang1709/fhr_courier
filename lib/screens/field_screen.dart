import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import '../screens/bottom_nav_screen.dart';
import '../screens/history_screen.dart';
import '../widgets/drawer.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/palette.dart';
import '../widgets/covid_bar_chart.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stats_grid.dart';
import '../data/data.dart';
import '../services/city_service.dart';
import 'package:http/http.dart' as http;

const baseUrl = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/';

class FieldScreen extends StatefulWidget {
  @override
  _FieldScreenState createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  DateTime _fromDate;
  DateTime _toDate;
  final format = DateFormat("yyyy-MM-dd HH:mm");

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final positionController = TextEditingController();
  final descriptionController = TextEditingController();
  final nearbyController = TextEditingController();
  String _position;
  String _description;
  String _nearby;
  bool _isDontSubmit;
  String _city;
  String _district;
  Color colorTextField = Colors.white;
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate;
  TimeOfDay selectedTime;
  ValueChanged<DateTime> selectDate;
  ValueChanged<TimeOfDay> selectTime;
  List<Map> districts;
  @override
  void initState() {
    this.districts = [];

    this._fromDate;
    this._toDate;
    this._city;
    this._district;
    this._isDontSubmit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<DropdownMenuItem<String>> items = [];
    return Scaffold(
      drawer: CustomeDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_toDate != null &&
              _fromDate != null &&
              _fromDate.hour != 0 &&
              _isDontSubmit) {
            if (_city != null && _district != null) {
              if (_formKey.currentState.validate()) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Đang xử lý...')));
                Map<String, dynamic> body = ({
                  "from_datetime": _fromDate.toString(),
                  "to_datetime": _toDate.toString(),
                  "city_id": _city,
                  "district_id": _district,
                  "location": positionController.text,
                  "activities": descriptionController.text,
                  "related_persons": nearbyController.text
                });
                addFieldFormMember(body).then((res) {
                  if (res['code'] == 200) {
                    Fluttertoast.showToast(
                        msg: "Đăng ký khai báo thành công",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);

                    Future.delayed(new Duration(seconds: 1), () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BottomNavScreen()));
                    });
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
              showSnackBar("Vui lòng nhập Tỉnh/TP");
            }
          } else {
            showSnackBar("Vui lòng nhập ngày đến ngày đi");
          }
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        backgroundColor: Palette.primaryColor,
        title: Text("KHAI BÁO Y TẾ"),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.1),
                    child: Row(
                      //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: size.width * 0.05),
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: colorTextField,
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                // child: FlatButton(
                                //   onPressed: () {
                                //     DatePicker.showDateTimePicker(context,
                                //         showTitleActions: true,
                                //         minTime: DateTime(2020, 1, 1),
                                //         maxTime: new DateTime.now(), onChanged: (date) {
                                //       print('change $date');
                                //     }, onConfirm: (date) {
                                //       setState(() {
                                //         this._fromDate = date;
                                //       });
                                //     },
                                //         currentTime: DateTime.now(),
                                //         locale: LocaleType.vi);
                                //   },
                                //   child: Text(
                                //     this._fromDate != null
                                //         ? this._fromDate.toString()
                                //         : 'Chọn thời gian đến',
                                //     style: TextStyle(color: Colors.blue),
                                //   ),
                                // )
                                BasicDateField(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: colorTextField,
                                borderRadius: BorderRadius.circular(10)),
                            child: BasicTimeField("fromDate"),
                            // child: FlatButton(
                            //   onPressed: () {
                            //     DatePicker.showDateTimePicker(context,
                            //         showTitleActions: true,
                            //         minTime: DateTime(2020, 1, 1),
                            //         maxTime: new DateTime.now(),
                            //         onChanged: (date) {
                            //       print('change $date');
                            //     }, onConfirm: (date) {
                            //       setState(() {
                            //         this._toDate = date;
                            //       });
                            //     },
                            //         currentTime: DateTime.now(),
                            //         locale: LocaleType.vi);
                            //   },
                            //   child: Text(
                            //     this._toDate != null
                            //         ? this._toDate.toString()
                            //         : 'Chọn thời gian đi',
                            //     style: TextStyle(color: Colors.blue),
                            //   ),
                            // )
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            padding: EdgeInsets.symmetric(
                                vertical: 1, horizontal: 5),
                            decoration: BoxDecoration(
                                color: colorTextField,
                                borderRadius: BorderRadius.circular(10)),
                            child: BasicTimeField("toDate"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    width: size.width * 0.95,
                    decoration: BoxDecoration(
                        color: colorTextField,
                        borderRadius: BorderRadius.circular(10)),
                    child: SearchableDropdown.single(
                      underline: "",
                      items: provinces.map((Map value) {
                        return new DropdownMenuItem<String>(
                          value: value['id'] + "_" + value['city_name'],
                          child: Text(value['city_name']),
                        );
                      }).toList(),
                      //isCaseSensitiveSearch: true,
                      searchFn: (String keyword, items) {
                        List<int> ret = List<int>();
                        if (keyword != null &&
                            items != null &&
                            keyword.isNotEmpty) {
                          keyword.split(" ").forEach((k) {
                            int i = 0;
                            items.forEach((item) {
                              if (k.isNotEmpty &&
                                  (item.value
                                      .toString()
                                      .toLowerCase()
                                      .contains(k.toLowerCase()))) {
                                ret.add(i);
                              }
                              i++;
                            });
                          });
                        }
                        if (keyword.isEmpty) {
                          ret =
                              Iterable<int>.generate(provinces.length).toList();
                        }
                        return (ret);
                      },
                      value: _city,
                      hint: "Chọn tỉnh/TP",
                      searchHint: "Tìm tỉnh/TP",
                      onChanged: (value) {
                        // print(value);
                        if (value == null) {
                          //print(value);
                          value = 1;
                        } else {
                          value = value.split("_")[0];
                        }
                        //print(value);
                        setState(() {
                          this._city = value;
                          this.districts = [];
                        });
                        _getListDisctrict(value);
                        // if (value == null) {
                        //   print(value);
                        //   value = 1;
                        // } else {
                        //   _getListDisctrict(value);
                        // }
                      },
                      displayClearIcon: false,
                      isExpanded: true,
                      // displayItem: (item, selected) {
                      //   return (Row(children: [
                      //     selected
                      //         ? Icon(
                      //             Icons.check,
                      //             color: Colors.green,
                      //           )
                      //         : Icon(
                      //             Icons.check_box_outline_blank,
                      //             color: Colors.grey,
                      //           ),
                      //     SizedBox(width: 7),
                      //     Expanded(
                      //       child: item,
                      //     ),
                      //   ]));
                      // },
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 3),
                      // padding:
                      //     EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                      width: size.width * 0.95,
                      height: size.height * 0.1,
                      decoration: BoxDecoration(
                          color: colorTextField,
                          borderRadius: BorderRadius.circular(10)),
                      child: SearchableDropdown.single(
                        underline: "",
                        items: districts.map((Map value) {
                          return new DropdownMenuItem<String>(
                            value: value['id'] + "_" + value['district_name'],
                            child: new Text(value['district_name'].toString()),
                          );
                        }).toList(),
                        // dialogBox: true,
                        //readOnly: true,
                        value: "x",
                        hint: "Chọn quận/huyện",
                        searchHint: "Tìm quận/huyện",
                        onChanged: (value) {
                          setState(() {
                            if (value == null) {
                              //print(value);
                              value = 0;
                            } else {
                              value = value.split("_")[0];
                            }
                            this._district = value;
                          });
                        },
                        isExpanded: true,
                        displayClearIcon: false,
                      )),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 3),
                      padding:
                          EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                      width: size.width * 0.95,
                      decoration: BoxDecoration(
                          color: colorTextField,
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
                          if (value.isEmpty || value.length >= 100) {
                            return 'Vui lòng điền thông tin (tối đa 100 ký tự)';
                          }
                          return null;
                        },
                      )),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    width: size.width * 0.95,
                    decoration: BoxDecoration(
                        color: colorTextField,
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
                          if (value.isEmpty || value.length >= 100) {
                            return 'Vui lòng điền thông tin (tối đa 100 ký tự)';
                          }
                          return null;
                        }),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    width: size.width * 0.95,
                    decoration: BoxDecoration(
                        color: colorTextField,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                        controller: nearbyController,
                        onChanged: (value) => {
                              setState(() {
                                this._nearby = this.nearbyController.text;
                              })
                            },
                        decoration: InputDecoration(
                            icon: Icon(Icons.supervised_user_circle),
                            hintText: "Người tiếp xúc",
                            border: InputBorder.none),
                        validator: (value) {
                          if (value.isEmpty || value.length < 5) {
                            return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                          }
                          if (value.isEmpty || value.length >= 100) {
                            return 'Vui lòng điền thông tin (tối đa 100 ký tự)';
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

  static Future addFieldFormMember(body) async {
    var url = '${baseUrl}tracking/member';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? null;
    print(body);
    print(userToken);
    try {
      var response = await http
          .post(url, body: body, headers: {"Authorization": userToken});
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = json.decode(response.body);
        print(map);
        return map;
      }
      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
  }

  Widget showSnackBar(text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String validatePosition(position) {}

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget BasicDateField() {
    final format = DateFormat("dd-MM-yyyy");
    return Column(children: <Widget>[
      Text('Chọn ngày'),
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
      Text(type == 'fromDate' ? 'Thời gian bắt đầu' : 'Thời gian kết thúc'),
      DateTimeField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
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
            } else {
              this._fromDate = new DateTime(this._fromDate.year,
                  this._fromDate.month, this._fromDate.day, 0, 0);
            }
          });
        },
      ),
    ]);
  }
}

// class BasicDateField extends StatelessWidget {
//   final format = DateFormat("dd-MM-yyyy");
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: <Widget>[
//       Text('Chọn ngày'),
//       DateTimeField(
//         format: format,
//         onShowPicker: (context, currentValue) {
//           return showDatePicker(
//               context: context,
//               firstDate: DateTime(2020),
//               initialDate: currentValue ?? DateTime.now(),
//               lastDate: new DateTime.now());
//         },
//         onChanged: (date) {
//           print(date);
//         },
//       ),
//     ]);
//   }
// }

class ComplexDateTimeField extends StatefulWidget {
  @override
  _ComplexDateTimeFieldState createState() => _ComplexDateTimeFieldState();
}

class _ComplexDateTimeFieldState extends State<ComplexDateTimeField> {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  final initialValue = DateTime.now();

  bool autoValidate = false;
  bool readOnly = true;
  bool showResetIcon = true;
  DateTime value = DateTime.now();
  int changedCount = 0;
  int savedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Complex date & time field (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            print(currentValue);
            return currentValue;
          }
        },
        autovalidate: autoValidate,
        validator: (date) => date == null ? 'Invalid date' : null,
        initialValue: initialValue,
        onChanged: (date) => setState(() {
          value = date;
          changedCount++;
          print(value);
        }),
        onSaved: (date) => setState(() {
          value = date;
          savedCount++;
        }),
        resetIcon: showResetIcon ? Icon(Icons.delete) : null,
        readOnly: readOnly,
        decoration: InputDecoration(
            //  helperText: 'Changed: $changedCount, Saved: $savedCount, $value'
            ),
      ),
      // CheckboxListTile(
      //   title: Text('autoValidate'),
      //   value: autoValidate,
      //   onChanged: (value) => setState(() => autoValidate = value),
      // ),
      // CheckboxListTile(
      //   title: Text('readOnly'),
      //   value: readOnly,
      //   onChanged: (value) => setState(() => readOnly = value),
      // ),
      // CheckboxListTile(
      //   title: Text('showResetIcon'),
      //   value: showResetIcon,
      //   onChanged: (value) => setState(() => showResetIcon = value),
      // ),
    ]);
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker(
      {Key key,
      this.labelText,
      this.selectedDate,
      this.selectedTime,
      this.selectDate,
      this.selectTime})
      : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(1970, 8),
        lastDate: new DateTime(2101));
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.body1;
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDropdown(
            labelText: labelText,
            valueText: new DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ),
        const SizedBox(width: 12.0),
        new Expanded(
          flex: 3,
          child: new _InputDropdown(
            valueText: selectedTime.format(context),
            valueStyle: valueStyle,
            onPressed: () {
              _selectTime(context);
            },
          ),
        ),
      ],
    );
  }
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key key,
      this.child,
      this.labelText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}
