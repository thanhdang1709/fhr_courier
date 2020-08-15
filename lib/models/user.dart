class User {
  String fullname;
  String phone;
  String email;
  String password;

  User({this.fullname, this.phone, this.email, this.password});

  factory User.fromJson(Map<String, dynamic> json) {
   return User( fullname : json['fullname'],
    phone : json['phone'],
    email : json['email'],
    password : json['password'],
   );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullname'] = this.fullname;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['password'] = this.password;
    return data;
  }
}