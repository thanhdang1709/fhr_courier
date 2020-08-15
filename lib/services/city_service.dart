import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../models/district.dart';
import 'package:http/http.dart' as http;
import '../models/city.dart';

import '../services/city_service.dart';

const baseUrl = 'http://vp.bmt-inc.vn/bmt_ift_api/public_html/api/';

class CityService {
  //final http.Client httpClient;

  // CityService({@required this.httpClient}) : assert(httpClient != null);

  static Future<List> getListCities() async {
    var url = '${baseUrl}city/list';
    try {
      var response = await http.get(url);
      if (200 == response.statusCode) {
        final jsonResponse = json.decode(response.body);
        City cities = new City.fromJson(jsonResponse);
        //print(cities.data);
        await cities.data.map((v) => print(v.id));
        return cities.data;
      }
      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
  }

  static Future getListDistrict(value) async {
    var url = '${baseUrl}district/list?city_id=$value';
    try {
      var response = await http.get(url);
      if (200 == response.statusCode) {
        final jsonResponse = json.decode(response.body);
        //District cities = new District.fromJson(jsonResponse);
        //print(cities.data);
        //await cities.data.map((v) => print(v.id));
        return jsonResponse;
      }
      if (400 == response.statusCode) {}
    } catch (e) {
      print(e);
    }
  }

  static Future addFieldFormGuest(body) async {
    var url = '${baseUrl}tracking/guest';
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
}
