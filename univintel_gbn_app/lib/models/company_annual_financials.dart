class CompanyAnnualFinancials  {
  String id;
  int annualRevenueRunRate;
  int monthlyBurnRate;
  String financialAnnotation;
  String revenueDriver;

  CompanyAnnualFinancials() {
    id = null;
    annualRevenueRunRate = 0;
    monthlyBurnRate = 0;
  }

  CompanyAnnualFinancials.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      annualRevenueRunRate = json['annualRevenueRunRate'],
      monthlyBurnRate = json['monthlyBurnRate'],
      financialAnnotation = json['financialAnnotation'],
      revenueDriver = json['revenueDriver'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'annualRevenueRunRate': annualRevenueRunRate,
      'monthlyBurnRate': monthlyBurnRate,
      'financialAnnotation': financialAnnotation,
      'revenueDriver': revenueDriver
    };
  }

}