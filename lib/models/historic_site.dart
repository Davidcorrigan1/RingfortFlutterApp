import 'dart:io';
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
  File image;

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
}
