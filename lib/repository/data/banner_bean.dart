class BannerBean {
  int? id;
  String? imagePath;

  BannerBean({this.id, this.imagePath});

  BannerBean.fromJson(Map<String, dynamic> json) {
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
