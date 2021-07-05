import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:univintel_gbn_app/controls/avatar_box.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/company.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/datetime_picker_formfield.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/validators.dart';
import 'package:univintel_gbn_app/pages/company/company_dashboard.dart';
import 'package:univintel_gbn_app/pages/company/companies.dart';
import 'package:univintel_gbn_app/models/local_selector_item.dart';
import 'package:univintel_gbn_app/controls/local_selector.dart';

class EditCompanyPage extends StatefulWidget {
  final String backToPage;
  final Company company;

  EditCompanyPage({Key key, this.backToPage, this.company}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditCompanyPageState();
}

class EditCompanyPageState extends State<EditCompanyPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController companySizeController = new TextEditingController();
  final TextEditingController industryController = new TextEditingController();
  String companyName = "";
  String companyDescription = "";
  String tagline = "";
  String phone = "";
  String website = "";
  String email = "";
  String linkedin = "";
  String twitter = "";
  String facebook = "";
  DateTime companyFounded = DateTime.now();
  String industry;
  String companySize;
  String abbreviation = "";
  bool displayCompany = true;
  bool displayInvestmentPortfolio = true;
  String logoid;

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.company.logoId != null) logoid = widget.company.logoId;
      companyName = widget.company.name == null ? "" :  widget.company.name;
      companyDescription = widget.company.description == null ? "" :  widget.company.description;
      if (widget.company.industry != null) industry = widget.company.industry;
      if (widget.company.companySize != null) companySize = widget.company.companySize;
      abbreviation = widget.company.abbreviation == null ? "" : widget.company.abbreviation;
      companyFounded = widget.company.founded;
      tagline = widget.company.tagline == null ? "" : widget.company.tagline;
      phone = widget.company.phone == null ? "" : widget.company.phone;
      website = widget.company.website == null ? "" : widget.company.website;
      if (widget.company.linkedin != null) linkedin = widget.company.linkedin;
      if (widget.company.twitter != null) twitter = widget.company.twitter;
      if (widget.company.facebook != null) facebook = widget.company.facebook;
      if (widget.company.email != null) email = widget.company.email;
      if (widget.company.displayCompany != null) displayCompany = widget.company.displayCompany;
      if (widget.company.displayInvestmentPortfolio != null) displayInvestmentPortfolio = widget.company.displayInvestmentPortfolio;
    });
  }

  @override
  Widget build(BuildContext context) {
    var companySizes = getCompanySizes(context);
    var stringCompanySize = companySize.toString();
    var size = companySizes.firstWhere((a) => a.id == stringCompanySize, orElse: () => null);
    companySizeController.text = size != null ? size.title : "";

    var industries = getIndustries(context);
    var stringIndustry = industry.toString();
    var selectedIndustry = industries.firstWhere((a) => a.id == stringIndustry, orElse: () => null);
    industryController.text = selectedIndustry != null ? selectedIndustry.title : "";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company.id == null ? UnivIntelLocale.of(context, "addcompany") : UnivIntelLocale.of(context, "editcompany")),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (!formKey.currentState.validate()) return;

              await saveCompany();

              if (widget.company.id != null) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => CompanyDashboardPage(companyId: widget.company.id)));
              } else {
                Navigator.of(context).pop();
                if (widget.backToPage != "dashboard") Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (ctxt) => CompaniesPage()));
              }
            },
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: companyName,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "companyname")),
                onChanged: (value) {
                  setState(() {
                    companyName = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "nameismandatory") : null
              ),
            ),
            formPadding(
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 8, 10, 0),
                          alignment: Alignment.center,
                          child: AvatarBox(
                            logoid ,
                            50,
                            localFileIfNotSpecifiedPath: 'assets/images/image_not_found.png',
                            onTap: () {
                              editLogo();
                            }
                          ),
                        )
                      ]
                    ),
                    flex: 4,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Column(
                            children: [
                              TextFormField(
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                initialValue: abbreviation,
                                decoration: textHintDecoration(UnivIntelLocale.of(context, "abbreviation")),
                                onChanged: (value) {
                                  abbreviation = value;
                                }
                              ),
                              DateTimeField(
                                format: DateFormat("MM/dd/yyyy"),
                                initialValue: companyFounded,
                                decoration: textHintDecoration(UnivIntelLocale.of(context, "founded")),
                                onChanged: (value) => companyFounded = value,
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1000),
                                      initialDate: currentValue ?? DateTime.now(),
                                      lastDate: DateTime.now().add(new Duration(days: 365))
                                  );
                                },
                              )
                            ]
                          )
                      ],
                    ),
                    flex: 6,
                  )
                ],
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 2,
                initialValue: tagline,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "tagline")),
                onChanged: (value) => tagline = value
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 3,
                initialValue: companyDescription,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "description")),
                onChanged: (value) {
                  setState(() {
                    companyDescription = value;
                  });
                },
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "descriptionismandatory") : null
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: phone,
                keyboardType: TextInputType.phone,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "phone")),
                validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "phoneismandatory") : null,
                onChanged: (value) => phone = value
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: email,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration(UnivIntelLocale.of(context, "companyemail")),
                onChanged: (value) => email = value,
                validator: (value) {
                  if (value.isEmpty) return null;

                  return validateEmail(value);
                },
              )
            ),
            formPadding(
              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: TextFormField(
                  maxLines: 1,
                  readOnly: true,
                  controller: industryController,
                  keyboardType: TextInputType.text,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "industry")),
                  onTap: () async {
                    var industries = getIndustries(context);
                    var result = await showSelector(context, industries, industry.toString());
                    if (result == null) return;

                    var id = result as String;
                    industry = id;
                    industryController.text = industries.firstWhere((a) => a.id == id).title;
                  },
                  //validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                )
              )
            ),
            formPadding(
              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: TextFormField(
                  maxLines: 1,
                  readOnly: true,
                  controller: companySizeController,
                  keyboardType: TextInputType.text,
                  decoration: textHintDecoration(UnivIntelLocale.of(context, "companysize")),
                  onTap: () async {
                    var result = await showSelector(context, getCompanySizes(context), companySize.toString());
                    if (result == null) return;

                    var id = result as String;
                    companySize = id;
                    var companySizes = getCompanySizes(context);
                    companySizeController.text = companySizes.firstWhere((a) => a.id == id).title;
                  },
                  //validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                )
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 36, 0, 0),
              child: Row( 
                children: [
                  Switch(
                    value: displayCompany,
                    onChanged: (value) {
                      setState(() {
                        displayCompany = value;
                      });
                    }
                  ),
                  Text(UnivIntelLocale.of(context, "displayorganization"))
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 36, 0, 0),
              child: Row( 
                children: [
                  Switch(
                    value: displayInvestmentPortfolio,
                    onChanged: (value) {
                      setState(() {
                        displayInvestmentPortfolio = value;
                      });
                    }
                  ),
                  Text(UnivIntelLocale.of(context, "showinvestmentportfoliopublic"))
                ],
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: website,
                keyboardType: TextInputType.text,
                decoration: textHintDecoration('Website'),
                onChanged: (value) => website = value,
                validator: (value) {
                  if (value.isEmpty) return null;

                  if (!value.startsWith('http://') && !value.startsWith('https://')) return (UnivIntelLocale.of(context, "urlisincorrect"));

                  return null;
                }
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                initialValue: linkedin,
                keyboardType: TextInputType.emailAddress,
                decoration: textHintDecoration('Linkedin'),
                onChanged: (value) => linkedin = value,
                validator: (value) {
                  if (value.isEmpty) return null;

                  if (!value.startsWith('https://linkedin.com/')) return (UnivIntelLocale.of(context, "urlisincorrect"));

                  return null;
                },
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                initialValue: twitter,
                decoration: textHintDecoration('Twitter'),
                onChanged: (value) => twitter = value,
                validator: (value) {
                  if (value.isEmpty) return null;

                  if (!value.startsWith('https://twitter.com/')) return (UnivIntelLocale.of(context, "urlisincorrect"));

                  return null;
                }
              )
            ),
            formPadding(
              TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                initialValue: facebook,
                decoration: textHintDecoration('Facebook'),
                onChanged: (value) => facebook = value,
                validator: (value) {
                  if (value.isEmpty) return null;

                  if (!value.startsWith('https://facebook.com/')) return (UnivIntelLocale.of(context, "urlisincorrect"));

                  return null;
                }
              )
            ),
            formPadding(
              widget.company.id == null ? null :
              RaisedButton(
                onPressed: () async {
                  var result = await apiService.get("api/1/companies/deletecompany/?id=" + widget.company.id);
                  if (result) Navigator.of(context).pop();
                },
                color: Colors.redAccent,
                child: Text(
                  UnivIntelLocale.of(context, "delete"),
                  style: TextStyle(fontSize: 15)
                ),
              )
            )
          ],
        )
      )
    );
  }

  Future<bool> saveCompany() async {
    widget.company.name = companyName;
    widget.company.description = companyDescription;
    widget.company.founded = companyFounded;
    widget.company.industry = industry;
    widget.company.companySize = companySize;
    widget.company.abbreviation = abbreviation;
    widget.company.facebook = facebook;
    widget.company.linkedin = linkedin;
    widget.company.twitter = twitter;
    widget.company.website = website;
    widget.company.phone = phone;
    widget.company.email = email;
    widget.company.logoId = logoid;
    widget.company.tagline = tagline;
    widget.company.displayInvestmentPortfolio = displayInvestmentPortfolio;

    var retry = await apiService.postJson(widget.company.id == null ? "api/1/companies/add" : "api/1/companies/update", widget.company.toJson());
    return retry == true;
  }

  void editLogo() async {
    final file = await getCroppedImage();
    if(file == null) return;

    final savedLogoId = await apiService.uploadImage(file);
    if (savedLogoId.length == 0) return;

    setState(() {
      logoid = savedLogoId;
    });
  }

  Future<dynamic> showSelector(BuildContext context, List<LocalSelectorItem> items, String selected) async {
    final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => LocalSelector(title: UnivIntelLocale.of(context, "category"), items: items, selectedId: selected)));
    return result;
  }


  List<LocalSelectorItem> getCompanySizes(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "0", title: "0-1 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "2", title: "2-10 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "11", title: "11-50 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "51", title: "51-200 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "201", title: "201-500 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "501", title: "501-1,000 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "1001", title: "1,001-5,000 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "5001", title: "5,001-10,000 " + UnivIntelLocale.of(context, "employees")));
    result.add(LocalSelectorItem(id: "10001", title: "10,001+ " + UnivIntelLocale.of(context, "employees")));

    return result;
  }

  List<LocalSelectorItem> getIndustries(BuildContext context) {
    var result = new List<LocalSelectorItem>();

    result.add(LocalSelectorItem(id: "1", title: "Accounting"));
    result.add(LocalSelectorItem(id: "2", title: "Airlines/Aviation"));
    result.add(LocalSelectorItem(id: "3", title: "Alternative Dispute Resolution"));
    result.add(LocalSelectorItem(id: "4", title: "Alternative Medicine"));
    result.add(LocalSelectorItem(id: "5", title: "Animation"));
    result.add(LocalSelectorItem(id: "6", title: "Apparel & Fashion"));
    result.add(LocalSelectorItem(id: "7", title: "Architecture & Planning"));
    result.add(LocalSelectorItem(id: "8", title: "Arts & Crafts"));
    result.add(LocalSelectorItem(id: "9", title: "Automotive"));
    result.add(LocalSelectorItem(id: "10", title: "Aviation & Aerospace"));
    result.add(LocalSelectorItem(id: "11", title: "Banking"));
    result.add(LocalSelectorItem(id: "12", title: "Biotechnology"));
    result.add(LocalSelectorItem(id: "13", title: "Broadcast Media"));
    result.add(LocalSelectorItem(id: "14", title: "Building Materials"));
    result.add(LocalSelectorItem(id: "15", title: "Business Supplies & Equipment"));
    result.add(LocalSelectorItem(id: "16", title: "Capital Markets"));
    result.add(LocalSelectorItem(id: "17", title: "Chemicals"));
    result.add(LocalSelectorItem(id: "18", title: "Civic & Social Organization"));
    result.add(LocalSelectorItem(id: "19", title: "Civil Engineering"));
    result.add(LocalSelectorItem(id: "20", title: "Commercial Real Estate"));
    result.add(LocalSelectorItem(id: "21", title: "Computer & Network Security"));
    result.add(LocalSelectorItem(id: "22", title: "Computer Games"));
    result.add(LocalSelectorItem(id: "23", title: "Computer Hardware"));
    result.add(LocalSelectorItem(id: "24", title: "Computer Networking"));
    result.add(LocalSelectorItem(id: "25", title: "Computer Software"));
    result.add(LocalSelectorItem(id: "26", title: "Construction"));
    result.add(LocalSelectorItem(id: "27", title: "Consumer Electronics"));
    result.add(LocalSelectorItem(id: "28", title: "Consumer Goods"));
    result.add(LocalSelectorItem(id: "29", title: "Consumer Services"));
    result.add(LocalSelectorItem(id: "30", title: "Cosmetics"));
    result.add(LocalSelectorItem(id: "31", title: "Dairy"));
    result.add(LocalSelectorItem(id: "32", title: "Defense & Space"));
    result.add(LocalSelectorItem(id: "33", title: "Design"));
    result.add(LocalSelectorItem(id: "34", title: "E-learning"));
    result.add(LocalSelectorItem(id: "35", title: "Education Management"));
    result.add(LocalSelectorItem(id: "36", title: "Electrical & Electronic Manufacturing"));
    result.add(LocalSelectorItem(id: "37", title: "Entertainment"));
    result.add(LocalSelectorItem(id: "38", title: "Environmental Services"));
    result.add(LocalSelectorItem(id: "39", title: "Events Services"));
    result.add(LocalSelectorItem(id: "40", title: "Executive Office"));
    result.add(LocalSelectorItem(id: "41", title: "Facilities Services"));
    result.add(LocalSelectorItem(id: "42", title: "Farming"));
    result.add(LocalSelectorItem(id: "43", title: "Financial Services"));
    result.add(LocalSelectorItem(id: "44", title: "Fine Art"));
    result.add(LocalSelectorItem(id: "45", title: "Fishery"));
    result.add(LocalSelectorItem(id: "46", title: "Food & Beverages"));
    result.add(LocalSelectorItem(id: "47", title: "Food Production"));
    result.add(LocalSelectorItem(id: "48", title: "Fundraising"));
    result.add(LocalSelectorItem(id: "49", title: "Furniture"));
    result.add(LocalSelectorItem(id: "50", title: "Gambling & Casinos"));
    result.add(LocalSelectorItem(id: "51", title: "Glass, Ceramics & Concrete"));
    result.add(LocalSelectorItem(id: "52", title: "Government Administration"));
    result.add(LocalSelectorItem(id: "53", title: "Government Relations"));
    result.add(LocalSelectorItem(id: "54", title: "Graphic Design"));
    result.add(LocalSelectorItem(id: "55", title: "Health, Wellness & Fitness"));
    result.add(LocalSelectorItem(id: "56", title: "Higher Education"));
    result.add(LocalSelectorItem(id: "57", title: "Hospital & Health Care"));
    result.add(LocalSelectorItem(id: "58", title: "Hospitality"));
    result.add(LocalSelectorItem(id: "59", title: "Human Resources"));
    result.add(LocalSelectorItem(id: "60", title: "Import & Export"));
    result.add(LocalSelectorItem(id: "61", title: "Individual & Family Services"));
    result.add(LocalSelectorItem(id: "62", title: "Industrial Automation"));
    result.add(LocalSelectorItem(id: "63", title: "Information Services"));
    result.add(LocalSelectorItem(id: "64", title: "Information Technology and Services"));
    result.add(LocalSelectorItem(id: "65", title: "Insurance"));
    result.add(LocalSelectorItem(id: "66", title: "International Affairs"));
    result.add(LocalSelectorItem(id: "67", title: "International Trade & Development"));
    result.add(LocalSelectorItem(id: "68", title: "Internet"));
    result.add(LocalSelectorItem(id: "69", title: "Investment Banking"));
    result.add(LocalSelectorItem(id: "70", title: "Investment Management"));
    result.add(LocalSelectorItem(id: "71", title: "Judiciary"));
    result.add(LocalSelectorItem(id: "72", title: "Law Enforcement"));
    result.add(LocalSelectorItem(id: "73", title: "Law Practice"));
    result.add(LocalSelectorItem(id: "74", title: "Legal Services"));
    result.add(LocalSelectorItem(id: "75", title: "Legislative Office"));
    result.add(LocalSelectorItem(id: "76", title: "Leisure, Travel & Tourism"));
    result.add(LocalSelectorItem(id: "77", title: "Libraries"));
    result.add(LocalSelectorItem(id: "78", title: "Logistics & Supply Chain"));
    result.add(LocalSelectorItem(id: "79", title: "Luxury Goods & Jewelry"));
    result.add(LocalSelectorItem(id: "80", title: "Machinery"));
    result.add(LocalSelectorItem(id: "81", title: "Management Consulting"));
    result.add(LocalSelectorItem(id: "82", title: "Maritime"));
    result.add(LocalSelectorItem(id: "83", title: "Market Research"));
    result.add(LocalSelectorItem(id: "84", title: "Marketing & Advertising"));
    result.add(LocalSelectorItem(id: "85", title: "Mechanical Or Industrial Engineering"));
    result.add(LocalSelectorItem(id: "86", title: "Media Production"));
    result.add(LocalSelectorItem(id: "87", title: "Medical Device"));
    result.add(LocalSelectorItem(id: "88", title: "Medical Practice"));
    result.add(LocalSelectorItem(id: "89", title: "Mental Health Care"));
    result.add(LocalSelectorItem(id: "90", title: "Military"));
    result.add(LocalSelectorItem(id: "100", title: "Mining & Metals"));
    result.add(LocalSelectorItem(id: "101", title: "Motion Pictures & Film"));
    result.add(LocalSelectorItem(id: "102", title: "Museums & Institutions"));
    result.add(LocalSelectorItem(id: "103", title: "Music"));
    result.add(LocalSelectorItem(id: "104", title: "Nanotechnology"));
    result.add(LocalSelectorItem(id: "105", title: "Newspapers"));
    result.add(LocalSelectorItem(id: "106", title: "Non-profit Organization Management"));
    result.add(LocalSelectorItem(id: "107", title: "Oil & Energy"));
    result.add(LocalSelectorItem(id: "108", title: "Online Media"));
    result.add(LocalSelectorItem(id: "109", title: "Outsourcing/Offshoring"));
    result.add(LocalSelectorItem(id: "110", title: "Package/Freight Delivery"));
    result.add(LocalSelectorItem(id: "111", title: "Packaging & Containers"));
    result.add(LocalSelectorItem(id: "112", title: "Paper & Forest Products"));
    result.add(LocalSelectorItem(id: "113", title: "Performing Arts"));
    result.add(LocalSelectorItem(id: "114", title: "Pharmaceuticals"));
    result.add(LocalSelectorItem(id: "115", title: "Philanthropy"));
    result.add(LocalSelectorItem(id: "116", title: "Photography"));
    result.add(LocalSelectorItem(id: "117", title: "Plastics"));
    result.add(LocalSelectorItem(id: "118", title: "Political Organization"));
    result.add(LocalSelectorItem(id: "119", title: "Primary/Secondary Education"));
    result.add(LocalSelectorItem(id: "120", title: "Printing"));
    result.add(LocalSelectorItem(id: "121", title: "Professional Training & Coaching"));
    result.add(LocalSelectorItem(id: "122", title: "Program Development"));
    result.add(LocalSelectorItem(id: "123", title: "Public Policy"));
    result.add(LocalSelectorItem(id: "124", title: "Public Relations & Communications"));
    result.add(LocalSelectorItem(id: "125", title: "Public Safety"));
    result.add(LocalSelectorItem(id: "126", title: "Publishing"));
    result.add(LocalSelectorItem(id: "127", title: "Railroad Manufacture"));
    result.add(LocalSelectorItem(id: "128", title: "Ranching"));
    result.add(LocalSelectorItem(id: "129", title: "Real Estate"));
    result.add(LocalSelectorItem(id: "130", title: "Recreational Facilities & Services"));
    result.add(LocalSelectorItem(id: "131", title: "Religious Institutions"));
    result.add(LocalSelectorItem(id: "132", title: "Renewables & Environment"));
    result.add(LocalSelectorItem(id: "133", title: "Research"));
    result.add(LocalSelectorItem(id: "134", title: "Restaurants"));
    result.add(LocalSelectorItem(id: "135", title: "Retail"));
    result.add(LocalSelectorItem(id: "136", title: "Security & Investigations"));
    result.add(LocalSelectorItem(id: "137", title: "Semiconductors"));
    result.add(LocalSelectorItem(id: "138", title: "Shipbuilding"));
    result.add(LocalSelectorItem(id: "139", title: "Sporting Goods"));
    result.add(LocalSelectorItem(id: "140", title: "Sports"));
    result.add(LocalSelectorItem(id: "142", title: "Supermarkets"));
    result.add(LocalSelectorItem(id: "144", title: "Textiles"));
    result.add(LocalSelectorItem(id: "143", title: "Think Tanks"));
    result.add(LocalSelectorItem(id: "144", title: "Tobacco"));
    result.add(LocalSelectorItem(id: "149", title: "Utilities"));
    result.add(LocalSelectorItem(id: "146", title: "Venture Capital & Private Equity"));
    result.add(LocalSelectorItem(id: "150", title: "Veterinary"));
    result.add(LocalSelectorItem(id: "151", title: "Wholesale"));
    result.add(LocalSelectorItem(id: "153", title: "Wine & Spirits"));
    result.add(LocalSelectorItem(id: "154", title: "Writing & Editing"));
    result.add(LocalSelectorItem(id: "156", title: "Staffing & Recruiting"));
    result.add(LocalSelectorItem(id: "141", title: "Telecommunications"));
    result.add(LocalSelectorItem(id: "143", title: "Translation & Localization"));
    result.add(LocalSelectorItem(id: "147", title: "Transportation/Trucking/Railroad"));
    result.add(LocalSelectorItem(id: "148", title: "Warehousing"));
    result.add(LocalSelectorItem(id: "152", title: "Wireless"));

    return result;
  }

}
