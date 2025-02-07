class BaseModel<T> {
  String? code;
  String? message;
  T? data;

  BaseModel({this.code, this.message, this.data});

  BaseModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }
}
