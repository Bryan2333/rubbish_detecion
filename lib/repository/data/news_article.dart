class NewsArticleModel {
  String? code;
  String? message;
  List<News>? data;

  NewsArticleModel({this.code, this.message, this.data});

  NewsArticleModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
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
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class News {
  int? id;
  String? url;
  String? imageUrl;
  String? title;
  String? author;
  String? createdTime;

  News(
      {this.id,
      this.url,
      this.imageUrl,
      this.title,
      this.author,
      this.createdTime});

  News.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    imageUrl = json['imageUrl'];
    title = json['title'];
    author = json['author'];
    createdTime = json['createdTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['imageUrl'] = imageUrl;
    data['title'] = title;
    data['author'] = author;
    data['createdTime'] = createdTime;
    return data;
  }
}
