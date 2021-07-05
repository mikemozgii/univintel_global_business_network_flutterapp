class Company  {
  String id;
  String name;
  String description;
  String accountId;
  DateTime founded;
  String tagline;
  String phone;
  String website;
  String linkedin;
  String twitter;
  String facebook;
  String companySize;
  String industry;
  String logoId;
  String abbreviation;
  String email;
  bool displayCompany;
  int companyRank;
  bool displayInvestmentPortfolio;

  Company() {
    id = null;
    name = "";
    description = "";
    accountId = null;
    abbreviation = "";
    displayCompany = true;
    companyRank = 1;
    email = "";
  }

  Company.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      description = json['description'],
      accountId = json['accountId'],
      founded = json['founded'] != null ? DateTime.parse(json['founded']) : null,
      tagline = json['tagline'],
      phone = json['phone'],
      website = json['website'],
      linkedin = json['linkedin'],
      twitter = json['twitter'],
      facebook = json['facebook'],
      companySize = json['companySize'] != null ? json['companySize'].toString() : null,
      industry = json['industry'] != null ? json['industry'].toString() : null,
      logoId = json['logoId'],
      abbreviation = json['abbreviation'],
      email = json['email'],
      displayCompany = json['displayCompany'],
      displayInvestmentPortfolio = json['displayInvestmentPortfolio'],
      companyRank = json['companyRank'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'description': description,
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'founded': founded != null ? founded.toIso8601String() : null,
      'tagline': tagline,
      'phone': phone,
      'website': website,
      'linkedin': linkedin,
      'twitter': twitter,
      'facebook': facebook,
      'companySize': companySize != null ? int.parse(companySize) : null,
      'industry': industry != null ? int.parse(industry) : null,
      'abbreviation': abbreviation,
      'logoId': logoId,
      'email': email,
      'displayCompany': displayCompany,
      'companyRank': companyRank,
      'displayInvestmentPortfolio': displayInvestmentPortfolio
    };
  }

}