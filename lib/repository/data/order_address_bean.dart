class OrderAddressBean {
  int? id;
  String? name;
  String? phoneNum;
  String? province;
  String? city;
  String? area;
  String? detail;
  String? pickupTime;
  String? createdAt;
  String? updatedAt;

  OrderAddressBean(
      {this.id,
      this.name,
      this.phoneNum,
      this.province,
      this.city,
      this.area,
      this.detail,
      this.pickupTime,
      this.createdAt,
      this.updatedAt});

  OrderAddressBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNum = json['phoneNum'];
    province = json['province'];
    city = json['city'];
    area = json['area'];
    detail = json['detail'];
    pickupTime = json['pickupTime'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phoneNum'] = phoneNum;
    data['province'] = province;
    data['city'] = city;
    data['area'] = area;
    data['detail'] = detail;
    data['pickupTime'] = pickupTime;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
