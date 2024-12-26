class NewsArticleModel {
  String? msg;
  String? code;
  Data? data;

  NewsArticleModel({this.msg, this.code, this.data});

  NewsArticleModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<News>? list;
  int? total;
  int? pageNum;
  int? pageSize;
  int? totalPages;

  Data({this.list, this.total, this.pageNum, this.pageSize, this.totalPages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <News>[];
      json['list'].forEach((v) {
        list!.add(News.fromJson(v));
      });
    }
    total = json['total'];
    pageNum = json['pageNum'];
    pageSize = json['pageSize'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['pageNum'] = pageNum;
    data['pageSize'] = pageSize;
    data['totalPages'] = totalPages;
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
