import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
//This multiselect was tested only for server side filtering

class SelectItem {
  final String id;
  final String filterText;
  Widget widget;
  final String _name;
  
  @override
  String toString() {
      return _name;
  }
  SelectItem(this.id, this._name, this.filterText);
}

class MultiSelectItems extends StatefulWidget {
  final List<String> selectedIds;
  final InputDecoration inputDecoration;
  final String barTitle;
  final List<SelectItem> suggestions;
  final Future<List<SelectItem>> Function(String searchText) serverFilter;

  MultiSelectItems(this.inputDecoration, this.selectedIds, this.barTitle, this.suggestions, this.serverFilter);
  @override
  MultiSelectItemsState createState() => MultiSelectItemsState();
}

InputDecoration defaultDecoartion(String hintField) {
  return InputDecoration(
    hintText: hintField, 
    suffixIcon: new Icon(Icons.search));
}

class MultiSelectItemsState extends State<MultiSelectItems> {
  GlobalKey key = GlobalKey<AutoCompleteTextFieldState<SelectItem>>();
  List<SelectItem> selectedItems = [];
  AutoCompleteTextField<SelectItem> textField;

  MultiSelectItemsState();

  @override
  void initState() {
    super.initState();
    initSearchBox();
  }

  serversideFiltering(String value) async {
    if(value.isEmpty || value.length < 3) return;
    final data = await widget.serverFilter(value);
    textField.suggestions.clear();
    for(var s in data)
      textField.addSuggestion(s);
  }


  void initSearchBox() {
    
    final filterBox = widget.serverFilter == null ?
    AutoCompleteTextField<SelectItem>(
      decoration: widget.inputDecoration,
      itemSubmitted: (item) => addItem(item),
      key: key,
      suggestions: widget.suggestions,
      itemBuilder: (context, item) => item.widget,
      itemSorter: (a, b) => a.filterText == b.filterText ? 0 : a.filterText.compareTo(b.filterText ) > 0 ? -1 : 1,
      itemFilter:(suggestion, input) => 
          suggestion.filterText.toLowerCase().indexOf(input.toLowerCase()) >= 0,
    ):
    AutoCompleteTextField<SelectItem>(
      decoration: widget.inputDecoration,
      itemSubmitted: (item) => addItem(item),
      key: key,
      textChanged: (value) async => await serversideFiltering(value),
      suggestions: widget.suggestions,
      itemBuilder: (context, item) => item.widget,
      itemSorter: (a, b) => a.filterText == b.filterText ? 0 : a.filterText.compareTo(b.filterText ) > 0 ? -1 : 1,
      itemFilter:(suggestion, input) => true,
    );

    setState(() { 
      textField = filterBox;
      selectedItems = widget.suggestions.where((item) => widget.selectedIds.contains(item.id)).toList();
    });
  }

  void removeItem(SelectItem item) {
    setState(() { selectedItems.remove(item); });
  }

  void addItem(SelectItem item) {
    if (selectedItems.contains(item)) return;
     setState(() { selectedItems.add(item); });
  }

   Widget selctedLocationWidget() {
    return Column(children:
      selectedItems.map((item) => 
        ListTile(
          title: Text(item._name),
          trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => removeItem(item))
      )).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barTitle),
        actions: <Widget>[
           IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                Navigator.pop(context, selectedItems.map((item) => item.id).toList());
              })
        ]),
      body: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: ListView(
        children: <Widget>[
        textField != null ? textField : Text("loading..."),
        if(selectedItems.length > 0) Padding(padding: EdgeInsets.only(top: 10), child: Text("Selected"),),
        selctedLocationWidget()
      ]))
    );
  }
}