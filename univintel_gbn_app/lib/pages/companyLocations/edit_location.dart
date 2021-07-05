import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/working_hour.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/location.dart';
import 'package:univintel_gbn_app/pages/companyLocations/locations.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/city_selector.dart';
import 'package:univintel_gbn_app/controls/working_hours_selector.dart';
import 'package:univintel_gbn_app/models/city_with_country.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';

import '../../validators.dart';

class EditLocationPage extends StatefulWidget {
  final Location item;

  EditLocationPage({Key key, this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditLocationPageState();
}

class EditLocationPageState extends State<EditLocationPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> locationFormKey = GlobalKey<FormState>();
  String name = "";
  final TextEditingController cityController = new TextEditingController();
  final TextEditingController workingHoursController = new TextEditingController();
  List<String> dayTranslates = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
  String postalCode ="";
  String line1 = "";
  String line2 = "";
  String description = "";
  bool visible = true;
  bool saving = false;
  String category = "";
  final TextEditingController categoryController = new TextEditingController();
  String workingHours = "[]";
  String contactPhone = "";
  String contactEmail = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.item.name != null) name = widget.item.name;
      if (widget.item.city != null) cityController.text = widget.item.city;
      if (widget.item.postalCode != null) postalCode = widget.item.postalCode;
      if (widget.item.line1 != null) line1 = widget.item.line1;
      if (widget.item.line2 != null) line2 = widget.item.line2;
      if (widget.item.description != null) description = widget.item.description;
      if (widget.item.category != null) category = widget.item.category;
      if (widget.item.visible != null) visible = widget.item.visible;
      if (widget.item.workingHours != null) workingHours = widget.item.workingHours;
      if (widget.item.contactPhone != null) contactPhone = widget.item.contactPhone;
      if (widget.item.contactEmail != null) contactEmail = widget.item.contactEmail;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (workingHoursController.text.isEmpty && workingHours.isNotEmpty) {
      var workingHoursModel = List<WorkingHour>();
      if (workingHours != null) {
        var jsonHours = json.decode(workingHours);
        for (var workingHour in jsonHours) {
          workingHoursModel.add(WorkingHour.fromJson(workingHour));
        }
      }
      workingHoursController.text = displayWorkingHours(workingHoursModel);
    }
    if (category != null && category.isNotEmpty) categoryController.text = UnivIntelLocale.of(context, "locationcategory" + category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.id == null ? UnivIntelLocale.of(context, "addlocation") : UnivIntelLocale.of(context, "editlocation")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (saving) return;

              if (!locationFormKey.currentState.validate()) return;

              saving = true;

              await save();

              saving = false;

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => LocationsPage(companyId: widget.item.companyId)));
            },
          )
        ]
      ),
      body: Form(
        key: locationFormKey,
        child: ListView(
          children: <Widget>[
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: name,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "name")),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 3,
                initialValue: description,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "description")),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                }
              )
            ),
            Row(
              children: [
                Switch(
                  value: visible,
                  onChanged: (value) {
                    setState(() {
                      visible = value;
                    });
                  }
                ),
                Text(UnivIntelLocale.of(context, "displaylocation"))
              ],
            ),
            formPadding(
              TextFormField(
                onTap: () {
                  showOverlay(context);
                },
                maxLines: 1,
                readOnly: true,
                controller: cityController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "city")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: postalCode,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "postalcode")),
                onChanged: (value) {
                  setState(() {
                    postalCode = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: line1,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "addressline1")),
                onChanged: (value) {
                  setState(() {
                    line1 = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 2,
                initialValue: line2,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "addressline2")),
                onChanged: (value) {
                  setState(() {
                    line2 = value;
                  });
                } 
              )
            ),
            formPadding(
              TextFormField(
                onTap: () {
                  showSelector(context);
                },
                maxLines: 1,
                readOnly: true,
                controller: categoryController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "category")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 2,
                initialValue: contactPhone,
                keyboardType: TextInputType.phone,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "contactphone")),
                onChanged: (value) {
                  setState(() {
                    contactPhone = value;
                  });
                } 
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 2,
                initialValue: contactEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "contactemail")),
                onChanged: (value) {
                  setState(() {
                    contactEmail = value;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) return null;

                  return validateEmail(value);
                }
              )
            ),
            formPadding(
              RaisedButton(
                onPressed: () => showWorkingHours(context),
                child: Text(
                  UnivIntelLocale.of(context, "workinghours"),
                  style: TextStyle(fontSize: 15)
                ),
              )
            ),
            formPadding(
              widget.item.id == null ? null :
              RaisedButton(
                onPressed: () async {
                  var retry = await apiService.get("api/1/locations/delete?id=" + widget.item.id);
                  if (!retry) return;

                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => LocationsPage(companyId: widget.item.companyId)));
                },
                color: Colors.redAccent,
                child: Text(
                  UnivIntelLocale.of(context, "delete"),
                  style: TextStyle(fontSize: 15)
                ),
              )
            )
          ]
        )
      ),
    );
  }

  Future<bool> save() async {
    widget.item.name = name;
    widget.item.city = cityController.value.text;
    widget.item.postalCode = postalCode;
    widget.item.line1 = line1;
    widget.item.line2 = line2;
    widget.item.description = description;
    widget.item.category = category;
    widget.item.visible = visible;
    widget.item.workingHours = workingHours;
    widget.item.contactPhone = contactPhone;
    widget.item.contactEmail = contactEmail;

    var retry = await apiService.postJson(widget.item.id == null ? "api/1/locations/add" : "api/1/locations/update", widget.item.toJson());
    return retry == true;
  }

  void showOverlay(BuildContext context) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => CitySelector()));
    if (result == null) return;

    var model = result as CityWithCountry;
    cityController.text = model.city + ", " + model.country;
  }

  void showSelector(BuildContext context) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: UnivIntelLocale.of(context, "category"), items: getCategoriesSelector(context), selectedId: category)));
    if (result == null) return;

    var id = result as String;
    category = id;
    categoryController.text = UnivIntelLocale.of(context, "locationcategory" + category);
  }

  void showWorkingHours(BuildContext context) async {
    var model = List<WorkingHour>();
    if (workingHours != null) {
      var hours = json.decode(workingHours);
      for (var workingHour in hours) {
        model.add(WorkingHour.fromJson(workingHour));
      }
    }

    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => WorkingHoursPage(workingHours: model)));
    if (result == null) return;

    workingHoursController.text = displayWorkingHours(result);
    workingHours = jsonEncode(result);
  }

  String displayWorkingHours(List<WorkingHour> workingHours) {
    var displayValue = "";

    for (var workingHour in workingHours) {
      if (workingHour.days.length == 0) continue;

      if (workingHour.days.length > 1) {
        var startDay = UnivIntelLocale.of(context, dayTranslates[workingHour.days[0]]).substring(0, 3);
        var endDay = UnivIntelLocale.of(context, dayTranslates[workingHour.days.length - 1]).substring(0, 3);
        displayValue += " " + startDay + "-" + endDay;
        displayValue += "(" + workingHour.start.format(context) + "-" + workingHour.end.format(context) + ")";
      } else {
        displayValue += " " + UnivIntelLocale.of(context, dayTranslates[workingHour.days[0]]).substring(0, 3);
        displayValue += "(" + workingHour.start.format(context) + "-" + workingHour.end.format(context) + ")";
      }
    }

    return displayValue;
  }

  List<LocalSelectorItem> getCategoriesSelector(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "food", title: UnivIntelLocale.of(context, "locationcategoryfood")));
    result.add(LocalSelectorItem(id: "auto", title: UnivIntelLocale.of(context, "locationcategoryauto")));
    result.add(LocalSelectorItem(id: "beauty", title: UnivIntelLocale.of(context, "locationcategorybeauty")));
    result.add(LocalSelectorItem(id: "health",title: UnivIntelLocale.of(context, "locationcategoryhealth")));
    result.add(LocalSelectorItem(id: "goods", title: UnivIntelLocale.of(context, "locationcategorygoods")));
    result.add(LocalSelectorItem(id: "services", title: UnivIntelLocale.of(context, "locationcategoryservices")));
    result.add(LocalSelectorItem(id: "tourism", title: UnivIntelLocale.of(context, "locationcategorytourism")));
    result.add(LocalSelectorItem(id: "products", title: UnivIntelLocale.of(context, "locationcategoryproducts")));
    result.add(LocalSelectorItem(id: "sport", title: UnivIntelLocale.of(context, "locationcategorysport")));
    result.add(LocalSelectorItem(id: "education", title: UnivIntelLocale.of(context, "locationcategoryeducation")));
    result.add(LocalSelectorItem(id: "development", title: UnivIntelLocale.of(context, "locationcategorydevelopment")));

    return result;
  }
}
