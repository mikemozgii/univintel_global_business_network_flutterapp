import 'package:flutter/material.dart';

class WorkingHour  {
  List<int> days;
  TimeOfDay start;
  TimeOfDay end;
  TimeOfDay dinnerStart;
  TimeOfDay dinnerEnd;
  bool isHasDinner;
  bool visible;

  WorkingHour() {
    days = new List<int>();
    start = TimeOfDay(hour: 9, minute: 0);
    end = TimeOfDay(hour: 18, minute: 0);
    dinnerStart = TimeOfDay(hour: 0, minute: 0);
    dinnerEnd = TimeOfDay(hour: 0, minute: 0);
    isHasDinner = false;
    visible = true;
  }

  WorkingHour.fromJson(Map<String, dynamic> json) {
    days = List<int>.from(json['days']);
    visible = json['visible'];
    isHasDinner = json['isHasDinner'];
    dinnerStart = TimeOfDay(hour: json['dinnerStart']['hour'], minute: json['dinnerStart']['minute']);
    dinnerEnd = TimeOfDay(hour: json['dinnerEnd']['hour'], minute: json['dinnerEnd']['minute']);
    start = TimeOfDay(hour: json['start']['hour'], minute: json['start']['minute']);
    end = TimeOfDay(hour: json['end']['hour'], minute: json['end']['minute']);
  }

  toJson() {
    return {
      'days': days,
      'visible': visible,
      'isHasDinner': isHasDinner,
      'start': {
        'hour': start.hour,
        'minute': start.minute
      },
      'end': {
        'hour': end.hour,
        'minute': end.minute
      },
      'dinnerStart': {
        'hour': dinnerStart.hour,
        'minute': dinnerStart.minute
      },
      'dinnerEnd': {
        'hour': dinnerEnd.hour,
        'minute': dinnerEnd.minute
      }
    };
  }

}