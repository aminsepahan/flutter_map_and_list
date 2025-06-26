// lib/models/camp_item_marker.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:dart_geohash/dart_geohash.dart';

class CampItemMarker with ClusterItem {
  final String id;
  final String label;
  final LatLng latLng;

  CampItemMarker({
    required this.id,
    required this.label,
    required this.latLng,
  });

  /// required by ClusterItem
  @override
  LatLng get location => latLng;

  /// optional: override if you want your own geohash logic
  @override
  String get geohash => GeoHasher().encode(
    latLng.latitude,
    latLng.longitude,
  );
}
