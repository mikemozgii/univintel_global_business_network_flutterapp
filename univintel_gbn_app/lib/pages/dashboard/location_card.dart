import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/models/company_items.dart';
import 'package:univintel_gbn_app/models/discount.dart';
import 'package:univintel_gbn_app/models/location_news.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/product.dart';
import 'package:univintel_gbn_app/models/working_hour.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globals.dart';

class LocationCardPage extends StatefulWidget {
  final String locationId;
  final String companyId;

  LocationCardPage({Key key, this.locationId, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LocationCardPageState();
}

class LocationCardPageState extends State<LocationCardPage> {
  bool isLoading = true;
  Company company;
  CompanyItems companyItems;
  List<WorkingHour> workingHours;
  List<LocaltionNews> locationNews;
  List<String> dayTranslates = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var companyReply = await apiGetResult("api/1/companies/mapsingle/" + widget.companyId, context);
    var workingHoursReply = await apiGetResult("api/1/locations/workinghours/?id=" + widget.locationId, context);
    var newsReply = await apiGetResult("api/1/news/allonmap?companyId=" + widget.companyId , context);
    final companyItemsReply = await apiGetResult("api/1/companies/companyitems?companyId=${widget.companyId}",context);


    setState(() {
      company = Company.fromJson(companyReply);
      companyItems = CompanyItems.fromJson(companyItemsReply);
      workingHours = List<WorkingHour>.from(workingHoursReply.map((map) => WorkingHour.fromJson(map)));
      locationNews = List<LocaltionNews>.from(newsReply.map((map) => LocaltionNews.fromJson(map)));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.category)),
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.new_releases)),
            ],
          )
        ),
        body: TabBarView(
            children: [
              getCompanyItemsTemplate(),
              ListView(
                children: [
                  fillCard(context),
                  fillWorkingHours(context)
                ]
              ),
              ListView(children: [
                fillNews()
              ])
              
            ]
          )
        )
      );
  }

  Widget fillNews() {
    if (locationNews.length == 0) return Container();

    List<Widget> news = List<Widget>();
    for (var locationNew in locationNews) {
      news.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: locationNew.imageId == null ?
            Container(
              width: MediaQuery.of(context).size.width,
              height: 230,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.new_releases, size: 100)
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.edit)
                    )
                  ),
                ]
              )
            )
          : Container(
            width: MediaQuery.of(context).size.width - 16,
            height: 230,
            decoration: new BoxDecoration(
              image: DecorationImage(
                image: apiService.getNetworkImageFromFiles(locationNew.imageId, fixCache: true),
                fit: BoxFit.cover
              )
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit)
              )
            )
          )
        )
      );
      news.add(
        Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              locationNew.body,
              style: TextStyle(
                fontSize: 18,
                color: systemGrayColor()
              )
            )
          )
        )
      );
    }

    return Column(children: news);
  }

  String getDisplayDays(List<int> days) {
    var result = "";
    for (var day in days) {
      result += UnivIntelLocale.of(context, dayTranslates[day]) + " ";
    }
    return result;
  }

  Widget fillWorkingHours(BuildContext context) {
    var result = List<Widget>();

    if (workingHours == null || workingHours.length == 0) return Container();

    result.add(
      Container(
        decoration: listSeparatingBorder(context)
      )
    );

    result.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Text(
          UnivIntelLocale.of(context, "workinghoursmap"),
          style: TextStyle(fontSize: 20),
        )
      )
    );

    for (var workingHour in workingHours) {
      for (var day in workingHour.days) {
        result.add(
          Text(
            UnivIntelLocale.of(context, dayTranslates[day]) + " " + workingHour.start.format(context) + " - " + workingHour.end.format(context)
          )
        );
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 2),
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: result
      )
    );
  }

  Widget fillCard(BuildContext context) {
    var result = new List<Widget>();

    result.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(2, 16, 0, 0),
                      child: AvatarBox(company.logoId , 50, localFileIfNotSpecifiedPath: 'assets/images/image_not_found.png'),
                    ),
                    flex: 8,
                  ),
                ]
              ),
              flex: 3,
            ),
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18)
                    )
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      company.tagline == null ? "" : company.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: systemGrayColor()
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        UnivIntelLocale.of(context, "rank") + ": " + company.companyRank.toString() + " " + UnivIntelLocale.of(context, "from") + " 10",
                        style: TextStyle(
                          fontSize: 14
                        )
                      )
                    )
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                            child: Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width - 220,
                                  height: 20,
                                  decoration: new BoxDecoration(
                                    color: systemGrayColor(),
                                    borderRadius: new BorderRadius.only(
                                      topLeft:  const  Radius.circular(3),
                                      topRight: const  Radius.circular(3),
                                      bottomLeft: const  Radius.circular(3),
                                      bottomRight: const  Radius.circular(3),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: (((company.companyRank * 10) / 100) * (MediaQuery.of(context).size.width - 220)),
                                  height: 20,
                                  decoration: new BoxDecoration(
                                    color: systemLinkColor(),
                                    borderRadius: new BorderRadius.only(
                                      topLeft:  const  Radius.circular(3),
                                      topRight: const  Radius.circular(3),
                                      bottomLeft: const  Radius.circular(3),
                                      bottomRight: const  Radius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          )
                        ],
                      )
                    )
                  )
                ],
              ),
              flex: 7,
            )
          ],
        )
      )
    );

    result.add(
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 0, 14),
          child: IntrinsicWidth(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  children: elementsSpacing(
                    socialIcons(context),
                    7
                  ),
                )
              )
            )
        )
      )
    );

    if (company.website != null || company.phone != null || company.email != null) {
      result.add(
        Container(
          width: MediaQuery.of(context).size.width - 14,
          decoration: boxSeparatingBorder(context),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 18, 8, 18),
            child:
              Column(
                children: fillContactsGroup(),
              )
          ),
        )
      );
    }

    if (company.description != null) {
      result.add(
        Container(
          width: MediaQuery.of(context).size.width - 14,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 10, 4, 0),
            child: Text(
              company.description,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18)
            )
          )
        )
      );
    }

    return Column(children: result);
  }

