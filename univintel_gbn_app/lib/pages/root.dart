import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:univintel_gbn_app/pages/dashboard.dart';
import 'package:univintel_gbn_app/pages/signin.dart';
import 'package:univintel_gbn_app/globals.dart';

class RootPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {

  @override
  void initState() {
    super.initState();

    getApiToken().then((value) => updateToken(value));
    
  }

  void updateToken(String token) {
    setState(() {
      if (token != null && token.length > 0) {
        setCurrentUserToken(token);
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => DashboardPage()));
      } else {
        resetCurrentUserToken();
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (ctxt) => LoginPage()));
      }
    });
  }

  Future<String> getApiToken() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: "api_token");
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [CircularProgressIndicator()]
    );
  }
}