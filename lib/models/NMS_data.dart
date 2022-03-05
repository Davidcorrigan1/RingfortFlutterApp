import 'package:flutter/foundation.dart';

// This class defines the National Monument Services Data. This data was
// downloaded from the National Monument Services website into csv
// and then loaded in a separate Firestore collection called NMS-Ringforts
class NMSData {
  String uid;
  String siteName;
  String siteDesc;
  double latitude;
  double longitude;

  // Class constructor
  NMSData(
      {@required this.uid,
      @required this.siteName,
      @required this.siteDesc,
      @required this.latitude,
      @required this.longitude});

  // A factory constructor to create NMSData object from JSON
  factory NMSData.fromJson(Map<String, dynamic> json) {
    return NMSData(
      uid: json['uid'] ?? '',
      siteName: json['siteName'] ?? '',
      siteDesc: json['siteDesc'] ?? '',
      latitude: double.parse(json['latitude']) ?? 0.0,
      longitude: double.parse(json['longitude']) ?? 0.0,
    );
  }

  // Function to turn Ringfort object to a Map of key values pairs
  Map<String, dynamic> toJson() => _NMSDataToJson(this);
}

// Convert a NMSData object into a map of key/value pairs.
Map<String, dynamic> _NMSDataToJson(NMSData instance) => <String, dynamic>{
      'uid': instance.uid,
      'siteName': instance.siteName,
      'siteDesc': instance.siteDesc,
      'latitude': instance.latitude.toString(),
      'longitude': instance.longitude.toString(),
    };
