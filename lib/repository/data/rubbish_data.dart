class RubbishDataModel {
  int? code;
  String? msg;
  Result? result;

  RubbishDataModel({this.code, this.msg, this.result});

  RubbishDataModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    result =
        json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  List<Rubbish>? list;

  Result({this.list});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <Rubbish>[];
      json['list'].forEach((v) {
        list!.add(Rubbish.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rubbish {
  String? name;
  int? type;
  int? aipre;
  String? explain;
  String? contain;
  String? tip;

  Rubbish(
      {this.name, this.type, this.aipre, this.explain, this.contain, this.tip});

  Rubbish.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    aipre = json['aipre'];
    explain = json['explain'];
    contain = json['contain'];
    tip = json['tip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['aipre'] = aipre;
    data['explain'] = explain;
    data['contain'] = contain;
    data['tip'] = tip;
    return data;
  }
}
