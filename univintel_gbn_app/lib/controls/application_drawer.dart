import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:univintel_gbn_app/controls/avatar_text_box.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/pages/company/company_dashboard.dart';
import 'package:univintel_gbn_app/pages/company/edit_company.dart';
import 'package:univintel_gbn_app/pages/discounts/discounts.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/pages/jobs/root.dart';
import 'package:univintel_gbn_app/pages/news/news.dart';
import 'package:univintel_gbn_app/pages/products/products.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/company/companies.dart';
import 'package:univintel_gbn_app/pages/companyCulture/root.dart';
import 'package:univintel_gbn_app/pages/companyContacts/contacts.dart';
import 'package:univintel_gbn_app/pages/companyLocations/locations.dart';
import 'package:univintel_gbn_app/pages/account_edit_info.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/edit_portfolio.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/companySummary/company_summary.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/annualFinancials/root.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/companyDocuments/root.dart';
import 'package:univintel_gbn_app/pages/investmentsPortfolio/fundingHistory/root.dart';
import 'package:univintel_gbn_app/pages/promotes/promotes.dart';
import 'package:univintel_gbn_app/pages/companyEmployee/root.dart';
import 'package:univintel_gbn_app/pages/dashboard.dart';

import 'avatar_box.dart';
import 'helper_functions.dart';

class ApplicationDrawer extends StatefulWidget {
  final bool showCompanyMenu;
  final bool showInvestmentsProfileMenu;
  final String itemId;
  final List<Company> companies;
  final Function backCallback;

