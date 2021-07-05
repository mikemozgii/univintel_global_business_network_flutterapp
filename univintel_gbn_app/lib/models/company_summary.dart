class CompanySummary  {
  String id;
  String managementTeam;
  String customerProblem;
  String productsAndServices;
  String targetMarket;
  String businessModel;
  String customerSegments;
  String salesMarketingStrategy;
  String competitors;
  String competitiveAdvantage;

  CompanySummary() {
    id = null;
  }

  CompanySummary.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      managementTeam = json['managementTeam'],
      customerProblem = json['customerProblem'],
      productsAndServices = json['productsAndServices'],
      targetMarket = json['targetMarket'],
      businessModel = json['businessModel'],
      customerSegments = json['customerSegments'],
      salesMarketingStrategy = json['salesMarketingStrategy'],
      competitors = json['competitors'],
      competitiveAdvantage = json['competitiveAdvantage'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'managementTeam': managementTeam,
      'customerProblem': customerProblem,
      'productsAndServices': productsAndServices,
      'targetMarket': targetMarket,
      'businessModel': businessModel,
      'customerSegments': customerSegments,
      'salesMarketingStrategy': salesMarketingStrategy,
      'competitors': competitors,
      'competitiveAdvantage': competitiveAdvantage
    };
  }

}