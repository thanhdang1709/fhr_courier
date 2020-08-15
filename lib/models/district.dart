class District {
  int code;
  String message;
  List<Data> data;

  District({this.code, this.message, this.data});

  District.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String id;
  String districtName;
  String cityId;
  String cityName;

  Data({this.id, this.districtName, this.cityId, this.cityName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    districtName = json['district_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['district_name'] = this.districtName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    return data;
  }
}
