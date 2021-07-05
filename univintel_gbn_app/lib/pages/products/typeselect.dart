import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/product.dart';

import 'edit_product.dart';


class ProductTypePage extends StatefulWidget {
  final String companyId;

  ProductTypePage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => ProductTypePageState();

}

class ProductTypePageState extends State<ProductTypePage> {
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
          title: Text(UnivIntelLocale.of(context, "createproduct")),
          onTap: () => addItem("product")),
        ListTile(
          leading: Icon(Icons.offline_bolt, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "createservice")),
          onTap: () => addItem("service")),
      ])
    );
  }

  void addItem(String type) {
    final emptyItem = new Product();
    emptyItem.type = type;
    emptyItem.currentPrice = 1;
    emptyItem.price = 1;
    emptyItem.companyId = widget.companyId;

    final companyPage = EditProductPage(item: emptyItem);
    Navigator.pop(context);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }
  
}
