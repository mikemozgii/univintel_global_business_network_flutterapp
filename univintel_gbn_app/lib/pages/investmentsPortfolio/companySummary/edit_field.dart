import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/models/company_summary.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/localization.dart';

class EditFieldPage extends StatefulWidget {
  final String mode;
  final CompanySummary companySummary;
  final String hint;

  EditFieldPage({Key key, this.mode, this.companySummary, this.hint}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditFieldPageState();
}

class EditFieldPageState extends State<EditFieldPage> {
  final ApiService apiService = new ApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String field = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      switch (widget.mode) {
        case "managementteam": {
          field = widget.companySummary.managementTeam == null ? "" :  widget.companySummary.managementTeam;
        }
        break;
        case "customerproblem": {
          field = widget.companySummary.customerProblem == null ? "" :  widget.companySummary.customerProblem;
        }
        break;
        case "productsandservices": {
          field = widget.companySummary.productsAndServices == null ? "" :  widget.companySummary.productsAndServices;
        }
        break;
        case "targetmarket": {
          field = widget.companySummary.targetMarket == null ? "" :  widget.companySummary.targetMarket;
        }
        break;
        case "businessmodel": {
          field = widget.companySummary.businessModel == null ? "" :  widget.companySummary.businessModel;
        }
        break;
        case "customersegments": {
          field = widget.companySummary.customerSegments == null ? "" :  widget.companySummary.customerSegments;
        }
        break;
        case "salesmarketingstrategy": {
          field = widget.companySummary.salesMarketingStrategy == null ? "" :  widget.companySummary.salesMarketingStrategy;
        }
        break;
        case "сompetitors": {
          field = widget.companySummary.competitors == null ? "" :  widget.companySummary.competitors;
        }
        break;
        case "competitiveadvantage": {
          field = widget.companySummary.competitiveAdvantage == null ? "" :  widget.companySummary.competitiveAdvantage;
        }
        break;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context,widget.mode)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () async {
              if (!formKey.currentState.validate()) return;

              await saveCompany();
            },
          )
        ]        
      ),
      body: Form(
        key: formKey,
        child: ListView(
            children: <Widget>[
              formPadding(
                Container(
                  height: 200,
                  child: TextFormField(
                    maxLines: 8,
                    maxLength: 500,
                    initialValue: field,
                    style: TextStyle(fontSize: 18.0),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        field = value;
                      });
                    },
                    validator: (value) => value.isEmpty ? UnivIntelLocale.of(context, "requiredfield") : null
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(widget.hint == null ? "" : widget.hint, style: TextStyle(color: systemGrayColor()))
              )
            ],
          ),
        )
    );
  }

  Future<bool> saveCompany() async {
    switch (widget.mode) {
        case "managementteam": {
          widget.companySummary.managementTeam = field;
        }
        break;
        case "customerproblem": {
          widget.companySummary.customerProblem = field;
        }
        break;
        case "productsandservices": {
          widget.companySummary.productsAndServices = field;
        }
        break;
        case "targetmarket": {
          widget.companySummary.targetMarket = field;
        }
        break;
        case "businessmodel": {
          widget.companySummary.businessModel = field;
        }
        break;
        case "customersegments": {
          widget.companySummary.customerSegments = field;
        }
        break;
        case "salesmarketingstrategy": {
          widget.companySummary.salesMarketingStrategy = field;
        }
        break;
        case "сompetitors": {
          widget.companySummary.competitors = field;
        }
        break;
        case "competitiveadvantage": {
          widget.companySummary.competitiveAdvantage = field;
        }
        break;
      }

    var retry = await apiService.postJson("api/1/companies/updatesummary/" + widget.companySummary.id, widget.companySummary.toJson());

    if (retry) Navigator.of(context).pop();

    return retry == true;
  }

}
