import 'dart:convert';

class CampSite {
  final String id;
  final String label;
  final GeoLocation geoLocation;
  final bool isCloseToWater;
  final bool isCampFireAllowed;
  final double pricePerNight;
  final String? photo;

  CampSite(
      {required this.id,
      required this.label,
      required this.geoLocation,
      required this.pricePerNight,
       this.photo,
       this.isCampFireAllowed=false,
       this.isCloseToWater=false});

  factory CampSite.fromRawJson(String str) => CampSite.fromJson(json.decode(str));

  factory CampSite.fromJson(Map<String, dynamic> json) => CampSite(
        id: json["id"],
        label: json["label"],
        pricePerNight: json["pricePerNight"],
        photo: json["photo"],
        geoLocation: GeoLocation.fromJson(json['geoLocation']),
        isCampFireAllowed: json["isCampFireAllowed"],
        isCloseToWater: json["isCloseToWater"],
      );
}

class GeoLocation {
  double lat;
  double long;

  GeoLocation({required this.lat, required this.long});

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      lat: json['lat'],
      long: json['long'],
    );
  }
}
