class UserDataModel {
  String? code;
  String? message;
  User? data;

  UserDataModel({this.code, this.message, this.data});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? User.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? username;
  String? email;
  int? age;
  String? gender;
  String? signature;
  String? avatar;
  int? participationCount;
  double? totalRecycleAmount;

  User(
      {this.id,
      this.username,
      this.email,
      this.age,
      this.gender,
      this.signature,
      this.avatar,
      this.participationCount,
      this.totalRecycleAmount});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    age = json['age'];
    gender = json['gender'];
    signature = json['signature'];
    avatar = json['avatar'];
    participationCount = json['participationCount'];
    totalRecycleAmount = json['totalRecycleAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['age'] = age;
    data['gender'] = gender;
    data['signature'] = signature;
    data['avatar'] = avatar;
    data['participationCount'] = participationCount;
    data['totalRecycleAmount'] = totalRecycleAmount;
    return data;
  }
}
