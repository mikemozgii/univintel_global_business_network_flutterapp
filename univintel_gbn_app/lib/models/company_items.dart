import 'package:univintel_gbn_app/models/discount.dart';
import 'package:univintel_gbn_app/models/product.dart';

class CompanyItems {
  List<Product> products;
  List<Product> services;
  List<Discount> discounts;
  List<Discount> coupons;

  CompanyItems();

  CompanyItems.fromJson(Map<String, dynamic> json):
    products = List<Product>.from(json['products'].map((map) => Product.fromJson(map))),
    services = List<Product>.from(json['services'].map((map) => Product.fromJson(map))),
    discounts = List<Discount>.from(json['discounts'].map((map) => Discount.fromJson(map))),
    coupons = List<Discount>.from(json['coupons'].map((map) => Discount.fromJson(map)));
}
