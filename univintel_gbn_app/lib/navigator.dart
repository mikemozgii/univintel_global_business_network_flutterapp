import 'package:flutter/material.dart';

void pushPage(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => page), (Route<dynamic> route) => false);
  }