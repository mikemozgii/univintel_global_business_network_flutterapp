import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/working_hour.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';

class WorkingHoursCardPage extends StatefulWidget {
  final WorkingHour item;
  final List<int> allowedDays;

  WorkingHoursCardPage({Key key, this.item, this.allowedDays}) : super(key: key);

  @override
  State<StatefulWidget> createState() => WorkingHoursCardPageState();
}

class WorkingHoursCardPageState extends State<WorkingHoursCardPage> {
  final GlobalKey<FormState> workingHoursFormKey = GlobalKey<FormState>();
  DateTime start;
  DateTime end;
  DateTime dinnerStart;
  DateTime dinnerEnd;
  bool visible = true;
  bool isHasDinner = false;
  List<bool> days = [false, false, false, false, false, false, false];
  bool sunday = false;
  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;
  List<String> dayTranslates = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

  @override
  void initState() {
    super.initState();

    setState(() {
      start = convertFromTime(TimeOfDay(hour: 9, minute: 0));
      end = convertFromTime(TimeOfDay(hour: 18, minute: 0));
      dinnerStart = convertFromTime(TimeOfDay(hour: 13, minute: 0));
      dinnerEnd = convertFromTime(TimeOfDay(hour: 15, minute: 0));
      if (widget.item.start != null) start = convertFromTime(widget.item.start);
      if (widget.item.end != null) end = convertFromTime(widget.item.end);
      if (widget.item.dinnerStart != null) dinnerStart = convertFromTime(widget.item.dinnerStart);
      if (widget.item.dinnerEnd != null) dinnerEnd = convertFromTime(widget.item.dinnerEnd);

      if (widget.item.visible != null) visible = widget.item.visible;
      if (widget.item.isHasDinner != null) isHasDinner = widget.item.isHasDinner;

      for (var i = 0;i < days.length; i++) {
        if (widget.item.days.contains(i)) {
          days[i] = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "workinghours")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (!workingHoursFormKey.currentState.validate()) return;
              if (days.length == 0) return;
              if (!days.any((element) => element == true)) return;

              save(context);
            },
          )
        ]
      ),
      body: Form(
        key: workingHoursFormKey,
        child: ListView(
          children: fillFields()
        )
      ),
    );
  }

  List<Widget> fillFields() {
    var result = new List<Widget>();
    result.add(
      Row(
        children: [
          Switch(
            value: visible,
            onChanged: (value) {
              setState(() {
                visible = value;
              });
            }
          ),
          Text(UnivIntelLocale.of(context, "displayworkinghourday"))
        ],
      )
    );
    result.add(
      Row(
        children: [
          Switch(
            value: isHasDinner,
            onChanged: (value) {
              setState(() {
                isHasDinner = value;
              });
            }
          ),
          Text(UnivIntelLocale.of(context, "hasdinner"))
        ],
      )
    );
    result.add(
      formPadding(
        DateTimeField(
          format: DateFormat("h:mm a"),
          initialValue: start,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "start")),
          onChanged: (value) => start = value,
          validator: (value) => value == null ? UnivIntelLocale.of(context, "requiredfield") : null,
          onShowPicker: (context, currentValue) {
            return showTimePickerAndGetDate(currentValue, context);
          },
        )
      )
    );
    result.add(
      formPadding(
        DateTimeField(
          format: DateFormat("h:mm a"),
          initialValue: end,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "end")),
          onChanged: (value) => end = value,
          validator: (value) => value == null ? UnivIntelLocale.of(context, "requiredfield") : null,
          onShowPicker: (context, currentValue) {
            return showTimePickerAndGetDate(currentValue, context);
          },
        )
      )
    );
    if (isHasDinner) {
      result.add(
        formPadding(
          DateTimeField(
            format: DateFormat("h:mm a"),
            initialValue: dinnerStart,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "dinnerstart")),
            onChanged: (value) => dinnerStart = value,
            validator: (value) => value == null ? UnivIntelLocale.of(context, "requiredfield") : null,
            onShowPicker: (context, currentValue) {
              return showTimePickerAndGetDate(currentValue, context);
            },
          )
        )
      );
      result.add(
        formPadding(
          DateTimeField(
            format: DateFormat("h:mm a"),
            initialValue: dinnerEnd,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "dinnerend")),
            onChanged: (value) => dinnerEnd = value,
            validator: (value) => value == null ? UnivIntelLocale.of(context, "requiredfield") : null,
            onShowPicker: (context, currentValue) {
              return showTimePickerAndGetDate(currentValue, context);
            },
          )
        )
      );
    }
    var iterator = 0;
    for (var day in days) {
      if (!widget.allowedDays.contains(iterator)) {
        iterator++;
        continue;
      }
      var index = iterator;
      result.add(
        Row(
          children: [
            Checkbox(
              value: day,
              onChanged: (value) {
                setState(() {
                  days[index] = value;
                });
              }
            ),
            Text(UnivIntelLocale.of(context, dayTranslates[iterator]))
          ],
        )
      );
      iterator++;
    }
    return result;
  }

  Future<DateTime> showTimePickerAndGetDate(DateTime timeInDate, BuildContext context) async {
    var time = await showTimePicker(context: context, initialTime: timeInDate != null ? convertFromDate(timeInDate) : TimeOfDay.now());
    return convertFromTime(time);
  }

  DateTime convertFromTime(TimeOfDay time) {
    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute );
  }

  TimeOfDay convertFromDate(DateTime date) {
    return TimeOfDay(hour: date.hour, minute: date.minute);
  }

  void save(BuildContext context) async {
    widget.item.isHasDinner = isHasDinner;
    widget.item.visible = visible;
    widget.item.start = convertFromDate(start);
    widget.item.end = convertFromDate(end);
    widget.item.dinnerStart = convertFromDate(dinnerStart);
    widget.item.dinnerEnd = convertFromDate(dinnerEnd);
    widget.item.days.clear();
    var iterator = 0;
    for(var day in days) {
      if (day) widget.item.days.add(iterator);

      iterator++;
    }

    Navigator.pop(context, widget.item);
  }

}
