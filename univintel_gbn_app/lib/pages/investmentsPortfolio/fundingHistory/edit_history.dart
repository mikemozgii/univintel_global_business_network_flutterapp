import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';
import 'package:univintel_gbn_app/models/funding_history.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/fundingHistory/root.dart';
import 'package:univintel_gbn_app/validators.dart';

class EditHistoryPage extends StatefulWidget {
  final CompanyFundingHistory fundingHistory;

  EditHistoryPage({Key key, this.fundingHistory}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditHistoryPageState();
}

class EditHistoryPageState extends State<EditHistoryPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController roundController = TextEditingController();
  String round = "series_seed";
  String capitalRaised = "0";
  DateTime closingDate;
  String investorName = "";
  String investorEmail = "";

  @override
  void initState() {
    super.initState();

    setState(() {
          round = widget.fundingHistory.round == null ? "series_seed" :  widget.fundingHistory.round;
          capitalRaised = widget.fundingHistory.capitalRaised == null ? "" :  widget.fundingHistory.capitalRaised.toString();
          closingDate = widget.fundingHistory.closingDate == null ? null :  widget.fundingHistory.closingDate;
          investorName = widget.fundingHistory.investorName == null ? "" :  widget.fundingHistory.investorName;
          investorEmail = widget.fundingHistory.investorEmail == null ? "" :  widget.fundingHistory.investorEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (round != null) {
      var rounds = getRounds(context);
      var selectedRole = rounds.firstWhere((element) => element.id == round);
      roundController.text = selectedRole.title;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "fundinground")),
        actions: [
           IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (!formKey.currentState.validate()) return;

                await save();
              })
        ]
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            formPadding(
              TextFormField(
                onTap: () async {
                  var industries = getRounds(context);
                  var result = await showSelector(context, industries, round, UnivIntelLocale.of(context, "rounds"));
                  if (result == null) return;

                  round = result as String;
                  roundController.text = industries.firstWhere((a) => a.id == round).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: roundController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "role")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                maxLength: 50,
                initialValue: capitalRaised,
                keyboardType: TextInputType.number,
                decoration: textInputDecoration(UnivIntelLocale.of(context, "capitalraised"), Icons.attach_money),
                onChanged: (value) {
                  setState(() {
                    capitalRaised = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              DateTimeField(
                format: DateFormat("MM/dd/yyyy"),
                initialValue: closingDate,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "founded")),
                onChanged: (value) => closingDate = value,
                validator: (value) => value == null ? UnivIntelLocale.of(context, "requiredfield") : null,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1000),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime.now().add(new Duration(days: 365))
                  );
                },
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                maxLength: 50,
                initialValue: investorName,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "investorname")),
                onChanged: (value) {
                  setState(() {
                    investorName = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                maxLength: 50,
                initialValue: investorEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "investoremail")),
                onChanged: (value) {
                  setState(() {
                    investorEmail = value;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) return UnivIntelLocale.of(context, "requiredfield");

                  return validateEmail(value);
                }
              )
            ),
            formPadding(
              widget.fundingHistory.id == null ? null :
              RaisedButton(
                onPressed: () async {
                  var retry = await apiGetResult("api/1/companies/deletefundinghistory/?companyId=" + widget.fundingHistory.companyId + "&id=" + widget.fundingHistory.id, context);
                  if (!retry) return;

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => FundingHistoryPage(companyId: widget.fundingHistory.companyId)));
                },
                color: Colors.redAccent,
                child: Text(
                  UnivIntelLocale.of(context, "delete"),
                  style: TextStyle(fontSize: 15)
                ),
              )
            )            
          ]
        )
      )
    );
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected, String title) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: title, items: items, selectedId: selected)));
    return result;
  }

  Future<bool> save() async {
    widget.fundingHistory.round = round;
    widget.fundingHistory.capitalRaised = int.parse(capitalRaised);
    widget.fundingHistory.closingDate = closingDate;
    widget.fundingHistory.investorEmail = investorEmail;
    widget.fundingHistory.investorName = investorName;

    var retry = await apiService.postJson("api/1/companies/addorupdatefundinghistory/", widget.fundingHistory.toJson());

    if (retry) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => FundingHistoryPage(companyId: widget.fundingHistory.companyId)));
    }

    return retry == true;
  }

    List<LocalSelectorItem> getRounds(BuildContext context) {
    var result = new List<LocalSelectorItem>();
    //Hided but may be need in future
    /*result.add(LocalSelectorItem(id: "founder", title: UnivIntelLocale.of(context, "roundfounder")));
    result.add(LocalSelectorItem(id: "friends_and_family", title: UnivIntelLocale.of(context, "roundfriends_and_family")));*/
    result.add(LocalSelectorItem(id: "series_seed", title: UnivIntelLocale.of(context, "roundseries_seed")));
    result.add(LocalSelectorItem(id: "series_a", title: UnivIntelLocale.of(context, "roundseries_a")));
    result.add(LocalSelectorItem(id: "series_b", title: UnivIntelLocale.of(context, "roundseries_b")));
    result.add(LocalSelectorItem(id: "series_c", title: UnivIntelLocale.of(context, "roundseries_c")));
    result.add(LocalSelectorItem(id: "other", title: UnivIntelLocale.of(context, "roundother")));

    return result;
  }


}
