class CityWithCountry  {
  String city;
  String country;

  CityWithCountry() {
    city = "";
    country = "";
  }

  CityWithCountry.fromJson(Map<String, dynamic> json)
    : city = json['city'],
      country = json['country'];

  toJson() {
    return {
      'city': city,
      'country': country
    };
  }

}