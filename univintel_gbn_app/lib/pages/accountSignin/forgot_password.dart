import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/services/api.dart';

class ForgotPasswordPage extends StatefulWidget {

  @override
  State<ForgotPasswordPage> createState() => ForgotPasswordPageState();

}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ApiService _apiService = new ApiService();

  String email = "";
  Scaffold scaffoldPage;

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      obscureText: false,
      onChanged: (value) {
        email = value;
      },
      style: TextStyle(fontSize: 20.0, color: Colors.white),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    return Scaffold(
      body: Builder (
        builder: (BuildContext context) {
            return Center(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 45.0),
                      emailField,
                      SizedBox(height: 25.0),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Color(0xff01A0C7),
                        child: MaterialButton(
                          color: systemLinkColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(26.0),
                            side: BorderSide(color: systemLinkColor())
                          ),
                          minWidth: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          onPressed: () => restore(context),
                          child: Text("Reset password",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                          )
                        )
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        )
      );
  }

  void restore(BuildContext context) async {
    if (email.isEmpty) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('You do not type email!'),
          /*action: SnackBarAction(
              label: 'UNDO',
              onPressed: scaffold.hideCurrentSnackBar
          ),*/
        ),
      );
      return;
    }

    await _apiService.getWithoutSession('api/1/authentification/forgotpassword?email=' + email);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout you email'),
        /*action: SnackBarAction(
            label: 'UNDO',
            onPressed: scaffold.hideCurrentSnackBar
        ),*/
      ),
    );
 
    Navigator.pop(context);
  }
}
