import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/application_drawer.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/controls/google_map.dart';
import 'package:univintel_gbn_app/models/discount.dart';
import 'package:univintel_gbn_app/models/map_location.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/pages/dashboard/dashboard_categories.dart';
import 'package:univintel_gbn_app/pages/dashboard/location_card.dart';
import 'package:geolocator/geolocator.dart';

class DashboardPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {

  bool languageChanged = false;
  Position devicePosition;
  bool isLoading = true;
  String currentCategory;
  TextEditingController searchEditingController = TextEditingController();
  List<MapLocation> locations = new List<MapLocation>();
  List<MapLocation> allLocations = new List<MapLocation>();
  final GlobalKey<GoogleMapViewState> googleCardKey = new GlobalKey<GoogleMapViewState>(); 
  List<Discount> allDiscounts = [];

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future getData() async {
    final retry = await apiGetResult("api/1/account/information", context);

    UnivIntelLocale.changeApplicationLocale(context, Locale(retry['language']));

    devicePosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //var nearLocationsUrl = "api/1/locations/nearlocations?latitude=${devicePosition.latitude}&longitude=${devicePosition.longitude}";
    var nearLocationsUrl = "api/1/locations/nearlocations?latitude=55.751878&longitude=37.617587"; // hardcode moscow
    var responsesLocations = await apiGetResult(nearLocationsUrl, context);

    setState(() {
      allLocations.clear();
      for (var responsesLocation in responsesLocations) {
        allLocations.add(MapLocation.fromJson(responsesLocation));
      }
      locations.addAll(allLocations);

      languageChanged = true;
      isLoading = false;
    });
    
    await loadDiscounts(allLocations.map((item) => item.id).toList());
  }

