import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:univintel_gbn_app/localization.dart';

class SignupConfirmPage extends StatefulWidget {
  final String email;
  final Future<bool> Function(String email, String code) confirm;

  SignupConfirmPage({Key key, this.email, this.confirm}) : super(key: key);
  @override
  State<StatefulWidget> createState() => SignupConfirmPageState();
}

class SignupConfirmPageState extends State<SignupConfirmPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _success;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "securitycode")),
      ),
      body: Form(
        key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(UnivIntelLocale.of(context, "pleasecheckyouremailforsecuritycode"), style: TextStyle(fontSize: 16, color: systemGrayColor())),
              ),
              Center (
                  child: Container(
                  width: 300,
                  child: 
                  PinCodeTextField(
                    textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                    textInputType: TextInputType.number,
                    length: 6,
                    autoFocus: true, 
                    obsecureText: false,
                    animationType: AnimationType.fade,
                    shape: PinCodeFieldShape.underline,
                    animationDuration: Duration(milliseconds: 300),
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 50,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    activeColor: Theme.of(context).selectedRowColor,
                    inactiveColor: Theme.of(context).selectedRowColor,
                    fieldWidth: 40,
                    controller: _codeController,
                    
                    onCompleted: (v) async {
                      _success = await widget.confirm(widget.email, v);
                      if(!_success) {
                        _codeController.clear();
                        final snackBar = SnackBar(content: Text("Failed"), duration: Duration(seconds: 5),);
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        //currentText = value;
                      });
                    }
                  )
                )
              )
            ],
          )
        ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  
}
