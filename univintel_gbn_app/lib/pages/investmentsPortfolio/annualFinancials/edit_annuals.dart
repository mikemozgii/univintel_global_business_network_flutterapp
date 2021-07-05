import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/company_annual_financials.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';

class EditAnnualSummaryPage extends StatefulWidget {
  final CompanyAnnualFinancials companyAnnualFinancials;

  EditAnnualSummaryPage({Key key, this.companyAnnualFinancials}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditAnnualSummaryPageState();
}

class EditAnnualSummaryPageState extends State<EditAnnualSummaryPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String annualRevenueRunRate;
  String monthlyBurnRate;
  String financialAnnotation;
  String revenueDriver;

  @override
  void initState() {
    super.initState();

    setState(() {
      annualRevenueRunRate = widget.companyAnnualFinancials.annualRevenueRunRate.toString();
      monthlyBurnRate = widget.companyAnnualFinancials.monthlyBurnRate.toString();
      financialAnnotation = widget.companyAnnualFinancials.financialAnnotation == null ? "" : widget.companyAnnualFinancials.financialAnnotation;
      revenueDriver = widget.companyAnnualFinancials.revenueDriver == null ? "" : widget.companyAnnualFinancials.revenueDriver;
    });
  }


  @override
  Widget build(BuildContext context) {
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
          children: <Widget>[
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                initialValue: annualRevenueRunRate,
                decoration: textInputDecoration(UnivIntelLocale.of(context, "annualrevenuerunrate"), Icons.attach_money),
                onChanged: (value) {
                  setState(() {
                    annualRevenueRunRate = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              Text(UnivIntelLocale.of(context, "annualrevenuerunratedescription"), style: TextStyle(color: systemGrayColor())),
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                initialValue: monthlyBurnRate,
                decoration: textInputDecoration(UnivIntelLocale.of(context, "monthlyburnrate"), Icons.attach_money),
                onChanged: (value) {
                  setState(() {
                    monthlyBurnRate = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              Text(UnivIntelLocale.of(context, "monthlyburnratedescription"), style: TextStyle(color: systemGrayColor())),
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                initialValue: financialAnnotation,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "financialannotation")),
                onChanged: (value) {
                  setState(() {
                    financialAnnotation = value;
                  });
                }
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                maxLength: 200,
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
            )
          ],
        )
      )
    );
  }

  Future<bool> saveCompany() async {
    widget.companyAnnualFinancials.annualRevenueRunRate = int.parse(annualRevenueRunRate);
    widget.companyAnnualFinancials.monthlyBurnRate = int.parse(monthlyBurnRate);
    widget.companyAnnualFinancials.financialAnnotation = financialAnnotation;
    widget.companyAnnualFinancials.revenueDriver = revenueDriver;

    var retry = await apiService.postJson("api/1/companies/updateannualfinancials", widget.companyAnnualFinancials.toJson());
    if (retry) Navigator.of(context).pop();

    return true;
  }

}
