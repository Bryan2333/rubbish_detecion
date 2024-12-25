class SmartAddress {
  String? province;
  String? city;
  String? provinceCode;
  int? logId;
  String? text;
  String? town;
  String? phonenum;
  String? detail;
  String? county;
  String? person;
  String? townCode;
  String? countyCode;
  String? cityCode;

  SmartAddress(
      {this.province,
      this.city,
      this.provinceCode,
      this.logId,
      this.text,
      this.town,
      this.phonenum,
      this.detail,
      this.county,
      this.person,
      this.townCode,
      this.countyCode,
      this.cityCode});

  SmartAddress.fromJson(Map<String, dynamic> json) {
    province = json['province'];
    city = json['city'];
    provinceCode = json['province_code'];
    logId = json['log_id'];
    text = json['text'];
    town = json['town'];
    phonenum = json['phonenum'];
    detail = json['detail'];
    county = json['county'];
    person = json['person'];
    townCode = json['town_code'];
    countyCode = json['county_code'];
    cityCode = json['city_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['province'] = province;
    data['city'] = city;
    data['province_code'] = provinceCode;
    data['log_id'] = logId;
    data['text'] = text;
    data['town'] = town;
    data['phonenum'] = phonenum;
    data['detail'] = detail;
    data['county'] = county;
    data['person'] = person;
    data['town_code'] = townCode;
    data['county_code'] = countyCode;
    data['city_code'] = cityCode;
    return data;
  }
}