  Future loadDiscounts(List<String> locationsIds) async{
    if(allLocations.length == 0) return;
    var discountFilters = {
      'locationsIds': locationsIds, 
    };
    final discountsResult = await apiPost(
      "api/1/discounts/byfilter",
      discountFilters,
      context
    );

    setState(() {
      allDiscounts = List<Discount>.from(discountsResult.map((map) => Discount.fromJson(map)));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      drawer: ApplicationDrawer(showCompanyMenu: false, companies: new List<Company>(), backCallback: backButtonHandler),
      body: Builder(
        builder: (context) => SafeArea(
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: devicePosition != null ?
                    Stack(
                      children: [
                        GoogleMapView(
                          key: googleCardKey,
                          /*latitude: devicePosition.latitude,
                          longitude: devicePosition.longitude,*/
                          //TODO: remove this code after not require moscow position
                          latitude: 55.751878,
                          longitude: 37.617587,
                          zoom: 14.4746,
                          markers: locations,
                          markerTapHandler: tapMarker
                        ),
                        InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 11.7, 0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                                color: Color.fromRGBO(255, 255, 255, .9),
                                boxShadow: [
                                  new BoxShadow(
                                    blurRadius: 1,
                                    color: systemGrayColorWithOpacity(.3),
                                    offset: new Offset(1, 1),
                                  ),
                                  new BoxShadow(
                                    blurRadius: 1,
                                    color: systemGrayColorWithOpacity(.3),
                                    offset: new Offset(-1, -1),
                                  )
                                ]
                              ),
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.menu,
                                size: 25.7,
                                color: Color.fromRGBO(101, 103, 100, 1)
                              )
                            )
                          )
                        )
                      ]
                    )
                    : Text("map")
                ),
                Expanded(
                  flex: 5,
                  child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        bottom: TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.category)),
                            Tab(icon: Icon(Icons.home)),
                            Tab(icon: Icon(Icons.image)),
                          ],
                        ),
                        titleSpacing: 0,
                        title: Row(children: [
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: TextFormField(
                                controller: searchEditingController,
                                decoration: InputDecoration(
                                hintText: UnivIntelLocale.of(context, "search"),
                                suffixIcon: searchEditingController.text.isNotEmpty ? IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      searchEditingController.clear();
                                      setState(() {
                                        currentCategory = "";
                                      });
                                      filterLocation(context);
                                    }
                                  ) : null
                                ),
                                onChanged: (value) {
                                  setState(() {
                                  });
                                },
                                onEditingComplete: () {
                                  filterLocation(context);
                                },
                              )
                            )
                          )
                        ])
                      ),
                      body: TabBarView(
                        children: [
                          fillCategoriesOrLocations(context),
                          ListView.builder(
                            itemCount: allDiscounts.length,
                            itemBuilder: (context, int index) {
                              return getItemTemplate(allDiscounts[index]);
                            },
                          ),
                          Text("fdfd")
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          )
        )
      )
    );
  }

  Widget fillCategoriesOrLocations(context) {
    if (currentCategory != null && currentCategory.isNotEmpty) {
      return ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, int index) {
          var element = locations[index];
          return InkWell(
            onTap: () {
              googleCardKey.currentState.goToMarker(element.id);
              Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => LocationCardPage(locationId: element.id, companyId: element.companyId)));
            },
            child:  Container(
              margin: EdgeInsets.all(2),
              decoration: listSeparatingBorder(context),
              width: MediaQuery.of(context).size.width - 4,
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(element.company, style: TextStyle(fontSize: 20))
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      element.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: systemGrayColor()
                      )
                    )
                  )
                ]
              )
            )
          );
        },
      );
    }

    return ListView(
      children: [
        Table(
          children: getCategories(context)
        )
      ],
    );
  }

  Widget getItemTemplate(Discount item) {
    return InkWell(
      onTap: () {
      },
      child: Container(
        decoration: listSeparatingBorder(context),
        padding: EdgeInsets.fromLTRB(8, 0, 0, 2),
        margin: EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width - 14,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    item.imageId != "" ? AvatarBox(item.imageId , 30, squared: true,) : Icon(Icons.local_offer, size: 40)
                  ]
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Container(
                    height: 65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: TextStyle(fontSize: 20)),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Text(item.description, maxLines: 3, style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis,))),
                      ]
                    ),
                  ),
                ),
              ]
            )
          ]
        )
      ),
    );
  }

  void filterLocation(context) {
    var displayLocations = new List<MapLocation>();
    var isCategoryFiltering = currentCategory != null && currentCategory.isNotEmpty;
    var categories = getCategoryModels(context);
    var category = isCategoryFiltering ? categories.firstWhere((element) => element.id == currentCategory) : null;
    var searchFilter = isCategoryFiltering && searchEditingController.text.isNotEmpty ? searchEditingController.text.replaceAll(category.name, "").trim().toLowerCase() : "";
    for (var location in allLocations) {
      if (isCategoryFiltering && location.category != currentCategory) continue;

      if (searchFilter.isNotEmpty && !(location.company.toLowerCase().contains(searchFilter) || location.name.toLowerCase().contains(searchFilter))) continue;

      displayLocations.add(location);
    }

    setState(() {
      locations.clear();
      locations.addAll(displayLocations);
      googleCardKey.currentState.refreshMarkers(locations);
    });
  }

  void tapMarker(String id){
    var mapLocation = allLocations.firstWhere((a) => a.id == id);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => LocationCardPage(locationId: id, companyId: mapLocation.companyId)));
  }

  Widget drawCategory(String name, IconData icon, String id) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          setState(() {
            currentCategory = id;
            searchEditingController.text = name + " ";
          });
          filterLocation(context);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(icon),
            ),
            Text(name)
          ],
        )
      )
    );
  }

  List<TableRow> getCategories(BuildContext context) {
    List<TableRow> result = List<TableRow>();

    var categories = getCategoryModels(context);

    var iterator = 0;
    var currentRow = TableRow(children: List<Widget>());
    for (var category in categories) {
      iterator++;

      currentRow.children.add(drawCategory(category.name, category.icon, category.id));

      if (iterator == 3) {
        iterator = 0;
        result.add(currentRow);
        currentRow = TableRow(children: List<Widget>());
      }
    }

    return result;
  }

  void backButtonHandler() {
    setState(() { });
  }

}
