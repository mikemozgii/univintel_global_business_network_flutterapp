
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/promote.dart';
import 'package:univintel_gbn_app/validators.dart';

class EditPromotePage extends StatefulWidget {
  final Promote item;
  final String entityId;
  final DateTime endDate;
  final int days;

  EditPromotePage({Key key, this.item, this.entityId, this.days, this.endDate}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditPromotePageState();
}

class EditPromotePageState extends State<EditPromotePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");
  List<String> companiesIds = [];
  int typeId;
  String availableId;
  String minRank;
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now().add(Duration(days: 1));
  String title;

  @override
  void initState() {
    super.initState();

    setState(() {
      typeId = widget.item.typeId;
      dateStart = widget.item.id == null ? DateTime.now() : widget.item.dateStart;
      dateEnd = widget.item.id == null ? DateTime.now().add(Duration(days: widget.days > 0 ? widget.days  : 1 )) : widget.item.dateEnd;
      title = widget.item.title ?? "";
    });

  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "newpromotion")),
        actions: [
           IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (await save()) {
                  Navigator.pop(context);
                }
              })
        ]),
      body: Form(key: formKey,
        child: ListView( 
        children: [
          formPadding(TextFormField(
            initialValue: title,
            keyboardType: TextInputType.text,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "name")),
            onChanged: (value) => setState(() { title = value; }),
            validator: (value) => emptyString(value))),
          formPadding(DateTimeField(
            format: dateFormat,
            initialValue: dateStart,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "datestart")),
            readOnly: true,
            onChanged: (value){
              dateStart = value;
              //TODO: use controller
              //if(dateStart == null) dateEnd = null;
              //else setEndDate();
            },
            validator: (value) => value == null ? UnivIntelLocale.of(context, "dateismandatory") : null,
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1000),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime.now().add(new Duration(days: 365))
              );
            },
          )),
          formPadding(DateTimeField(
            format: dateFormat,
            initialValue: dateEnd,
            enabled: widget.days == 0,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "dateend")),
            readOnly: true,
            onChanged: (value) => dateEnd = value,
            validator: (value) => value == null ? UnivIntelLocale.of(context, "dateismandatory") : null,
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1000),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime.now().add(new Duration(days: 365))
              );
            },
          ))
          ])
     
    ));
  }

  void setEndDate() {
    var date = widget.days > 0 ? dateStart.add(new Duration(days: widget.days)) : dateEnd;
    date = widget.endDate != null && date.compareTo(widget.endDate) < 0 ? widget.endDate : date;
    dateEnd = date;
    //setState(() {  });
  }
  
  Future<bool> save() async {
    if (!formKey.currentState.validate()) return false;
    widget.item.title = title;
    widget.item.dateStart = DateTime(dateStart.year, dateStart.month, dateStart.day);
    widget.item.dateEnd = DateTime(dateEnd.year, dateEnd.month, dateEnd.day);
    widget.item.typeId = typeId;

    var promoteModel = {
      'item': widget.item.toJson(),
      'entityId': widget.entityId
    };
    var retry = await apiPost(
      widget.item.id == null ? "api/1/promotes/add" : "api/1/promotes/update",
      promoteModel,
      context);
    return retry;
  }
}