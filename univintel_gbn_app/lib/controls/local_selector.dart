import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';

class LocalSelector extends StatefulWidget {
  final List<LocalSelectorItem> items;
  final String selectedId;
  final String title;

  LocalSelector({Key key, this.items, this.selectedId, this.title}): super(key: key);

  @override
  State<StatefulWidget> createState() => LocalSelectorState();

}

class LocalSelectorState extends State<LocalSelector> {
  String filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(4, 4, 4, 0) ,
        child: Column(
          children: [
            TextFormField(
              maxLines: 1,
              initialValue: filter,
              keyboardType: TextInputType.text,
              decoration: textHintDecoration(widget.title),
              onChanged: (value) {
                setState(() {
                  filter = value;
                });
              }
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 150,
                child: SingleChildScrollView(
                  child: Column(
                    children: filteringItems(widget.items).map((LocalSelectorItem record) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        color: widget.selectedId == record.id ? Theme.of(context).selectedRowColor : null,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(record.id);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: record.displayItem != null ? record.displayItem : Text(record.title, style: TextStyle(fontSize: 18))
                          )
                        )
                      );
                    }).toList()
                  )
                )
              )
            )
          ],
        )
      )
    );
  }

  List<LocalSelectorItem> filteringItems(List<LocalSelectorItem> items) {
    if (filter == null || filter.isEmpty) return items;

    return items.where((a) => a.title.toLowerCase().contains(filter.toLowerCase())).toList();
  }

}