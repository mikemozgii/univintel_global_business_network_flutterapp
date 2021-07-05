class CompanyCulture  {
  String id;
  String culture;
  String cultureVideoLink;

  CompanyCulture() {
    id = null;
  }

  CompanyCulture.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      culture = json['culture'],
      cultureVideoLink = json['cultureVideoLink'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'culture': culture,
      'cultureVideoLink': cultureVideoLink
    };
  }

}