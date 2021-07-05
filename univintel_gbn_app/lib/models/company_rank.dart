class CompanyRank  {
  int id;
  String name;
  String description;
  double price;

  CompanyRank() {
    id = null;
    name = "";
    description = "";
    price = 0;
  }

  CompanyRank.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      description = json['description'],
      price = json['price'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'description': description,
      'price': price
    };
  }

}