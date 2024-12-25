class NewsDataModel {
  int? code;
  String? msg;
  List<News>? data;

  NewsDataModel({this.code, this.msg, this.data});

  NewsDataModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <News>[];
      json['data'].forEach((v) {
        data!.add(News.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class News {
  String? url;
  String? imageUrl;
  String? title;
  String? author;
  String? createdTime;

  News({this.url, this.imageUrl, this.title, this.author, this.createdTime});

  News.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    imageUrl = json['imageUrl'];
    title = json['title'];
    author = json['author'];
    createdTime = json['created_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['imageUrl'] = imageUrl;
    data['title'] = title;
    data['author'] = author;
    data['created_time'] = createdTime;
    return data;
  }
}
