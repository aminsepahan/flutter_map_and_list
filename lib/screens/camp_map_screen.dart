import 'dart:async';
import 'dart:typed_data';
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
  final Completer<GoogleMapController> _mapController = Completer();
  late final gmc.ClusterManager<CampItemMarker> _clusterManager;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _clusterManager = gmc.ClusterManager<CampItemMarker>(
      widget.campItems,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: [1, 5, 10, 15, 20],
      extraPercent: 0.2,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() => _markers = markers);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    _clusterManager.setMapId(controller.mapId);
    // Center on selected camp if provided
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

  /// Generates a circular cluster icon displaying the count
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

  /// Custom marker builder that highlights the selected camp
  Future<Marker> _markerBuilder(gmc.Cluster<CampItemMarker> cluster) async {
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
      final bool isSelected = widget.selectedCamp?.id == item.id;
      return Marker(
        markerId: MarkerId(item.id),
        position: item.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: item.label,
          snippet: isSelected ? 'Selected Campus' : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.selectedCamp?.latLng ??
        (widget.campItems.isNotEmpty
            ? widget.campItems.first.latLng
            : const LatLng(52.5200, 13.4050));

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: widget.selectedCamp != null ? 15 : 10,
        ),
        markers: _markers,
        onMapCreated: _onMapCreated,
        onCameraMove: _onCameraMove,
        onCameraIdle: _onCameraIdle,
      ),
    );
  }
}