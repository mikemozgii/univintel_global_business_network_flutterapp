
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/promote.dart';
import 'package:univintel_gbn_app/pages/promotes/edit_promote.dart';

class PromotesPage extends StatefulWidget {
  final String companyId;

  PromotesPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => PromotesPageState();

}

class PromotesPageState extends State<PromotesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final String apiRoute = "api/1/promotes/";
  List<Promote> items = new List<Promote>();
  bool isLoading = true;
  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var filterModel = {
      'CompanyId': widget.companyId
    };
    final result = await apiPost(
      "${apiRoute}byfilter",
      filterModel,
      context
    );

    setState(() {
      items = List<Promote>.from(result.map((map) => Promote.fromJson(map)));
      isLoading = false;
    });
  }

  void removeItem(int index) {
    final item =  items.elementAt(index);
    setState(() { items.removeAt(index); });
    showSnackBarToDelete(
      scaffoldKey, 
      UnivIntelLocale.of(context, "canceldelete"),
      5000,
      onDelete: () async => await apiGet("${apiRoute}delete?id=${item.id}", context, scaffoldState: scaffoldKey.currentState),
      onCancel: () => insertItem(item, position: index)
    );
  }

  void insertItem(Promote item, {int position = -1}){
    setState(() { 
      if(position == -1 || items.length <= position) items.add(item);
      else items.insert(position, item); 
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "promotes")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => goNewItemPage(),
          )
        ]
      ),
      body: fillItems(context)
    );
  }

  void goNewItemPage() {
    // final page = ProductTypePage(companyId: widget.companyId);
    // Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => page));
  }

  Widget fillItems(BuildContext context) {
    if (items.isEmpty){
      return Center(
        child: InkWell(
          onTap: () => goNewItemPage(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16),)
        )
      );
    }

    return getListItems();
  }

  Widget getListItems() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, int index) {
        final item = items[index];
        final onDeleteFunc = () => removeItem(index);
        return getSlidableBuilder(
          context,
          getItemTemplate(item),
          Key(item.id),
          null,
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      },
    );
  }

  Widget getItemTemplate(Promote item) {
    return InkWell(
      onTap: () {
        final itemPage = EditPromotePage(item: item);
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => itemPage));
      },
      child: Container(
        decoration: listSeparatingBorder(context),
        padding: EdgeInsets.fromLTRB(8, 0, 0, 2),
        margin: EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width - 14,
        height: 70,
        child: 
          Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer, size: 40)
              ]
            ),
            Container(
              padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width*0.7,
              child: Container(
                height: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.title, style: TextStyle(fontSize: 20)),
                    Text("${dateFormat.format(item.dateStart)} - ${dateFormat.format(item.dateEnd)} ", style: TextStyle(fontSize: 10), maxLines: 2,),
                  ]
                ),
              ),
            ),
            /*Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("${UnivIntelLocale.of(context, item.typeId)}", style: TextStyle(fontSize: 10)),
              ],
            )*/
          ],
        )
      ),
    );
  }
}
