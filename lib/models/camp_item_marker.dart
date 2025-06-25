import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart' as gmc;
import 'package:dart_geohash/dart_geohash.dart';

class CampItemMarker implements gmc.ClusterItem<CampItemMarker> {
  final String id;
  final String label;
  final LatLng latLng;

  CampItemMarker({
    required this.id,
    required this.label,
    required this.latLng,
  });

  @override
  LatLng get location => latLng;

  @override
  String get geohash => GeoHasher().encode(
    latLng.latitude,
    latLng.longitude,
  );

  @override
  CampItemMarker get item => this;
}
