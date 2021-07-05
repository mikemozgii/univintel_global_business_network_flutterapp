import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/company_culture.dart';
import 'package:univintel_gbn_app/models/company_file.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/validators.dart';
import 'package:univintel_gbn_app/pages/companyCulture/root.dart';

class CompanyCulturePage extends StatefulWidget {
  final String companyId;

  CompanyCulturePage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CompanyCulturePageState();

}

class CulturePayload {
  final CompanyCulture culture;
  final CompanyFile file;

  CulturePayload({this.file, this.culture});
}

class CompanyCulturePageState extends State<CompanyCulturePage> {
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
            icon: const Icon(Icons.check),
            onPressed: () => save(),
          )
        ],
      ),
      body: renderBody(context)
    );
  }

  Future uploadImageCulture() async {
    final file = await getCroppedImage(cropStyle: CropStyle.rectangle);
    if(file == null) return;

    String id = imageFile == null ? "" : imageFile.id;
    await apiService.uploadFile(file, companyId: widget.companyId, tag: 'cultureimage', id: id );

    CompanyFile createdFile;
    if (imageFile == null) {
      var retry = await apiService.get("api/1/companies/culture/" + widget.companyId);
      createdFile = CompanyFile.fromJson(retry["cultureImage"]);
    }

    setState(() {
      if (createdFile != null) imageFile = createdFile;
      imageFileUrl = apiService.getNetworkImageFromFiles(imageFile.id, fixCache: true);
    });
  }

  Widget renderBody(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Form(
        key: formKey,
        child: ListView(
        children: [
          Column (
            children: [
              Column(
                children:[
                InkWell(
                  onTap: () async {
                  await uploadImageCulture();
                  },
                  child: Container(
                  height: 250,
                  width: 250,
                  decoration: imageFile == null ? BoxDecoration() :
                  BoxDecoration(
                    image: DecorationImage(
                    image: imageFileUrl,
                    fit: BoxFit.cover
                    )
                  ),
                  child: imageFile == null? Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.panorama, size: 100)
                  ) : Container(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                  alignment: Alignment.bottomCenter,
                    child: Text(
                    UnivIntelLocale.of(context, imageFile == null ? "taptoupload" : "taptochange"),
                    style: TextStyle(color: systemGrayColor()),
                    ),
                  ),
                )
              ],),
              formPadding(
                  TextFormField(
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    initialValue: culture,
                    decoration: textHintDecoration(UnivIntelLocale.of(context, "description")),
                    onChanged: (value) {
                      setState(() {
                        culture = value;
                      });
                    },
                    validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                  )
                ),
                formPadding(
                  TextFormField(
                    maxLines: 1,
                    keyboardType: TextInputType.url,
                    initialValue: cultureVideoLink,
                    decoration: textHintDecoration(UnivIntelLocale.of(context, "culturepresentation")),
                    onChanged: (value) {
                      setState(() {
                        cultureVideoLink = value;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) return null;

                      return incorrectUrl(value, UnivIntelLocale.of(context, "urlisincorrect"));
                    }
                  )
                )
            ],
          )
        ]
      )
    );
  }

  void save() async {
    if (!formKey.currentState.validate()) return;

    item.cultureVideoLink = cultureVideoLink;
    item.culture = culture;

    await apiService.postJson("api/1/companies/updateculture", item.toJson());

    Navigator.pop(context);
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => CompanyCultureViewPage(companyId: widget.companyId)));
  }

}
