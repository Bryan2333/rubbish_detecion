class RubbishTypeDescModel {
  int? code;
  String? msg;
  RubbishTypeDesc? data;

  RubbishTypeDescModel({this.code, this.msg, this.data});

  RubbishTypeDescModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    data = json['data'] != null ? RubbishTypeDesc.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RubbishTypeDesc {
  String? name;
  String? desc;
  List<String>? disposalAdvice;
  List<String>? handleMethods;
  List<String>? commonThings;

  RubbishTypeDesc(
      {this.name,
      this.desc,
      this.disposalAdvice,
      this.handleMethods,
      this.commonThings});

  RubbishTypeDesc.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    desc = json['desc'];
    disposalAdvice = json['disposal_advice'].cast<String>();
    handleMethods = json['handle_methods'].cast<String>();
    commonThings = json['common_things'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['desc'] = desc;
    data['disposal_advice'] = disposalAdvice;
    data['handle_methods'] = handleMethods;
    data['common_things'] = commonThings;
    return data;
  }
}
