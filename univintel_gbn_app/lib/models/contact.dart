class Contact  {
  String id;
  String name;
  String city;
  String postalCode;
  String line1;
  String line2;
  String cityId;
  String accountId;
  String fullName;
  String title;
  String phone;
  String email;
  int role;
  String companyId;
  bool visible;
  bool visibleEmail;
  String imageId;
  bool visiblePhone;

  Contact() {
    id = null;
    name = "";
    role = 0;
    accountId = null;
  }

  Contact.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      city = json['city'],
      accountId = json['accountId'],
      postalCode = json['postalCode'],
      line1 = json['line1'],
      line2 = json['line2'],
      cityId = json['cityId'],
      fullName = json['fullName'],
      title = json['title'],
      phone = json['phone'],
      email = json['email'],
      role = json['role'],
      visible = json['visible'],
      visibleEmail = json['visibleEmail'],
      companyId = json['companyId'],
      visiblePhone = json['visiblePhone'],
      imageId = json['imageId'];

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
      'fullName': fullName,
      'title': title,
      'phone': phone,
      'email': email,
      'role': role,
      'companyId': companyId,
      'visible': visible,
      'visibleEmail': visibleEmail,
      'visiblePhone': visiblePhone,
      'imageId': imageId
    };
  }

}