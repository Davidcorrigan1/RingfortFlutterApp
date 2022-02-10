import 'package:flutter/foundation.dart';


class HistoricSite {
  String uid;
  String siteName;
  String siteDesc;
  String siteAccess;
  double latitude;
  double longitude;
  double siteSize;
  String address;
  String province;
  String county;
  String image;

  HistoricSite({
    @required this.uid,
    @required this.siteName,
    @required this.siteDesc,
    @required this.siteAccess,
    @required this.latitude,
    @required this.longitude,
    @required this.siteSize,
    this.address,
    this.province,
    this.county,
    @required this.image,
  });

  // A factory constructor to create Ringfort object from JSON
  factory HistoricSite.fromJson(Map<String, dynamic> json) =>
      _historicSiteFromJson(json);

  // Function to turn Ringfort object to a Map of key values pairs
  Map<String, dynamic> toJson() => _historicSiteToJson(this);
}

// Add a function to convert a map of key/value pairs into a historicSite object
HistoricSite _historicSiteFromJson(Map<String, dynamic> json) {
  return HistoricSite(
      uid: json['uid'] as String,
      siteName: json['siteName'] as String,
      siteDesc: json['siteDesc'] as String,
      siteAccess: json['siteAccess'] as String,
      siteSize: json['siteSize'] as double,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
      province: json['province'] as String,
      county: json['county'] as String,
      image: json['image'] as String);
}

// Convert a historicSite object into a map of key/value pairs.
Map<String, dynamic> _historicSiteToJson(HistoricSite instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'siteName': instance.siteName,
      'siteDesc': instance.siteDesc,
      'siteAccess': instance.siteAccess,
      'siteSize': instance.siteSize,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'province': instance.province,
      'county': instance.county,
      'image': instance.image,
    };
