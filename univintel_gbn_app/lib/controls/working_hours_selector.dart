import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/working_hour.dart';
import 'package:univintel_gbn_app/controls/working_hours_selector_card.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:uuid/uuid.dart';
import 'helper_functions.dart';

class WorkingHoursPage extends StatefulWidget {
  final List<WorkingHour> workingHours;

  WorkingHoursPage({Key key, this.workingHours}): super(key: key);

  @override
  State<StatefulWidget> createState() => WorkingHoursPageState();

}

class WorkingHoursPageState extends State<WorkingHoursPage> {
  List<WorkingHour> items = new List<WorkingHour>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  List<String> dayTranslates = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

  @override
  void initState() {
    super.initState();

    items.addAll(widget.workingHours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "workinghours")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addWorkingHour(),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              Navigator.pop(context, items);
            },
          )
        ],
      ),
      body: getBody(context)
    );
  }

  List<int> getAllowedDays(WorkingHour item) {
    var existingDays = new List<int>();
    var reservedDays = new List<int>();

    if (item == null) { // "add" case
      for (var workingHour in items) reservedDays.addAll(workingHour.days);
    } else {
      for (var workingHour in items) {
        if (workingHour == item) continue;

        reservedDays.addAll(workingHour.days);
      }
    }

    for (var i = 0; i < 7; i++) if (!reservedDays.contains(i)) existingDays.add(i);

    return existingDays;
  }

  void addWorkingHour() async {
    var allowedDays = getAllowedDays(null);
    if (allowedDays.length == 0) {
      //show snackbar days limit
      return;
    }
    var result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => WorkingHoursCardPage(item: WorkingHour(), allowedDays: allowedDays)));
    if (result != null) {
      setState(() {
        items.add(result);
      });
    }
  }

  Widget fillDay(WorkingHour workingHour) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => WorkingHoursCardPage(item: workingHour, allowedDays: getAllowedDays(workingHour))));
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(2),
        decoration: listSeparatingBorder(context),
        width: MediaQuery.of(context).size.width - 4,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workingHour.start.format(context) + " - " + workingHour.end.format(context),
              style: TextStyle(
                fontSize: 16
              ),
            ),
            Text(
              getDisplayDays(workingHour.days),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: systemGrayColor()
              ),
            )
          ]
        )
      )
    );
  }

  String getDisplayDays(List<int> days) {
    var result = "";
    for (var day in days) {
      result += UnivIntelLocale.of(context, dayTranslates[day]) + " ";
    }
    return result;
  }

  Widget getBody(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: InkWell(
          onTap: () => addWorkingHour(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16),)
        )
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, int index) {
        final item = items[index];
        final onDeleteFunc = () => removeItem(index);
        return getSlidableBuilder(
          context,
          fillDay(item),
          Key(Uuid().v4()),
          null,
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      }
    );
  }

  void removeItem(int index) {
    final item =  items.elementAt(index);
    setState(() { items.removeAt(index); });
    showSnackBarToDelete(
      scaffoldKey,
      UnivIntelLocale.of(context, "canceldelete"),
      5000,
      onDelete: () {
        //don't need this because list in memory mapped to json directly.
      },
      onCancel: () {
        setState(() {
          defaultInsertItem(item, items, position: index);
        });
      }
    );
  }

}
