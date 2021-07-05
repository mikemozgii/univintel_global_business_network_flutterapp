import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../localization.dart';

InputDecoration textInputDecoration(String hint, IconData icon) {
  return new InputDecoration(
    labelText: hint,
    icon: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: new Icon(
        icon,
        color: Colors.grey,
      )
    ) 
  );
}

Color systemGrayColor() {
  return Color.fromRGBO(130, 144, 157, 1);
}

Color systemGrayColorWithOpacity(opacity) {
  return Color.fromRGBO(130, 144, 157, opacity);
}

Color systemLinkColor() {
  return Color.fromRGBO(129, 176, 213, 1);
}

InputDecoration textHintDecoration(String hint) {
  return new InputDecoration(
    labelText: hint
  );
}

InputDecoration textHintDecorationSeparated(String hint, String label) {
  return new InputDecoration(
    hintText: hint,
    labelText: label
  );
}

InputDecoration textHintDecorationWithoutLabel(String hint) {
  return new InputDecoration(
    hintText: hint
  );
}


Widget formPadding(Widget widget) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(9, 11.0, 9, 0.0),
    child: widget
  );
}

Widget formPaddingWithoutTop(Widget widget) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
    child: widget
  );
}

Widget formPaddingWithVisible(Widget widget, bool isVisible) {
  if (!isVisible) return Container();

  return formPadding(widget);
}

Scaffold loadingScaffold() {
  return Scaffold(
    body: Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(57, 164, 255, 1))))
  );
}

BoxDecoration listSeparatingBorder(BuildContext context, {bool isUp = false}) {
  return BoxDecoration(
    border: isUp ? Border(top: BorderSide(color: Theme.of(context).dividerColor)) : Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
  );
}

BoxDecoration boxSeparatingBorder(BuildContext context) {
  return BoxDecoration(
    border: Border(
      bottom: BorderSide(color: Theme.of(context).dividerColor),
      top: BorderSide(color: Theme.of(context).dividerColor)
    ),
  );
}

List<Widget> elementsSpacing(List<Widget> widgets, double spaceBetween) {
  var result = new List<Widget>();

  for (var widget in widgets) {
    result.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, spaceBetween, 0),
        child: widget
      )
    );
  }

  return result;
}

Future<File> getCroppedImage({CropStyle cropStyle = CropStyle.circle}) async {
  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  if(image == null) return null;
  File file = await ImageCropper.cropImage(
    sourcePath: image.path,
    cropStyle: cropStyle,
    aspectRatioPresets: [
      CropAspectRatioPreset.square
    ],
    androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false),
    iosUiSettings: IOSUiSettings(
      minimumAspectRatio: 1.0,
    )
  );
  return file;
}

SlideActionBuilderDelegate getDefaultDeleteSlideAction(Function onDelete) {
  return SlideActionBuilderDelegate(
    actionCount: 1,
    builder: (context, index, animation, renderingMode) {
      return IconSlideAction(
        color: renderingMode == SlidableRenderingMode.slide
            ? Colors.red.withOpacity(animation.value)
            : Colors.red,
        icon: Icons.delete,
        onTap: () => onDelete(),
      );
  });
}

void defaultInsertItem<T>(T item, List<T> items, {int position = -1}){
  if(position == -1 || items.length <= position) items.add(item);
  else items.insert(position, item); 
}

Future<bool> Function(SlideActionType) getOnWillDeleteDismiss(Function onDelete) => (SlideActionType type) {
  if(type == SlideActionType.secondary) {
    onDelete();
    return Future.value(true);
  }
  else return Future.value(false);
};

Widget getSlidableBuilder(BuildContext context, Widget child, Key key, 
                          SlideActionBuilderDelegate actionDelegate, 
                          SlideActionBuilderDelegate secondaryActionDelegate,
                          Future<bool> Function(SlideActionType) onWillDismiss) {
  return Slidable.builder(
    key: key,
    direction: Axis.horizontal,
    actionPane: SlidableDrawerActionPane(),
    secondaryActionDelegate: secondaryActionDelegate,
    actionDelegate: actionDelegate,
    dismissal: SlidableDismissal(
      child: SlidableDrawerDismissal(),
      onWillDismiss: onWillDismiss,
      closeOnCanceled: true,
    ),
    child: child
  );
}

Widget getAccountRankDecoration(BuildContext context, String accountRank) {
  if(accountRank == "free")
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color.fromRGBO(129, 176, 213, 1), borderRadius: BorderRadius.all(Radius.circular(3))),
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: Text(UnivIntelLocale.of(context, accountRank), style: TextStyle(fontSize: 15, color: Colors.white)),
      ),
    );
  if(accountRank == "premium")
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 131, 108, 59), borderRadius: BorderRadius.all(Radius.circular(3))),
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: Text(UnivIntelLocale.of(context, accountRank), style: TextStyle(fontSize: 15, color: Colors.white)),
      ),
    );
  
  return Container();
}
