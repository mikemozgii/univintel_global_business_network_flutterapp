import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/avatar_text_box.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/contact.dart';
import 'package:univintel_gbn_app/pages/companyContacts/edit_contacts.dart';
import 'package:univintel_gbn_app/localization.dart';

class ContactsPage extends StatefulWidget {
  final String companyId;

  ContactsPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => ContactsPageState();

}

class ContactsPageState extends State<ContactsPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Contact> items = new List<Contact>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var retry = await apiService.get("api/1/contacts/all?companyid=" + widget.companyId);
    var result = new List<Contact>();
    for (var item in retry) {
      result.add(Contact.fromJson(item));
    }
    setState(() {
      items = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "contacts")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () => addContact(),
          )
        ]
      ),
      body: fillContacts(context)
    );
  }

  void addContact() {
    final emptyContact = new Contact();
    emptyContact.companyId = widget.companyId;

    final companyPage = EditContactPage(contact: emptyContact);
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }

  void removeItem(int index) {
    final item =  items.elementAt(index);
    setState(() { items.removeAt(index); });
    showSnackBarToDelete(
      scaffoldKey,
      UnivIntelLocale.of(context, "canceldelete"),
      5000,
      onDelete: () async => await apiGet("api/1/contacts/delete?id=" + item.id, context, scaffoldState: scaffoldKey.currentState),
      onCancel: () => insertItem(item, position: index)
    );
  }

  void insertItem(Contact item, {int position = -1}){
    setState(() { 
      if(position == -1 || items.length <= position) items.add(item);
      else items.insert(position, item); 
    });
  }

  Widget getItemTemplate(Contact item) {
    return InkWell(
      onTap: () {
        final itemPage = EditContactPage(contact: item);
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => itemPage));
      },
      child: 
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
          child: Container(
            decoration: listSeparatingBorder(context),
            margin: EdgeInsets.all(2),
            width: MediaQuery.of(context).size.width - 14,
            height: 80,
            child: Row (
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  child: Align(child: item.imageId != null ? AvatarBox(item.imageId , 30, isDocumentImage: true) : AvatarTextBox(item.fullName.substring(0, 2), 30))
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20)
                        ),
                        Text(
                          item.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: systemGrayColor()
                          )
                        ),
                      ]
                    )
                  )
                )
              ]
            )
          ),
        )
    );
  }

  Widget getListItems() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, int index) {
        final item = items[index];
        final onDeleteFunc = () => removeItem(index);
        return getSlidableBuilder(
          context,
          getItemTemplate(item),
          Key(item.id),
          null,
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      }
    );
  }

  Widget fillContacts(BuildContext context) {
    if (items.length == 0) {
      return Center(
        child: InkWell(
          onTap: () => addContact(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16),)
        )
      );
    }

    return getListItems();
  }

}
