import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/palette.dart';
import '../config/styles.dart';
import '../data/data.dart';
import '../widgets/drawer.dart';
import '../widgets/widgets.dart';
import 'package:http/http.dart' as http;

import '../screens/map_screen.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _country = 'USA';
  List listNews;
  bool _loading;
  DioCacheManager _dioCacheManager;
  Future getListNews() async {
    var url = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/news/list';
    print("cache: " + _dioCacheManager.toString());
    try {
      _dioCacheManager = DioCacheManager(CacheConfig());
      Options _cacheOptions = buildCacheOptions(Duration(hours: 1));
      Dio _dio = Dio();
      _dio.interceptors.add(_dioCacheManager.interceptor);
      Response response = await _dio.get(url, options: _cacheOptions);
      if (200 == response.statusCode) {
        //return response.body;
        Map<String, dynamic> map = response.data;
        //print(map);
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
    this.getListNews().then((value) {
      if (value['code'] == 200) {
        setState(() {
          // print(value.length);
          this.listNews = value['data'];
          _loading = false;
          print(listNews.length);
        });
        if (!mounted) return;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: CustomeDrawer(),
      appBar: CustomAppBar(),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: Future.delayed(new Duration(milliseconds: 200), () {}),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Text(
                          "Tin mới",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    // Row(
                    //   children: <Widget>[
                    //     Flexible(
                    //       child: Container(
                    //         padding: const EdgeInsets.all(20.0),
                    //         decoration: BoxDecoration(
                    //           color: Palette.primaryColor,
                    //           borderRadius: BorderRadius.only(
                    //             bottomLeft: Radius.circular(40.0),
                    //             bottomRight: Radius.circular(40.0),
                    //           ),
                    //         ),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: <Widget>[
                    //             Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 Text(
                    //                   'Nếu bạn cảm thấy bị bệnh với bất kỳ triệu chứng COVID-19 nào, vui lòng gọi hoặc nhắn tin cho chúng tôi ngay lập tức để được giúp đỡ',
                    //                   style: const TextStyle(
                    //                     color: Colors.white70,
                    //                     fontSize: 15.0,
                    //                   ),
                    //                 ),
                    //               ],
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // Row(
                    //   children: <Widget>[
                    //     Flexible(
                    //       child: Container(
                    //         padding: const EdgeInsets.all(20.0),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: <Widget>[
                    //             Text(
                    //               'Cách phòng ngừa',
                    //               style: const TextStyle(
                    //                 fontSize: 22.0,
                    //                 fontWeight: FontWeight.w600,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 20.0),
                    //             Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               children: prevention
                    //                   .map((e) => Column(
                    //                         children: <Widget>[
                    //                           Image.asset(
                    //                             e.keys.first,
                    //                             height: screenHeight * 0.12,
                    //                           ),
                    //                           SizedBox(
                    //                               height: screenHeight * 0.015),
                    //                           Text(
                    //                             e.values.first,
                    //                             style: const TextStyle(
                    //                               fontSize: 10.0,
                    //                               fontWeight: FontWeight.w500,
                    //                             ),
                    //                             textAlign: TextAlign.center,
                    //                           )
                    //                         ],
                    //                       ))
                    //                   .toList(),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    Container(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: listNews.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildYourOwnTest(
                                  screenHeight,
                                  listNews[index]["title"],
                                  listNews[index]["description"],
                                  listNews[index]["image_url"],
                                  listNews[index]['link'],
                                  listNews[index]['pub_date']);
                            }),
                      ),
                    ),
                  ],
                ));
              }),
    );
  }

  SliverToBoxAdapter _buildHeader(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Palette.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*Text(
                  'Nếu bạn cảm thấy không được khỏe',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),*/
                //SizedBox(height: screenHeight * 0.01),
                Text(
                  'Nếu bạn cảm thấy bị bệnh với bất kỳ triệu chứng COVID-19 nào, vui lòng gọi hoặc nhắn tin cho chúng tôi ngay lập tức để được giúp đỡ',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15.0,
                  ),
                ),
                //SizedBox(height: screenHeight * 0.03),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton.icon(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      onPressed: () {},
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Gọi ngay',
                        style: Styles.buttonTextStyle,
                      ),
                      textColor: Colors.white,
                    ),
                    FlatButton.icon(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      onPressed: () {},
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                      ),
                      label: Text(
                        'SMS',
                        style: Styles.buttonTextStyle,
                      ),
                      textColor: Colors.white,
                    ),
                  ],
                ),*/
              ],
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildPreventionTips(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Cách phòng ngừa',
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: prevention
                  .map((e) => Column(
                        children: <Widget>[
                          Image.asset(
                            e.keys.first,
                            height: screenHeight * 0.12,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Text(
                            e.values.first,
                            style: const TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildYourOwnTest(double screenHeight, String title,
      String description, String imageUrl, String postUrl, String pub_date) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 2.0,
        ),
        padding: const EdgeInsets.all(2.0),
        height: screenHeight * 0.2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            //colors: [Color(0xFFAD9FE4), Palette.primaryColor],
            colors: [Colors.white, Colors.grey[200]],
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MapScreen(title: title, url: postUrl);
            }));

            // _launchURL() async {
            //   var url = postUrl;
            //   if (await canLaunch(url)) {
            //     await launch(url);
            //   } else {
            //     throw 'Could not launch $url';
            //   }
            // }
            // _launchURL();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                // placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: imageUrl,
                width: size.width * 0.35,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      Text(
                        pub_date,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9.0,
                            fontStyle: FontStyle.italic),
                        maxLines: 1,
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
