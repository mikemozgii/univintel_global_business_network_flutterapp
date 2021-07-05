class CompanyFile  {
  String id;
  String name;
  String type;
  int size;
  String accountId;
  String companyId;
  DateTime uploaded;
  String tag;

  CompanyFile() {
    id = null;
    accountId = null;
  }

  CompanyFile.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      type = json['type'],
      accountId = json['accountId'],
      size = json['size'],
      uploaded = DateTime.parse(json['uploaded']),
      companyId = json['companyId'],
      tag = json['tag'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'type': type,
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'uploaded': uploaded.toIso8601String(),
      'size': size,
      'companyId': companyId,
      'tag': tag
    };
  }

}