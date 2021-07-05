import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/models/news.dart';
import 'package:univintel_gbn_app/localization.dart';

import 'edit_news.dart';

class NewsPage extends StatefulWidget {
  final String companyId;

  NewsPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => NewsPageState();

}

class NewsPageState extends State<NewsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final String apiRoute = "api/1/news/";
  List<News> items = new List<News>();
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
      items = List<News>.from(result.map((map) => News.fromJson(map)));
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

  void insertItem(News item, {int position = -1}){
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
        title: Text(UnivIntelLocale.of(context, "news")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () => addItem(),
          )
        ]        
      ),
      body: fillItems(context)
    );
  }

  void addItem() {
    final emptyItem = new News();
    emptyItem.companyId = widget.companyId;

    final companyPage = EditNewsPage(news: emptyItem);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }

  Widget fillItems(BuildContext context) {
    if (items.length == 0){
            return Center(
        child: InkWell(
          onTap: () => addItem(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16))
        )
      );
    }

    return getListItems();
  }

  Widget getItemTemplate(News item) {
    return InkWell(
      onTap: () {
        final itemPage = EditNewsPage(news: item);
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => itemPage));
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
        child: Container(
          decoration: listSeparatingBorder(context),
          margin: EdgeInsets.all(2),
          width: MediaQuery.of(context).size.width - 14,
          height: 80,
          child: Row (
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 60,
                height: 60,
                child: Align(
                  child: AvatarBox(
                    item.imageId ,
                    30,
                    localFileIfNotSpecifiedPath: 'assets/images/image_not_found.png',
                    isDocumentImage: true,
                    squared: true,
                  )
                )
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding (
                      padding: EdgeInsets.fromLTRB(10, 14, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: TextStyle(fontSize: 20)),
                          Text(
                            item.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: systemGrayColor()
                            )
                          )
                        ],
                      )
                    )
                  ]
                ),
                flex: 6
              ),
            ]
          )
        ),
      )
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
          null,
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      },
    );
  }

}
