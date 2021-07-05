import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/contact.dart';
import 'package:univintel_gbn_app/models/job.dart';
import 'package:univintel_gbn_app/models/location.dart';
import 'package:univintel_gbn_app/pages/discounts/discount_locations.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';
import 'package:univintel_gbn_app/pages/jobs/root.dart';

class EditJobPage extends StatefulWidget {
  final Job item;

  EditJobPage({Key key, this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditJobPageState();
}

class EditJobPageState extends State<EditJobPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> locationFormKey = GlobalKey<FormState>();

  List<LocalSelectorItem> workingExpirienceItems = List<LocalSelectorItem>();
  List<LocalSelectorItem> contactItems = List<LocalSelectorItem>();
  List<String> locationItems = List<String>();
  final TextEditingController typePositionController = new TextEditingController();
  final TextEditingController workedExpirienceController = new TextEditingController();
  final TextEditingController contactController = new TextEditingController();
  String name;
  String description;
  String locations = "[]";
  String contactId;
  int salaryMin = 0;
  int salaryMax = 0;
  String typePosition;
  String skills;
  String workedExperience;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {

    var retry = await apiService.get("api/1/contacts/all?companyid=" + widget.item.companyId);

    setState(() {
      workingExpirienceItems = getWorkedExpirience();
      contactItems = List<LocalSelectorItem>.from(
        retry.map(
          (map) {
            var contact = Contact.fromJson(map);
            return LocalSelectorItem(id: contact.id, title: contact.fullName);
          }
        )
      );
      if (widget.item.name != null) name = widget.item.name;
      if (widget.item.description != null) description = widget.item.description;
      if (widget.item.locations != null) locations = widget.item.locations;
      locationItems = List<String>.from(jsonDecode(locations));
      if (widget.item.contactId != null) contactId = widget.item.contactId;
      if (widget.item.salaryMin != null) salaryMin = widget.item.salaryMin;
      if (widget.item.salaryMax != null) salaryMax = widget.item.salaryMax;
      if (widget.item.typePosition != null) typePosition = widget.item.typePosition;
      if (widget.item.skills != null) skills = widget.item.skills;
      if (widget.item.workedExperience != null) workedExperience = widget.item.workedExperience;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    if (typePosition != null && typePosition.isNotEmpty) {
      var typePositions = getTypePositions(context);
      var selectedTypePosition = typePositions.firstWhere((element) => element.id == typePosition);
      typePositionController.text = selectedTypePosition.title;
    }
    if (workedExperience != null && workedExperience.isNotEmpty) {
      var selectedWorkingExpirience = workingExpirienceItems.firstWhere((element) => element.id == workedExperience);
      workedExpirienceController.text = selectedWorkingExpirience.title;
    }
    if (contactId != null) contactController.text = contactItems.firstWhere((element) => element.id == contactId).title;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.id == null ? UnivIntelLocale.of(context, "addjob") : UnivIntelLocale.of(context, "editjob")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (!locationFormKey.currentState.validate()) return;
 
              await save();
 
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => JobsPage(companyId: widget.item.companyId)));
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
              Text("Annual Salary range", style: TextStyle(fontSize: 18, color: systemLinkColor())),
            ),
            formPaddingWithoutTop(
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLines: 1,
                      initialValue: salaryMin.toString(),
                      keyboardType: TextInputType.number,
                      decoration: textHintDecoration(UnivIntelLocale.of(context, "fromheader")),
                      onChanged: (value) {
                        setState(() {
                          salaryMin = int.parse(value);
                        });
                      },
                      validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                    ),
                    flex: 5,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: TextFormField(
                        maxLines: 1,
                        initialValue: salaryMax.toString(),
                        keyboardType: TextInputType.number,
                        decoration: textHintDecoration(UnivIntelLocale.of(context, "to")),
                        onChanged: (value) {
                          setState(() {
                            salaryMax = int.parse(value);
                          });
                        },
                        validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                      )
                    ),
                    flex: 5,
                  )
                ],
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
            formPadding(
              TextFormField(
                onTap: () async {
                  var typePositions = getTypePositions(context);
                  var result = await showSelector(context, typePositions, typePosition, UnivIntelLocale.of(context, "typeofposition"));
                  if (result == null) return;

                  typePosition = result as String;
                  typePositionController.text = typePositions.firstWhere((a) => a.id == typePosition).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: typePositionController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "typeofposition")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: skills,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "skills")),
                onChanged: (value) {
                  setState(() {
                    skills = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                onTap: () async {
                  var result = await showSelector(context, workingExpirienceItems, workedExperience, UnivIntelLocale.of(context, "workedexpirience"));
                  if (result == null) return;

                  workedExperience = result as String;
                  workedExpirienceController.text = workingExpirienceItems.firstWhere((a) => a.id == workedExperience).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: workedExpirienceController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "workedexpirience")),
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${UnivIntelLocale.of(context, "locations")}: ${locationItems.length}"),
                  IconButton(
                    icon: Icon(Icons.add_location),
                    onPressed: () => showLocationsDialog()
                  ),
                ]
              ) 
            ),
            formPaddingWithoutTop(
              TextFormField(
                onTap: () async {
                  var result = await showSelector(context, contactItems, contactId, UnivIntelLocale.of(context, "recruitingcontact"));
                  if (result == null) return;

                  contactId = result as String;
                  contactController.text = contactItems.firstWhere((a) => a.id == contactId).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: contactController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "recruitingcontact")),
              )
            ),
            formPadding(
              widget.item.id == null ? null :
              RaisedButton(
                onPressed: () async {
                  var retry = await apiService.get("api/1/jobs/delete?id=" + widget.item.id + "&companyId=" + widget.item.companyId);
                  if (!retry) return;

                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => JobsPage(companyId: widget.item.companyId)));
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
    widget.item.locations = locations;
    widget.item.contactId = contactId;
    widget.item.salaryMin = salaryMin;
    widget.item.salaryMax = salaryMax;
    widget.item.description = description;
    widget.item.typePosition = typePosition;
    widget.item.skills = skills;
    widget.item.workedExperience = workedExperience;
    widget.item.locations = jsonEncode(locationItems);

    var retry = await apiService.postJson(widget.item.id == null ? "api/1/jobs/add" : "api/1/jobs/update", widget.item.toJson());
    return retry == true;
  }

  void showLocationsDialog() async {
    final result = await showDialog<List<Location>>(
      context: context,
      builder: (BuildContext context) {
        return  MultiSelectLocations(widget.item.companyId, locationItems);
      });

    if(result != null) {
      setState(() { locationItems = result.map((location) => location.id.toString()).toList(); });
    }
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected, String title) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: title, items: items, selectedId: selected)));
    return result;
  }

  List<LocalSelectorItem> getTypePositions(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "fulltime", title: UnivIntelLocale.of(context, "fulltime")));
    result.add(LocalSelectorItem(id: "parttime", title: UnivIntelLocale.of(context, "parttime")));

    return result;
  }

  List<LocalSelectorItem> getWorkedExpirience() {
    var result = new List<LocalSelectorItem>();

    for (var i = 0; i < 10; i++) {
      result.add(LocalSelectorItem(id: i.toString(), title: i.toString()));
    }
    result.add(LocalSelectorItem(id: "10+", title: "10+"));

    return result;
  }

}
