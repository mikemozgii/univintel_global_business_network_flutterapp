import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/controls/helper_functions.dart';
import 'package:univintel_gbn_app/controls/basic_inputs.dart';
import 'package:univintel_gbn_app/models/job.dart';
import 'package:univintel_gbn_app/services/api.dart';
import 'package:univintel_gbn_app/localization.dart';
import 'package:univintel_gbn_app/pages/jobs/edit_jobs.dart';

class JobsPage extends StatefulWidget {
  final String companyId;

  JobsPage({Key key, this.companyId}): super(key: key);

  @override
  State<StatefulWidget> createState() => JobsPageState();

}

class JobsPageState extends State<JobsPage> {
  final ApiService apiService = new ApiService();
  List<Job> items = new List<Job>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void getData() async {
    var retry = await apiService.get("api/1/jobs/all/?companyid=" + widget.companyId);

    setState(() {
      items = List<Job>.from(retry.map((map) => Job.fromJson(map)));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingScaffold();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(UnivIntelLocale.of(context, "jobs")),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addJob()
          )
        ]
      ),
      body: fillItems(context)
    );
  }

  void addJob() {
    var newJob = Job();
    newJob.companyId = widget.companyId;
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditJobPage(item: newJob)));
  }

  Widget getItemTemplate(Job item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctxt) => EditJobPage(item: item)));
      },
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        decoration: listSeparatingBorder(context),
        width: MediaQuery.of(context).size.width - 4,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(item.name, style: TextStyle(fontSize: 20))
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                item.description == null ? "" : item.description,
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
    );
  }

  void removeItem(int index) {
    final item =  items.elementAt(index);
    setState(() { items.removeAt(index); });
    showSnackBarToDelete(
      scaffoldKey,
      UnivIntelLocale.of(context, "canceldelete"),
      5000,
      onDelete: () async => await apiGet("api/1/jobs/delete?id=" + item.id + "&companyId=" + widget.companyId, context, scaffoldState: scaffoldKey.currentState),
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
          onTap: () => addJob(),
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
