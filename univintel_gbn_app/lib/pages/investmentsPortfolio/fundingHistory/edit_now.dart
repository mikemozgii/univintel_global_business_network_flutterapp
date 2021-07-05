import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/funding_now.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';

class EditNowPage extends StatefulWidget {
  final CompanyFundingNow fundingNow;

  EditNowPage({Key key, this.fundingNow}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditNowPageState();
}

class EditNowPageState extends State<EditNowPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController roundController = TextEditingController();
  final TextEditingController securityTypeController = TextEditingController();
  String round = "series_seed";
  String seeking = "";
  String securityType = "preferred_equity";

  @override
  void initState() {
    super.initState();

    setState(() {
          round = widget.fundingNow.round == null ? "series_seed" :  widget.fundingNow.round;
          seeking = widget.fundingNow.seeking == null ? "" :  widget.fundingNow.seeking.toString();
          securityType = widget.fundingNow.securityType == null ? "preferred_equity" :  widget.fundingNow.securityType;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (round != null) {
      var rounds = getRounds(context);
      var selectedRole = rounds.firstWhere((element) => element.id == round);
      roundController.text = selectedRole.title;
    }
    if (securityType != null) {
      var securityTypes = getSecurityType(context);
      var selectedSecurityType = securityTypes.firstWhere((element) => element.id == securityType);
      securityTypeController.text = selectedSecurityType.title;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "onlynow")),
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
                maxLength: 200,
                initialValue: seeking,
                keyboardType: TextInputType.number,
                decoration: textInputDecoration(UnivIntelLocale.of(context, "seeking"), Icons.attach_money),
                onChanged: (value) {
                  setState(() {
                    seeking = value;
                  });
                }
              )
            ),
            formPadding(
              TextFormField(
                onTap: () async {
                  var securityTypes = getSecurityType(context);
                  var result = await showSelector(context, securityTypes, securityType, UnivIntelLocale.of(context, "securitytype"));
                  if (result == null) return;

                  securityType = result as String;
                  securityTypeController.text = securityTypes.firstWhere((a) => a.id == securityType).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: securityTypeController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "securitytype")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
          ],
        )
      )
    );
  }


  Future<bool> saveCompany() async {
    widget.fundingNow.round = round;
    widget.fundingNow.seeking = int.parse(seeking);
    widget.fundingNow.securityType = securityType;

    var retry = await apiService.postJson("api/1/companies/updatefundinghistory/", widget.fundingNow.toJson());

    if (retry) Navigator.of(context).pop();

    return retry == true;
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected, String title) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: title, items: items, selectedId: selected)));
    return result;
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

  List<LocalSelectorItem> getSecurityType(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "preferred_equity", title: UnivIntelLocale.of(context, "securitytypepreferred_equity")));
    result.add(LocalSelectorItem(id: "common_equity", title: UnivIntelLocale.of(context, "securitytypecommon_equity")));
    result.add(LocalSelectorItem(id: "convertible_note", title: UnivIntelLocale.of(context, "securitytypeconvertible_note")));

    return result;
  }

}
