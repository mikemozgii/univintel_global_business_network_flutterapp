import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/models/dashboard_category.dart';
import 'package:univintel_gbn_app/localization.dart';

List<DashboardCategory> getCategoryModels(BuildContext context) {
  var result = new List<DashboardCategory>();

  result.add(DashboardCategory(id: "food", name: UnivIntelLocale.of(context, "locationcategoryfood") , icon: Icons.restaurant));
  result.add(DashboardCategory(id: "auto", name: UnivIntelLocale.of(context, "locationcategoryauto"), icon: Icons.directions_car));
  result.add(DashboardCategory(id: "beauty", name: UnivIntelLocale.of(context, "locationcategorybeauty"), icon: Icons.face));
  result.add(DashboardCategory(id: "health", name: UnivIntelLocale.of(context, "locationcategoryhealth"), icon: Icons.favorite));
  result.add(DashboardCategory(id: "goods", name: UnivIntelLocale.of(context, "locationcategorygoods"), icon: Icons.store));
  result.add(DashboardCategory(id: "services", name: UnivIntelLocale.of(context, "locationcategoryservices"), icon: Icons.build));
  result.add(DashboardCategory(id: "tourism", name: UnivIntelLocale.of(context, "locationcategorytourism"), icon: Icons.flight_takeoff));
  result.add(DashboardCategory(id: "products", name: UnivIntelLocale.of(context, "locationcategoryproducts"), icon: Icons.shopping_basket));
  result.add(DashboardCategory(id: "sport", name: UnivIntelLocale.of(context, "locationcategorysport"), icon: Icons.fitness_center));
  result.add(DashboardCategory(id: "education", name: UnivIntelLocale.of(context, "locationcategoryeducation"), icon: Icons.school));
  result.add(DashboardCategory(id: "development", name: UnivIntelLocale.of(context, "locationcategorydevelopment"), icon: Icons.format_paint));
  result.add(DashboardCategory(id: "enterteinment", name: UnivIntelLocale.of(context, "locationcategoryenterteinment"), icon: Icons.casino));

  return result;
}

//sorry about it, need remake based on single method
List<DashboardCategory> getCategoryModelsWithoutTranslations() {
  var result = new List<DashboardCategory>();

  result.add(DashboardCategory(id: "food", name: "" , icon: Icons.restaurant));
  result.add(DashboardCategory(id: "auto", name: "", icon: Icons.directions_car));
  result.add(DashboardCategory(id: "beauty", name: "", icon: Icons.face));
  result.add(DashboardCategory(id: "health", name: "", icon: Icons.favorite));
  result.add(DashboardCategory(id: "goods", name: "", icon: Icons.store));
  result.add(DashboardCategory(id: "services", name: "", icon: Icons.build));
  result.add(DashboardCategory(id: "tourism", name: "", icon: Icons.flight_takeoff));
  result.add(DashboardCategory(id: "products", name: "", icon: Icons.shopping_basket));
  result.add(DashboardCategory(id: "sport", name: "", icon: Icons.fitness_center));
  result.add(DashboardCategory(id: "education", name: "", icon: Icons.school));
  result.add(DashboardCategory(id: "development", name: "", icon: Icons.format_paint));
  result.add(DashboardCategory(id: "enterteinment", name: "", icon: Icons.casino));

  return result;
}