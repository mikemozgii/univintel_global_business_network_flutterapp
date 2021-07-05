class CompanyFinancialYear  {
  String id;
  int year;
  int revenue;
  int expenditure;
  String revenueDriver;
  String companyId;

  CompanyFinancialYear() {
    id = null;
    companyId = null;
  }

  CompanyFinancialYear.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      year = json['year'],
      revenue = json['revenue'],
      expenditure = json['expenditure'],
      companyId = json['companyId'],
      revenueDriver = json['revenueDriver'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'companyId': companyId == null ? '00000000-0000-0000-0000-000000000000' : companyId,
      'year': year,
      'revenue': revenue,
      'expenditure': expenditure,
      'revenueDriver': revenueDriver,
      'companyId': companyId
    };
  }

}