List<Widget> fillContactsGroup() {
    var result = new List<Widget>();

    if (company.website != null && company.website.isNotEmpty) { 
      result.add(getLinkRowIcon(FontAwesomeIcons.globe, company.website.replaceAll("http://", "").replaceAll("https://", ""), company.website));
    }

    if (company.phone != null && company.phone.isNotEmpty) {
      result.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: getLinkRowIcon(Icons.phone, company.phone, "tel://" + company.phone)
        )
      );
    }

    if (company.email != null && company.email.isNotEmpty) {
      result.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: getLinkRowIcon(Icons.email, company.email, "mailto://" + company.email)
        )
      );
    }

    return result;
  }

  Widget getItemTypeSplitLine() {
    return Container(
      height: 5,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color:systemGrayColor()))));
  }

  Widget getItemTypeLable(String text) {
      return Row(
        children: [
          Text(text, style: TextStyle(fontSize: 20, color: systemGrayColor())),
        ],
      );
  }

  Widget getCompanyItemsTemplate() {
    var widgets = List<Widget>();
    if(companyItems.products.length > 0) {
      widgets.add(getItemTypeLable(UnivIntelLocale.of(context, "products")));
      widgets.addAll(companyItems.products.map((e) => getProductTemplate(e)));
      widgets.add(getItemTypeSplitLine());
    }
    if(companyItems.services.length > 0) {
      widgets.add(getItemTypeLable(UnivIntelLocale.of(context, "services")));
      widgets.addAll(companyItems.services.map((e) => getProductTemplate(e)));
      widgets.add(getItemTypeSplitLine());
    }
    if(companyItems.discounts.length > 0) {
      widgets.add(getItemTypeLable(UnivIntelLocale.of(context, "discounts")));
      widgets.addAll(companyItems.discounts.map((e) => getDiscountItemTemplate(e)));
      widgets.add(getItemTypeSplitLine());
    }
    if(companyItems.coupons.length > 0) {
      widgets.add(getItemTypeLable(UnivIntelLocale.of(context, "coupons")));
      widgets.addAll(companyItems.coupons.map((e) => getDiscountItemTemplate(e)));
    }
    
    return Padding(
      padding: EdgeInsets.only(left:5.0),
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left:5.0),
            child: Column(children: widgets)
          )
        ]
      ),
    );
  }

  Widget getProductTemplate(Product item) {
    return InkWell(
      onTap: () {
      },
      child: Container(
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

  Widget getDiscountItemTemplate(Discount item) {
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

  List<Widget> socialIcons(BuildContext context) {
    var result = new List<Widget>();

    result.add(Icon(Icons.favorite, size: 30));
    result.add(Text("0"));
    result.add(Icon(Icons.remove_red_eye, size: 30));
    result.add(Text("0"));

    if (company.facebook != null && company.facebook.isNotEmpty) {
      result.add(
        InkWell(
          onTap: () async {
            if (await canLaunch(company.facebook)) await launch(company.facebook);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Icon(FontAwesomeIcons.facebook, size: 24)
          )
        )
      );
    }
    if (company.twitter != null && company.twitter.isNotEmpty) {
      result.add(
        InkWell(
          onTap: () async {
            if (await canLaunch(company.twitter)) await launch(company.twitter);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Icon(FontAwesomeIcons.twitter, size: 24)
          )
        )
      );
    }
    if (company.linkedin != null && company.linkedin.isNotEmpty) {
      result.add(
        InkWell(
          onTap: () async {
            if (await canLaunch(company.linkedin)) await launch(company.linkedin);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Icon(FontAwesomeIcons.linkedin, size: 24)
          )
        )
      );
    }

    return result;
  }

  Widget getLinkRowIcon(IconData icon, String displayLink, String link) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 8, 0),
          child: Icon(icon)
        ),
        InkWell(
          onTap: () async {
            if (await canLaunch(link)) await launch(link);
          },
          child: Text(
            displayLink,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              color: systemLinkColor()
            )
          )
        )
      ],
    );
  }

}
