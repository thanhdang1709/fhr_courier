import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/palette.dart';
import '../config/styles.dart';
import '../data/data.dart';
import '../screens/map_screen.dart';
import '../widgets/drawer.dart';
import '../widgets/network_sensity.dart';
import '../widgets/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/case.dart';
import '../helpers/format.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:swipedetector/swipedetector.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Việt Nam'),
    new Tab(text: 'Thế Giới'),
  ];
  int totalCase = 0;
  int totalDeaded = 0;
  int recovered = 0;
  int critcial = 0;
  int treated = 0;
  int localtion = 0;

  int totalCase_world = 0;
  int totalDeaded_world = 0;
  int recovered_world = 0;
  int critcial_world = 0;
  int treated_world = 0;
  int localtion_world = 0;

  int totalCase_vn = 0;
  int totalDeaded_vn = 0;
  int recovered_vn = 0;
  int critcial_vn = 0;
  int treated_vn = 0;
  int localtion_vn = 0;

  int _initialIndexTab;
  String lastUpdate;
  bool _loading;

  Case case_json;
  DioCacheManager _dioCacheManager;
  TabController _tabController;
  Future _getInfoCase() async {
    var url = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/cv19/report';
    try {
      _dioCacheManager = DioCacheManager(CacheConfig());

      Options _cacheOptions = buildCacheOptions(Duration(minutes: 10));
      Dio _dio = Dio();
      _dio.interceptors.add(_dioCacheManager.interceptor);
      Response response = await _dio.get(url, options: _cacheOptions);
      if (200 == response.statusCode) {
        Map<String, dynamic> map = (response.data);
        // setState(() {
        //   _loading = false;
        // });
        print(map.length);
        return map;
      }

      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _loading = true;
    _initialIndexTab = 0;

    _getInfoCase().then((res) {
      if (res['code'] == 200) {
        print(res['data']);
        setState(() {
          this.lastUpdate = res['data']['last_updated'];
          this.totalCase_vn = res['data']['vietnam']['confirmed'];
          this.totalDeaded_vn = res['data']['vietnam']['deaths'];
          this.recovered_vn = res['data']['vietnam']['recovered'];
          this.critcial_vn = res['data']['vietnam']['critical'];
          this.treated_vn = res['data']['vietnam']['tests'];

          this.totalCase_world = res['data']['world']['confirmed'];
          this.totalDeaded_world = res['data']['world']['deaths'];
          this.recovered_world = res['data']['world']['recovered'];
          this.critcial_world = res['data']['world']['critical'];
          this.treated_world = res['data']['world']['tests'];
          _loading = false;
          Future.delayed(new Duration(milliseconds: 200), () {
            this.totalCase = this.totalCase_vn;
            this.totalDeaded = this.totalDeaded_vn;
            this.recovered = this.recovered_vn;
            this.critcial = this.critcial_vn;
            this.treated = this.treated_vn;
          });
        });
      }
      _tabController = new TabController(vsync: this, length: myTabs.length);
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            future: Future.delayed(new Duration(milliseconds: 200), () {}),
            builder: (context, snapshot) {
              return Scaffold(
                drawer: CustomeDrawer(),
                resizeToAvoidBottomPadding: false,
                backgroundColor: Palette.primaryColor,
                appBar: CustomAppBar(),
                body: SwipeDetector(
                  child: CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    slivers: <Widget>[
                      _buildHeader(),
                      _buildRegionTabBar(),
                      //_buildStatsTabBar(),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            left: 40.0, top: 20, bottom: 20),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "Thời gian cập nhật: " +
                                Format.stringToTime(lastUpdate),
                            //lastUpdate,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Column(
                              children: <Widget>[
                                Flexible(
                                  child: Row(
                                    children: <Widget>[
                                      _buildStatCard(
                                          'Tổng ca',
                                          Format.numberFormat(totalCase),
                                          Colors.orange),
                                      _buildStatCard(
                                          'Tử vong',
                                          Format.numberFormat(this.totalDeaded),
                                          Colors.red),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Row(
                                    children: <Widget>[
                                      _buildStatCard(
                                          'Bình phục',
                                          Format.numberFormat(this.recovered),
                                          Colors.green),
                                      _buildStatCard(
                                          'Đang điều trị',
                                          Format.numberFormat((this.totalCase -
                                              this.recovered -
                                              this.totalDeaded)),
                                          Colors.purple),
                                      // _buildStatCard(
                                      //     'Nguy kịch',
                                      //     this.critcial.toString(),
                                      //     Colors.purple),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildYourOwnTest()
                    ],
                  ),
                  onSwipeLeft: () {
                    // final indexTab = TabBar.of(context).index;
                    print("left");
                  },
                  onSwipeRight: () {
                    print("right");
                  },
                  swipeConfiguration: SwipeConfiguration(
                      verticalSwipeMinVelocity: 100.0,
                      verticalSwipeMinDisplacement: 50.0,
                      verticalSwipeMaxWidthThreshold: 100.0,
                      horizontalSwipeMaxHeightThreshold: 50.0,
                      horizontalSwipeMinDisplacement: 50.0,
                      horizontalSwipeMinVelocity: 200.0),
                ),
              );
            });
  }

  SliverPadding _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.all(20.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          'Thống kê',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRegionTabBar() {
    return SliverToBoxAdapter(
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BubbleTabIndicator(
              tabBarIndicatorSize: TabBarIndicatorSize.tab,
              indicatorHeight: 40.0,
              indicatorColor: Colors.white,
            ),
            labelStyle: Styles.tabTextStyle,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            tabs: myTabs,
            onTap: (index) {
              if (1 == index) {
                setState(() {
                  this._loading = false;
                  this.totalCase = this.totalCase_world;
                  this.totalDeaded = this.totalDeaded_world;
                  this.recovered = this.recovered_world;
                  this.critcial = this.critcial_world;
                  this.treated = this.treated_world;
                });
              } else {
                setState(() {
                  this._loading = false;
                  this.totalCase = this.totalCase_vn;
                  this.totalDeaded = this.totalDeaded_vn;
                  this.recovered = this.recovered_vn;
                  this.critcial = this.critcial_vn;
                  this.treated = this.treated_vn;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  SliverPadding _buildStatsTabBar() {
    return SliverPadding(
      padding: const EdgeInsets.all(20.0),
      sliver: SliverToBoxAdapter(
        child: DefaultTabController(
          length: 3,
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelStyle: Styles.tabTextStyle,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: <Widget>[
              Text('Tổng'),
              Text('Hôm nay'),
              Text('Hôm qua'),
            ],
            onTap: (index) {
              print(index);
            },
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildYourOwnTest() {
    Size size = MediaQuery.of(context).size;
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MapScreen(
                title: "Bản đồ dịch tễ",
                url: "https://maps.vnpost.vn/corona/#/app"
                //url: "https://www.youtube.com/watch?v=Q88PzIqTck8",
                );
          }));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          padding: const EdgeInsets.all(10.0),
          height: size.height * 0.15,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x12FFF7), Palette.primaryColor],
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/images/byt.png'),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bản đồ dịch tễ!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Theo dõi lịch trình di chuyển\n của các ca nhiễm.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildStatCard(String title, String count, MaterialColor color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color(0x005b96)],
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
