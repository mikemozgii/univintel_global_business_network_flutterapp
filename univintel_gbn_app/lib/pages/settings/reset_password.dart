import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/localization.dart';

import '../../validators.dart';

class ResetPasswordPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ResetPasswordPageState();

}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void test(code) {
    print(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "changepassword")),
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
                if (!formKey.currentState.validate()) return;

                await apiGet(
                  "api/1/account/resetpassword?oldPassword=${passwordController.text}&newPassword=${newPasswordController.text}",
                  context,
                  scaffoldState: scaffoldkey.currentState,
                  navigateToErrorPage: true);
                  Navigator.pop(context);
            },
            )
          ],
      ),
      body: 
      Form(
        key: formKey,
        child: Column(
          children: [
            //throw 'oh no, an error',
            formPadding(
              new TextFormField(
                controller: passwordController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                obscureText: true,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "password")),
                validator: (value) => emptyString(value)
              )
            ),
            formPadding(
              new TextFormField(
                controller: newPasswordController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "newpassword")),
                validator: (value) => emptyString(value)
              )
            ),
            formPadding(
              new TextFormField(
                controller: confirmPasswordController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "confirmpassword")),
                validator: (value) {
                  if (value == newPasswordController.text) return null;

                  return UnivIntelLocale.of(context, "incorrect_data");
                }
              )
            ),
          ],
        ),
      )
    );
  }
}
