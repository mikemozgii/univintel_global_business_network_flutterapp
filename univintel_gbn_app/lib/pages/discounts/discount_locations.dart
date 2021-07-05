import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/location.dart';
import 'package:univintel_gbn_app/services/api.dart';

class MultiSelectLocations extends StatefulWidget {
  final String companyId;
  final List<String> selectedLocationsIds;
  MultiSelectLocations(this.companyId, this.selectedLocationsIds);
  @override
  _MultiSelectLocationsState createState() => _MultiSelectLocationsState();
}

class _MultiSelectLocationsState extends State<MultiSelectLocations> {
  bool isSelected = false;
  final ApiService apiService = new ApiService();
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<Location>>();
  List<Location> selectedLocations = [];
  AutoCompleteTextField<Location> textField;

  @override
  void initState() {
    super.initState();
    getLocations().then((value) => initSearchBox(value));
  }

  Future<List<Location>> getLocations() async {
    var retry = await apiService.get("api/1/locations/all?companyid=" + widget.companyId);
    var result = new List<Location>();
    for (var item in retry) {
      result.add(Location.fromJson(item));
    }
    return result;
  }

  void initSearchBox(List<Location> locations) {
    
    final filterBox = new AutoCompleteTextField<Location>(
      decoration: new InputDecoration(
        hintText: UnivIntelLocale.of(context, "locations")),
      itemSubmitted: (item) => addLocation(item),
      key: key,
      suggestions: locations,
      itemBuilder: (context, suggestion) => Container(
        color: Theme.of(context).appBarTheme.color,
        child: ListTile(
            title: Text(suggestion.name)
          )
      ),
      minLength: 0,
      suggestionsAmount: 5,
      itemSorter: (a, b) => a.name == b.name ? 0 : a.name.compareTo(b.name ) > 0 ? -1 : 1,
      itemFilter: (suggestion, input) => suggestion.name.toLowerCase().indexOf(input.toLowerCase()) >= 0
    );

    setState(() { 
        textField = filterBox;
        selectedLocations = locations.where((item) => widget.selectedLocationsIds.contains(item.id)).toList();
      });
  }

  void removeLocationById(Location item) {
    setState(() { selectedLocations.remove(item); });
  }

  void addLocation(Location item) {
    if (selectedLocations.contains(item)) return;
     setState(() { selectedLocations.add(item); });
  }

   Widget selctedLocationWidget() {
    return Column(children:
      selectedLocations.map((item) => 
        ListTile(
          title: Text(item.name),
          trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => removeLocationById(item))
      )).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Company Locations"),
        actions: <Widget>[
           IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                Navigator.pop(context, selectedLocations);
              })
        ]),
      body: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: ListView(
          children: [
            textField != null ? textField : Text("Locations loading..."),
            selctedLocationWidget()
          ]
        )
      )
    );
  }
}