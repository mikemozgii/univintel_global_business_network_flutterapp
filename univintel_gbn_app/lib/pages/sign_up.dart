import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/pages/signin.dart';
import 'package:univintel_gbn_app/pages/signup_confirm.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/services/models/signup.dart';
import '../validators.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final ApiService _apiService = new ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      key: scaffoldkey,
      body: Form(
        key: _formKey,
        child: ListView (
          children: <Widget>[
            formPadding(
              new TextFormField(
                controller: _emailController,
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                decoration: textHintDecoration('Email'),
                validator: (value) => validateEmail(value)
              )
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _register();
                  }
                },
                child: const Text('Continue'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //Example code for registration.
  void _register() async {
    var model = new Signup(email: _emailController.text, timeZone: 'Europe/Moscow');
    var res = await _apiService.signup(model);
    if(res.isEmpty)
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SignupConfirmPage(email: model.email, confirm: _confirm)));
    else {
      final snackBar = SnackBar(content: Text(res));
      scaffoldkey.currentState.showSnackBar(snackBar);
    }
  }

  Future<bool> _confirm(String email, String code) async {
    var res = await _apiService.verufyEmail(email, code); 
    if (res) {
      Navigator.pop(context);
      Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => LoginPage()));
      return true;
    }
    return false;
  }
}
