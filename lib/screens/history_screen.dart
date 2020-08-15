import 'dart:convert';
import 'dart:math';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import '../helpers/format.dart';
import '../widgets/drawer.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/palette.dart';
import '../config/contanst.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../services/city_service.dart';
import './filter_history_screen.dart';

import '../data/data.dart';
import '../services/city_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  final controller = ScrollController();
  List<dynamic> listHistories;
  String itemCount;
  bool _loading;
  int page;
  int present;
  bool _isSearch;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final positionController = TextEditingController();
  final descriptionController = TextEditingController();
  final nearbyController = TextEditingController();
  String _position;
  String _description;
  String _nearby;
  DateTime _fromDate;
  DateTime _toDate;
  String _city;
  String _district;
  List<Map> districts;

  Color colorTextField = Colors.white;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    this._loading = true;
    this._isSearch = false;
    this.page = 1;
    this.getListHistory(this.page).then((res) {
      print(res['data']['items']);
      setState(() {
        this._loading = false;
        this.itemCount = res['data']['total'];
        print(res['data']['items'].runtimeType);
        this.listHistories = res['data']['items'];
        this.present = listHistories.length;
        print(this.itemCount);
      });
    });

    this.districts = [{}];

    this._fromDate;
    this._toDate;
    this._city;
    this._district;
    super.initState();
  }

  Widget appBarTitle = new Text("Lịch sử tiếp xúc");
  Icon actionIcon = new Icon(Icons.search);
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _loading
        ? Center(
            child: Container(
                color: Palette.primaryColor,
                //color: Color(0xFF0E3311).withOpacity(0.1),
                child: new FlareActor(
                  "assets/covid.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                )))
        : FutureBuilder(
            future: Future.delayed(new Duration(microseconds: 200), () {}),
            builder: (context, snapshot) {
              return Scaffold(
                  drawer: CustomeDrawer(),
                  resizeToAvoidBottomPadding: false,
                  backgroundColor: Palette.primaryColor,
                  appBar: AppBar(
                      backgroundColor: Palette.primaryColor,
                      centerTitle: true,
                      title: appBarTitle,
                      actions: <Widget>[
                        // IconButton(
                        //   icon: actionIcon,
                        //   onPressed: () {
                        //     setState(() {
                        //       this._isSearch = !_isSearch;
                        //     });
                        //   },
                        // ),
                        new IconButton(
                          icon: actionIcon,
                          onPressed: () {
                            setState(() {
                              if (this.actionIcon.icon == Icons.search) {
                                this.actionIcon = new Icon(Icons.close);
                                // this.appBarTitle = new TextField(
                                //   style: new TextStyle(
                                //     color: Colors.white,
                                //   ),
                                //   decoration: new InputDecoration(
                                //       prefixIcon: new Icon(Icons.search,
                                //           color: Colors.white),
                                //       hintText:
                                //           "tìm kiếm...(địa điểm, nội dung, tiếp xúc)",
                                //       hintStyle:
                                //           new TextStyle(color: Colors.white)),
                                // );
                                this._isSearch = true;
                              } else {
                                this._isSearch = false;
                                this.actionIcon = new Icon(Icons.search);
                                this.appBarTitle = new Text("Lịch sử tiếp xúc");
                              }
                            });
                          },
                        ),
                      ]),
                  body: GestureDetector(
                      onTap: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: this._isSearch
                          ? SingleChildScrollView(
                              child: Container(
                                  // child: Form(
                                  //   key: _formKey,
                                  //   child: Center(
                                  //     child: Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.center,
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: <Widget>[
                                  //         Row(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.spaceAround,
                                  //           children: <Widget>[
                                  //             Column(
                                  //               children: <Widget>[
                                  //                 Container(
                                  //                     margin:
                                  //                         EdgeInsets.symmetric(
                                  //                             vertical: 3),
                                  //                     padding:
                                  //                         EdgeInsets.symmetric(
                                  //                             vertical: 3,
                                  //                             horizontal: 10),
                                  //                     decoration: BoxDecoration(
                                  //                         color: colorTextField,
                                  //                         borderRadius:
                                  //                             BorderRadius
                                  //                                 .circular(10)),
                                  //                     child: FlatButton(
                                  //                       onPressed: () {
                                  //                         DatePicker
                                  //                             .showDateTimePicker(
                                  //                                 context,
                                  //                                 showTitleActions:
                                  //                                     true,
                                  //                                 minTime: DateTime(
                                  //                                     2020,
                                  //                                     1,
                                  //                                     1),
                                  //                                 maxTime:
                                  //                                     new DateTime
                                  //                                         .now(),
                                  //                                 onChanged:
                                  //                                     (date) {
                                  //                           print('change $date');
                                  //                         }, onConfirm: (date) {
                                  //                           setState(() {
                                  //                             this._fromDate =
                                  //                                 date;
                                  //                           });
                                  //                         },
                                  //                                 currentTime:
                                  //                                     DateTime
                                  //                                         .now(),
                                  //                                 locale:
                                  //                                     LocaleType
                                  //                                         .vi);
                                  //                       },
                                  //                       child: Text(
                                  //                         this._fromDate != null
                                  //                             ? this
                                  //                                 ._fromDate
                                  //                                 .toString()
                                  //                             : 'Chọn thời gian đến',
                                  //                         style: TextStyle(
                                  //                             color: Colors.blue,
                                  //                             fontSize: 12),
                                  //                       ),
                                  //                     )),
                                  //               ],
                                  //             ),
                                  //             Column(
                                  //               children: <Widget>[
                                  //                 Container(
                                  //                     margin:
                                  //                         EdgeInsets.symmetric(
                                  //                             vertical: 3),
                                  //                     padding:
                                  //                         EdgeInsets.symmetric(
                                  //                             vertical: 3,
                                  //                             horizontal: 10),
                                  //                     decoration: BoxDecoration(
                                  //                         color: colorTextField,
                                  //                         borderRadius:
                                  //                             BorderRadius
                                  //                                 .circular(10)),
                                  //                     child: FlatButton(
                                  //                       onPressed: () {
                                  //                         DatePicker
                                  //                             .showDateTimePicker(
                                  //                                 context,
                                  //                                 showTitleActions:
                                  //                                     true,
                                  //                                 minTime: DateTime(
                                  //                                     2020,
                                  //                                     1,
                                  //                                     1),
                                  //                                 maxTime:
                                  //                                     new DateTime
                                  //                                         .now(),
                                  //                                 onChanged:
                                  //                                     (date) {
                                  //                           print('change $date');
                                  //                         }, onConfirm: (date) {
                                  //                           setState(() {
                                  //                             this._toDate = date;
                                  //                           });
                                  //                         },
                                  //                                 currentTime:
                                  //                                     DateTime
                                  //                                         .now(),
                                  //                                 locale:
                                  //                                     LocaleType
                                  //                                         .vi);
                                  //                       },
                                  //                       child: Text(
                                  //                         this._toDate != null
                                  //                             ? this
                                  //                                 ._toDate
                                  //                                 .toString()
                                  //                             : 'Chọn thời gian đi',
                                  //                         style: TextStyle(
                                  //                             color: Colors.blue),
                                  //                       ),
                                  //                     )),
                                  //               ],
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         Container(
                                  //           margin:
                                  //               EdgeInsets.symmetric(vertical: 3),
                                  //           padding: EdgeInsets.symmetric(
                                  //               vertical: 3, horizontal: 10),
                                  //           width: size.width * 0.95,
                                  //           decoration: BoxDecoration(
                                  //               color: colorTextField,
                                  //               borderRadius:
                                  //                   BorderRadius.circular(10)),
                                  //           child: SearchableDropdown.single(
                                  //             items: provinces.map((Map value) {
                                  //               return new DropdownMenuItem<
                                  //                   String>(
                                  //                 value: value['id'],
                                  //                 child: new Text(
                                  //                     value['city_name']),
                                  //               );
                                  //             }).toList(),
                                  //             value: "x",
                                  //             hint: "Chọn tỉnh/TP",
                                  //             searchHint: "Tìm tỉnh/TP",
                                  //             onChanged: (value) {
                                  //               setState(() {
                                  //                 this._city = value;
                                  //                 this.districts = [];
                                  //               });

                                  //               _getListDisctrict(value);
                                  //             },
                                  //             isExpanded: true,
                                  //           ),
                                  //         ),
                                  //         Container(
                                  //             margin: EdgeInsets.symmetric(
                                  //                 vertical: 3),
                                  //             padding: EdgeInsets.symmetric(
                                  //                 vertical: 3, horizontal: 10),
                                  //             width: size.width * 0.95,
                                  //             decoration: BoxDecoration(
                                  //                 color: colorTextField,
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(10)),
                                  //             child: SearchableDropdown.single(
                                  //               items: districts.map((Map value) {
                                  //                 return new DropdownMenuItem<
                                  //                     String>(
                                  //                   value: value['id'].toString(),
                                  //                   child: new Text(
                                  //                       value['district_name']
                                  //                           .toString()),
                                  //                 );
                                  //               }).toList(),
                                  //               dialogBox: true,
                                  //               //readOnly: true,
                                  //               value: "x",
                                  //               hint: "Chọn quận/huyện",
                                  //               searchHint: "Tìm quận/huyện",
                                  //               onChanged: (value) {
                                  //                 setState(() {
                                  //                   this._district = value;
                                  //                 });
                                  //               },
                                  //               isExpanded: true,
                                  //             )),
                                  //         Container(
                                  //             margin: EdgeInsets.symmetric(
                                  //                 vertical: 3),
                                  //             padding: EdgeInsets.symmetric(
                                  //                 vertical: 3, horizontal: 10),
                                  //             width: size.width * 0.95,
                                  //             decoration: BoxDecoration(
                                  //                 color: colorTextField,
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(10)),
                                  //             child: TextFormField(
                                  //               controller: positionController,
                                  //               decoration: InputDecoration(
                                  //                   icon:
                                  //                       Icon(Icons.add_location),
                                  //                   hintText: "Địa điểm",
                                  //                   border: InputBorder.none),
                                  //               validator: (value) {
                                  //                 if (value.isEmpty ||
                                  //                     value.length < 5) {
                                  //                   return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                                  //                 }
                                  //                 if (value.isEmpty ||
                                  //                     value.length >= 30) {
                                  //                   return 'Vui lòng điền thông tin (tối đa 30 ký tự)';
                                  //                 }
                                  //                 return null;
                                  //               },
                                  //             )),
                                  //         Container(
                                  //           margin:
                                  //               EdgeInsets.symmetric(vertical: 3),
                                  //           padding: EdgeInsets.symmetric(
                                  //               vertical: 3, horizontal: 10),
                                  //           width: size.width * 0.95,
                                  //           decoration: BoxDecoration(
                                  //               color: colorTextField,
                                  //               borderRadius:
                                  //                   BorderRadius.circular(10)),
                                  //           child: TextFormField(
                                  //               controller: descriptionController,
                                  //               decoration: InputDecoration(
                                  //                   icon: Icon(Icons.note),
                                  //                   hintText: "Nội dung",
                                  //                   border: InputBorder.none),
                                  //               validator: (value) {
                                  //                 if (value.isEmpty ||
                                  //                     value.length < 5) {
                                  //                   return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                                  //                 }
                                  //                 if (value.isEmpty ||
                                  //                     value.length >= 30) {
                                  //                   return 'Vui lòng điền thông tin (tối đa 30 ký tự)';
                                  //                 }
                                  //                 return null;
                                  //               }),
                                  //         ),
                                  //         Container(
                                  //           margin:
                                  //               EdgeInsets.symmetric(vertical: 3),
                                  //           padding: EdgeInsets.symmetric(
                                  //               vertical: 3, horizontal: 10),
                                  //           width: size.width * 0.95,
                                  //           decoration: BoxDecoration(
                                  //               color: colorTextField,
                                  //               borderRadius:
                                  //                   BorderRadius.circular(10)),
                                  //           child: TextFormField(
                                  //               controller: nearbyController,
                                  //               onChanged: (value) => {
                                  //                     setState(() {
                                  //                       this._nearby = this
                                  //                           .nearbyController
                                  //                           .text;
                                  //                     })
                                  //                   },
                                  //               decoration: InputDecoration(
                                  //                   icon: Icon(Icons
                                  //                       .supervised_user_circle),
                                  //                   hintText: "Người tiếp xúc",
                                  //                   border: InputBorder.none),
                                  //               validator: (value) {
                                  //                 if (value.isEmpty ||
                                  //                     value.length < 5) {
                                  //                   return 'Vui lòng điền thông tin (tối thiểu 5 ký tự)';
                                  //                 }
                                  //                 if (value.isEmpty ||
                                  //                     value.length >= 30) {
                                  //                   return 'Vui lòng điền thông tin (tối đa 30 ký tự)';
                                  //                 }
                                  //                 return null;
                                  //               }),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  ),
                            )
                          : Container(
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(5),
                                  itemCount: (present <= listHistories.length)
                                      ? listHistories.length + 1
                                      : listHistories.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return (index >= listHistories.length)
                                        ? Container(
                                            color: Colors.blue[200],
                                            child: FlatButton(
                                              child: Text(
                                                "Xem thêm",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (int.parse(itemCount) >
                                                      listHistories.length) {
                                                    page++;
                                                    getListHistory(page)
                                                        .then((res) {
                                                      print(
                                                          res['data']['items']);
                                                      setState(() {
                                                        this
                                                            .listHistories
                                                            .addAll(res['data']
                                                                ['items']);
                                                        print(
                                                            this.listHistories);
                                                      });
                                                    });
                                                  }
                                                });
                                              },
                                            ),
                                          )
                                        : PreventCard(
                                            title: listHistories[index]
                                                ['location'],
                                            cityName: listHistories[index]
                                                ['city_name'],
                                            districtName: listHistories[index]
                                                ['district_name'],
                                            text: listHistories[index]
                                                ['activities'],
                                            near: listHistories[index]
                                                ['related_persons'],
                                            fromDate: listHistories[index]
                                                ['from_datetime'],
                                            toDate: listHistories[index]
                                                ['to_datetime'],
                                          );
                                  }),
                            )));
            });
  }

  Future getListHistory(page) async {
    var url =
        'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/tracking/history_list?page=$page';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? null;
    //print(body);
    print(userToken);
    try {
      var response = await http.get(url, headers: {"Authorization": userToken});
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = json.decode(response.body);

        return map;
      }
      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
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
}

class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  final String near;
  final String fromDate;
  final String toDate;
  final String cityName;
  final String districtName;
  const PreventCard(
      {Key key,
      this.image,
      this.title,
      this.text,
      this.near,
      this.fromDate,
      this.toDate,
      this.cityName,
      this.districtName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {print("HELLO")},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Palette.primaryColor, Colors.blue[800]],
                    //colors: [Colors.grey, Colors.grey[200]],
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 25,
                      color: kShadowColor,
                    ),
                  ],
                ),
              ),
              //Image.asset(image),
              Positioned(
                left: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  height: 100,
                  width: MediaQuery.of(context).size.width - 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Địa điểm: $cityName - $districtName - $title',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          'Nội dung: $text \nNgười tiếp xúc: $near',
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Từ ${Format.stringToTime(fromDate)} đến ${Format.stringToTime(toDate)}",
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        ),
                      ),
                      /*Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset("assets/icons/forward.svg"),
                      ),*/
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
