class OrderWastePhotoBean {
  int? id;
  int? wasteId;
  String? imagePath;

  OrderWastePhotoBean({this.id, this.wasteId, this.imagePath});

  OrderWastePhotoBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    wasteId = json['wasteId'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['wasteId'] = wasteId;
    data['imagePath'] = imagePath;
    return data;
  }
}
