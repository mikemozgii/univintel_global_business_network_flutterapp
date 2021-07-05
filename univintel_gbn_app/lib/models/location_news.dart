class LocaltionNews  {
  String id;
  String title;
  String body;
  String link;
  String imageId;

  LocaltionNews() {
    id = null;
    title = "";
    body = "";
    link = "";
  }

  LocaltionNews.fromJson(Map<String, dynamic> json)
    : id = json['id'],
    title = json['title'], 
    body = json['body'],
    link = json['link'],
    imageId = json['imageId'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'title': title,
      'body': body,
      'link': link,
      'imageId': imageId
    };
  }

}