import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/localization.dart';

import '../../validators.dart';

class ChangePasswordPage extends StatefulWidget {
  final String companyId;
  final String accountId;

  ChangePasswordPage({Key key, this.companyId, this.accountId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChangePasswordPageState();

}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "changepassword")),
        actions: [
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
                if (!formKey.currentState.validate()) return;

                await apiGet(
                  "api/1/companies/changepassword?companyId=${widget.companyId}&id=${widget.accountId}&password=${passwordController.text}",
                  context,
                  scaffoldState: scaffoldkey.currentState,
                  navigateToErrorPage: true
                );

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
            formPadding(
              new TextFormField(
                controller: passwordController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                obscureText: true,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "newpassword")),
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
                decoration: textHintDecoration(UnivIntelLocale.of(context, "confirmpassword")),
                validator: (value) {
                  var requiredRule = emptyString(value);
                  if (requiredRule != null) return requiredRule;

                  if (value != passwordController.text) return "Password don't match";

                  return null;
                }
              )
            ),
          ],
        ),
      )
    );
  }
}
