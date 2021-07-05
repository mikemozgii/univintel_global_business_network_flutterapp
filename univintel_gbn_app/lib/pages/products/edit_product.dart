import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/globals.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/location.dart';
import 'package:univintel_gbn_app/models/product.dart';
import 'package:univintel_gbn_app/pages/discounts/discount_locations.dart';
import 'package:univintel_gbn_app/pages/products/products.dart';
import 'package:univintel_gbn_app/pages/promotes/select_companies.dart';
import 'package:univintel_gbn_app/validators.dart';

class EditProductPage extends StatefulWidget {
  final Product item;

  EditProductPage({Key key, this.item}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditProductPageState();
}

class EditProductPageState extends State<EditProductPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController upcController = TextEditingController();
  final TextEditingController priceCurrentController = TextEditingController();
  

  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");
  String type;
  bool isVisible = true;
  bool free = false;
  String imageId = "";
  List<String> selectedLocationsIds = [];
  List<String> companiesIds = [];
  String typeId;
  String minRank;
  DateTime dateEnd;
  DateTime dateStart;

  String discount;


  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title ?? "";
    descriptionController.text = widget.item.description ?? "";
    linkController.text = widget.item.link ?? "";
    upcController.text = widget.item.upc ?? "";
    priceCurrentController.text = widget.item.currentPrice.toString();
    priceController.text = widget.item.price.toString();
    priceController.addListener(() {
      setState(() {  discount = calculateDiscount(); });
    });
    priceCurrentController.addListener(() {
      setState(() {  discount = calculateDiscount(); });
    });

    setState(() {
      type = widget.item.type;
      free = double.tryParse(priceController.text) == 0;
      isVisible = widget.item.isVisible  ?? true;
      minRank = widget.item.minRank.toString() ?? "0";
      dateEnd = widget.item.dateEnd == null ? null : widget.item.dateEnd;
      dateStart = widget.item.dateStart == null ? null :widget.item.dateStart;
      companiesIds = widget.item.onlyCompanies.length > 0 ? widget.item.onlyCompanies.split(",") : [];
      imageId = widget.item.imageId;
      discount = calculateDiscount();
    });

