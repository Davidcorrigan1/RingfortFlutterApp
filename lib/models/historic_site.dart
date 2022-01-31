import 'dart:io';
import 'package:flutter/foundation.dart';

class HistoricSite {
  final String uid;
  final String siteName;
  final String siteDesc;
  final double latitude;
  final double longitude;
  final String address;
  final File image;

  HistoricSite({
    @required this.uid,
    @required this.siteName,
    @required this.siteDesc,
    @required this.latitude,
    @required this.longitude,
    this.address,
    @required this.image,
  });
}
