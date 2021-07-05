import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/validators.dart';
import 'package:univintel_gbn_app/pages/companyEmployee/root.dart';
import 'package:univintel_gbn_app/globals.dart';

class CreateEmployeePage extends StatefulWidget {
  final String companyId;

  CreateEmployeePage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateEmployeePageState();

}

class CreateEmployeePageState extends State<CreateEmployeePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String errorMessage = "";
  String email = "";
  String firstname = "";
  String lastname = "";
  String position = "";
  String avatarId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "addemployee")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => save(context),
          )
        ],
      ),
      body: renderBody(context)
    );
  }

  Widget renderBody(BuildContext context) {

    return Form(
        key: formKey,
        child: ListView(
        children: [
          Column (
            children: [
              avatarId == null ?
                InkWell(
                  onTap: () async => await uploadImage(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 230,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.account_circle, size: 100)
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.edit)
                          )
                        ),
                      ]
                    )
                  )
                )
              : InkWell(
                onTap: () async {
                  await uploadImage();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 230,
                  decoration: new BoxDecoration(
                    image: DecorationImage(
                      image: apiService.getNetworkImage(avatarId),
                      fit: BoxFit.cover
                    )
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.edit)
                    )
                  )
                )
              ),
              formPadding(
                TextFormField(
                  maxLines: 1,
                  maxLength: 200,
                  keyboardType: TextInputType.text,
                  initialValue: email,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "email")),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) return UnivIntelLocale.of(context, "requiredfield");

                    return validateEmail(value);
                  }
                )
              ),
              formPadding(
                TextFormField(
                  maxLines: 1,
                  maxLength: 120,
                  keyboardType: TextInputType.text,
                  initialValue: firstname,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "firstname")),
                  onChanged: (value) {
                    setState(() {
                      firstname = value;
                    });
                  },
                  validator: (value) {
                    return value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null;
                  }
                )
              ),
              formPadding(
                TextFormField(
                  maxLines: 1,
                  maxLength: 120,
                  keyboardType: TextInputType.text,
                  initialValue: lastname,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "lastname")),
                  onChanged: (value) {
                    setState(() {
                      lastname = value;
                    });
                  },
                  validator: (value) {
                    return value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null;
                  }
                )
              ),
              formPadding(
                TextFormField(
                  maxLines: 1,
                  maxLength: 100,
                  keyboardType: TextInputType.text,
                  initialValue: position,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "title")),
                  onChanged: (value) {
                    setState(() {
                      position = value;
                    });
                  },
                  validator: (value) {
                    return value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null;
                  }
                )
              ),
              formPadding(
                Text(errorMessage, style: TextStyle(color: Colors.red))
              )
            ],
          )
        ]
      )
    );
  }

  Future uploadImage() async {
    final file = await getCroppedImage();
    if (file == null) return;

    setState(() {
      avatarId = "";
    });

    var fileId = await apiService.uploadImage(file, id: avatarId == null ? "" : avatarId, type: "avatar" );

    setState(() {
      avatarId = fileId;
    });
  }

  void save(BuildContext context) async {
    if (!formKey.currentState.validate()) return;

    var url = "api/1/companies/signupemployee?email=" + email + "&companyId=" + widget.companyId.toString();
    url += "&firstName=" + firstname + "&lastName=" + lastname;
    url += "&position=" + position;
    if (avatarId != null) url += "&avatarId=" + avatarId;
    var response = await apiGetResult(url, context);
    var responseErrorMessage = response["error"].toString();

    if (responseErrorMessage.isEmpty) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => EmployeesPage(companyId: widget.companyId)));
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(milliseconds: 2000),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(responseErrorMessage),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()
            )
          ],
        ),
        )
      );
    }
  }

}
