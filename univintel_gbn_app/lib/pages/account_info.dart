import 'package:flutter/material.dart';

import 'account_edit_info.dart';

class AccountInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountInfoPageState();
}

class AccountInfoPageState extends State<AccountInfoPage> {
  bool _editMode = false;
  String val = "Free";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Account Info'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => AccountEditInfoPage()));
              //setState(() { _editMode = true; });
              },)
          ],
        ),
        body: Center(
            child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                "https://i.imgur.com/BoN9kdC.png")))),
                  Text("John Doe, san andreas", textScaleFactor: 1.5)
                ]),
                Padding( 
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0), 
                  child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(children: <Widget>[
                          Text("Subscription", textScaleFactor: 1.5),
                          Padding( padding: const EdgeInsets.fromLTRB(5, 0, 0, 5), child: Icon(Icons.fiber_new, color: Colors.red, size: 20.0,))
                        ]),
                        _editMode ? Row(children: <Widget>[
                           DropdownButton<String>(
                            value: val,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.white
                            ),
                            underline: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                val = newValue;
                              });
                            },
                            items: <String>['Free', 'Basic', 'Pro']
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row( children: <Widget>[Text(value), _getIcon(value)]),
                                );
                              })
                              .toList(),
                          )
                           //IconButton(icon: Icon(Icons.arrow_upward, color: Colors.green, size: 20.0), onPressed: () {}) 
                           ]
                           , mainAxisAlignment: MainAxisAlignment.end,) 
                           : SizedBox(height: 25.0)
                    ])
                ),
               

              ],
            )
          ],
        )));
  }
  
  Icon _getIcon(String val){
    if(val == "Basic") return Icon(Icons.slow_motion_video, color: Colors.yellow, size: 20.0);
    if(val == "Pro") return Icon(Icons.person_add, color: Colors.blue, size: 20.0);
    return Icon(Icons.fiber_new, color: Colors.red, size: 20.0);
  }
}
