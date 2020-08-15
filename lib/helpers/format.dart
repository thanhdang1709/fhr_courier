import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Format {
  // String stringTime;
  //FormatTime({this.stringTime});

  static String stringToTime(stringTime) {
    //DateTime tempDate = new DateFormat("dd-MM-yyyy hh:mm:ss").parse(stringTime);
    //String string = dateFormat.format(DateTime.now());
    //DateTime dateTime = dateFormat.parse(stringTime);
    List<String> listDate = stringTime.split(' ');
    List dateList = listDate[0].split('-');
    String dateParse =
        '${listDate[1]} ngày ${dateList[2]}-${dateList[1]}-${dateList[0]}';
    return dateParse;
  }

  static String stringToDate(stringTime) {
    //DateTime tempDate = new DateFormat("dd-MM-yyyy hh:mm:ss").parse(stringTime);
    //String string = dateFormat.format(DateTime.now());
    //DateTime dateTime = dateFormat.parse(stringTime);
    List<String> listDate = stringTime.split(' ');
    List dateList = listDate[0].split('-');
    String dateParse = '${dateList[2]}-${dateList[1]}-${dateList[0]}';
    return dateParse;
  }

  static numberFormat(number) {
    final formatter = new NumberFormat("#,###");
    return formatter.format(number);
  }
}
