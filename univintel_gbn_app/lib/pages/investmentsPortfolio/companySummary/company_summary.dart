import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/company_summary.dart';
import 'package:univintel_gbn_app/models/company_file.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/companySummary/edit_field.dart';

class CompanySummaryPage extends StatefulWidget {
  final String companyId;

  CompanySummaryPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => CompanySummaryPageState();

}

class AllSummaryModels {
  final CompanySummary summary;
  final CompanyFile pitchDeck;

  AllSummaryModels({this.summary, this.pitchDeck});
}

class CompanySummaryPageState extends State<CompanySummaryPage> {
  final ApiService apiService = new ApiService();
  CompanySummary item;
  CompanyFile pitchDeck;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    refreshItems();
  }

  void refreshItems() async {
    var retry = await apiService.get("api/1/companies/summary/" + widget.companyId);
    var pitchDecks = await apiService.get("api/1/companies/pitchdeck/" + widget.companyId);
    Map<String, dynamic> pitchDeckEntity;
    for (var item in pitchDecks) {
      pitchDeckEntity = item;
    }

    setState(() {
      item = CompanySummary.fromJson(retry);
      pitchDeck = pitchDeckEntity != null ? CompanyFile.fromJson(pitchDeckEntity) : null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "companysummary")),
      ),
      body: fillSummary(context)
    );
  }

  Widget fillSummary(BuildContext context) {
    if (item == null) {
      return Center (
          child: CircularProgressIndicator()
      );
    }

    return ListView (
      children: [
        Column (
          children: [
            drawSummaryBlock(context, UnivIntelLocale.of(context, "managementteam"), item.managementTeam, UnivIntelLocale.of(context, "managementteamdescription"), "managementteam"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "customerproblem"), item.customerProblem, UnivIntelLocale.of(context, "customerproblemdescription"), "customerproblem"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "productsandservices"), item.productsAndServices, UnivIntelLocale.of(context, "productsandservicesdescription"), "productsandservices"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "targetmarket"), item.targetMarket, UnivIntelLocale.of(context, "targetmarketdescription"), "targetmarket"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "businessmodel"), item.businessModel, UnivIntelLocale.of(context, "businessmodeldescription"), "businessmodel"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "customersegments"), item.customerSegments, UnivIntelLocale.of(context, "customersegmentsdescription"), "customersegments"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "salesmarketingstrategy"), item.salesMarketingStrategy, UnivIntelLocale.of(context, "salesmarketingstrategydescription"), "salesmarketingstrategy"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "сompetitors"), item.competitors, UnivIntelLocale.of(context, "сompetitorsdescription"), "сompetitors"),
            drawSummaryBlock(context, UnivIntelLocale.of(context, "competitiveadvantage"), item.competitiveAdvantage, UnivIntelLocale.of(context, "competitiveadvantagedescription"), "competitiveadvantage"),
            drawPitchDeckBlock(context, UnivIntelLocale.of(context, "pitchdeck"), pitchDeck != null ? pitchDeck.name : UnivIntelLocale.of(context, "notuploaded"))
          ]
        )
      ]
    );
  }

  Widget drawSummaryBlock(BuildContext context, String title, String value, String defaultDescription, String mode) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditFieldPage(companySummary: item, mode: mode, hint: defaultDescription)));
        },
        child: Container(
          decoration: listSeparatingBorder(context),
          margin: EdgeInsets.all(2),
          width: MediaQuery.of(context).size.width - 14,
          height: 80,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Row(
              children: [
                Container (
                  width: MediaQuery.of(context).size.width - 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                          child: Text(title, style: TextStyle(fontSize: 20), textAlign: TextAlign.left)
                        )
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          value == null ? defaultDescription : value,
                          style: TextStyle(color: systemGrayColor()),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis
                        )
                      )
                    ]
                  )
                )
              ],
            )
          )
        )
    );
  }

  Widget drawPitchDeckBlock(BuildContext context, String title, String value) {
    return InkWell(
      onTap: () async {
        File file = await FilePicker.getFile();
        if (file == null) return;

        String id = pitchDeck == null ? "" : pitchDeck.id;
        await apiService.uploadFile(file, companyId: widget.companyId, tag: 'pitchdeck', id: id );

        refreshItems();
      },
      child: Container(
        margin: EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width - 14,
        height: 80,
        child: Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Row(
            children: [
              Container (
                width: MediaQuery.of(context).size.width - 44,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                        child: Text(title, style: TextStyle(fontSize: 20), textAlign: TextAlign.left)
                      )
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        value,
                        style: TextStyle(color: systemGrayColor()),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis
                      )
                    )
                  ]
                )
              )
            ],
          )
        )
      )
    );
  }
}
