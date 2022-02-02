import 'dart:io';
import 'package:flutter/foundation.dart';

class HistoricSite {
  String uid;
  String siteName;
  String siteDesc;
  String siteAccess;
  double latitude;
  double longitude;
  String address;
  File image;

  HistoricSite({
    @required this.uid,
    @required this.siteName,
    @required this.siteDesc,
    @required this.siteAccess,
    @required this.latitude,
    @required this.longitude,
    this.address,
    @required this.image,
  });
}
