import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/pages/company/edit_company.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/company/company_dashboard.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';

class CompaniesPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => CompaniesPageState();

}

class CompaniesPageState extends State<CompaniesPage> {
  final ApiService apiService = new ApiService();
  List<Company> companies = new List<Company>();
  bool showAddButton = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    var retry = await apiService.get("api/1/companies/all");
    var result = new List<Company>();
    for (var item in retry) {
      result.add(Company.fromJson(item));
    }

    var showButton = await apiService.get("api/1/companies/allowadd");

    setState(() {
      companies = result;
      showAddButton = showButton;
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "companies")),
        actions: companies.length > 0 ? [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: UnivIntelLocale.of(context, "save"),
              onPressed: () => addCompany(context),
            )
          ] : [],        
      ),
      body: fillCompanies(context)
    );
  }

  void addCompany(BuildContext context) {
    if (!showAddButton) {
      showConfirm(context);
      return;
    }
    final companyPage = EditCompanyPage(backToPage: "companies", company: Company());
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => companyPage));
  }

  Widget fillCompanies(BuildContext context) {
    if (companies.length == 0 && showAddButton) {
      return Center(
        child: Text(UnivIntelLocale.of(context, "nocreatedorganizations"))
      );
    }

    var rows = new List<Widget>();
    for (var company in companies) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => CompanyDashboardPage(companyId: company.id)));
              },
              child: Container(
                decoration: listSeparatingBorder(context),
                padding: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      child: Align(child: AvatarBox(company.logoId , 30, localFileIfNotSpecifiedPath: 'assets/images/image_not_found.png',))
                    ),
                    Column(
                      children: [
                        Padding (
                          padding: EdgeInsets.fromLTRB(10, 14, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(company.name, style: TextStyle(fontSize: 20)),
                              Row(
                                children: elementsSpacing(
                                  [
                                    Icon(Icons.star),
                                    Text("0"),
                                    Icon(Icons.favorite),
                                    Text("0"),
                                    Icon(Icons.remove_red_eye),
                                    Text("0")
                                  ],
                                  6
                                ),
                              )
                            ],
                          )
                        )
                      ]
                    )
                  ]
                )
              ),
            )
          ]
        )
      );
    }
    return Column(children: rows);
  }

  void showConfirm(BuildContext context){
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        content: new Text(UnivIntelLocale.of(context, 'companylimitconfirmmessage'), style: new TextStyle(fontSize: 20)),
        actions: [
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text(UnivIntelLocale.of(context, 'yes'))
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text(UnivIntelLocale.of(context, 'no'))
          ),
        ],
      )
    );
  }

}
