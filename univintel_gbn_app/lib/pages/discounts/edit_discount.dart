import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';
import 'package:univintel_gbn_app/globals.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/discount.dart';
import 'package:univintel_gbn_app/models/location.dart';
import 'package:univintel_gbn_app/pages/discounts/discount_locations.dart';
import 'package:univintel_gbn_app/pages/promotes/select_companies.dart';
import 'package:univintel_gbn_app/validators.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';


import 'discounts.dart';

class EditDiscountPage extends StatefulWidget {
  final Discount item;

  EditDiscountPage({Key key, this.item}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditDiscountPageState();
}

class EditDiscountPageState extends State<EditDiscountPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool onProcces = false;
  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");
  String type;
  String imageId = "";
  String title = "";
  String description = "";
  String link = "";
  String code = "";
  bool isVisible = true;
  bool reusable = false;
  List<String> selectedLocationsIds = [];
  List<String> companiesIds = [];
  String typeId;
  String minRank;
  DateTime dateEnd;
  DateTime dateStart;

  @override
  void initState() {
    super.initState();
    setState(() {
      type = widget.item.type;
      imageId = widget.item.imageId ?? "";
      title = widget.item.title ?? "";
      description = widget.item.description ?? "";
      link = widget.item.link ?? "";
      code = widget.item.code ?? "";
      isVisible = widget.item.isVisible ?? true;
      reusable = widget.item.reusable ?? false;
      minRank = widget.item.minRank.toString();
      dateEnd = widget.item.dateEnd == null ? null : widget.item.dateEnd;
      dateStart = widget.item.dateStart == null ? null :widget.item.dateStart;
      companiesIds = widget.item.onlyCompanies.length > 0 ? widget.item.onlyCompanies.split(",") : [];
    });
    getAddresses();
  }

  void getAddresses() async {
    if(widget.item.id == null) return;

    var result = await apiGetResult(
      "api/1/discounts/locations?companyid=${widget.item.companyId}&id=${widget.item.id}",
      context);

    if(result == null) return;

    setState(() { selectedLocationsIds = List<String>.from(result); });
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
                  goDiscountsPage();
                }
              })
        ]),
      body:  Form(key: formKey,
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
        formPadding( TextFormField(
          maxLines: 1,
          initialValue: title,
          keyboardType: TextInputType.text,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "title")),
          onChanged: (value) => setState(() { title = value; }),
          validator: (value) => emptyString(value))),
          type == "coupon" ? 
        formPadding(TextFormField(
            maxLines: 1,
            initialValue: code,
            keyboardType: TextInputType.number,
            decoration: textHintDecoration(UnivIntelLocale.of(context, "code")),
            onChanged: (value) => setState(() { code = value; })
        )) : Container(),
        Row(children: [
          Switch(value: isVisible, onChanged: (bool value) => setState(() { isVisible = value; }),),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(UnivIntelLocale.of(context, "visible")),
          )
        ],),
        Row(children: [
          Switch(value: reusable, onChanged: (bool value) => setState(() { reusable = value; }),),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(UnivIntelLocale.of(context, "canreused")),
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
          initialValue: description,
          keyboardType: TextInputType.text,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "description")),
          onChanged: (value) => setState(() { description = value; }),
          validator: (value) => emptyString(value))),
        formPadding(TextFormField(
          maxLines: 1,
          initialValue: link,
          keyboardType: TextInputType.url,
          decoration: textHintDecoration(UnivIntelLocale.of(context, "link")),
          onChanged: (value) => setState(() { link = value; }),
          validator: (value) => emptyString(value))), 
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text("${UnivIntelLocale.of(context, "locations")}: ${selectedLocationsIds.length}"),
            IconButton(
              icon: Icon(Icons.add_location),
              onPressed: () async => await showLocationsDialog()),
          ],),
        ),
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
        ])));
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

  void goDiscountsPage() {
    Navigator.of(context).pop(true);
    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => DiscountsPage(companyId: widget.item.companyId)));
  }

  Future editImage() async {
    final file = await getCroppedImage(cropStyle: CropStyle.rectangle);
    if(file == null) return;
    
    final logoId = await apiUploadImage(file, "discount", context);
    if (logoId.length == 0) return;
    
    setState(() {
      imageId = logoId;
    });
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

  Future<bool> save() async {
    if (!onProcces && !formKey.currentState.validate()) return false;
    onProcces = true;
    widget.item.title = title;
    widget.item.description = description;
    widget.item.link = link;
    widget.item.type = type;
    widget.item.code = code;
    widget.item.imageId = imageId;
    widget.item.addressesIds = selectedLocationsIds;
    widget.item.isVisible = isVisible;
    widget.item.reusable = reusable;
    widget.item.dateEnd = dateEnd != null ? DateTime(dateEnd.year, dateEnd.month, dateEnd.day) : null;
    widget.item.dateStart = dateStart != null ?  DateTime(dateStart.year, dateStart.month, dateStart.day) : null;
    widget.item.minRank = int.parse(minRank);
    widget.item.onlyCompanies = companiesIds.join(",");

    var retry = await apiPost(
      widget.item.id == null ? "api/1/discounts/add" : "api/1/discounts/update",
      widget.item.toJson(),
      context);
    onProcces = false;
    return retry == true;
  }
}