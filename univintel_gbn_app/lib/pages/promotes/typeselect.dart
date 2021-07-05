import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/promote.dart';
import 'package:univintel_gbn_app/models/promote_type.dart';
import 'package:univintel_gbn_app/pages/promotes/edit_promote.dart';


class PromoteTypePage extends StatefulWidget {
  final String companyId;
  final String entinyTypeId;
  final String entinyId;
  final DateTime endDate;

  PromoteTypePage({Key key, this.companyId, this.entinyTypeId, this.endDate, this.entinyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => PromoteTypePageState();

}

class PromoteTypePageState extends State<PromoteTypePage> {
  bool isLoading = true;
  List<PromoteType> items = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final result = await apiGetResult(
      "api/1/promotes/types",
      context);

    setState(() {
      items = List<PromoteType>.from(result.map((map) => PromoteType.fromJson(map)));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
      ),
      body: ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, int index) {
        final item = items[index];
        return ListTile(
          leading: Icon(Icons.local_offer, color: systemGrayColor()),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(UnivIntelLocale.of(context, item.name), style: TextStyle(color: getColor(item.color)),),
              Text("\$${item.price}")
            ],),
          subtitle: Text(UnivIntelLocale.of(context, item.description)),
          onTap: () => addItem(item));
      })
    );
  }

  Color getColor(String color) {
    switch(color) {
      case 'gold': return Colors.yellow;
      case 'silver': return Colors.grey;
      default : return Colors.white;
    }
  }

  void addItem(PromoteType type) {
    final emptyItem = new Promote();
    emptyItem.companyId = widget.companyId;
    emptyItem.typeId = type.id;
    emptyItem.itemTypeId = widget.entinyTypeId;
    final companyPage = EditPromotePage(item: emptyItem, entityId: widget.entinyId, days: type.days, endDate: widget.endDate,);
    Navigator.pop(context);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }
  
}