    getAddresses();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    upcController.dispose();
    priceController.dispose();
    priceCurrentController.dispose();
    super.dispose();
  }

  void getAddresses() async {
    if(widget.item.id == null) return;

    var result = await apiGetResult(
      "api/1/products/locations?companyid=${widget.item.companyId}&id=${widget.item.id}",
      context);

    if(result == null) return;

    setState(() { selectedLocationsIds = List<String>.from(result); });
  }

  String calculateDiscount() {
    if(priceController.text.isEmpty || priceCurrentController.text.isEmpty) return "0";
    final price = double.parse(priceController.text);
    final priceCurrent = double.parse(priceCurrentController.text);
    return priceCurrent > 0 && price > 0 ? (100 - priceCurrent / price * 100).toString() : "0";
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "${widget.item.id == null ? "new" : ""}$type")),
        actions: [
           IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (await save()) {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => ProductsPage(companyId: widget.item.companyId)));
                }
              })
        ]),
      body: Form(key: formKey,
        child: ListView( 
        children: [
          Column(
            children:[
              InkWell(
              onTap: () async {
                await editImage();
              },
              child: Container(
                height: 250,
                width: 250,
                decoration:  imageId == null || imageId.isEmpty ? BoxDecoration() :
                BoxDecoration(
                  image: DecorationImage(
                    image: apiService.getNetworkImage(imageId),
                    fit: BoxFit.cover
                  )
                ),
                child: imageId == null || imageId.isEmpty ? Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.panorama, size: 100)
                ) : Container(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                  child: Text(
                    UnivIntelLocale.of(context, imageId == null || imageId.isEmpty ? "taptoupload" : "taptochange"),
                    style: TextStyle(color: systemGrayColor()),
                  ),
              ),
            )
          ],),
        formPadding(TextFormField(
          maxLines: 1,
          controller: titleController,
          keyboardType: TextInputType.text,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "title")),
          validator: (value) => emptyString(value))),
        Row(children: [
          Switch(value: free, onChanged: (bool value) => setState(() { free = value; priceCurrentController.text = "0"; priceController.text = "0"; })),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(UnivIntelLocale.of(context, "free")),
          )
        ],),
        if(!free)
          formPadding(TextFormField(
            maxLines: 1,
            controller: priceController,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r'^(0|([1-9][0-9]{0,99}))(\.[0-9]{0,2})?'))
            ],
            keyboardType: TextInputType.number,
            decoration: textInputDecoration(UnivIntelLocale.of(context, "originalprice"), Icons.attach_money),
            validator: (value) => validateCurency(value))),
        if(!free)
          formPadding(TextFormField(
            maxLines: 1,
            controller: priceCurrentController,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r'^(0|([1-9][0-9]{0,99}))(\.[0-9]{0,2})?'))
            ],
            keyboardType: TextInputType.number,
            decoration: textInputDecoration(UnivIntelLocale.of(context, "currentprice"), Icons.attach_money),
            validator: (value) => validateCurency(value))),
        if(!free)
          formPadding(
            Text("${UnivIntelLocale.of(context, "discount")} $discount%")
          ),
        Row(children: [
          Switch(value: isVisible, onChanged: (bool value) => setState(() { isVisible = value; }),),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(UnivIntelLocale.of(context, "visible")),
          )
        ],),
        formPadding(DateTimeField(
          format: dateFormat,
          initialValue: dateStart,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "datestart")),
          onChanged: (value) => dateStart = value,
          readOnly: true,
          validator: (value) => value != null && dateEnd != null && value.isAfter(dateEnd) ? UnivIntelLocale.of(context, "incorrectdate") : null,
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
          decoration: textHintDecoration(UnivIntelLocale.of(context, "dateend")),
          onChanged: (value) => dateEnd = value,
          readOnly: true,
          validator: (value) => value != null && dateStart != null && value.isBefore(dateStart) ? UnivIntelLocale.of(context, "incorrectdate") : null,
          onShowPicker: (context, currentValue) {
            return showDatePicker(
                context: context,
                firstDate: DateTime(1000),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime.now().add(new Duration(days: 365))
            );
          },
        )),
        formPadding(TextFormField(
          maxLines: 8,
          minLines: 4,
          controller: descriptionController,
          keyboardType: TextInputType.text,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "description")),
          validator: (value) => emptyString(value))),
        formPadding(TextFormField(
          maxLines: 1,
          controller: linkController,
          keyboardType: TextInputType.url,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "link")),
          validator: (value) => emptyString(value))), 
        type == "product" ? formPadding(TextFormField(
          maxLines: 1,
          controller: upcController,
          keyboardType: TextInputType.number,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "upc")),
          validator: (value) => emptyString(value))) : Container(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text("${UnivIntelLocale.of(context, "locations")}: ${selectedLocationsIds.length}"),
            IconButton(
              icon: Icon(Icons.add_location),
              onPressed: () async => await showLocationsDialog()),
          ])),
          formPadding(TextFormField(
            initialValue: minRank,
            keyboardType: TextInputType.number,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "forcomapnieswithminimumrankorhigher")),
            onChanged: (value) => setState(() { minRank = value; }),
            validator: (value) => emptyString(value))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("${UnivIntelLocale.of(context, "additionalcompanies")}: ${companiesIds.length}"),
              IconButton(
              icon: Icon(Icons.business),
              onPressed: () async => await showCompaniesDialog())
            ]))
        ])
     
    ));
  }

  showCompaniesDialog() async {
    final suggestions = mapCompanies(await apiPost('api/1/companies/globalfilter', { 'ids': companiesIds }, context), Theme.of(context).appBarTheme.color);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return  MultiSelectItems(
          new InputDecoration( hintText: "${UnivIntelLocale.of(context, "companies")}:"),
          companiesIds,
          UnivIntelLocale.of(context, "selectcompanies"),
          suggestions,
          (value) async { return mapCompanies(await apiPost('api/1/companies/globalfilter', { 'name': value }, context), Theme.of(context).appBarTheme.color);} 
        );
      });

    if(result != null) {
      setState(() { companiesIds = result.map((id) => id.toString()).toList(); });
    }
  }

  Future editImage() async {
    final file = await getCroppedImage(cropStyle: CropStyle.rectangle);
    if(file == null) return;
    
    final logoId = await apiUploadImage(file, "product", context);
    if (logoId.length == 0) return;
    
    setState(() {
      imageId = logoId;
    });
  }

  showLocationsDialog() async {
    final result = await showDialog<List<Location>>(
      context: context,
      builder: (BuildContext context) {
        return  MultiSelectLocations(widget.item.companyId, selectedLocationsIds);
      });

    if(result != null) {
      setState(() { selectedLocationsIds = result.map((location) => location.id.toString()).toList(); });
    }
  }
  
  Future<bool> save() async {
    if (!formKey.currentState.validate()) return false;
    widget.item.title =titleController.text;
    widget.item.description = descriptionController.text;
    widget.item.price = free ? 0 : double.parse(priceController.text);
    widget.item.currentPrice = free ? 0 : double.parse(priceCurrentController.text);
    widget.item.link = linkController.text;
    widget.item.type = type;
    widget.item.imageId = imageId;
    widget.item.isVisible = isVisible;
    if(type == "product") widget.item.upc = upcController.text;
    widget.item.addressesIds = selectedLocationsIds;
    widget.item.minRank = int.parse(minRank);
    widget.item.onlyCompanies = companiesIds.join(",");
    widget.item.dateEnd = dateEnd != null ? DateTime(dateEnd.year, dateEnd.month, dateEnd.day) : null;
    widget.item.dateStart = dateStart != null ?  DateTime(dateStart.year, dateStart.month, dateStart.day) : null;
    
    var retry = await apiPost(
      widget.item.id == null ? "api/1/products/add" : "api/1/products/update",
      widget.item.toJson(),
      context);
    return retry == true;
  }
}