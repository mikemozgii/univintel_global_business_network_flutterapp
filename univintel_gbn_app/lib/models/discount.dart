class Discount {
  String id;
  String title;
  String link;
  String type;
  String description;
  String code;
  String companyId;
  String accountId;
  String imageId;
  bool isVisible;
  bool reusable;
  List<String> addressesIds;
  DateTime dateEnd;
  DateTime dateStart;
  int minRank;
  String onlyCompanies;

  Discount() {
    id = null;
    onlyCompanies = "";
    minRank = 0;
  }

  Discount.fromJson(Map<String, dynamic> json)
    : id = json['id'],
    title = json['title'], 
    link = json['link'],
    description = json['description'],
    imageId = json['imageId'] ?? "",
    type = json['type'],
    code = json['code'],
    isVisible = json['isVisible'],
    reusable = json['reusable'],
    accountId = json['accountId'],
    minRank = json['minRank'],
    onlyCompanies = json['onlyCompanies'],
    addressesIds = json['addressesIds'] ?? [],
    dateEnd = json['dateEnd'] == null ? null : DateTime.parse(json['dateEnd']), 
    dateStart = json['dateStart'] == null ? null : DateTime.parse(json['dateStart']), 
    companyId = json['companyId'];


  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'title': title,
      'link': link,
      'description': description,
      'imageId': imageId == "" ? '00000000-0000-0000-0000-000000000000' : imageId,
      'type': type ?? "",
      'code': code ?? "",
      'isVisible': isVisible,
      'reusable': reusable,
      'addressesIds': addressesIds ?? [],
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'dateEnd': dateEnd == null ? null : dateEnd.toIso8601String(),
      'dateStart': dateStart == null ? null : dateStart.toIso8601String(),
      'minRank': minRank,
      'onlyCompanies': onlyCompanies,
      'companyId': companyId
    };
  }

}