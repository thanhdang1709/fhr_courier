import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/palette.dart';
import 'package:flutter_showcase/flutter_showcase.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import "package:collection/collection.dart";
import 'package:http/http.dart' as http;
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import '../data/data.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import '../helpers/format.dart';

class ShowcaseHistoryTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HistoryTimeline();
  }
}

class _HistoryTimelineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timeline',
      builder: Frame.builder,
      home: _HistoryTimeline(),
    );
  }
}

class _HistoryTimeline extends StatefulWidget {
  @override
  __HistoryTimelineState createState() => __HistoryTimelineState();
}

class __HistoryTimelineState extends State<_HistoryTimeline> {
  GlobalKey _dropdownButtonKey;
  Map listMap;
  bool _loading = true;
  int page;
  int perPage = 100;
  int totalItem;
  int pageItem;
  bool scrollEnd;
  bool maxPaging;
  bool _isSearch;
  bool _isSearchProvince;
  DateTime from_date;
  DateTime to_date;
  ScrollController _controller;
  String keywordSearch;
  List listProvice = [];
  List listDate = [];
  int _selectedProvice;
  List _selectedChoice = [];
  Widget appBarTitle = new Text("Lịch sử tiếp xúc");
  Icon actionIcon = new Icon(Icons.search);
  Icon actionIconSort = new Icon(Icons.sort);
  DateTime _initialFilterFromDate = new DateTime.now();
  DateTime _initialFilterToDate = new DateTime.now();
  String _selectedProvinceString;
  Future getListHistory(
      page, perpage, keyword, from_date, to_date, city_id) async {
    // var url =
    //     'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/tracking/history_list';

    var url =
        'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/tracking/history_list?page=$page&per_page=$perpage&keyword=$keyword&from_datetime=${from_date.toString().substring(0, 10)}&to_datetime=${to_date.toString().substring(0, 10)}&city_id=$city_id';
    print(url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? null;
    // //print(body);
    // print(userToken);
    try {
      var response = await http.get(url, headers: {"Authorization": userToken});
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = json.decode(response.body);
        //print(map);
        return map;
      }
      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
  }

  List listHistories;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        scrollEnd = true;
      });
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        scrollEnd = false;
      });
    }
  }

  @override
  void initState() {
    this.page = 1;
    this.scrollEnd = false;
    this.maxPaging = false;
    this.pageItem = 0;
    this.totalItem = 0;
    this.keywordSearch = '';
    this._selectedProvice = 0;
    this.from_date = new DateTime(2020);
    this.to_date = new DateTime.now();
    this._isSearch = false;
    this._isSearchProvince = true;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    this
        .getListHistory(
            page, perPage, keywordSearch, from_date, to_date, _selectedProvice)
        .then((value) {
      setState(() {
        this.listHistories = value['data']['items'];
        //listHistories.where((e) => e.)
        this.totalItem = int.tryParse(value['data']['total']);
        this.pageItem = listHistories.length;
        print(pageItem);
        var newMap = groupBy(listHistories, (obj) => obj['from_date']);

        var newMapProvice = groupBy(listHistories, (obj) => obj['city_name']);
        this.listProvice = newMapProvice.keys.toList();
        this.listDate = newMap.keys.toList();

        print(listProvice);
        print(newMap.length);
        this._loading = false;
        this.listMap = newMap;
        //print(listHistories);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [
            Palette.primaryColor,
            //Color(0xFF3A3E88),
            Palette.primaryColor,
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          accentColor: const Color(0xFFDB84B1).withOpacity(0.2),
        ),
        child: SafeArea(
          child: Scaffold(
            floatingActionButton: (pageItem < totalItem &&
                    scrollEnd &&
                    !maxPaging)
                ? FloatingActionButton.extended(
                    icon: Icon(Icons.refresh),
                    label: Text(
                      'Tải thêm',
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.lightBlueAccent,
                    onPressed: () {
                      this.page++;
                      setState(() {
                        if (page * perPage > totalItem) this.maxPaging = true;
                        this._loading = true;
                      });
                      getListHistory(page, perPage, keywordSearch, from_date,
                              to_date, _selectedProvice)
                          .then((value) {
                        setState(() {
                          this.listHistories = value['data']['items'];
                          this.totalItem = int.tryParse(value['data']['total']);
                          this.pageItem = listHistories.length;
                          print(pageItem);
                          var newMap =
                              groupBy(listHistories, (obj) => obj['from_date']);
                          var newMapProvice =
                              groupBy(listHistories, (obj) => obj['city_name']);
                          this.listProvice..addAll(newMapProvice.keys.toList());
                          this.listProvice = [
                            ...{...this.listProvice}
                          ];
                          ;
                          print(newMap.length);
                          this._loading = false;
                          this.listMap.addAll(newMap);
                          // _controller.animateTo(
                          //     _controller.position.maxScrollExtent,
                          //     curve: Curves.easeOut,
                          //     duration: const Duration(milliseconds: 500),
                          //   );
                          // _controller
                          //     .jumpTo(_controller.position.maxScrollExtent);
                        });
                      });
                    })
                : null,
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(),
            // body: Container(
            //   child: ListView.builder(
            //       padding: const EdgeInsets.all(8),
            //       itemCount: listItems.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return ListTimeline(
            //           date: "20202020",
            //           hour: "20;20",
            //           weather: "Hello",
            //           temperature: "hello",
            //           phrase: "Hello",
            //           isFirst: true,
            //           isLast: false,
            //         );
            //       }

            //       ),
            // ),

            body: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)))
                : _isSearchProvince
                    ? FutureBuilder(
                        future: Future.delayed(
                            new Duration(milliseconds: 200), () {}),
                        builder: (context, snapshot) {
                          return totalItem != 0
                              ? Padding(
                                  padding:
                                      EdgeInsets.only(top: size.height * 0.08),
                                  child: ListView.builder(
                                      controller: _controller,
                                      padding: const EdgeInsets.all(8),
                                      itemCount: listMap.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String key =
                                            listMap.keys.elementAt(index);
                                        print(totalItem);
                                        return ListTimeline(
                                          listItems: listMap[key],
                                          date: key.toString(),
                                        );
                                      }),
                                )
                              : Center(
                                  child: Text(
                                    "Không tìm thấy lịch sử khai báo",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                );
                        })
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: size.height * 0.1),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 3),
                              //width: size.width * 0.9,
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10)),
                              child: SearchableDropdown.single(
                                items: provinces.map((Map value) {
                                  return new DropdownMenuItem<String>(
                                    value: value['id'].toString() +
                                        "_" +
                                        value['city_name'].toString(),
                                    child:
                                        new Text(value['city_name'].toString()),
                                  );
                                }).toList(),
                                dialogBox: true,
                                //readOnly: true,
                                value: _selectedProvinceString,
                                hint: "Chọn tỉnh/thành",
                                searchHint: "Tìm tỉnh/thành",
                                onChanged: (select) {
                                  if (select == null) select = "0_0";
                                  setState(() {
                                    _selectedProvinceString = select;
                                    _selectedProvice =
                                        int.parse(select.split("_")[0]);

                                    getListHistory(
                                            page,
                                            perPage,
                                            keywordSearch,
                                            from_date,
                                            to_date,
                                            _selectedProvice)
                                        .then((res) {
                                      setState(() {
                                        this.listHistories =
                                            res['data']['items'];
                                        this.totalItem =
                                            int.tryParse(res['data']['total']);
                                        this.pageItem = listHistories.length;
                                        print(pageItem);
                                        var newMap = groupBy(listHistories,
                                            (obj) => obj['from_date']);
                                        var newMapProvice = groupBy(
                                            listHistories,
                                            (obj) => obj['city_name']);
                                        this.listProvice
                                          ..addAll(newMapProvice.keys.toList());
                                        this.listProvice = [
                                          ...{...this.listProvice}
                                        ];
                                        ;
                                        actionIconSort = new Icon(Icons.sort);
                                        _isSearchProvince = true;
                                        print(newMap.length);
                                        this._loading = false;
                                        this.listMap = (newMap);
                                      });
                                    });
                                  });
                                },
                                onClear: () {
                                  print("clear");
                                },
                                isExpanded: true,
                                displayClearIcon: true,
                              )),
                          // FlatButton(
                          //   padding: EdgeInsets.symmetric(
                          //       vertical: 5, horizontal: 5),
                          //   color: Colors.cyan[500],
                          //   onPressed: () {
                          //     setState(() {
                          //       _selectedProvice = 0;

                          //       getListHistory(page, perPage, keywordSearch,
                          //               from_date, to_date, _selectedProvice)
                          //           .then((value) {
                          //         setState(() {
                          //           this.listHistories = value['data']['items'];
                          //           this.totalItem =
                          //               int.tryParse(value['data']['total']);
                          //           this.pageItem = listHistories.length;
                          //           print(pageItem);
                          //           var newMap = groupBy(listHistories,
                          //               (obj) => obj['from_date']);
                          //           var newMapProvice = groupBy(listHistories,
                          //               (obj) => obj['city_name']);
                          //           this.listProvice
                          //             ..addAll(newMapProvice.keys.toList());
                          //           this.listProvice = [
                          //             ...{...this.listProvice}
                          //           ];
                          //           ;
                          //           actionIconSort = new Icon(Icons.sort);
                          //           _isSearchProvince = true;
                          //           print(newMap.length);
                          //           this._loading = false;
                          //           this.listMap = (newMap);
                          //         });
                          //       });
                          //     });
                          //   },
                          //   child: Column(
                          //     //crossAxisAlignment: CrossAxisAlignment.center,
                          //     children: <Widget>[
                          //       Icon(Icons.refresh, color: Colors.white),
                          //       Text(
                          //         "Xóa bộ lọc",
                          //         style: TextStyle(color: Colors.white),
                          //       )
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),

            // : Container(
            //     child: SearchableDropdown.single(
            //       items: provinces.map((Map value) {
            //         return new DropdownMenuItem<String>(
            //           value: value['id'].toString() +
            //               "_" +
            //               value['city_name'],
            //           child: new Text(value['city_name'].toString()),
            //         );
            //       }).toList(),
            //       //isCaseSensitiveSearch: true,
            //       value: "x",
            //       hint: "Chọn tỉnh/TP",
            //       searchHint: "Tìm tỉnh/TP",
            //       onChanged: (value) {},
            //       isExpanded: true,
            //     ),
            //   ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      //elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Palette.primaryColor,
      // title: Text(
      //   'Lịch sử khai báo',
      //   style: GoogleFonts.lato(
      //     color: const Color(0xFFffffff),
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      title: appBarTitle,
      actions: <Widget>[
        new IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close);
                this.appBarTitle = new TextField(
                  onSubmitted: (keyword) {
                    setState(() {
                      this.keywordSearch = keyword;
                      this._loading = true;
                    });
                    getListHistory(page, perPage, keywordSearch, from_date,
                            to_date, _selectedProvice)
                        .then((value) {
                      setState(() {
                        this.listHistories = value['data']['items'];
                        this.totalItem = int.tryParse(value['data']['total']);
                        this.pageItem = listHistories.length;
                        print(pageItem);
                        var newMap =
                            groupBy(listHistories, (obj) => obj['from_date']);
                        var newMapProvice =
                            groupBy(listHistories, (obj) => obj['city_name']);
                        this.listProvice = (newMapProvice.keys.toList());
                        this.listProvice = [
                          ...{...this.listProvice}
                        ];
                        ;
                        print(newMap.length);
                        this._loading = false;
                        this.listMap = (newMap);
                      });
                    });
                  },
                  textInputAction: TextInputAction.search,
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      //hintText: "tìm...(địa điểm, nội dung, tiếp xúc)",
                      hintText: "Tìm kiếm...",
                      hintStyle: new TextStyle(color: Colors.white)),
                );
                this._isSearch = true;
              } else {
                getListHistory(
                        page, perPage, '', from_date, to_date, _selectedProvice)
                    .then((value) {
                  setState(() {
                    this._loading = true;
                    this.keywordSearch = '';
                  });
                  setState(() {
                    this.listHistories = value['data']['items'];
                    this.totalItem = int.tryParse(value['data']['total']);
                    this.pageItem = listHistories.length;
                    print(pageItem);
                    var newMap =
                        groupBy(listHistories, (obj) => obj['from_date']);
                    var newMapProvice =
                        groupBy(listHistories, (obj) => obj['city_name']);
                    this.listProvice = (newMapProvice.keys.toList());
                    this.listProvice = [
                      ...{...this.listProvice}
                    ];
                    ;
                    print(newMap.length);
                    this._loading = false;
                    this.listMap = (newMap);
                  });
                });
                this._isSearch = false;
                this.actionIcon = new Icon(Icons.search);
                this.appBarTitle = new Text("Lịch sử tiếp xúc");
              }
            });
          },
        ),
        // PopupMenuButton(
        //   icon: new Icon(Icons.date_range),
        //   onSelected: _selectDate,
        //   itemBuilder: (BuildContext context) {
        //     return listDate.map((value) {
        //       return PopupMenuItem(value: value, child: Text(value));
        //     }).toList();
        //   },
        // ),
        new IconButton(
            icon: new Icon(Icons.date_range),
            onPressed: () async {
              DateTime now = new DateTime.now();
              final List<DateTime> picked = await DateRagePicker.showDatePicker(
                  context: context,
                  initialFirstDate: _initialFilterFromDate,
                  initialLastDate: _initialFilterToDate
                    ..subtract(new Duration(days: 7)),
                  firstDate: new DateTime(2020),
                  lastDate: new DateTime(now.year + 1, now.month, now.day));
              if (picked != null && picked.length == 2) {
                print(picked.runtimeType);
                getListHistory(page, perPage, '', picked[0], picked[1],
                        _selectedProvice)
                    .then((value) {
                  setState(() {
                    this._loading = true;
                    this.keywordSearch = '';
                    this._initialFilterFromDate = picked[0];
                    this._initialFilterToDate = picked[1];
                    this.listHistories = value['data']['items'];
                    this.totalItem = int.tryParse(value['data']['total']);
                    this.pageItem = listHistories.length;
                    print(pageItem);
                    var newMap =
                        groupBy(listHistories, (obj) => obj['from_date']);
                    var newMapProvice =
                        groupBy(listHistories, (obj) => obj['city_name']);
                    this.listProvice = (newMapProvice.keys.toList());
                    this.listProvice = [
                      ...{...this.listProvice}
                    ];
                    ;
                    print(newMap.length);
                    this._loading = false;
                    this.listMap = (newMap);
                  });
                });
              }
            }),
        // PopupMenuButton(
        //   onSelected: _select,
        //   itemBuilder: (BuildContext context) {
        //     return listProvice.map((value) {
        //       return PopupMenuItem(value: value, child: Text(value));
        //     }).toList();
        //   },
        // ),
        new IconButton(
          icon: actionIconSort,
          onPressed: () {
            setState(() {
              if (this.actionIconSort.icon == Icons.sort) {
                this.actionIconSort = new Icon(Icons.close);

                this._isSearchProvince = !this._isSearchProvince;
              } else {
                this.actionIconSort = new Icon(Icons.sort);
                this._isSearchProvince = !this._isSearchProvince;
              }
            });
          },
        )
      ],
    );
  }

  void _select(choice) {
    setState(() {
      print(choice);
      //_selectedChoice = choice;
    });
  }

  void _selectDate(choice) {
    setState(() {
      //this._searchDate = choice;
      print(choice);
      //_selectedChoice = choice;
    });
  }

  TimelineTile _buildTimelineTile({
    _IconIndicator indicator,
    String hour,
    String weather,
    String temperature,
    String phrase,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineX: 0.2,
      isFirst: isFirst,
      topLineStyle: LineStyle(color: Colors.white.withOpacity(0.7)),
      indicatorStyle: IndicatorStyle(
        indicatorY: 0.3,
        drawGap: true,
        width: 30,
        height: 30,
        indicator: const _IconIndicator(
          iconData: Icons.location_on,
          size: 20,
        ),
      ),
      isLast: isLast,
      leftChild: Center(
        child: Container(
          alignment: const Alignment(0.0, -0.50),
          child: Text(
            hour,
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      rightChild: Padding(
        padding: const EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              weather,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              temperature,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phrase,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _IconIndicator extends StatelessWidget {
  const _IconIndicator({
    Key key,
    this.iconData,
    this.size,
  }) : super(key: key);

  final IconData iconData;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: Icon(
                iconData,
                size: size,
                color: const Color(0xFF9E3773).withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class ListTimeline extends StatelessWidget {
  String date;
  String hour;
  String weather;
  String temperature;
  String phrase;
  List listItems;
  bool isFirst = false;
  bool isLast = false;
  ListTimeline({
    Key key,
    this.date,
    this.listItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        //SizedBox(height: MediaQuery.of(context).size.height * 0.1),

        _ContainerHeader(
          date: Format.stringToDate(date),
        ),
        ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: this.listItems.length,
            itemBuilder: (BuildContext context, int index) {
              //print(listItems.length);
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineX: 0.2,
                isFirst: index == 0 ? true : false,
                topLineStyle: LineStyle(color: Colors.white.withOpacity(0.7)),
                indicatorStyle: IndicatorStyle(
                  indicatorY: 0.3,
                  drawGap: true,
                  width: 30,
                  height: 30,
                  indicator: const _IconIndicator(
                    iconData: Icons.location_on,
                    size: 20,
                  ),
                ),
                isLast: listItems.length == index + 1 ? true : false,
                leftChild: Center(
                  child: Container(
                    alignment: const Alignment(0.0, -0.50),
                    child: Text(
                      listItems[index]['from_hour'].substring(0, 5) +
                          " - " +
                          listItems[index]['to_hour'].substring(0, 5),
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                rightChild: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 5, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        listItems[index]['city_name'] +
                            " - " +
                            listItems[index]['district_name'] +
                            " - " +
                            listItems[index]['location'],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nội dung: ' + listItems[index]['activities'],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Người tiếp xúc: ' +
                            listItems[index]['related_persons'],
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
        // Container(
        //   color: Colors.blue[200],
        //   child: FlatButton(
        //     child: Text(
        //       "Xem thêm",
        //       style:
        //           TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //     ),
        //     onPressed: () {},
        //   ),
        // )
      ],
    );
  }
}

class _ContainerHeader extends StatelessWidget {
  _ContainerHeader({Key key, this.date}) : super(key: key);

  String date;
  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: const BoxConstraints(minHeight: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            // Text(
            //   '06-08-2020',
            //   style: GoogleFonts.lato(
            //     fontSize: 18,
            //     color: const Color(0xFFF4A5CD),
            //   ),
            // ),
            //const SizedBox(width: 5),

            Text(
              date,
              style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.yellow[50],
                fontWeight: FontWeight.bold,
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     Expanded(
            //       child: Text(
            //         'Quận Tân Phú',
            //         overflow: TextOverflow.ellipsis,
            //         textAlign: TextAlign.right,
            //         style: GoogleFonts.lato(
            //           fontSize: 14,
            //           color: const Color(0xFF4A448F).withOpacity(0.8),
            //           fontWeight: FontWeight.w800,
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     Text(
            //       'Đường Âu Cơ',
            //       style: GoogleFonts.lato(
            //         fontSize: 14,
            //         color: const Color(0xFF4A448F).withOpacity(0.8),
            //         fontWeight: FontWeight.w800,
            //       ),
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}

class _Sun extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 25,
            spreadRadius: 20,
          ),
        ],
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}
