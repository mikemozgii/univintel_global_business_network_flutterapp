import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/discount.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'edit_discount.dart';


class DiscountTypePage extends StatefulWidget {
  final String companyId;

  DiscountTypePage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => DiscountTypePageState();

}

class DiscountTypePageState extends State<DiscountTypePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

     setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(children: [
        ListTile(
          leading: Icon(Icons.local_offer, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "сreatediscount")),
          onTap: () => addItem("discount")),
        ListTile(
          leading: Icon(Icons.offline_bolt, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "createcoupon")),
          onTap: () => addItem("coupon")),
      ])
    );
  }

  void addItem(String type) {
    final emptyItem = new Discount();
    emptyItem.type = type;
    emptyItem.companyId = widget.companyId;

    final companyPage = EditDiscountPage(item: emptyItem);
    Navigator.pop(context);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }
  
}
