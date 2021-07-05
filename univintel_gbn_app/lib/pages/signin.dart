import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/pages/sign_up.dart';
import 'package:univintel_gbn_app/pages/signup_confirm.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:univintel_gbn_app/pages/dashboard.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/navigator.dart';
import 'package:univintel_gbn_app/validators.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final ApiService _apiService = new ApiService();
  final GlobalKey<FormState> locationFormKey = GlobalKey<FormState>();
  String login = "";
  String password = "";
  TextStyle style = TextStyle(fontSize: 20.0, color: Colors.white);
  TextStyle styleHint = TextStyle(fontSize: 15.0, color: Colors.grey);
  final scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var locale = Localizations.localeOf(context);
    var localeCode = locale.languageCode != 'en' && locale.languageCode != 'ru' ? 'en' : locale.languageCode;
    UnivIntelLocale.changeApplicationLocale(context, Locale(localeCode));

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: password.isEmpty || login.isEmpty ? Colors.grey : Color(0xff01A0C7),
      child: MaterialButton(
        color: systemLinkColor(),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(26.0),
          side: BorderSide(color: systemLinkColor())
        ),
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () => _trylogin(),
        child: Text(UnivIntelLocale.of(context,"login"),
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      key: scaffoldkey,
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 105.0,
                  child:Image.asset(
                    "assets/images/circled_u.png",
                    color: Colors.white,
                    fit: BoxFit.fitHeight
                  ),
                ),
                SizedBox(height: 15.0),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(UnivIntelLocale.of(context,"UNIVINTEL"), style: TextStyle(fontSize: 18,color: systemGrayColor())),
                          ],
                        ),
                      ),
                    ]
                ),
                SizedBox(height: 10.0),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(UnivIntelLocale.of(context,"Global Social Business Network"), style: TextStyle(fontSize: 16,color: systemGrayColor())),
                          ],
                        ),
                      ),
                    ]
                ),
                SizedBox(height: 45.0),
                Form(
                  key: locationFormKey,
                  child: TextFormField(
                    obscureText: false,
                    onChanged:  (value) => setState(() { login = value; }),
                    validator: (value) {
                      if (value.isEmpty) return UnivIntelLocale.of(context, "requiredfield");

                      return validateEmail(value);
                    },
                    style: style,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintStyle: styleHint,
                        hintText: UnivIntelLocale.of(context,"email")
                    )
                  )
                ),
                SizedBox(height: 25.0),
                SizedBox(
                  height: 15.0,
                ),
                loginButon,
                SizedBox(
                  height: 40.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,                  
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(UnivIntelLocale.of(context,"donthaveanaccountyet"), style: TextStyle(fontSize: 16,color: systemGrayColor())),
                        ],
                      ),
                    ),
                  ]
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SignUpPage()));
                    } ,
                    child: Text(
                      UnivIntelLocale.of(context,"signup"),
                      style: TextStyle(
                        color: systemLinkColor(),
                        fontSize: 16
                      ),
                    ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _trylogin() async {
    if (!locationFormKey.currentState.validate()) return;

    var res = await _apiService.trysignin(login, "en");
    if(res.isEmpty){
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SignupConfirmPage(email: login, confirm: _login)));
    }
    else {
      final snackBar = SnackBar(content: Text(res));
      scaffoldkey.currentState.showSnackBar(snackBar);
    }
  }

  Future<bool> _login(String login, String code) async {
    if(login.isEmpty) return false;
    var res = await _apiService.signin(login, code);
    if (res.isEmpty) {
      setState(() { password = ""; login = ""; });
      var userInformation = await _apiService.get('api/1/account/information');
      final storage = new FlutterSecureStorage();
      await storage.write(key: "user_email", value: userInformation["email"]);
      await storage.write(key: "user_name", value: userInformation["name"]);
      await storage.write(key: "user_avatar", value: userInformation["avatarId"]);
      await storage.write(key: "account_rank", value: userInformation["rankId"]);
      await storage.write(key: "user_isemployee", value: userInformation["isEmployee"].toString());
      if (userInformation["employeeCompanyId"] != null) await storage.write(key: "user_employeecompany", value: userInformation["employeeCompanyId"]);
      pushPage(context, DashboardPage());
      return true;
    }
    else {
      final snackBar = SnackBar(content: Text(UnivIntelLocale.of(context, res)));
      scaffoldkey.currentState.showSnackBar(snackBar);
      return false;
    }
  }
}
