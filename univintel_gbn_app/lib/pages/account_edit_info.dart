import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/avatar_text_box.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/models/account_info.dart';
import 'package:univintel_gbn_app/pages/settings/root.dart';
import 'package:univintel_gbn_app/pages/signin.dart';
import 'package:univintel_gbn_app/pages/signup_confirm.dart';
import 'package:univintel_gbn_app/services/api.dart';
import '../localization.dart';
import '../validators.dart';

class AccountEditInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountEditInfoPageState();
}

class AccountEditInfoPageState extends State<AccountEditInfoPage> {
  final ApiService _apiService = new ApiService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioNameController = TextEditingController();

  String currentRank = '';
  String bioText = '';

  String userAvatar = "";
  String userEmail = "";
  String userFullName = "";

  File avatar;
  bool onProcces = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getUserInfo().then((value) => updateUserInfo(value));
  }

  String getShortName(String name) {
    if (name == null || name.trim().isEmpty) return "NN";

    var parts = name.split(" ");
    if (parts.length == 2) return parts[0][0] + parts[1][0];

    return name.substring(0,2);
  }

  Widget avatarBox() {
     return userAvatar.length > 0 ? 
      AvatarBox(userAvatar, 30, onTap: () async => await avatarTap()) :
      AvatarTextBox(getShortName(userFullName), 30, onTap: () async => await avatarTap());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    double buttonFontSize = 16;
    var buttonsTextStyle = TextStyle(fontSize: buttonFontSize);

    var headerTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: systemLinkColor()
    );

    return Scaffold(
        key: scaffoldkey,
        appBar: AppBar(
          title: Text(UnivIntelLocale.of(context, "settings")),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130.0),
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.white),
              child: Container(
                height: 130.0,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      avatarBox(),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [ 
                              Padding(
                                padding: const EdgeInsets.only(top: 35.0, right: 10),
                                child: Container(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: getAccountRankDecoration(context, currentRank)
                                  )
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userFullName == null || userFullName.trim().isEmpty ? userEmail : userFullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 20)),
                                ]),
                              ])),)
                        ]
                    )
                  ),
            ),
            ),
          ),
        ),
        body: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: Text(
                        UnivIntelLocale.of(context, "account"),
                        style: headerTextStyle
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: FlatButton(
                        onPressed: ()  {
                          changeUserName();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 130,
                                child: Text(
                                  userFullName == null || userFullName.trim().isEmpty ? userEmail : userFullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: buttonFontSize)
                                )
                              ),
                              Text(UnivIntelLocale.of(context, "usernamedescription"), style: TextStyle(color: systemGrayColor()))
                            ],
                          )
                        ]
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: FlatButton(
                        onPressed: () async { 
                            await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              if (isLoading) return loadingScaffold();
                              return Scaffold(
                                appBar: AppBar(
                                actions: [
                                    IconButton(
                                    icon: Icon(Icons.done),
                                    onPressed: () async {
                                      if(emailFormKey.currentState.validate())
                                        await _changeEmail();
                                    })
                                ]),
                                body: 
                                  Form(key: emailFormKey,
                                  child:
                                    Column(
                                    children: [
                                      formPadding(
                                        new TextFormField(
                                          controller: _emailController,
                                          maxLines: 1,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: textHintDecoration(UnivIntelLocale.of(context, "email")),
                                          validator: (value) => validateEmail(value)
                                        )
                                      )
                                    ]
                                  )
                              ));
                            }
                          );    
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 130,
                                child: Text(
                                  userEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: buttonFontSize)
                                )
                              ),
                              Text(UnivIntelLocale.of(context, "emaildescription"), style: TextStyle(color: systemGrayColor()))
                            ],
                          )
                        ]
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: FlatButton(
                      onPressed: () async {
                        var result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                              actions: [
                                  IconButton(
                                  icon: Icon(Icons.done),
                                  onPressed: () {
                                    Navigator.pop(context, _bioNameController.text);
                                  })
                              ]),
                              body: Column(
                                children: [
                                  formPadding(
                                    TextFormField(
                                      maxLines: 6,
                                      minLines: 4,
                                      maxLength: 150,
                                      controller: _bioNameController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      decoration: textHintDecoration(UnivIntelLocale.of(context, "bio"))
                                    )
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
                                    child: Text(
                                      UnivIntelLocale.of(context, "biodescription"),
                                      style: TextStyle(color: systemGrayColor())
                                    )
                                  )
                                ]
                              )
                            );
                          }
                        );
                        if (result != null) {
                          setState(() {
                            bioText = result;
                          });
                          await _submit();
                        } else {
                          _bioNameController.text = bioText;
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [ Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            bioText == null || bioText.trim().isEmpty ? UnivIntelLocale.of(context, "bio") : bioText,
                            style: TextStyle(
                              fontSize: buttonFontSize
                            )
                          ),
                          Text(bioText == null || bioText.trim().isEmpty ? UnivIntelLocale.of(context, "biodescription") : UnivIntelLocale.of(context, "bio"), style: TextStyle(color: systemGrayColor()))
                        ],
                      )])
                    ),
                  ),
                  Container(
                    color: Color.fromRGBO(14, 29, 36, 1),
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: Text(
                        UnivIntelLocale.of(context, "settings"),
                        style: headerTextStyle
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FlatButton(
                          onPressed: () => changeRank(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: currentRank == "free" ? Icon(Icons.update, color: systemGrayColor()) : Icon(Icons.cancel, color: systemGrayColor()),
                              ),
                              currentRank == "free" ?
                              Text(
                                UnivIntelLocale.of(context, "upgrade_to_premium"),
                                style: buttonsTextStyle
                              ):
                              Row(children: [
                                Text(
                                UnivIntelLocale.of(context, "Cancel Premium Subscription"),
                                style: buttonsTextStyle
                              ),

                              ],)
                            ]
                          )
                        ),
                        Divider(color: Theme.of(context).dividerColor, height: 2),
                        FlatButton(
                          onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => ChangeLanguagePage())),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(Icons.language, color: systemGrayColor()),
                              ),
                              Text(
                                UnivIntelLocale.of(context, "changelanguage"),
                                style: buttonsTextStyle
                              )
                            ]
                          )
                        ),
                        Divider(color: Theme.of(context).dividerColor, height: 2),
                        FlatButton(
                          onPressed: () => signout(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(Icons.exit_to_app, color: systemGrayColor()),
                              ),
                              Text(
                                UnivIntelLocale.of(context, "signout"),
                                style: buttonsTextStyle
                              )
                            ]
                          ))
                    ],),
                  )
                ],
              )
            )
          ],
        )
      );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioNameController.dispose();
    super.dispose();
  }

  void changeUserName() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
          actions: [
              IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                Navigator.pop(context);
              })
          ]),
          body: 
            Column(
              children: [
                formPadding(
                  TextFormField(
                    decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, labelText: UnivIntelLocale.of(context, "firstname")),
                    maxLines: 1,
                    controller: _firstNameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: (value) => emptyString(value)),
                ),
                formPadding(
                  TextFormField(
                    decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, labelText: UnivIntelLocale.of(context, "lastname")),
                    maxLines: 1,
                    controller: _lastNameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) => emptyString(value))
                )
              ],
            ),
          );
      }
    );
    setState(() {
      userFullName = '${_firstNameController.text} ${_lastNameController.text}';
    });
    await _submit();
  }

  void signout() async {
    final result = await _apiService.get("api/1/authentification/signout");

    if (result) {
      final storage = new FlutterSecureStorage();
      await storage.delete(key: "api_token");

      Navigator.pop(context);

      Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (ctxt) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  Future avatarTap() async {
    final file = await getCroppedImage();
    if(file == null) return;
    
    setState(() {
      userAvatar = "";
    });

    final avatarId = await _apiService.uploadImage(file);
    if (avatarId.length == 0) return;
    
    final accountModel = AcountInfo('', '', avatarId, '');
    final response = await _apiService.postJson('api/1/account/avatar', accountModel);
    if(!response["result"]) return;
    
    final storage = new FlutterSecureStorage();
    await storage.write(key: "user_avatar", value: avatarId);
    setState(() {
      userAvatar = avatarId;
    });
    
  }

  void updateUserInfo(AcountInfo userInfo) {
    _lastNameController.text = userInfo.lastName;
    _firstNameController.text = userInfo.firstName;
    _bioNameController.text = userInfo.bio;
    final fullName = userInfo.firstName  + ' ' + userInfo.lastName;
    setState(() {
      userEmail = userInfo.email;
      userAvatar = userInfo.avatarId;
      userFullName = fullName;
      currentRank = userInfo.rankId;
      bioText =  _bioNameController.text;
    });
  }

  Future<AcountInfo> getUserInfo() async {
    final data = await apiGetResult('api/1/account/information', context);
    return AcountInfo.fromJson(data);
  }

  Future<bool> _submit() async {
    if (!onProcces && !_formKey.currentState.validate()) return false;
    onProcces = true;
    var accountInfo =
        AcountInfo(_firstNameController.text, _lastNameController.text, null, _bioNameController.text);
    if(_emailController.text.isNotEmpty)
      accountInfo.email = _emailController.text;
    try {
      await _apiService.postJson('api/1/account/edit', accountInfo);
      final storage = new FlutterSecureStorage();
      await storage.write(
          key: "user_name",
          value:  "${accountInfo.firstName} ${accountInfo.lastName}");
      if(_emailController.text.isNotEmpty) await storage.write(key: "user_email", value: accountInfo.email);
      return true;
    } catch (e) {
      return false;
    } finally {
      onProcces = false;
    }
  }

  Future _changeEmail() async {
    final res = await longProccess(() => _apiService.checkEmail(_emailController.text));
    if(res.isEmpty) {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SignupConfirmPage(email: _emailController.text, confirm: _confirm)));
    }
    else {
      Navigator.of(context).pop();
      final snackBar = SnackBar(content: Text(res));
      scaffoldkey.currentState.showSnackBar(snackBar);
      _emailController.clear();
    }
  }

  Future<bool> _confirm(String email, String code) async {
    var res = await longProccess(() => _apiService.verufyEmail(email, code));
    
    if (res) {
      await _submit();
      setState(() {
        userEmail = _emailController.text;
      });
      _emailController.clear();
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  void changeRank() async {
    var rankId = currentRank == "free" ? "premium" : "free";
    var request =  apiGetResult(
    "api/1/account/changerank?rank=$rankId",
    context);
     
    var res = await longProccess(() => request);
    if(res) {
      setState(() {
        currentRank = rankId;
      });
      final storage = new FlutterSecureStorage();
      await storage.write(
          key: "account_rank",
          value:  rankId);
    }
  }

  Future<dynamic> longProccess(Function proccess) async {
    try {
      setState(() {
        isLoading = true;
      });
      return await proccess();
    } catch(e) {

    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
