import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/city_selector.dart';
import 'package:univintel_gbn_app/models/contact.dart';
import 'package:univintel_gbn_app/models/city_with_country.dart';
import 'package:univintel_gbn_app/pages/companyContacts/contacts.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/validators.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;

  EditContactPage({Key key, this.contact}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditContactPageState();
}

class EditContactPageState extends State<EditContactPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String name = "";
  final TextEditingController cityController = new TextEditingController();
  final TextEditingController roleController = new TextEditingController();
  String fullName = "";
  String title = "";
  String phone = "";
  String email = "";
  bool visible = true;
  bool visibleEmail = true;
  bool visiblePhone = true;
  int role = 0;
  String imageId;

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.contact.name != null) name = widget.contact.name;
      if (widget.contact.fullName != null) fullName = widget.contact.fullName;
      if (widget.contact.title != null) title = widget.contact.title;
      if (widget.contact.phone != null) phone = widget.contact.phone;
      if (widget.contact.email != null) email = widget.contact.email;
      if (widget.contact.role != null) role = widget.contact.role;
      if (widget.contact.city != null) cityController.text = widget.contact.city;
      if (widget.contact.visible != null) visible = widget.contact.visible;
      if (widget.contact.visibleEmail != null) visibleEmail = widget.contact.visibleEmail;
      if (widget.contact.imageId != null) imageId = widget.contact.imageId;
      if (widget.contact.visiblePhone != null) visiblePhone = widget.contact.visiblePhone;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (role != null) {
      var roles = getRoles(context);
      var selectedRole = roles.firstWhere((element) => element.id == role.toString());
      roleController.text = selectedRole.title;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.id == null ? UnivIntelLocale.of(context, "addcontact") : UnivIntelLocale.of(context, "editcontact")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (!formKey.currentState.validate()) return;

              await save(context);

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => ContactsPage(companyId: widget.contact.companyId)));
            },
          )
        ]
      ),
      body: Form(
        key: formKey,
        child: ListView(
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
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: fullName,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "fullname")),
                onChanged: (value) {
                  setState(() {
                    fullName = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
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
                Text(UnivIntelLocale.of(context, "displaycontact"))
              ],
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: email,
                keyboardType: TextInputType.emailAddress,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "email")),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) return UnivIntelLocale.of(context, "requiredfield");

                  return validateEmail(value);
                }
              )
            ),
            Row(
              children: [
                Switch(
                  value: visibleEmail,
                  onChanged: (value) {
                    setState(() {
                      visibleEmail = value;
                    });
                  }
                ),
                Text(UnivIntelLocale.of(context, "displaycontactemail"))
              ],
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: phone,
                keyboardType: TextInputType.phone,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "phone")),
                onChanged: (value) {
                  setState(() {
                    phone = value;
                  });
                }
              )
            ),
            Row(
              children: [
                Switch(
                  value: visiblePhone,
                  onChanged: (value) {
                    setState(() {
                      visiblePhone = value;
                    });
                  }
                ),
                Text(UnivIntelLocale.of(context, "displaycontactphone"))
              ],
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: title,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "title")),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                }
              )
            ),
            formPadding(
              TextFormField(
                onTap: () async {
                  var industries = getRoles(context);
                  var result = await showSelector(context, industries, role.toString());
                  if (result == null) return;

                  var id = result as String;
                  role = int.parse(id);
                  roleController.text = industries.firstWhere((a) => a.id == id).title;
                },
                maxLines: 1,
                readOnly: true,
                controller: roleController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "role")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
              )
            ),
            formPadding(
              TextFormField(
                onTap: () {
                  showOverlay(context);
                },
                maxLines: 1,
                readOnly: true,
                controller: cityController,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "city"))
              )
            ),
            formPadding(
              widget.contact.id == null ? null :
              RaisedButton(
                onPressed: () async {
                  var retry = await apiService.get("api/1/contacts/delete?id=" + widget.contact.id);
                  if (!retry) return;

                  Navigator.of(context).pop(); 
                  Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => ContactsPage(companyId: widget.contact.companyId)));
                },
                color: Colors.redAccent,
                child: Text(
                  UnivIntelLocale.of(context, "delete"),
                  style: TextStyle(fontSize: 15)
                ),
              )
            )
          ]
        )
      )
    );
  }

  Future uploadImage() async {
    final file = await getCroppedImage(cropStyle: CropStyle.rectangle);
    if (file == null) return;

    var fileId = await apiService.uploadFile(file, companyId: widget.contact.companyId, tag: 'contactimage', id: imageId == null ? "" : imageId );

    setState(() {
      imageId = fileId;
    });
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: UnivIntelLocale.of(context, "role"), items: items, selectedId: selected)));
    return result;
  }

  Future<bool> save(BuildContext context) async {
      widget.contact.name = name;
      widget.contact.city = cityController.value.text;
      widget.contact.fullName = fullName;
      widget.contact.title = title;
      widget.contact.phone = phone;
      widget.contact.email = email;
      widget.contact.role = role;
      widget.contact.visible = visible;
      widget.contact.visibleEmail = visibleEmail;
      widget.contact.imageId = imageId;
      widget.contact.visiblePhone = visiblePhone;

    var retry = await apiService.postJson(widget.contact.id == null ? "api/1/contacts/add" : "api/1/contacts/update", widget.contact.toJson());
    return retry == true;
  }

  void showOverlay(BuildContext context) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => CitySelector()));
    if (result == null) return;

    var model = result as CityWithCountry;
    cityController.text = model.city + ", " + model.country;
  }

  List<LocalSelectorItem> getRoles(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "0", title: UnivIntelLocale.of(context, "Team member")));
    result.add(LocalSelectorItem(id: "1", title: UnivIntelLocale.of(context, "Founder")));
    result.add(LocalSelectorItem(id: "2", title: UnivIntelLocale.of(context, "Advisor")));
    result.add(LocalSelectorItem(id: "3", title: UnivIntelLocale.of(context, "Attorney")));
    result.add(LocalSelectorItem(id: "4", title: UnivIntelLocale.of(context, "Board Member")));
    result.add(LocalSelectorItem(id: "5", title: UnivIntelLocale.of(context, "Human Resource")));

    return result;
  }

}
