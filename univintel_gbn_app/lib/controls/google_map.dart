import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:univintel_gbn_app/models/dashboard_category.dart';
import 'package:univintel_gbn_app/models/map_location.dart';
import 'package:univintel_gbn_app/pages/dashboard/dashboard_categories.dart';

void drawIconOnCanvas(Canvas canvas, IconData icon, double width, double height) {
  var builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      fontFamily: icon.fontFamily,
      fontSize: width * 0.6,
      textAlign: TextAlign.center
    )
  )
  ..pushStyle(new ui.TextStyle(foreground: Paint()..color = Colors.redAccent))
  ..addText(String.fromCharCode(icon.codePoint));
  var paragraph = builder.build();
  paragraph.layout(ui.ParagraphConstraints(width: width));
  canvas.drawParagraph(paragraph, Offset(0, height * 0.20));
}

MaterialColor getColorForPromoteType(String promoteType, bool isDiscount) {
  switch (promoteType) {
    case "gold": return isDiscount ? Colors.yellow : Colors.green;
    case "silver": return isDiscount ? Colors.red : Colors.orange;
  }
  return Colors.blue;
}

MaterialColor getPromoteColor(String discountType, String productType) {
  if (discountType != null && productType != null) {
    var isDiscount = discountType == "gold";

    return getColorForPromoteType(isDiscount ? discountType : productType, isDiscount);
  }

  return getColorForPromoteType(discountType != null ? discountType : productType, discountType != null);
}

Future<Uint8List> getBytesFromCanvas(String text, String category, {String discountType, String productType, int level: 1}) async {
  int width = 24 * level;
  int height = 24 * level;
  double start = height / 2;
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  var outerCircleColor = Colors.blue;

  if (discountType != null || productType != null) outerCircleColor = getPromoteColor(discountType, productType);

  canvas.drawCircle(Offset(start, start), start, Paint()..color = outerCircleColor);
  //canvas.drawCircle(Offset(start, start), start - 4, Paint()..color = Colors.white);
  if (level == 2) {
    if (discountType != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
      painter.text = TextSpan(
        text: "%",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent
        ),
      );
      painter.layout();
      painter.paint(canvas, Offset(width * 0.5 - painter.width * 0.5, height * 0.5 - painter.height * 0.5));
    }
    if (discountType == null) {
      var categoryItem = getCategoryModelsWithoutTranslations().firstWhere((element) => element.id == category);  
      drawIconOnCanvas(canvas, categoryItem.icon, width.toDouble(), height.toDouble());
    }
  }
  final img = await pictureRecorder.endRecording().toImage(width, height);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({this.latitude, this.longitude});
}

typedef MarkerTapHandler = void Function(String id);

class GoogleMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final List<MapLocation> markers;
  final Function markerTapHandler;

  GoogleMapView({Key key, this.latitude, this.longitude, this.zoom, this.markers, this.markerTapHandler}): super(key: key);

  @override
  State<GoogleMapView> createState() => GoogleMapViewState(markers);

}

class GoogleMapViewState extends State<GoogleMapView> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List<MapLocation> initialMarkers;
  List<DashboardCategory> categories;
  double currentZoom;

  GoogleMapViewState(List<MapLocation> mapMarkers) {
    initialMarkers = mapMarkers;
  }

  @override
  void initState() {
    super.initState();

    currentZoom = widget.zoom;

    for (var marker in initialMarkers) add(marker, tapHandler: widget.markerTapHandler);
    initialMarkers.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) categories = getCategoryModels(context);

    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: widget.zoom,
        ),
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapToolbarEnabled: true,
        markers: Set<Marker>.of(markers.values),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);

          setState(() {
            mapController = controller;
            controller.setMapStyle("[{\"featureType\": \"poi\",\"stylers\": [{\"visibility\": \"off\"}]}]");
          });
        },
        onCameraIdle: () {
          
        },
        onCameraMove: (CameraPosition position) {
          currentZoom = position.zoom;
        },
    );
  }

  void refreshMarkers(List<MapLocation> locations) {
    markers.clear();
    for (var marker in locations) add(marker, tapHandler: widget.markerTapHandler);
  }

  Future<void> goToPosition(double latitude, double longitude, {double bearing = 0, double tilt = 0, double zoom = 0}) async {
    final GoogleMapController controller = await _controller.future;
    var position = CameraPosition(target: LatLng(latitude, longitude), bearing: bearing, tilt: tilt, zoom: zoom);
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  Future<void> goToMarker(String id) async {
    Marker targetMarker;
    markers.forEach((key, value) {
      if (key.value == id) targetMarker = value;
      return false;
    });

    final GoogleMapController controller = await _controller.future;
    var position = CameraPosition(target: targetMarker.position, bearing: 0, tilt: 0, zoom: currentZoom);
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  Future<Coordinates> getCurrentPosition(BuildContext context) async {
    //WORKAROUND: https://github.com/flutter/flutter/issues/41653
    final devicePixelRatio = Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;

   var _latLng = await mapController.getLatLng(
    ScreenCoordinate(
        x: (context.size.width * devicePixelRatio) ~/ 2.0,
        y: (context.size.height * devicePixelRatio) ~/ 2.0,
      )
    );

    return Coordinates(latitude: _latLng.latitude, longitude: _latLng.longitude);
  }

  void add(MapLocation mapLocation, {Function tapHandler}) async {
    final level = mapLocation.discountType != null || mapLocation.productType != null ? 2 : 1;
    final Uint8List markerIcon = await getBytesFromCanvas(
      mapLocation.name + " " + mapLocation.company,
      mapLocation.category,
      discountType: mapLocation.discountType,
      productType: mapLocation.productType,
      level: level
    );

    final MarkerId markerId = MarkerId(mapLocation.id);

    //BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context), assetName)

    final Marker marker = Marker(
      markerId: markerId,
      anchor: Offset(0.01, 0),
      flat: true,
      zIndex: level.toDouble(),
      position: LatLng(
        mapLocation.latitude,
        mapLocation.longitude,
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      onTap: () {
        if (tapHandler != null) tapHandler(mapLocation.id);
      }
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

}