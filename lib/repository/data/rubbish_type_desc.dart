class RubbishTypeDescModel {
  String? msg;
  String? code;
  RubbishTypeDesc? data;

  RubbishTypeDescModel({this.msg, this.code, this.data});

  RubbishTypeDescModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    code = json['code'];
    data = json['data'] != null ? RubbishTypeDesc.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RubbishTypeDesc {
  int? id;
  int? type;
  String? name;
  String? description;
  List<String>? disposalAdvice;
  List<String>? handleMethods;
  List<String>? commonThings;

  RubbishTypeDesc(
      {this.id,
      this.type,
      this.name,
      this.description,
      this.disposalAdvice,
      this.handleMethods,
      this.commonThings});

  RubbishTypeDesc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    disposalAdvice = json['disposalAdvice'].cast<String>();
    handleMethods = json['handleMethods'].cast<String>();
    commonThings = json['commonThings'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['description'] = description;
    data['disposalAdvice'] = disposalAdvice;
    data['handleMethods'] = handleMethods;
    data['commonThings'] = commonThings;
    return data;
  }
}
