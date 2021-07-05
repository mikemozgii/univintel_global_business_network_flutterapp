import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/companyEmployee/root.dart';
import 'package:univintel_gbn_app/globals.dart';
import 'change_password.dart';

class EditEmployeePage extends StatefulWidget {
  final String companyId;
  final String accountId;

  EditEmployeePage({Key key, this.companyId, this.accountId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditEmployeePageState();

}

class EditEmployeePageState extends State<EditEmployeePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String errorMessage = "";
  String firstname = "";
  String lastname = "";
  String position = "";
  String avatarId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getData();
  }
  
  void getData() async {
    var retry = await apiGetResult("api/1/companies/signleaccounts/?companyid=" + widget.companyId + "&id=" + widget.accountId, context);

    setState(() {
      firstname = retry["firstName"];
      lastname = retry["lastName"];
      position = retry["position"];
      avatarId = retry["avatarId"];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "editemployee")),
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
                FlatButton(
                  onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => ChangePasswordPage(companyId: widget.companyId, accountId: widget.accountId))),
                  color: systemLinkColor(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(UnivIntelLocale.of(context, "changepassword")),
                      )
                    ]
                  )
                ),
              ),
              formPadding(
                RaisedButton(
                  onPressed: () async {
                    var retry = await apiGetResult("api/1/companies/deleteemployee?id=" + widget.accountId + "&companyId=" + widget.companyId, context);
                    if (!retry) return;

                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => EmployeesPage(companyId: widget.companyId)));
                  },
                  color: Colors.redAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        UnivIntelLocale.of(context, "delete"),
                        style: TextStyle(fontSize: 15)
                      )
                    ]
                  )
                )
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
      avatarId = null;
    });

    var fileId = await apiService.uploadImage(file, id: avatarId == null ? "" : avatarId, type: "avatar" );

    setState(() {
      avatarId = fileId;
    });
  }

  void save(BuildContext context) async {
    if (!formKey.currentState.validate()) return;

    var url = "api/1/companies/updateemployee?id=" + widget.accountId + "&companyId=" + widget.companyId;
    url += "&firstName=" + firstname + "&lastName=" + lastname;
    url += "&position=" + position;
    if (avatarId != null) url += "&avatarId=" + avatarId;
    await apiGetResult(url, context);

    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => EmployeesPage(companyId: widget.companyId)));
  }

}
