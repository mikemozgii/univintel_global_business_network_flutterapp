class Product  {
  String id;
  String title;
  String link;
  String type;
  String description;
  String upc;
  double price;
  double currentPrice;
  String companyId;
  String accountId;
  String imageId;
  bool isVisible;
  List<String> addressesIds;
  int minRank;
  DateTime dateEnd;
  DateTime dateStart;
  String onlyCompanies;

  Product() {
    id = null;
    price = 0;
    currentPrice = 0;
    onlyCompanies = "";
    minRank = 0;
  }

  Product.fromJson(Map<String, dynamic> json)
    : id = json['id'],
    title = json['title'] ?? "", 
    link = json['link'] ?? "",
    description = json['description'] ?? "",
    price = json['price'],
    currentPrice = json['currentPrice'],
    type = json['type'] ?? "",
    upc = json['upc'] ?? "",
    accountId = json['accountId'],
    imageId = json['imageId'] ?? "",
    isVisible = json['isVisible'],
    addressesIds = json['addressesIds'] ?? [],
    minRank = json['minRank'],
    onlyCompanies = json['onlyCompanies'],
    dateEnd = json['dateEnd'] == null ? null : DateTime.parse(json['dateEnd']), 
    dateStart = json['dateStart'] == null ? null : DateTime.parse(json['dateStart']), 
    companyId = json['companyId'];


  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'title': title,
      'link': link,
      'description': description,
      'price': price,
      'currentPrice': currentPrice,
      'type': type,
      'upc': upc,
      'isVisible': isVisible,
      'imageId': imageId == "" ? '00000000-0000-0000-0000-000000000000' : imageId,
      'addressesIds': addressesIds ?? [],
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'minRank': minRank,
      'onlyCompanies': onlyCompanies,
      'dateEnd': dateEnd == null ? null : dateEnd.toIso8601String(),
      'dateStart': dateStart == null ? null : dateStart.toIso8601String(),
      'companyId': companyId
    };
  }

}