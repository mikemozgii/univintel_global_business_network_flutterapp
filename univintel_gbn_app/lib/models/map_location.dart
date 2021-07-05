class MapLocation  {
  String id;
  String name;
  String company;
  int level;
  double latitude;
  double longitude;
  String companyId;
  String category;
  String discountType;
  String productType;

  MapLocation() {
    id = null;
    level = 0;
    latitude = 0;
    longitude = 0;
  }

  MapLocation.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      company = json['company'],
      level = json['level'],
      latitude = json['latitude'],
      companyId = json['companyId'],
      category = json['category'],
      discountType = json['discountType'],
      productType = json['productType'],
      longitude = json['longitude'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'company': 'company',
      'level': level == null ? 0 : level,
      'latitude': latitude,
      'longitude': longitude,
      'companyId': companyId,
      'discountType': discountType,
      'productType': productType,
      'category': category
    };
  }

}