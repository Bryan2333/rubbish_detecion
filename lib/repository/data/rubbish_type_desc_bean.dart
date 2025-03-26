class RubbishTypeDescBean {
  int? id;
  int? type;
  String? name;
  String? description;
  dynamic disposalAdvice;
  dynamic handleMethods;
  dynamic commonThings;

  RubbishTypeDescBean(
      {this.id,
      this.type,
      this.name,
      this.description,
      this.disposalAdvice,
      this.handleMethods,
      this.commonThings});

  RubbishTypeDescBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    disposalAdvice = json['disposalAdvice'];
    handleMethods = json['handleMethods'];
    commonThings = json['commonThings'];
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
