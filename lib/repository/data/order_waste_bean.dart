import 'package:rubbish_detection/repository/data/order_waste_photo_bean.dart';

class OrderWasteBean {
  int? id;
  int? type;
  String? name;
  double? weight;
  int? unit;
  String? description;
  List<OrderWastePhotoBean>? photos;
  String? createdAt;
  String? updatedAt;

  OrderWasteBean(
      {this.id,
      this.type = 0,
      this.name,
      this.weight,
      this.unit = 1,
      this.description,
      this.photos,
      this.createdAt,
      this.updatedAt});

  OrderWasteBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    weight = json['weight'];
    unit = json['unit'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['photos'] != null) {
      photos = <OrderWastePhotoBean>[];
      json['photos'].forEach((v) {
        photos!.add(OrderWastePhotoBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['weight'] = weight;
    data['unit'] = unit;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
