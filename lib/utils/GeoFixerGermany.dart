import 'dart:math' as math;

import '../models/camp_site.dart';

// Germany as a Box
const double _targetLatMin = 47.27;   // southernmost point
const double _targetLatMax = 55.06;   // northernmost point
const double _targetLngMin = 5.87;    // westernmost point
const double _targetLngMax = 15.04;   // easternmost point

//
extension GeoFixerGermany on List<CampSite> {
  List<CampSite> mapAndScaleToGermany() {
    if (isEmpty) return [];

    // Gather raw min/max
    final rawLats  = map((c) => c.geoLocation.lat);
    final rawLngs  = map((c) => c.geoLocation.long);
    final rawLatMin = rawLats.reduce(math.min);
    final rawLatMax = rawLats.reduce(math.max);
    final rawLngMin = rawLngs.reduce(math.min);
    final rawLngMax = rawLngs.reduce(math.max);

    return map((c) {
      final rawLat = c.geoLocation.lat;
      final rawLng = c.geoLocation.long;

      // Linear interpolation into Western Europe box
      final newLat = _targetLatMin +
          (rawLat - rawLatMin) /
              (rawLatMax - rawLatMin) *
              (_targetLatMax - _targetLatMin);
      final newLng = _targetLngMin +
          (rawLng - rawLngMin) /
              (rawLngMax - rawLngMin) *
              (_targetLngMax - _targetLngMin);

      return CampSite(
        id: c.id,
        label: c.label,
        pricePerNight: c.pricePerNight,
        photo: c.photo,
        geoLocation: GeoLocation(lat: newLat, long: newLng),
        isCampFireAllowed: c.isCampFireAllowed,
        isCloseToWater: c.isCloseToWater,
      );
    }).toList();
  }
}
