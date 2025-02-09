class RecognitionCollectionBean {
  int? id;
  int? userId;
  String? image;
  int? rubbishType;
  String? rubbishName;
  String? createdAt;

  RecognitionCollectionBean(
      {this.id,
      this.userId,
      this.image,
      this.rubbishType,
      this.rubbishName,
      this.createdAt});

  RecognitionCollectionBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    image = json['image'];
    rubbishType = json['rubbishType'];
    rubbishName = json['rubbishName'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['image'] = image;
    data['rubbishType'] = rubbishType;
    data['rubbishName'] = rubbishName;
    data['createdAt'] = createdAt;
    return data;
  }
}
