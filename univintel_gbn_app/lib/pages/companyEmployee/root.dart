import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/controls/avatar_text_box.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/employee_account.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/companyEmployee/create_employee.dart';
import 'package:univintel_gbn_app/pages/companyEmployee/edit_employee.dart';

class EmployeesPage extends StatefulWidget {
  final String companyId;

  EmployeesPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => EmployeesPageState();

}

class EmployeesPageState extends State<EmployeesPage> {
  final ApiService apiService = new ApiService();
  List<EmployeeAccount> items = new List<EmployeeAccount>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var retry = await apiService.get("api/1/companies/allaccounts/?companyid=" + widget.companyId);

    setState(() {
      items = List<EmployeeAccount>.from(retry.map((map) => EmployeeAccount.fromJson(map)));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "employeespage")),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addEmployee()
          )
        ]
      ),
      body: fillItems(context)
    );
  }

  void addEmployee() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => CreateEmployeePage(companyId: widget.companyId)));
  }

  String getShortName(String fullName) {
    if (fullName == " ") return "NN";

    var parts = fullName.split(" "); 

    return parts[0][0] + parts[1][0];
  }

  Widget getItemTemplate(EmployeeAccount item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditEmployeePage(companyId: widget.companyId, accountId: item.id)));
      },
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        decoration: listSeparatingBorder(context),
        width: MediaQuery.of(context).size.width - 4,
        height: 80,
        child: Row (
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 60,
              height: 60,
              child: Align(child: item.avatarId != null ? AvatarBox(item.avatarId , 30) : AvatarTextBox(getShortName(item.name), 30))
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Text(item.email, style: TextStyle(fontSize: 20))
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: systemGrayColor()
                        )
                      )
                    )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  void removeItem(int index) {
    final item =  items.elementAt(index);
    setState(() { items.removeAt(index); });
    showSnackBarToDelete(
      scaffoldKey,
      UnivIntelLocale.of(context, "canceldelete"),
      5000,
      onDelete: () async => await apiGet("api/1/companies/deleteemployee?id=" + item.id + "&companyId=" + widget.companyId, context, scaffoldState: scaffoldKey.currentState),
      onCancel: () {
        setState(() {
          defaultInsertItem(item, items, position: index);
        });
      }
    );
  }

  Widget fillItems(BuildContext context) {
    if (items.length == 0) {
      return Center(
        child: InkWell(
          onTap: () => addEmployee(),
          child: Text("+ " + UnivIntelLocale.of(context, "add"), style: TextStyle(color: systemLinkColor(), fontSize: 16))
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
          getItemTemplate(item),
          Key(item.id),
          null,
          getDefaultDeleteSlideAction(onDeleteFunc),
          getOnWillDeleteDismiss(onDeleteFunc)
        );
      }
    );
  }

}
