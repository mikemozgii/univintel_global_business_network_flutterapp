import 'package:flutter/material.dart';
import 'package:univintel_gbn_app/globals.dart';

class AvatarBox extends StatefulWidget {
  final String id;
  final double radius;
  final Function onTap;
  final Function onDoubleTap;
  final bool squared;
  final bool roundedCorners;
  final String localFileIfNotSpecifiedPath;
  final bool isDocumentImage;

  AvatarBox(this.id, this.radius, { Key key, this.onTap, this.onDoubleTap, this.localFileIfNotSpecifiedPath, this.squared = false, this.isDocumentImage = false, this.roundedCorners = false});

  @override
  State<StatefulWidget> createState() => AvatarBoxState();

}

class AvatarBoxState extends State<AvatarBox> {
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) widget.onTap();
      },
      onDoubleTap: () {
        if (widget.onDoubleTap != null) widget.onDoubleTap();
      },
      child: getAvatarWidget(),
    );
  }

  NetworkImage getNetworkImage() {
    return widget.isDocumentImage ? apiService.getNetworkImageFromFiles(widget.id) : apiService.getNetworkImage(widget.id);
  }

  Widget getAvatarWidget() {
    final img = widget.id != "" && widget.id != null ? getNetworkImage() : (widget.localFileIfNotSpecifiedPath != null ? ExactAssetImage(widget.localFileIfNotSpecifiedPath) : getNetworkImage());
    if(widget.id == "" && (widget.onDoubleTap != null || widget.onTap != null))
    
      return Container(
        width: widget.radius * 2,
        child: Center(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Icon(Icons.add_photo_alternate, size: widget.radius),
        )),
      );
    if(widget.squared) {
      var imageWidget = Image(
        image: img,
        height: widget.radius * 2,
        width: widget.radius * 2
      );
      return ClipRRect(
        borderRadius: widget.roundedCorners ? BorderRadius.circular(14) : BorderRadius.circular(1),
        child: imageWidget
      );
    }
    else 
      return CircleAvatar(
        backgroundImage: img,
        radius: widget.radius,
      );
  }
}