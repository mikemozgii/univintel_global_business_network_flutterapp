import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/funding_now.dart';
import 'package:univintel_gbn_app/models/funding_history.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/fundingHistory/edit_now.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/fundingHistory/edit_history.dart';

class FundingHistoryPage extends StatefulWidget {
  final String companyId;

  FundingHistoryPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FundingHistoryPageState();

}

class AllFundingHistory {
  final CompanyFundingNow fundingNow;
  final List<CompanyFundingHistory> history;

  AllFundingHistory({this.fundingNow, this.history});
}

class FundingHistoryPageState extends State<FundingHistoryPage> {
  final ApiService apiService = new ApiService();
  bool isLoading = true;
  CompanyFundingNow item = new CompanyFundingNow();
  List<CompanyFundingHistory> history = new List<CompanyFundingHistory>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async  {
    var retry = await apiService.get("api/1/companies/fundinghistory/" + widget.companyId);
    var roundNow = CompanyFundingNow.fromJson(retry['now']);
    var historyRetry = new List<CompanyFundingHistory>();
    for (var item in retry['history']) {
      historyRetry.add(CompanyFundingHistory.fromJson(item));
    }

    setState(() {
      item = roundNow;
      history = historyRetry;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "fundinghistory")),
        actions: [
           IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditNowPage(fundingNow: item)));
              })
        ]
      ),
      floatingActionButton: history.length > 0 ? FloatingActionButton(
        backgroundColor: systemLinkColor(),
        onPressed: () {
          var newItem = new CompanyFundingHistory();
          newItem.companyId = widget.companyId;
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditHistoryPage(fundingHistory: newItem)));
        },
        child: Icon(Icons.add, color: Theme.of(context).textTheme.subtitle1.color),
      ) : null,
      body: renderBody(context)
    );
  }

  Widget renderBody(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return ListView (
      children: [
        Column (
          children: drawBlocks(context)
        )
      ]
    );
  }

  List<Widget> drawBlocks(BuildContext context) {
    List<Widget> widgets = new List<Widget>();
    var headerTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: systemLinkColor()
    );

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(8, 14, 8, 8),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(UnivIntelLocale.of(context, "currentstageoffinancing"), style: headerTextStyle)
        )
      )
    );
    widgets.add(drawSummary());
    widgets.add(Padding(
      padding: EdgeInsets.all(8),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(UnivIntelLocale.of(context, "previousfundingsteps"), style: headerTextStyle)
        )
      )
    );

    if (history.length == 0) {
      widgets.add(
        Container(
          height: MediaQuery.of(context).size.height - 260,
          child: Center(
            child: InkWell(
              onTap: () {
                var newItem = new CompanyFundingHistory();
                newItem.companyId = widget.companyId;
                Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditHistoryPage(fundingHistory: newItem)));
              },
              child: Text(
                "+ " + UnivIntelLocale.of(context, "add"),
                style: TextStyle(color: systemLinkColor(),
                  fontSize: 16
                )
              )
            )
          )
        )
      );
    }

    for (var historyItem in history) { 
      widgets.add(drawHistoryItem(historyItem));
    }

    return widgets;
  }

  Widget drawSummary() {
    return InkWell(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(UnivIntelLocale.of(context, "round") + ": "),
                            flex: 6
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text((item.round != null ? UnivIntelLocale.of(context, "round" + item.round) : UnivIntelLocale.of(context, "notspecified"))),
                            ),
                            flex: 4
                          )
                        ]
                      ),
                      Container(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(UnivIntelLocale.of(context, "seeking") + ": ",
                              style: TextStyle(fontSize: 12)
                            ),
                            flex: 6
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                item.seeking != null ? "\$ " + item.seeking.toString() : UnivIntelLocale.of(context, "notspecified"),
                                style: TextStyle(fontSize: 12)
                              ),
                            ),
                            flex: 4
                          )
                        ]
                      ),                      
                      /*Align(
                        alignment: Alignment.topLeft,
                        child: Text(item.securityType == null ? "" : UnivIntelLocale.of(context, "securitytype" + item.securityType), style: TextStyle(fontSize: 12), textAlign: TextAlign.left)
                      )*/
                    ]
                  )
                )
              )
            ],
          )
      ),
    );
  }

  Widget drawHistoryItem(CompanyFundingHistory fundingItem) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red),
      onDismissed: (direction) {
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Item deleted"),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: UnivIntelLocale.of(context, "undo"),
              onPressed: () {
                getData();
              },
            )
          )
        ).closed.then(
          (SnackBarClosedReason reason) async {
            if (reason != SnackBarClosedReason.timeout)  return;

            await apiGetResult("api/1/companies/deletefundinghistory/?companyId=" + widget.companyId + "&id=" + fundingItem.id, context);

            getData();
          }
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditHistoryPage(fundingHistory: fundingItem)));
        },
        child: Container(
          decoration: listSeparatingBorder(context),
          margin: EdgeInsets.all(2),
          width: MediaQuery.of(context).size.width - 14,
          height: 80,
          child: Row(
            children: [
              Container (
                width: MediaQuery.of(context).size.width - 44,
                child: 
                  Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(UnivIntelLocale.of(context, "round") + ": " + (fundingItem.round != null ? UnivIntelLocale.of(context, "round" + fundingItem.round) : UnivIntelLocale.of(context, "notspecified")), style: TextStyle(fontSize: 16), textAlign: TextAlign.left)
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(UnivIntelLocale.of(context, "capitalraised") + ": " + fundingItem.capitalRaised.toString() + " \$", style: TextStyle(fontSize: 12), textAlign: TextAlign.left)
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(UnivIntelLocale.of(context, "investor") + ": " + fundingItem.investorName, style: TextStyle(fontSize: 12), textAlign: TextAlign.left)
                        )
                      ]
                    )
                  )
              )
            ]
          )
        )
      )
    );
  }
}
