class UserBean {
  int? id;
  String? username;
  String? email;
  int? age;
  String? gender;
  String? signature;
  String? avatar;
  int? participationCount;
  double? totalRecycleAmount;
  String? role;

  UserBean(
      {this.id,
      this.username,
      this.email,
      this.age,
      this.gender,
      this.signature,
      this.avatar,
      this.participationCount,
      this.totalRecycleAmount,
      this.role});

  UserBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    age = json['age'];
    gender = json['gender'];
    signature = json['signature'];
    avatar = json['avatar'];
    participationCount = json['participationCount'];
    role = json['role'];
    if (json['totalRecycleAmount'] is num) {
      totalRecycleAmount = json['totalRecycleAmount'].toDouble();
    } 
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
    data['role'] = role;
    return data;
  }
}
