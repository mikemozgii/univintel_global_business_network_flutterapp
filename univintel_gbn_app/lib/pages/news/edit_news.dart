import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/models/news.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/news/news.dart';
import 'package:univintel_gbn_app/validators.dart';
import 'package:univintel_gbn_app/globals.dart';


class EditNewsPage extends StatefulWidget {
  final News news;

  EditNewsPage({Key key, this.news}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditNewsPageState();
}

class EditNewsPageState extends State<EditNewsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool visible = true;
  String link = "";
  DateTime datePublish;
  String imageId;

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.news.title != null) _titleController.text = widget.news.title;
      if (widget.news.body != null) _bodyController.text = widget.news.body;
      if (widget.news.link != null) link = widget.news.link;
      if (widget.news.imageId != null) imageId = widget.news.imageId;
      if (widget.news.datePublish != null) datePublish = widget.news.datePublish;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "news")),
        actions: [
           IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (await save()) backToList();
              })
        ]),
      body: ListView(
        children: [
          Column(
            children: [
              Column(
                children:[
                  InkWell(
                  onTap: () async {
                    await uploadImage();
                  },
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration:  imageId == null || imageId.isEmpty ? BoxDecoration() :
                    BoxDecoration(
                      image: DecorationImage(
                        image: apiService.getNetworkImageFromFiles(imageId, fixCache: true),
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
                controller: _titleController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "title")),
                validator: (value) => emptyString(value))
              ),
              formPadding(TextFormField(
                maxLines: 8,
                minLines: 4,
                controller: _bodyController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "message")),
                validator: (value) => emptyString(value))
              ),
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
                  Text(UnivIntelLocale.of(context, "shownews"))
                ],
              ),
              formPadding(
                TextFormField(
                  maxLines: 1,
                  initialValue: link,
                  keyboardType: TextInputType.url,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "link")),
                  onChanged: (String value) {
                    setState(() {
                      link = value;
                    });
                  },
                  validator: (value) {
                    var requiredMessage = emptyString(value);
                    if (requiredMessage != null) return requiredMessage;

                    return incorrectUrl(value, UnivIntelLocale.of(context, "urlisincorrect"));

                  }
                )
              ),
              formPadding(
                DateTimeField(
                  format: DateFormat("MM/dd/yyyy"),
                  initialValue: datePublish,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "datepublish")),
                  onChanged: (value) => datePublish = value,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1000),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now().add(new Duration(days: 365))
                    );
                  },
                )
              ),
              formPadding(
                widget.news.id == null ? null :
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  child: RaisedButton(
                    onPressed: () async {
                      var retry = await apiGetResult("api/1/news/delete?id=" + widget.news.id, context);
                      if (!retry) return;

                      backToList();
                    },
                    color: Colors.redAccent,
                    child: Text(
                      UnivIntelLocale.of(context, "delete"),
                      style: TextStyle(fontSize: 15)
                    ),
                  )
                )
              )
            ]
          )
        ]
      )
    );
  }

  Future uploadImage() async {
    final file = await getCroppedImage(cropStyle: CropStyle.rectangle);
    if (file == null) return;

    var fileId = await apiService.uploadFile(file, companyId: widget.news.companyId, tag: 'blogimage', id: imageId == null ? "" : imageId );

    setState(() {
      imageId = fileId;
    });
  }

  void backToList() {
    Navigator.pop(context);
    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => NewsPage(companyId: widget.news.companyId)));
  }

  Future<bool> save() async {
    widget.news.title =_titleController.text;
    widget.news.body = _bodyController.text;
    widget.news.visible = visible;
    widget.news.link = link;
    widget.news.imageId = imageId;
    widget.news.datePublish = datePublish;

    final retry = await apiService.postJson(
      widget.news.id == null ? "api/1/news/add" : "api/1/news/update",
      widget.news.toJson()
    );
      //context);

    return retry == true;
  }
}