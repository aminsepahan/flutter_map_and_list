// lib/screens/camp_map_screen.dart

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as gmc;
import '../models/camp_item_marker.dart';

class CampMapScreen extends StatefulWidget {
  final List<CampItemMarker> campItems;
  final CampItemMarker? selectedCamp;

  const CampMapScreen({
    Key? key,
    required this.campItems,
    this.selectedCamp,
  }) : super(key: key);

  @override
  _CampMapScreenState createState() => _CampMapScreenState();
}

class _CampMapScreenState extends State<CampMapScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  late GoogleMapController _gmapController;
  late final gmc.ClusterManager<CampItemMarker> _clusterManager;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _clusterManager = gmc.ClusterManager<CampItemMarker>(
      widget.campItems,
      _updateMarkers,
      markerBuilder: _markerBuilder,
    );
  }

  @override
  void didUpdateWidget(covariant CampMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.campItems != oldWidget.campItems) {
      _clusterManager.setItems(widget.campItems);
      _clusterManager.updateMap();
    }
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() => _markers = markers);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapControllerCompleter.complete(controller);
    _gmapController = controller;
    _clusterManager.setMapId(controller.mapId);
    if (widget.selectedCamp != null) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(widget.selectedCamp!.latLng, 15),
      );
    }
    _clusterManager.updateMap();
  }

  void _onCameraMove(CameraPosition position) {
    _clusterManager.onCameraMove(position);
  }

  void _onCameraIdle() {
    _clusterManager.updateMap();
  }

  Future<Marker> _markerBuilder(gmc.Cluster<CampItemMarker> cluster) async {
    if (cluster.isMultiple) {
      final icon = await _createClusterBitmap(cluster.count);
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: icon,
        onTap: () async {
          final zoom = await _gmapController.getZoomLevel();
          _gmapController.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, zoom + 1),
          );
        },
        infoWindow: InfoWindow(title: '${cluster.count} items'),
      );
    } else {
      final item = cluster.items.first;
      final bool isSelected = widget.selectedCamp?.id == item.id;
      final icon = await _createSingleMarkerBitmap(
        isSelected ? BitmapDescriptor.hueGreen : null,
      );
      return Marker(
        markerId: MarkerId(item.id),
        position: item.latLng,
        icon: icon,
        infoWindow: InfoWindow(
          title: item.label,
          snippet: isSelected ? 'Selected Campus' : null,
        ),
      );
    }
  }

  Future<BitmapDescriptor> _createSingleMarkerBitmap(double? hue) async {
    if (hue != null) {
      // keep the green highlight for selected pins
      return BitmapDescriptor.defaultMarkerWithHue(hue);
    }
    // Non‐selected: use your custom PNG
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/tent.png',
    );
  }

  Future<BitmapDescriptor> _createClusterBitmap(int count) async {
    const int size = 40;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Color(0xFF68B4A8);
    final radius = size / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: const TextStyle(
          fontSize: 20,
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

    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.selectedCamp?.latLng ??
        (widget.campItems.isNotEmpty
            ? widget.campItems.first.latLng
            : const LatLng(52.5200, 13.4050));

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: widget.selectedCamp != null ? 15 : 10,
      ),
      markers: _markers,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
    );
  }
}
