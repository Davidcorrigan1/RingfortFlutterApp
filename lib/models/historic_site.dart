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
  String lastUpdatedBy;
  String createdBy;

  // Class constructor
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
    @required this.lastUpdatedBy,
    @required this.createdBy,
  });

  // A factory constructor to create Ringfort object from JSON
  factory HistoricSite.fromJson(Map<String, dynamic> json) {
    return HistoricSite(
        uid: json['uid'] ?? '',
        siteName: json['siteName'] ?? '',
        siteDesc: json['siteDesc'] ?? '',
        siteAccess: json['siteAccess'] ?? '',
        siteSize: json['siteSize'] ?? 0.0,
        latitude: json['latitude'] ?? 0.0,
        longitude: json['longitude'] ?? 0.0,
        address: json['address'] ?? '',
        province: json['province'] ?? '',
        county: json['county'] ?? '',
        image: json['image'] ?? '',
        lastUpdatedBy: json['lastUpdatedBy'] ?? '',
        createdBy: json['createdBy']);
  }

  // Function to turn Ringfort object to a Map of key values pairs
  Map<String, dynamic> toJson() => _historicSiteToJson(this);
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
      'lastUpdatedBy': instance.lastUpdatedBy,
      'createdBy': instance.createdBy
    };
