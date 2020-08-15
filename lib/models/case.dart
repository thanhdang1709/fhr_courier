class Case {
  int confirmed;
  int recovered;
  int deaths;
  int critical;
  int tests;

  Case(
      {this.confirmed, this.recovered, this.deaths, this.critical, this.tests});

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case (
      confirmed : json['confirmed'],
      recovered : json['recovered'],
      deaths : json['deaths'],
      critical : json['critical'],
      tests : json['tests'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['confirmed'] = this.confirmed;
    data['recovered'] = this.recovered;
    data['deaths'] = this.deaths;
    data['critical'] = this.critical;
    data['tests'] = this.tests;
    return data;
  }
}