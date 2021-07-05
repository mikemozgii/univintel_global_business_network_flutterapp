import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/company_common.dart';
import 'package:univintel_gbn_app/localization.dart';

class InvestmentPortfolioPage extends StatefulWidget {
  final String companyId;

  InvestmentPortfolioPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InvestmentPortfolioPageState();

}

class InvestmentPortfolioPageState extends State<InvestmentPortfolioPage> {
  final ApiService apiService = new ApiService();
  CompanyCommon item = new CompanyCommon();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    updateItem();
  }

  void updateItem() async {
    var retry = await apiService.get("api/1/companies/common/" + widget.companyId);

    setState(() {
      item = CompanyCommon.fromJson(retry);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "investmentporfolio")),
      ),
      body: renderBody(context)
    );
  }

  Widget renderBody(BuildContext context) {
    return ListView (
      children: [
        Column (
          children: [
            drawCommonBlock(UnivIntelLocale.of(context, "onelinepitch"), item.oneLinePitch, UnivIntelLocale.of(context, "onelinepitchempty"), "onelinepitch"),
            drawCommonBlock(UnivIntelLocale.of(context, "incorporationtype"), item.incorporationType, UnivIntelLocale.of(context, "pleaseselectanoption"), "incorporationtype", isNeedTranslation: true, translationPrefix: "incorparetedtypes"),
            drawCommonBlock(UnivIntelLocale.of(context, "companystage"), item.companyStage, UnivIntelLocale.of(context, "pleaseselectanoption"), "companystage", isNeedTranslation: true, translationPrefix: "companystage"),
            drawCommonBlock(UnivIntelLocale.of(context, "pitchvideolink"), item.pitchVideoLink, UnivIntelLocale.of(context, "pitchvideolinkempty"), "pitchvideolink")
          ]
        )
      ]
    );
  }

  String getTranslate(String prefix, String value) {
    return UnivIntelLocale.of(context, prefix + value);
  }

  Widget drawCommonBlock(String title, String value, String defaultDescription, String mode, {bool isNeedTranslation = false, String translationPrefix = ""}) {
    return InkWell(
        onTap: () {
          //Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditPortfolioPage(companyCommon: item, mode: mode)));
        },
        child: Container(
          decoration: listSeparatingBorder(context),
          margin: EdgeInsets.all(2),
          width: MediaQuery.of(context).size.width - 14,
          height: 80,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Container (
                  width: MediaQuery.of(context).size.width - 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(title, style: TextStyle(fontSize: 20), textAlign: TextAlign.left)
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            value == null ? defaultDescription : isNeedTranslation ? getTranslate(translationPrefix, value) : value,
                            style: TextStyle(fontSize: 10),
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis
                          )
                        )
                      )
                    ]
                  )
                )
              )
            ],
          )
        )
    );
  }

}
