import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/company/company_dashboard.dart';

class CompanyRankChangedPage extends StatefulWidget {
  final int rank;
  final String companyId;

  CompanyRankChangedPage({this.rank, this.companyId});

  @override
  State<StatefulWidget> createState() => CompanyRankChangedPageState();

}

class CompanyRankChangedPageState extends State<CompanyRankChangedPage> {
  bool isLoading = true;
  int rank = 0;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    await apiGetResult("api/1/companyranks/setrank?rank=" + widget.rank.toString() + "&companyId=" + widget.companyId, context);

    setState(() {
      rank = widget.rank;
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
      body: Center(
        child: Column(
          children: [
            Text("You New Rank is " + widget.rank.toString()),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => CompanyDashboardPage(companyId: widget.companyId)));
              },
              child: Text("Back")
            )
          ]
        )
      )
    );
  }


}
