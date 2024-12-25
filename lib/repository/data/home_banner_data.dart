class HomeBannerDataModel {
  List<HomeBanner>? data;
  int? code;
  String? msg;

  HomeBannerDataModel({this.data, this.code, this.msg});

  HomeBannerDataModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <HomeBanner>[];
      json['data'].forEach((v) {
        data!.add(HomeBanner.fromJson(v));
      });
    }
    code = json['errorCode'];
    msg = json['errorMsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['errorCode'] = code;
    data['errorMsg'] = msg;
    return data;
  }
}

class HomeBanner {
  int? id;
  String? imagePath;

  HomeBanner({this.id, this.imagePath});

  HomeBanner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imagePath'] = imagePath;
    return data;
  }
}
