import 'package:rubbish_detection/repository/data/order_address_bean.dart';
import 'package:rubbish_detection/repository/data/order_waste_bean.dart';

class OrderBean {
  int? id;
  int? userId;
  OrderWasteBean? waste;
  OrderAddressBean? address;
  String? orderDate;
  int? orderStatus; // 0 - 未完成，1 - 处理中, 2 - 已完成, 3 - 已取消
  double? estimatedPrice;
  double? actualPrice;
  String? createdAt;
  String? updatedAt;

  OrderBean(
      {this.id,
      this.userId,
      this.waste,
      this.address,
      this.orderDate,
      this.orderStatus,
      this.estimatedPrice,
      this.actualPrice,
      this.createdAt,
      this.updatedAt});

  OrderBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    waste =
        json['waste'] != null ? OrderWasteBean.fromJson(json['waste']) : null;
    address = json['address'] != null
        ? OrderAddressBean.fromJson(json['address'])
        : null;
    orderDate = json['orderDate'];
    orderStatus = json['orderStatus'];
    estimatedPrice = json['estimatedPrice'];
    actualPrice = json['actualPrice'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    if (waste != null) {
      data['waste'] = waste!.toJson();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['orderDate'] = orderDate;
    data['orderStatus'] = orderStatus;
    data['estimatedPrice'] = estimatedPrice;
    data['actualPrice'] = actualPrice;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
