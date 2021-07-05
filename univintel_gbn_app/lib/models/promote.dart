class Promote  {
  String id;
  String title;
  DateTime dateStart;
  DateTime dateEnd;
  int typeId;
  String companyId;
  String itemTypeId;


  Promote() {
    id = null;
  }

    Promote.fromJson(Map<String, dynamic> json)
    : id = json['id'],
    title = json['title'] ?? "", 
    dateStart = DateTime.parse(json['dateStart']) ?? "", 
    dateEnd = DateTime.parse(json['dateEnd']) ?? "", 
    itemTypeId = json['itemTypeId'] ?? "", 
    typeId = json['typeId'] ?? "", 
    companyId = json['companyId'];


  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'title': title,
      'typeId': typeId,
      'itemTypeId': itemTypeId,
      'dateStart': dateStart.toIso8601String(),
      'dateEnd': dateEnd.toIso8601String(),
      'companyId': companyId
    };
  }
}