import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body:  Center(child: Text("error"))
    );
   
  }
}