import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/company_financial_year.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/annualFinancials/root.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';

class EditFinancialYearPage extends StatefulWidget {
  final CompanyFinancialYear financialsYear;
  final List<int> existingsYears;

  EditFinancialYearPage({Key key, this.financialsYear, this.existingsYears}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditFinancialYearPageState();
}

class EditFinancialYearPageState extends State<EditFinancialYearPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController yearController = TextEditingController();
  String expenditure;
  String revenue;
  String revenueDriver;
  String year;

  @override
  void initState() {
    super.initState();

    setState(() {
      expenditure = widget.financialsYear.expenditure.toString();
      revenue = widget.financialsYear.revenue.toString();
      year = widget.financialsYear.id == null ? getDefaultYear(context) : widget.financialsYear.year.toString();
      revenueDriver = widget.financialsYear.revenueDriver == null ? "" : widget.financialsYear.revenueDriver;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (year != null) {
      var years = getDefaultYears(context);
      var selectedYear = years.firstWhere((element) => element.id == year);
      yearController.text = selectedYear.title;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "annualfinancials")),
        actions: [
           IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (!formKey.currentState.validate()) return;

                await saveCompany();
              })
        ]
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            widget.financialsYear.id == null ?
              formPadding(
                TextFormField(
                  onTap: () async {
                    var years = getDefaultYears(context);
                    var result = await showSelector(context, years, year, UnivIntelLocale.of(context, "year"));
                    if (result == null) return;

                    year = result as String;
                    yearController.text = years.firstWhere((a) => a.id == year).title;
                  },
                  maxLines: 1,
                  readOnly: true,
                  controller: yearController,
                  keyboardType: TextInputType.text,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "year")),
                  validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                )
              ) :
              formPadding(
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  initialValue: year,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "year")),
                  enabled: false
                )
              ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                initialValue: revenue,
                decoration: textInputDecoration(UnivIntelLocale.of(context, "revenue"), Icons.attach_money),
                onChanged: (value) {
                  setState(() {
                    revenue = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                initialValue: expenditure,
                decoration: textInputDecoration(UnivIntelLocale.of(context, "expenditure"), Icons.attach_money),
                onChanged: (value) {
                  setState(() {
                    expenditure = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                initialValue: revenueDriver,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "revenuedriver")),
                onChanged: (value) {
                  setState(() {
                    revenueDriver = value;
                  });
                }
              )
            ),
            formPadding(
              Text(UnivIntelLocale.of(context, "revenuedriverdescription"), style: TextStyle(color: systemGrayColor())),
            ),
            formPadding(
              widget.financialsYear.id == null ? null :
              RaisedButton(
                onPressed: () async {
                  var retry = await apiGetResult("api/1/companies/deleteannualfinancials/?companyId=" + widget.financialsYear.companyId + "&id=" + widget.financialsYear.id, context);
                  if (!retry) return;

                  Navigator.of(context).pop();
                  Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => AnnualFinancialsPage(companyId: widget.financialsYear.companyId)));
                },
                color: Colors.redAccent,
                child: Text(
                  UnivIntelLocale.of(context, "delete"),
                  style: TextStyle(fontSize: 15)
                ),
              )
            )
          ],
        )
      )
    );
  }

  Future<bool> saveCompany() async {
    widget.financialsYear.expenditure = int.parse(expenditure);
    widget.financialsYear.revenue = int.parse(revenue);
    widget.financialsYear.year = int.parse(year);
    widget.financialsYear.revenueDriver = revenueDriver;

    var retry = await apiService.postJson("api/1/companies/addorupdatefinancialyear", widget.financialsYear.toJson());
    if (retry){ 
      Navigator.of(context).pop();
      if (widget.financialsYear.id == null) {
        Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => AnnualFinancialsPage(companyId: widget.financialsYear.companyId)));
      }
    }

    return true;
  }

  String getDefaultYear(BuildContext context) {
    var startYear = DateTime.now().year;

    for (var i = startYear; i < i + 10; i++) {
      if (widget.existingsYears.contains(i)) continue;

      return i.toString();
    }

    return (startYear - 1).toString();
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected, String title) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: title, items: items, selectedId: selected)));
    return result;
  }

  List<LocalSelectorItem> getDefaultYears(BuildContext context) {
    var result = new List<LocalSelectorItem>();
    var startYear = DateTime.now().year - 10;
    var endYear = startYear + 21;
    var currentYear = int.parse(year);
    for (var i = startYear; i < endYear; i++) {
      if (i != currentYear && widget.existingsYears.contains(i)) continue;

      var stringYear = i.toString();
      result.add(LocalSelectorItem(id: stringYear, title: stringYear));
    }

    return result;
  }

}