  ApplicationDrawer({Key key, this.showCompanyMenu = false, this.companies, this.itemId = "", this.showInvestmentsProfileMenu = false, this.backCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ApplicationDrawerState();
}

class ApplicationDrawerState extends State<ApplicationDrawer> {
  String userEmail = "";
  String userName = "";
  String userAvatar = "";
  String accountRank = "";
  bool isPaid = false;
  bool showAdditionalOptions = false;
  bool needUpdateCompanies = true;
  bool showPortfolio = false;
  List<Company> companies = new List<Company>();
  bool isEmployee = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    final storage = new FlutterSecureStorage();
    final email = await storage.read(key: "user_email");
    String name = await storage.read(key: "user_name");
    String avatar = await storage.read(key: "user_avatar");
    var isUserEmployee = await storage.read(key: "user_isemployee");
    var rankId = await storage.read(key: "account_rank");

    if (name == null) name = "No set";
    if (avatar == null) avatar = "";

    var companiesResponse;
    if (widget.companies != null) companiesResponse = await apiGetResult("api/1/companies/all", context);

    setState(() {
      userEmail = email;
      userName = name;
      userAvatar = avatar;
      isEmployee = isUserEmployee == "true";
      accountRank = rankId;
      if (companiesResponse != null) {
        companies = List<Company>.from(companiesResponse.map((map) => Company.fromJson(map)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Container(
        color: Color.fromRGBO(23, 36, 44, 1),
        child: new ListView(
          children: _fillOptions()
        )
      )
    );
  }

  void goNewsPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => NewsPage(companyId: widget.itemId)));
  }

  void goProductsPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => ProductsPage(companyId: widget.itemId)));
  }

  void goDiscountsPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => DiscountsPage(companyId: widget.itemId)));
  }

  void goEmployeesPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => EmployeesPage(companyId: widget.itemId)));
  }

  void goCompaniesPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => CompaniesPage()));
  }

  void goCompanyPage(String id) {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => CompanyDashboardPage(companyId: id)));
  }

  void goAddCompanyPage() async {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => EditCompanyPage(backToPage: "dashboard", company: Company())));
  }

  void goContactsPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => ContactsPage(companyId: widget.itemId)));
  }

  void goLocationsPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => LocationsPage(companyId: widget.itemId)));
  }

  void goPromotesPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => PromotesPage(companyId: widget.itemId)));
  }

  void goInvestmentProfilePage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => EditPortfolioPage(companyId: widget.itemId)));
  }

  void goCompanySummaryPage() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => CompanySummaryPage(companyId: widget.itemId)));
  }

  void goAnnualFinancials() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => AnnualFinancialsPage(companyId: widget.itemId)));
  }

  void goCompanyDocuments() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => CompanyDocumentsPage(companyId: widget.itemId)));
  }

  void goCompanyFundingHistory() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => FundingHistoryPage(companyId: widget.itemId)));
  }

  void goCompanyCulture() {
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => CompanyCultureViewPage(companyId: widget.itemId)));
  }

  String getShortName(String name) {
    if (name == null || name == "" || name == " ") return "NN";

    var parts = name.split(" ");
    if (parts.length == 2) return parts[0][0] + parts[1][0];

    return name.substring(0,2);
  }

  List<Widget> _fillOptions() {
    List<Widget> result = new List<Widget>();
    result.add(DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAvatar.length > 0 ? AvatarBox(userAvatar, 40) : AvatarTextBox(getShortName(userName), 32, fontSize: 20),
            Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.topRight,
                  child: getAccountRankDecoration(context, accountRank)
                )
              ),
              flex: 6,
            )
          ]
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(userName, style: TextStyle(fontSize: 20))
                      ]
                    ),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: systemGrayColor())
                    )
                  ]
                ),
                flex: 9,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showAdditionalOptions = !showAdditionalOptions;
                      });
                    },
                    child: showAdditionalOptions ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down)
                  )
                ),
                flex: 1
              )
            ]
          )
        ),
      ]),
      decoration: BoxDecoration(color: Color.fromRGBO(31, 49, 63, 1)),
    ));

    if (showAdditionalOptions) {
      result.add(
        Container(
          child: ListTile(
            leading: Icon(Icons.settings, color: systemGrayColor()),
            title: Text(UnivIntelLocale.of(context, "settings"), style: menuOptionTextStyle()),
            onTap: () {
              pushToRoute(AccountEditInfoPage());
            }
          )
        )
      );
      result.add(
        Container(
          decoration: listSeparatingBorder(context),
          child: ListTile(
            leading: Icon(Icons.person, color: systemGrayColor()),
            title: Text(UnivIntelLocale.of(context, "invitefriends"), style: menuOptionTextStyle()),
            onTap: () {
              //I don't think about it
            }
          )
        )
      );
    }

    if (widget.showCompanyMenu && !isEmployee) {
      result.add(ListTile(
        leading: Icon(Icons.home, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "dashboard"), style: menuOptionTextStyle()),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => DashboardPage()));
        },
      ));
      result.add(ListTile(
        leading: Icon(Icons.store, color: systemGrayColor()),
        title: Row(
          children: [
            Expanded(
              child: Text(UnivIntelLocale.of(context, "companyinfooption"), style: menuOptionTextStyle())
            ),
            showPortfolio ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down)
          ]
        ),
        onTap: () {
          setState(() {
            showPortfolio = !showPortfolio;
          });
        },
      ));
      if (showPortfolio) {
        var portfolioOptions = new List<Widget>();
        portfolioOptions.add(ListTile(
          leading: Icon(Icons.work, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "investmentsprofile"), style: menuOptionTextStyle()),
          onTap: () => goInvestmentProfilePage(),
        ));
        portfolioOptions.add(ListTile(
          leading: Icon(Icons.next_week, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "companysummary"), style: menuOptionTextStyle()),
          onTap: () => goCompanySummaryPage(),
        ));
        portfolioOptions.add(ListTile(
          leading: Icon(Icons.pie_chart, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "annualfinancials"), style: menuOptionTextStyle()),
          onTap: () => goAnnualFinancials()
        ));
        portfolioOptions.add(ListTile(
          leading: Icon(Icons.description, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "documents"), style: menuOptionTextStyle()),
          onTap: () => goCompanyDocuments()
        ));
        portfolioOptions.add(ListTile(
          leading: Icon(Icons.import_contacts, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "fundinghistory"), style: menuOptionTextStyle()),
          onTap: () => goCompanyFundingHistory()
        ));
        result.add(
          Container(
            decoration: listSeparatingBorder(context),
            child: Column(
              children: portfolioOptions
            )
          )
        );
      }
      result.add(ListTile(
        leading: Icon(Icons.library_books, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "news"), style: menuOptionTextStyle()),
        onTap: () => goNewsPage(),
      ));


      result.add(ListTile(
        leading: Icon(Icons.merge_type, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "promotes"), style: menuOptionTextStyle()),
        onTap: () => goPromotesPage()
      ));


      result.add(ListTile(
        leading: Icon(Icons.category, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "productsandservices"), style: menuOptionTextStyle()),
        onTap: () => goProductsPage(),
      ));
      result.add(ListTile(
        leading: Icon(Icons.local_offer, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "couponsanddiscounts"), style: menuOptionTextStyle()),
        onTap: () => goDiscountsPage(),
      ));
      result.add(ListTile(
          leading: Icon(Icons.place, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "locations"), style: menuOptionTextStyle()),
          onTap: () => goLocationsPage()
      ));
      result.add(ListTile(
          leading: Icon(Icons.contacts, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "contacts"), style: menuOptionTextStyle()),
          onTap: () => goContactsPage()
      ));
      result.add(ListTile(
        leading: Icon(Icons.group, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "employeespage"), style: menuOptionTextStyle()),
        onTap: () => goEmployeesPage(),
      ));
      result.add(ListTile(
        leading: Icon(Icons.featured_play_list, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "jobs"), style: menuOptionTextStyle()),
        onTap: () {
          pushToRoute(JobsPage(companyId: widget.itemId));
        },
      ));
      result.add(ListTile(
          leading: Icon(Icons.nature_people, color: systemGrayColor()),
          title: Text(UnivIntelLocale.of(context, "culture"), style: menuOptionTextStyle()),
          onTap: () => goCompanyCulture()
      ));
    }

    if (widget.companies != null && !isEmployee) {
      for (var company in companies) {
        var companyId = company.id;
        result.add(ListTile(
          leading: Container(
            width: 30,
            height: 30,
            child: Align(child: company.logoId != null ? AvatarBox(company.logoId , 30, localFileIfNotSpecifiedPath: 'assets/images/image_not_found.png',) : AvatarTextBox(company.name.substring(0,2), 30, fontSize: 14))
          ),
          title: Text(company.name, style: menuOptionTextStyle()),
          onTap: () => goCompanyPage(companyId)
        ));
      }
      result.add(ListTile(
        leading: Icon(Icons.add, color: systemGrayColor()),
        title: Text(UnivIntelLocale.of(context, "addcompany"), style: menuOptionTextStyle()),
        onTap: () => goAddCompanyPage()
      ));
    }

    return result;
  }

  TextStyle menuOptionTextStyle() {
    return TextStyle(fontSize: 16);
  }

  void pushToRoute(Widget routeWidget) async {
    Navigator.pop(context);
    if (widget.backCallback != null) {
      await Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => routeWidget));
      widget.backCallback();
    } else {
      Navigator.push(context, new MaterialPageRoute(builder: (ctxt) => routeWidget));
    }
  }

}
