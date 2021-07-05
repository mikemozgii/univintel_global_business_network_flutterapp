import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/pages/account_edit_info.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/localization.dart';

class ChangeLanguagePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ChangeLanguagePageState();

}

class ChangeLanguagePageState extends State<ChangeLanguagePage> {
  final ApiService apiService = new ApiService();
  String currentLanguage = 'en';

  @override
  void initState() {
    super.initState();

    getUserCompanies().then((value) => setState(() { currentLanguage = value; }));
  }

  Future<String> getUserCompanies() async {
    var retry = await apiService.get("api/1/account/information");
    return retry['language'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "changelanguage")),
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
              var retry = await apiService.get("api/1/account/changelanguage?language=" + currentLanguage);
              if (!retry) return;

              UnivIntelLocale.changeApplicationLocale(context, Locale(currentLanguage));

              Navigator.pop(context);
              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => AccountEditInfoPage()));
            },
            )
          ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('English'),
            leading: Radio(
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (String value) =>  setState(() { currentLanguage = value; })
            ),
          ),
          ListTile(
            title: Text('Русский'),
            leading: Radio(
              value: 'ru',
              groupValue: currentLanguage,
              onChanged: (String value) =>  setState(() { currentLanguage = value; })
            ),
          ),
        ],
      ),
    );
  }


}
