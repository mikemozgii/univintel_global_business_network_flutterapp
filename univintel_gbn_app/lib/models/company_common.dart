class CompanyCommon  {
  String id;
  String oneLinePitch;
  String incorporationType;
  String companyStage;
  String pitchVideoLink;

  CompanyCommon() {
    id = null;
  }

  CompanyCommon.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      oneLinePitch = json['oneLinePitch'],
      incorporationType = json['incorporationType'],
      companyStage = json['companyStage'],
      pitchVideoLink = json['pitchVideoLink'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'oneLinePitch': oneLinePitch,
      'incorporationType': incorporationType,
      'companyStage': companyStage,
      'pitchVideoLink': pitchVideoLink
    };
  }

}