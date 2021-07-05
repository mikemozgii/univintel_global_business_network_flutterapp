class News  {
  String id;
  String title;
  String body;
  String companyId;
  String accountId;
  bool visible;
  String link;
  String imageId;
  DateTime datePublish;

  News() {
    id = null;
    title = "";
    body = "";
    visible = true;
    link = "";
  }

  News.fromJson(Map<String, dynamic> json)
    : id = json['id'],
    title = json['title'], 
    body = json['body'],
    accountId = json['accountId'],
    visible = json['visible'],
    link = json['link'],
    imageId = json['imageId'],
    datePublish = DateTime.parse(json['datePublish']),
    companyId = json['companyId'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'title': title,
      'body': body,
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'companyId': companyId,
      'link': link,
      'visible': visible,
      'datePublish': datePublish.toIso8601String(),
      'imageId': imageId
    };
  }

}