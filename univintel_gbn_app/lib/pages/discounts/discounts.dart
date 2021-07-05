import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/discount.dart';
import 'package:univintel_gbn_app/pages/discounts/typeselect.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/promotes/typeselect.dart';
import 'edit_discount.dart';


class DiscountsPage extends StatefulWidget {
  final String companyId;

  DiscountsPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => DiscountsPageState();

}

class DiscountsPageState extends State<DiscountsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final String apiRoute = "api/1/discounts/";
  List<Discount> items = new List<Discount>();
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final result = await apiGetResult(
      "${apiRoute}all?companyid=${widget.companyId}",
      context);

    setState(() {
      items = List<Discount>.from(result.map((map) => Discount.fromJson(map)));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "couponsanddiscounts")),
        actions: [
           IconButton(
              icon: Icon(Icons.add),
              onPressed: () => goNewItemPage()
           )
        ]
      ),
      body: fillItems(context)
    );
  }
  
  void goNewItemPage() {
    final page = DiscountTypePage(companyId: widget.companyId);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => page));
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

  void insertItem(Discount item, {int position = -1}){
    setState(() { 
      if(position == -1 || items.length <= position) items.add(item);
      else items.insert(position, item); 
    });
  }

  Widget getSlidableItemWidget(BuildContext context, int index) {
    final item = items[index];
    return Slidable.builder(
      key: Key(item.id),
      direction: Axis.horizontal,
      actionPane: SlidableDrawerActionPane(),
      secondaryActionDelegate: SlideActionBuilderDelegate(
        actionCount: 1,
        builder: (context, index, animation, renderingMode) {
          return IconSlideAction(
            color: renderingMode == SlidableRenderingMode.slide
                ? Colors.red.withOpacity(animation.value)
                : Colors.red,
            icon: Icons.delete,
            onTap: () => removeItem(index),
          );
      }),
      actionDelegate: SlideActionBuilderDelegate(
        actionCount: 1,
        builder: (context, index, animation, renderingMode) {
          return IconSlideAction(
            color: renderingMode == SlidableRenderingMode.slide
                ? Colors.green.withOpacity(animation.value)
                : Colors.green,
            icon: Icons.trending_up,
            caption: UnivIntelLocale.of(context, "promote"),
            onTap: () => {},
          );
      }),
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onWillDismiss: (type) {
          if(type == SlideActionType.secondary) {
            removeItem(index);
            return true;
          }
          else return false;
        },
        closeOnCanceled: true,
      ),
      child: InkWell(
        onTap: () {
          final itemPage = EditDiscountPage(item: item);
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => itemPage));
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
      ),
    );
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
            final promoteSelectionPage = PromoteTypePage( companyId: widget.companyId, entinyTypeId: "discount", entinyId: items[index].id);
            Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => promoteSelectionPage));
          },
        );
    });
  }

  Widget getItemTemplate(Discount item) {
    return InkWell(
      onTap: () {
        final itemPage = EditDiscountPage(item: item);
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => itemPage));
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
                    item.imageId != "" ? AvatarBox(item.imageId , 30, squared: true) : Icon(Icons.local_offer, size: 60)
                  ]
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Container(
                    height: 65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.title, style: TextStyle(fontSize: 20)),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Text(
                              item.description,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12, color: systemGrayColor()),
                              overflow: TextOverflow.ellipsis
                            )
                          )
                        ),
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

  Widget fillItems(BuildContext context) {
    if (items.length == 0) {
      return Center(
        child: InkWell(
          onTap: () => goNewItemPage(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16),)
        )
      );
    }

    return getListItems();
  }

}
