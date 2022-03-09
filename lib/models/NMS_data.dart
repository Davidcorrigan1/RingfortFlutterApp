import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Function to convert from firestore snapshot into a NMSData object
  // Getting the uid from the document reference id.
  factory NMSData.fromFirestore(DocumentSnapshot document) {
    final newNMSData = NMSData.fromJson(document.data());

    newNMSData.uid = document.reference.id;

    return newNMSData;
  }

// Convert a NMSData object into a map of key/value pairs.
  Map<String, dynamic> _NMSDataToJson(NMSData instance) => <String, dynamic>{
        'uid': instance.uid,
        'siteName': instance.siteName,
        'siteDesc': instance.siteDesc,
        'latitude': instance.latitude.toString(),
        'longitude': instance.longitude.toString(),
      };
}
