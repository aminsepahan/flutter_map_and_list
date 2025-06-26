// lib/models/camp_item_marker.dart

import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CampItemMarker with ClusterItem {
  final String id;
  final String label;
  final double lat;
  final double lng;

  CampItemMarker({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
  });

  /// required by ClusterItem
  @override
  LatLng get location => LatLng(lat, lng);

  /// optional: override if you want your own geohash logic
  @override
  String get geohash => GeoHasher().encode(
    lat,
    lng,
  );

  LatLng get latLng => LatLng(lat, lng);
}
