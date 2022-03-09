import 'package:flutter/foundation.dart';

import '../models/historic_site.dart';

class HistoricSiteStaging {
  String uid;
  String action;
  DateTime actionDate;
  String actionStatus;
  String actionedBy;
  HistoricSite updatedSite;
  String nmdUID;

  // Class constructor
  HistoricSiteStaging({
    @required this.uid,
    @required this.action,
    @required this.actionDate,
    @required this.actionStatus,
    @required this.actionedBy,
    @required this.updatedSite,
    @required this.nmdUID,
  });

  // A factory constructor to create Ringfort object from JSON
  factory HistoricSiteStaging.fromJson(Map<String, dynamic> json) {
    return HistoricSiteStaging(
        uid: json['uid'] ?? '',
        action: json['action'] ?? '',
        actionDate: json['actionDate'].toDate() ?? DateTime.now(),
        actionStatus: json['actionStatus'] ?? '',
        actionedBy: json['actionedBy'] ?? '',
        updatedSite:
            HistoricSite.fromJson(json['updatedSite'] as Map<String, dynamic>),
        nmdUID: json['nmdUID'] ?? '');
  }

  // Function to turn Ringfort object to a Map of key values pairs
  Map<String, dynamic> toJson() => _historicSiteStagingToJson(this);
}

// Convert a historicSite object into a map of key/value pairs.
Map<String, dynamic> _historicSiteStagingToJson(HistoricSiteStaging instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'action': instance.action,
      'actionDate': instance.actionDate,
      'actionStatus': instance.actionStatus,
      'actionedBy': instance.actionedBy,
      'updatedSite': instance.updatedSite.toJson(),
      'nmdUID': instance.nmdUID,
    };
