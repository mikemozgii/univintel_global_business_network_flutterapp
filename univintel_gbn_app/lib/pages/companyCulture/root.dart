import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/company_culture.dart';
import 'package:univintel_gbn_app/models/company_file.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/companyCulture/edit_culture.dart';

class CompanyCultureViewPage extends StatefulWidget {
  final String companyId;

  CompanyCultureViewPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CompanyCultureViewPageState();

}

class CompanyCultureViewPageState extends State<CompanyCultureViewPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ApiService apiService = new ApiService();
  CompanyCulture item = new CompanyCulture();
  CompanyFile imageFile;
  NetworkImage imageFileUrl;
  bool isLoading = true;
  String culture = "";
  String cultureVideoLink = "";

  @override
  void initState() {
    super.initState();

    refreshData();
  }

  void refreshData() async {
    var retry = await apiService.get("api/1/companies/culture/" + widget.companyId);

    var payload =  CulturePayload(culture: CompanyCulture.fromJson(retry["culture"]), file: retry["cultureImage"] != null ? CompanyFile.fromJson(retry["cultureImage"]) : null );
    if (payload.file != null) imageFileUrl = apiService.getNetworkImageFromFiles(payload.file.id, fixCache: true);

    setState(() {
      item = payload.culture;
      culture = payload.culture.culture;
      cultureVideoLink = payload.culture.cultureVideoLink;
      imageFile = payload.file;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "culture")),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => {
              Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => CompanyCulturePage(companyId: widget.companyId)))
            },
          )
        ],
      ),
      body: renderBody(context)
    );
  }

  Widget renderBody(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Form(
        key: formKey,
        child: ListView(
        children: [
          Column (
            children: [
              imageFile == null ?
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 230,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.panorama, size: 100)
                      )
                    ]
                  )
                )
              : Container(
                width: MediaQuery.of(context).size.width,
                height: 230,
                decoration: new BoxDecoration(
                  image: DecorationImage(
                    image: imageFileUrl,
                    fit: BoxFit.cover
                  )
                )
              ),
              formPaddingWithVisible(
                Row(children: [Text(culture != null ? culture : "")]),
                culture != null
              ),
              formPaddingWithVisible(
                Text(cultureVideoLink != null ? cultureVideoLink : ""),
                cultureVideoLink != null
              )
            ],
          )
        ]
      )
    );
  }

}
