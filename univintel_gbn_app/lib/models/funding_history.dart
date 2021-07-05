class CompanyFundingHistory  {
  String id;
  String round;
  int capitalRaised;
  DateTime closingDate;
  String investorName;
  String investorEmail;
  String companyId;
  String accountId;

  CompanyFundingHistory() {
    id = null;
    companyId = null;
    accountId = null;
  }

  CompanyFundingHistory.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      round = json['round'],
      capitalRaised = json['capitalRaised'],
      closingDate = DateTime.parse(json['closingDate']),
      investorName = json['investorName'],
      investorEmail = json['investorEmail'],
      companyId = json['companyId'],
      accountId = json['accountId'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'round': round,
      'capitalRaised': capitalRaised,
      'closingDate': closingDate.toIso8601String(),
      'investorName': investorName,
      'investorEmail': investorEmail,
      'companyId': companyId
    };
  }

}