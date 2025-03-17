class NewsBean {
  int? id;
  String? url;
  String? imageUrl;
  String? title;
  String? author;
  String? publishTime;

  NewsBean(
      {this.id,
      this.url,
      this.imageUrl,
      this.title,
      this.author,
      this.publishTime});

  NewsBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    imageUrl = json['imageUrl'];
    title = json['title'];
    author = json['author'];
    publishTime = json['publishTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['imageUrl'] = imageUrl;
    data['title'] = title;
    data['author'] = author;
    data['publishTime'] = publishTime;
    return data;
  }
}
