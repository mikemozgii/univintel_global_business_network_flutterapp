class Location  {
  String id;
  String name;
  String city;
  String postalCode;
  String line1;
  String line2;
  String cityId;
  String accountId;
  String companyId;
  String description;
  String category;
  bool visible;
  String workingHours;
  String contactPhone;
  String contactEmail;

  Location() {
    id = null;
    accountId = null;
  }

  Location.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      city = json['city'],
      accountId = json['accountId'],
      postalCode = json['postalCode'],
      line1 = json['line1'],
      line2 = json['line2'],
      cityId = json['cityId'],
      description = json['description'],
      category = json['category'],
      visible = json['visible'],
      workingHours = json['workingHours'],
      contactPhone = json['contactPhone'],
      contactEmail = json['contactEmail'],
      companyId = json['companyId'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'city': city,
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'postalCode': postalCode,
      'line1': line1,
      'line2': line2,
      'cityId': cityId == null ? '00000000-0000-0000-0000-000000000000' : cityId,
      'companyId': companyId,
      'description': description,
      'category': category,
      'visible': visible,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'workingHours': workingHours
    };
  }

}