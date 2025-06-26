import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as gmc;
import '../models/camp_item_marker.dart';

Future<Marker> markerBuilder(gmc.Cluster<CampItemMarker> cluster) async {
  if (cluster.isMultiple) {
    final icon = await _createClusterBitmap(cluster.count);
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      icon: icon,
      infoWindow: InfoWindow(
        title: '${cluster.count} campuses',
      ),
    );
  } else {
    final item = cluster.items.first;
    return Marker(
      markerId: MarkerId(item.id),
      position: item.latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: item.label,
      ),
    );
  }
}

Future<BitmapDescriptor> _createClusterBitmap(int count) async {
  const int size = 100;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint()..color = Colors.blue;
  final double radius = size / 2;
  canvas.drawCircle(Offset(radius, radius), radius, paint);

  final textPainter = TextPainter(
    text: TextSpan(
      text: count.toString(),
      style: const TextStyle(
        fontSize: 40,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
  );

  final ui.Image image = await recorder.endRecording().toImage(size, size);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}