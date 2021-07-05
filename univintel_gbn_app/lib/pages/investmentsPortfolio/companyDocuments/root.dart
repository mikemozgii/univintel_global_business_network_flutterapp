import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/models/company_file.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/globals.dart';

class CompanyDocumentsPage extends StatefulWidget {
  final String companyId;

  CompanyDocumentsPage({Key key, this.companyId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CompanyDocumentsPageState();

}

class CompanyDocumentsPageState extends State<CompanyDocumentsPage> {
  List<CompanyFile> items = new List<CompanyFile>();
  bool isLoading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    refreshItems();
  }

  void refreshItems() async {
    var retry = await apiService.get("api/1/companies/documents/" + widget.companyId);
    var result = new List<CompanyFile>();
    for (var file in retry) {
      result.add(CompanyFile.fromJson(file));
    }

    setState(() {
      items = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "documents")),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: UnivIntelLocale.of(context, "save"),
            onPressed: () => addAdditionalDocument(),
          ),
        ],
      ),
      body: renderBody(context)
    );
  }

  Widget renderBody(BuildContext context) {
    if (isLoading) {
      return Center (
          child: CircularProgressIndicator()
      );
    }

    return ListView (
      children: [
        Column (
          children: drawBlocks()
        )
      ]
    );
  }

  addAdditionalDocument() async {
    List<File> files = await FilePicker.getMultiFile();
    if (files == null || files.length == 0 ) return;

    for (var file in files) {
      await apiService.uploadFile(file, companyId: widget.companyId, tag: "companydocument" );
    }

    refreshItems();
  }
  addOrUpdateDocument(String tag, CompanyFile companyFile) async {
    File file = await FilePicker.getFile();
    if (file == null) return;

    if (companyFile != null) {
      await apiService.uploadFile(file, companyId: widget.companyId, tag: tag, id: companyFile.id );
    } else {
      await apiService.uploadFile(file, companyId: widget.companyId, tag: tag );
    }

    refreshItems();
  }

  List<Widget> drawBlocks() {
    List<Widget> blocks = new List<Widget>();
    int index = 0;
    var businessPlan = items.firstWhere((a) => a.tag == 'businessplan', orElse: () => null);
    blocks.add(drawCommonBlock(UnivIntelLocale.of(context, 'businessplan'), businessPlan != null ? businessPlan.name : null, UnivIntelLocale.of(context, "notuploaded"), 'businessplan', ++index, companyFile: businessPlan));

    var financialprojection = items.firstWhere((a) => a.tag == 'financialprojection', orElse: () => null);
    blocks.add(drawCommonBlock(UnivIntelLocale.of(context, 'financialprojection'), financialprojection != null ? financialprojection.name : null, UnivIntelLocale.of(context, "notuploaded"), 'financialprojection', ++index, companyFile: financialprojection));

    var additionalDocuments = items.where((a) => a.tag == 'companydocument').toList();
    for (var additionalDocument in additionalDocuments) {
      blocks.add(drawCommonBlock(UnivIntelLocale.of(context, 'supplementaldocument'), additionalDocument.name, "", 'companydocument', ++index, companyFile: additionalDocument));
    }

    return blocks;
  }

  Widget drawCommonBlock(String title, String value, String defaultDescription, String mode, int index, { CompanyFile companyFile }) {
    var mainContent = InkWell(
      onTap: () {
        if (companyFile != null) return;

        addOrUpdateDocument(mode, companyFile);
      },
      child: Container(
      margin: EdgeInsets.all(2),
      width: MediaQuery.of(context).size.width - 14,
      decoration: listSeparatingBorder(context),
      height: 100,
      child: Row(
        children: [
          Container (
            width: MediaQuery.of(context).size.width - 44,
            child: 
              Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(title, style: TextStyle(fontSize: 20), textAlign: TextAlign.left)
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              value == null ? defaultDescription : value,
                              style: TextStyle(
                                fontSize: 14,
                                color: systemGrayColor()
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left
                            )
                          )
                        ]
                      )
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: value == null ? Text(
                          UnivIntelLocale.of(context, 'upload'),
                          style: TextStyle(color: systemLinkColor()),
                        ) : null
                      )
                      
                    )
                  ]
                )
              )
            )
          ]
        )
      ),
    );

    if (companyFile == null) return mainContent;

    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.red),
      onDismissed: (direction) {
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("File deleted"),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: UnivIntelLocale.of(context, "undo"),
              onPressed: () {
                refreshItems();
              },
            )
          )
        ).closed.then(
          (SnackBarClosedReason reason) async {
            if (reason != SnackBarClosedReason.timeout)  return;

            await apiGetResult("api/1/companies/deletedocuments/" + widget.companyId + "/" + companyFile.id, context);

            refreshItems();
          }
        );
      },
      child: mainContent
    );
  }

}
