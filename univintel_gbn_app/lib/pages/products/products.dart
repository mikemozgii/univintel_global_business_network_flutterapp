
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/product.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/products/typeselect.dart';
import 'package:univintel_gbn_app/pages/promotes/typeselect.dart';

import 'edit_product.dart';

class ProductsPage extends StatefulWidget {
  final String companyId;

  ProductsPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => ProductsPageState();

}

class ProductsPageState extends State<ProductsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final String apiRoute = "api/1/products/";
  List<Product> items = new List<Product>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final result = await apiGetResult(
      "${apiRoute}all?companyid=${widget.companyId}",
      context
    );

    setState(() {
      items = List<Product>.from(result.map((map) => Product.fromJson(map)));
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

  void insertItem(Product item, {int position = -1}){
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
        title: Text(UnivIntelLocale.of(context, "productsandservices")),
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
    final page = ProductTypePage(companyId: widget.companyId);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => page));
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
          getMainActionBuilder(),
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      },
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
            final promoteSelectionPage = PromoteTypePage( companyId: widget.companyId, entinyTypeId: "product", entinyId: items[index].id);
            Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => promoteSelectionPage));
          },
        );
    });
  }

  Widget getItemTemplate(Product item) {
    return InkWell(
      onTap: () {
        final itemPage = EditProductPage(item: item);
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
                item.imageId != "" ? AvatarBox(item.imageId , 30, squared: true) : 
                 item.type == "product" ? Icon(Icons.local_offer, size: 60) : Icon(Icons.local_shipping, size: 60)
              ]
            ),
            Container(
              padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width*0.9 - 100,
              child: Container(
                height: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.title, style: TextStyle(fontSize: 20)),
                    Text(item.description, style: TextStyle(fontSize: 10), maxLines: 2,),
                  ]
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("\$ ${item.price}", style: TextStyle(fontSize: 10)),
              ],
            )
          ],
        )
      ),
    );
  }
}
