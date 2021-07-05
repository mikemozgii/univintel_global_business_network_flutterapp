import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/pages/error_page.dart';
import 'package:univintel_gbn_app/pages/promotes/select_companies.dart';
import 'package:univintel_gbn_app/pages/signin.dart';
import '../services/api_exception.dart';
import '../globals.dart' as globals;

Widget notHaveItemsMessage(String message) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(message)
    ],
  );
}

void showSnackBarToDelete(GlobalKey<ScaffoldState> scaffoldKey, String text, int duration, {Function onDelete, Function onCancel}) {
  final snackBar = SnackBar(
    duration: Duration(milliseconds: duration),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        IconButton(
          icon: Icon(Icons.rotate_left),
          onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()
        )
      ],
    ),
  );
    
  scaffoldKey.currentState.showSnackBar(snackBar)
  .closed
  .then((reason) {
    if (reason == SnackBarClosedReason.timeout) {
      onDelete();
    } else {
      onCancel();
    }
  });
}

Future<dynamic> apiGetResult(String url, BuildContext context, {ScaffoldState scaffoldState, bool navigateToErrorPage = true}) async {
  return await handleApiException(
    () => globals.apiService.get(url),
    context,
    scaffoldState,
    navigateToErrorPage
  );
}

Future apiGet(String url, BuildContext context, {ScaffoldState scaffoldState, bool navigateToErrorPage = true}) async {
  await handleApiException(
    () => globals.apiService.getWithoutResult(url),
    context,
    scaffoldState,
    navigateToErrorPage
  );
}

Future<dynamic> apiPost(String url, dynamic model, BuildContext context, {ScaffoldState scaffoldState, bool navigateToErrorPage = true}) async{
  return await handleApiException(
    () => globals.apiService.post(url, model),
    context,
    scaffoldState,
    navigateToErrorPage
  );
}

Future<String> apiUploadImage(File file, String imageType, BuildContext context, {ScaffoldState scaffoldState, bool navigateToErrorPage = true}) async{
  return await handleApiException(
    () => globals.apiService.uploadImage(file, type: imageType),
    context,
    scaffoldState,
    navigateToErrorPage
  );
}

Future<dynamic> handleApiException(Function apiRequest, BuildContext context, ScaffoldState scaffoldState, bool navigateToErrorPage) async {
  try {
    return await apiRequest();
  } on ApiException catch(e) {
    final code = e.getCode();
    if (scaffoldState != null) {
      var message = "";
      switch (code) {
        case 401: message = "expired"; break;
        case 400: message = e.getMessage(); break;
        default: message = "error";
      }

      final snackBar = SnackBar(content: Text(message));
      scaffoldState.showSnackBar(snackBar);
    }
    if(code == 401) {
      final storage = new FlutterSecureStorage();
      await storage.delete(key: "api_token");
      Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (ctxt) => LoginPage()), (Route<dynamic> route) => false);
    } else {
      if(navigateToErrorPage) Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => ErrorPage()));
    }
    throw Exception();
  } catch(e) {
    if(navigateToErrorPage) Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => ErrorPage()));
    throw Exception();
  }
}

List<SelectItem> mapCompanies(dynamic data, Color color){
    var res = List<SelectItem>();
    for(var item in data) {
      final company = Company.fromJson(item);
      res.add(SelectItem(company.id, company.name, company.name + company.description)
      ..widget = Container(
        color: color,
        child: ListTile(title: Text(company.name))) 
      );
    }
    return res;
  }
