import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/company_common.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';

class EditPortfolioPage extends StatefulWidget {
  final String companyId;

  EditPortfolioPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditPortfolioPageState();
}

class EditPortfolioPageState extends State<EditPortfolioPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController incorporationTypeController = TextEditingController();
  final TextEditingController companyStageController = TextEditingController();

  bool isLoading = true;
  String oneLinePitch = "";
  String incorporationType;
  String companyStage;
  String pitchVideoLink = "";
  CompanyCommon companyCommon;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var retry = await apiService.get("api/1/companies/common/" + widget.companyId);
    companyCommon = CompanyCommon.fromJson(retry);

    setState(() {
      oneLinePitch = companyCommon.oneLinePitch == null ? "" :  companyCommon.oneLinePitch;
      if (companyCommon.incorporationType != null) incorporationType = companyCommon.incorporationType;
      if (companyCommon.companyStage != null) companyStage = companyCommon.companyStage;
      pitchVideoLink = companyCommon.pitchVideoLink == null ? "" :  companyCommon.pitchVideoLink;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    if (incorporationType != null) {
      var incorportedTypes = getIncorporateTypes(context);
      var selectedIncorporateType = incorportedTypes.firstWhere((element) => element.id == incorporationType);
      incorporationTypeController.text = selectedIncorporateType.title;
    }

    if (companyStage != null) {
      var companyStages = getCompanyStage(context);
      var selectedCompanyStage = companyStages.firstWhere((element) => element.id == companyStage);
      companyStageController.text = selectedCompanyStage.title;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, 'investmentporfolio')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (!formKey.currentState.validate()) return;

              await saveCompany();
            },
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            formPadding(
              TextFormField(
                maxLines: 3,
                initialValue: oneLinePitch,
                decoration: textHintDecorationSeparated(UnivIntelLocale.of(context, "onelinepitchempty"), UnivIntelLocale.of(context, "onelinepitch")),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    oneLinePitch = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                onTap: () async {
                  var items = getIncorporateTypes(context);
                  var result = await showSelector(context, items, incorporationType, UnivIntelLocale.of(context, "incorporationtype"));
                  if (result == null) return;

                  incorporationType = result as String;
                  incorporationTypeController.text = items.firstWhere((a) => a.id == incorporationType).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: incorporationTypeController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "incorporationtype")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                onTap: () async {
                  var items = getCompanyStage(context);
                  var result = await showSelector(context, items, companyStage, UnivIntelLocale.of(context, "companystage"));
                  if (result == null) return;

                  companyStage = result as String;
                  companyStageController.text = items.firstWhere((a) => a.id == companyStage).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: companyStageController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "companystage")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 3,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "pitchvideolink")),
                initialValue: pitchVideoLink,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    pitchVideoLink = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              Text(
                UnivIntelLocale.of(context, "pitchvideolinkempty"),
                style: TextStyle(color: systemGrayColor())
              )
            )
          ],
        )
      )
    );
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected, String title) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: title, items: items, selectedId: selected)));
    return result;
  }

  Future<bool> saveCompany() async {
    companyCommon.oneLinePitch = oneLinePitch;
    companyCommon.incorporationType = incorporationType;
    companyCommon.companyStage = companyStage;
    companyCommon.pitchVideoLink = pitchVideoLink;

    var retry = await apiService.postJson("api/1/companies/updatecommon/" + companyCommon.id, companyCommon.toJson());
    return retry;
  }

  List<LocalSelectorItem> getIncorporateTypes(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "notincorparated", title: UnivIntelLocale.of(context, "incorparetedtypesnotincorparated")));
    result.add(LocalSelectorItem(id: "other", title: UnivIntelLocale.of(context, "incorparetedtypesother")));
    result.add(LocalSelectorItem(id: "c-corp", title: UnivIntelLocale.of(context, "incorparetedtypesc-corp")));
    result.add(LocalSelectorItem(id: "s-corp", title: UnivIntelLocale.of(context, "incorparetedtypess-corp")));
    result.add(LocalSelectorItem(id: "b-corp", title: UnivIntelLocale.of(context, "incorparetedtypesb-corp")));
    result.add(LocalSelectorItem(id: "llc", title: UnivIntelLocale.of(context, "incorparetedtypesllc")));

    return result;
  }

  List<LocalSelectorItem> getCompanyStage(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "concept", title: UnivIntelLocale.of(context, "companystageconcept")));
    result.add(LocalSelectorItem(id: "indevelopment", title: UnivIntelLocale.of(context, "companystageindevelopment")));
    result.add(LocalSelectorItem(id: "prototype", title: UnivIntelLocale.of(context, "companystageprototype")));
    result.add(LocalSelectorItem(id: "fullproduct", title: UnivIntelLocale.of(context, "companystagefullproduct")));
    result.add(LocalSelectorItem(id: "500k", title: UnivIntelLocale.of(context, "companystage500k")));
    result.add(LocalSelectorItem(id: "1m", title: UnivIntelLocale.of(context, "companystage1m")));
    result.add(LocalSelectorItem(id: "3m", title: UnivIntelLocale.of(context, "companystage3m")));
    result.add(LocalSelectorItem(id: "5m", title: UnivIntelLocale.of(context, "companystage5m")));
    result.add(LocalSelectorItem(id: "10m", title: UnivIntelLocale.of(context, "companystage10m")));
    result.add(LocalSelectorItem(id: "20m", title: UnivIntelLocale.of(context, "companystage20m")));
    result.add(LocalSelectorItem(id: "50m", title: UnivIntelLocale.of(context, "companystage50m")));
    result.add(LocalSelectorItem(id: "more50m", title: UnivIntelLocale.of(context, "companystagemore50m")));

    return result;
  }

}
