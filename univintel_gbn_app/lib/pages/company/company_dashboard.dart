import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/avatar_text_box.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/application_drawer.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/pages/company/edit_company.dart';
import 'package:univintel_gbn_app/pages/company/company_ranks.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDashboardPage extends StatefulWidget {
  final String companyId;

  CompanyDashboardPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CompanyDashboardPageState();

}

class CompanyDashboardPageState extends State<CompanyDashboardPage> {
  final ApiService apiService = new ApiService();
  Company item = new Company();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var retry = await apiService.get("api/1/companies/single/" + widget.companyId);
    var company = Company.fromJson(retry);

    setState(() {
      item = company;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "companyinfo")),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () => editCompany(),
          ),
        ],
      ),
      drawer: ApplicationDrawer(showCompanyMenu: true, itemId: item.id),
      body: renderBody(context)
    );
  }

  void editCompany() {
    final companyPage = EditCompanyPage(backToPage: "companydashboard", company: item);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }

  Widget renderBody(BuildContext context) {
    if (item == null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator()
        ]
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: ListView(
        children: [
          Column (
            children: fillCard(context),
          )
        ]
      )
    );
  }

  String getShortName(String name) {
    if (name == null || name == "") return "NN";

    return name.substring(0,2);
  }

  List<Widget> fillCard(BuildContext context) {
    var result = new List<Widget>();

    result.add(
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 14, 4, 0),
          child: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
          )
        )
      )
    );

    List<Widget> headerColumn = List<Widget>();

    if (item.abbreviation != null && item.abbreviation.isNotEmpty) {
      headerColumn.add(
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Text(
              item.abbreviation ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16)
            )
          )
        )
      );
    }

    if (item.tagline != null && item.tagline.isNotEmpty) {
      headerColumn.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            item.tagline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: systemGrayColor()
            )
          )
        )
      );
    }

    headerColumn.add(
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                  child: Stack(
                    children: [
                      Container(
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
                      FractionallySizedBox(
                        widthFactor: item.companyRank / 10,
                        child: Container(
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
                        )
                      ),
                      Container(
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          UnivIntelLocale.of(context, "rank") + " " + item.companyRank.toString(),
                          style: TextStyle(
                            fontSize: 14
                          )
                        )
                      )
                    ],
                  )
                ),
                flex: 9,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => new CompanyRanksPage(currentRank: item.companyRank, companyId: item.id)))
                  },
                  child: Icon(Icons.arrow_upward, color: systemGrayColor())
                ),
                flex: 1,
              )
            ],
          )
        )
      )
    );

    result.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child:  item.logoId != null ? AvatarBox(item.logoId , 40) : AvatarTextBox(getShortName(item.name), 40, fontSize: 26)
                    ),
                    flex: 8,
                  )
                ]
              ),
              flex: 3,
            ),
            Expanded(
              child: Column(
                children: headerColumn,
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

    if (item.website != null || item.phone != null || item.email != null) {
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

    if (item.description != null) {
      result.add(
        Container(
          width: MediaQuery.of(context).size.width - 14,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 10, 4, 0),
            child: Text(
              item.description,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18, color: systemGrayColor())
            )
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
          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: Icon(icon, color: systemGrayColor(), size: 18)
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
              fontSize: 16,
              color: systemLinkColor()
            )
          )
        )
      ],
    );
  }

  List<Widget> fillContactsGroup() {
    var result = new List<Widget>();

    if (item.website != null && item.website.isNotEmpty) { 
      result.add(getLinkRowIcon(FontAwesomeIcons.globe, item.website.replaceAll("http://", "").replaceAll("https://", ""), item.website));
    }

    if (item.phone != null && item.phone.isNotEmpty) {
      result.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: getLinkRowIcon(Icons.phone, item.phone, "tel://" + item.phone)
        )
      );
    }

    if (item.email != null && item.email.isNotEmpty) {
      result.add(
        Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: getLinkRowIcon(Icons.email, item.email, "mailto://" + item.email)
        )
      );
    }

    return result;
  }

  List<Widget> socialIcons(BuildContext context) {
    var result = new List<Widget>();
    var iconSize = 18.0;
    var iconSocialSize = 16.0;

    result.add(Icon(Icons.favorite, size: iconSize, color: systemGrayColor()));
    result.add(Text("0"));
    result.add(Icon(Icons.remove_red_eye, size: iconSize, color: systemGrayColor()));
    result.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
        child: Text("0")
      )
    );

    if (item.facebook != null && item.facebook.isNotEmpty) {
      result.add(
        InkWell(
          onTap: () async {
            if (await canLaunch(item.facebook)) await launch(item.facebook);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Icon(FontAwesomeIcons.facebook, size: iconSocialSize, color: systemGrayColor())
          )
        )
      );
    }
    if (item.twitter != null && item.twitter.isNotEmpty) {
      result.add(
        InkWell(
          onTap: () async {
            if (await canLaunch(item.twitter)) await launch(item.twitter);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Icon(FontAwesomeIcons.twitter, size: iconSocialSize, color: systemGrayColor())
          )
        )
      );
    }
    if (item.linkedin != null && item.linkedin.isNotEmpty) {
      result.add(
        InkWell(
          onTap: () async {
            if (await canLaunch(item.linkedin)) await launch(item.linkedin);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            child: Icon(FontAwesomeIcons.linkedin, size: iconSocialSize, color: systemGrayColor())
          )
        )
      );
    }

    return result;
  }

}
