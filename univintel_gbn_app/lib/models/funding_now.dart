class CompanyFundingNow  {
  String id;
  String round;
  int seeking;
  String securityType;

  CompanyFundingNow() {
    id = null;
  }

  CompanyFundingNow.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      round = json['round'],
      seeking = json['seeking'],
      securityType = json['securityType'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'round': round,
      'seeking': seeking,
      'securityType': securityType
    };
  }

}