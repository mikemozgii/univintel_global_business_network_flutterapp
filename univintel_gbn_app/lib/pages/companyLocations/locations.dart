import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/promote.dart';
import 'package:univintel_gbn_app/pages/promotes/edit_promote.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/location.dart';
import 'package:univintel_gbn_app/pages/companyLocations/edit_location.dart';
import 'package:univintel_gbn_app/localization.dart';

class LocationsPage extends StatefulWidget {
  final String companyId;

  LocationsPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => LocationsPageState();

}

class LocationsPageState extends State<LocationsPage> {
  final ApiService apiService = new ApiService();
  List<Location> items = new List<Location>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getItems().then((value) => updateItems(value));
  }

  void updateItems(List<Location> loadedItems) {
    setState(() {
      items = loadedItems;
      isLoading = false;
    });
  }

  Future<List<Location>> getItems() async {
    var retry = await apiService.get("api/1/locations/all?companyid=" + widget.companyId);
    var result = new List<Location>();
    for (var item in retry) {
      result.add(Location.fromJson(item));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "locations")),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addContact()
          )
        ]
      ),
      body: fillContacts(context)
    );
  }

  void addContact() {
    final emptyContact = new Location();
    emptyContact.companyId = widget.companyId;

    final companyPage = EditLocationPage(item: emptyContact);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }

  Widget getItemTemplate(Location item) {
    return InkWell(
      onTap: () {
        final itemPage = EditLocationPage(item: item); 
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => itemPage));
      },
      child: Container(
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
              child: Text(item.name, style: TextStyle(fontSize: 20))
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                item.city + ", " + item.line1,
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
      ),
    );
  }

  void removeItem(int index) {
    final item =  items.elementAt(index);
    setState(() { items.removeAt(index); });
    showSnackBarToDelete(
      scaffoldKey,
      UnivIntelLocale.of(context, "canceldelete"),
      5000,
      onDelete: () async => await apiGet("api/1/locations/delete?id=" + item.id, context, scaffoldState: scaffoldKey.currentState),
      onCancel: () {
        setState(() {
          defaultInsertItem(item, items, position: index);
        });
      }
    );
  }

  SlideActionBuilderDelegate getMainActionBuilder() {
    return SlideActionBuilderDelegate(
      actionCount: 1,
      builder: (context, index, animation, renderingMode) {
        return IconSlideAction(
          color: renderingMode == SlidableRenderingMode.slide
              ? Colors.green.withOpacity(animation.value)
              : Colors.green,
          icon: Icons.trending_up,
          caption: UnivIntelLocale.of(context, "promote"),
          onTap: (){
            var promote = Promote();
            promote.companyId = widget.companyId;
            promote.itemTypeId = "location";
            //promote.availableId = "for_all";
            final promotePage = EditPromotePage(item: promote, entityId: items[index].id );
            Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => promotePage));
          },
        );
    });
  }

  Widget fillContacts(BuildContext context) {
    if (items.length == 0) {
      return Center(
        child: InkWell(
          onTap: () => addContact(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16))
        )
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, int index) {
        final item = items[index];
        final onDeleteFunc = () => removeItem(index);
        return getSlidableBuilder(
          context,
          getItemTemplate(item),
          Key(item.id),
          getMainActionBuilder(),
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      }
    );
  }

}
