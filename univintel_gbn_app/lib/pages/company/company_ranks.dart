import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/company_rank.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/globals.dart';
import 'package:univintel_gbn_app/pages/company/company_rank_changed.dart';

class CompanyRanksPage extends StatefulWidget {
  final int currentRank;
  final String companyId;

  CompanyRanksPage({this.currentRank, this.companyId});

  @override
  State<StatefulWidget> createState() => CompanyRanksPageState();

}

class CompanyRanksPageState extends State<CompanyRanksPage> {
  List<CompanyRank> companyRanks = new List<CompanyRank>();
  bool isLoading = true;
  String rank = "0";

  @override
  void initState() {
    super.initState();

    rank = widget.currentRank.toString();

    loadData();
  }

  void loadData() async {
    var retry = await apiService.get("api/1/companyranks/all");
    var result = new List<CompanyRank>();
    for (var item in retry) {
      var model = CompanyRank.fromJson(item);
      if (model.id < 2) continue;

      result.add(model);
    }

    setState(() {
      companyRanks = result;
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "ranks"))
      ),
      body: ListView(
        children: [fillRanks(context)]
      )
    );
  }

  Widget fillRanks(BuildContext context) {
    var rows = new List<Widget>();
    for (var companyRank in companyRanks) {
      rows.add(
        InkWell(
          onTap: () {
            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => CompanyRankChangedPage(companyId: widget.companyId, rank: companyRank.id)));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: listSeparatingBorder(context),
                padding: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row (
                      children: [
                        Expanded(
                          child: Text(companyRank.name, style: TextStyle(fontSize: 18)),
                          flex: 8,
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Text(companyRank.price.toString() + "\$", style: TextStyle(fontSize: 18)),
                          ),
                          flex: 2,
                        )
                      ]
                    ),
                    Text(
                      companyRank.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    )
                  ]
                ),
              )
            ]
          )
        )
      );
    }
    return Column(children: rows);
  }

}
