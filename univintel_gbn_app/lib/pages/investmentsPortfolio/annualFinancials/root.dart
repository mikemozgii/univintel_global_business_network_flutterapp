import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/annualFinancials/edit_annuals.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/annualFinancials/edit_year.dart';
import 'package:univintel_gbn_app/models/company_annual_financials.dart';
import 'package:univintel_gbn_app/models/company_financial_year.dart';
import 'package:univintel_gbn_app/localization.dart';

class AnnualFinancialsPage extends StatefulWidget {
  final String companyId;

  AnnualFinancialsPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AnnualFinancialsPageState();

}

class AnnualFinancialsPageState extends State<AnnualFinancialsPage> {
  final ApiService apiService = new ApiService();
  CompanyAnnualFinancials item = new CompanyAnnualFinancials();
  bool isLoading = true;
  List<CompanyFinancialYear> years = new List<CompanyFinancialYear>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    getItem();
  }

  void getItem() async {
    var retry = await apiService.get("api/1/companies/annualfinancials/" + widget.companyId);
    var annualFinancials = CompanyAnnualFinancials.fromJson(retry['annual']);
    var annualYears = new List<CompanyFinancialYear>();
    for (var year in retry['years']) {
      annualYears.add(CompanyFinancialYear.fromJson(year));
    }

    setState(() {
      item = annualFinancials;
      years = annualYears;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "annualfinancials")),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditAnnualSummaryPage(companyAnnualFinancials: item)));
            }
          ),
        ],
      ),
      floatingActionButton: years.length > 0 ? FloatingActionButton(
        backgroundColor: systemLinkColor(),
        onPressed: () {
          var newYear = new CompanyFinancialYear();
          newYear.expenditure = 0;
          newYear.revenue = 0;
          newYear.year = DateTime.now().year;
          newYear.companyId = widget.companyId;
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditFinancialYearPage(financialsYear: newYear, existingsYears: getFinancialsYears())));
        },
        child: Icon(Icons.add, color: Theme.of(context).textTheme.subtitle1.color),
      ) : null,
      body: renderBody(context)
    );
  }

  Widget renderBody(BuildContext context) {
    return ListView (
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4, 10, 0, 0),
          child: Column (
            children: drawBlocks()
          )
        )
      ]
    );
  }

  List<Widget> drawBlocks() {
    List<Widget> widgets = new List<Widget>();
    widgets.add(drawSummary());
    widgets.add(drawYearHeader());

    if (years.length == 0) {
      widgets.add(
        Container(
          height: MediaQuery.of(context).size.height - 260,
          child: Center(
            child: InkWell(
              onTap: () {
                var newYear = new CompanyFinancialYear();
                newYear.expenditure = 0;
                newYear.revenue = 0;
                newYear.year = DateTime.now().year;
                newYear.companyId = widget.companyId;
                Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditFinancialYearPage(financialsYear: newYear, existingsYears: getFinancialsYears())));
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

    for (var financialYear in years) {
      widgets.add(drawYear(financialYear));
    }

    return widgets;
  }

  Widget drawSummary() {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width - 14,
        height: 80,
        child: Row(
          children: [
            Container (
              width: MediaQuery.of(context).size.width - 44,
              decoration: listSeparatingBorder(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(UnivIntelLocale.of(context, "annualrevenuerunrate") + ": ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left),
                          flex: 6
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("\$ " + item.annualRevenueRunRate.toString(), style: TextStyle(fontSize: 18), textAlign: TextAlign.left),
                          ),
                          flex: 4
                        )
                      ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(UnivIntelLocale.of(context, "monthlyburnrate") + ": ", style: TextStyle(fontSize: 18), textAlign: TextAlign.left),
                          flex: 6
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("\$ " + item.monthlyBurnRate.toString(), style: TextStyle(fontSize: 18), textAlign: TextAlign.left),
                          ),
                          flex: 4
                        )
                      ]
                    ),
                  )
                ]
              )
            )
          ],
        )
      )
    );
  }

  List<int> getFinancialsYears() {
    List<int> existingYears = new List<int>();
    for (var existingYear in years) {
      existingYears.add(existingYear.year);
    }
    return existingYears;
  }

  Widget drawYearHeader() {
    var headerTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: systemLinkColor()
    );

    return InkWell(
      child: Container(
        margin: EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width - 14,
        height: 30,
        child: Row(
          children: [
            Container (
              width: MediaQuery.of(context).size.width - 44,
              child:Table (
                border: null,
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                children: [
                  TableRow(children: [
                      Center(child: Text(UnivIntelLocale.of(context, "year"), style: headerTextStyle)),
                      Center(child: Text(UnivIntelLocale.of(context, "revenue"), style: headerTextStyle)),
                      Center(child: Text(UnivIntelLocale.of(context, "expenditure"), style: headerTextStyle)),
                    ]
                  )
                ]
              )
            )
          ],
        )
      )
    );
  }

  Widget drawYear(CompanyFinancialYear financialYear) {
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
                getItem();
              },
            )
          )
        ).closed.then(
          (SnackBarClosedReason reason) async {
            if (reason != SnackBarClosedReason.timeout)  return;

            await apiGetResult("api/1/companies/deleteannualfinancials/?companyId=" + widget.companyId + "&id=" + financialYear.id, context);

            getItem();
          }
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditFinancialYearPage(financialsYear: financialYear, existingsYears: getFinancialsYears())));
        },
        child: Container(
          margin: EdgeInsets.all(2),
          width: MediaQuery.of(context).size.width - 14,
          height: 30,
          child: Row(
            children: [
              Container (
                width: MediaQuery.of(context).size.width - 44,
                child: Table (
                  border: null,
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: [
                    TableRow(children: [
                        Center(child: Text(financialYear.year.toString())),
                        Center(child: Text("\$ " + financialYear.revenue.toString())),
                        Center(child: Text("\$ " + financialYear.expenditure.toString()))
                      ]
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
