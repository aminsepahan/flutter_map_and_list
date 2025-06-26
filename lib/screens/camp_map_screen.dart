import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart' as gmc;
import 'package:road_surfer_task/models/camp_item_marker.dart';
import 'package:road_surfer_task/models/camp_site.dart';

final campsitesProvider = StateProvider<List<CampSite>>((ref) => []);

final clusterItemsProvider = Provider<List<CampItemMarker>>((ref) {
  final camps = ref.watch(campsitesProvider);
  return camps
      .map((camp) => CampItemMarker(
    id: camp.id,
    label: camp.label,
    latLng: LatLng(camp.geoLocation.lat, camp.geoLocation.long),
  ))
      .toList();
});

class CampMapScreen extends ConsumerStatefulWidget {
  final List<CampSite> campsites;
  final CampSite selectedCampSite;

  const CampMapScreen({
    super.key,
    required this.campsites,
    required this.selectedCampSite,
  });

  @override
  ConsumerState<CampMapScreen> createState() => _CampMapScreenState();
}

class _CampMapScreenState extends ConsumerState<CampMapScreen> {
  Set<Marker> _markers = {};
  final _completer = Completer<GoogleMapController>();
  gmc.ClusterManager<CampItemMarker>? _clusterManager;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campsitesProvider.notifier).state = widget.campsites;
      _initCluster();
    });
  }

  void _initCluster() {
    final items = ref.read(clusterItemsProvider);
    _clusterManager = gmc.ClusterManager<CampItemMarker>(
      items,
      _updateMarkers,
      markerBuilder: (dynamic c) => _markerBuilder(c as gmc.Cluster<CampItemMarker>),
      stopClusteringZoom: 17,
    );
  }

  void _updateMarkers(Set<Marker> markers) => setState(() => _markers = markers);

  Future<Marker> _markerBuilder(gmc.Cluster<CampItemMarker> cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      infoWindow: cluster.isMultiple
          ? InfoWindow(title: 'number of camps: ${cluster.count}')
          : InfoWindow(title: cluster.items.first?.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onCameraMove: _clusterManager?.onCameraMove,
      onCameraIdle: _clusterManager?.updateMap,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.selectedCampSite.geoLocation.lat,
          widget.selectedCampSite.geoLocation.long,
        ),
        zoom: 14,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);

    // trigger initial cluster pass
    final pos = CameraPosition(
      target: LatLng(
        widget.selectedCampSite.geoLocation.lat,
        widget.selectedCampSite.geoLocation.long,
      ),
      zoom: 14,
    );
    _clusterManager?.onCameraMove(pos);
    _clusterManager?.updateMap();
  }
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted && kDebugMode) {
        print("Location permission denied");
      }
    }
  }

}

