import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/city_with_country.dart';

class CitySelector extends StatefulWidget {
  CitySelector({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => CitySelectorState();

}

class CitySelectorState extends State<CitySelector> {
  final ApiService apiService = new ApiService();

  final List<CityWithCountry> items = new List<CityWithCountry>();

  bool isBusy = false;

  String filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "selectcity")),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(4, 4, 4, 0) ,
        child: Column(
          children: [
            TextFormField(
              maxLines: 1,
              initialValue: filter,
              enabled: isBusy == false,
              keyboardType: TextInputType.text,
              decoration: textHintDecoration(UnivIntelLocale.of(context, "city")),
              onChanged: (value) {
                setState(() {
                  filter = value;
                });
              },
              onEditingComplete: () async {
                await getItemsByFilter();
              }
            ),
            Container(
              height: MediaQuery.of(context).size.height - 150,
              child: SingleChildScrollView(
                child: Column(
                  children: items.map((CityWithCountry record) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(record);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(record.city + ", " + record.country, style: TextStyle(fontSize: 18))
                        )
                      )
                    );
                  }).toList()
                )
              )
            )
          ],
        )
      )
    );
  }

  Future<bool> getItemsByFilter() async {
    if (filter.isEmpty) {
      setState(
        () {
          items.clear();
        }
      );
      return new Future.value(true);
    }

    setState(() => {
      isBusy = true
    });

    var response = await apiService.get("api/1/locations/cities?filter=" + filter);

    setState(() {
      isBusy = false;
      items.clear();
      for (var item in response) items.add(CityWithCountry.fromJson(item));
    });

    return true;
  }

}