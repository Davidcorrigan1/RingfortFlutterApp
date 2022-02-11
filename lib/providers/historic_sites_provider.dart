import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../helpers/location_helper.dart';
import '../models/historic_site.dart';
import '../firebase/firebaseDB.dart';

class HistoricSitesProvider with ChangeNotifier {
  final FirebaseDB firebaseDB = FirebaseDB();

  //-------------------------------------------------------------
  // private list of sites
  //-------------------------------------------------------------
  List<HistoricSite> _sites = [];

  //-------------------------------------------------------------
  // This is a getter for the private sites list which
  // should be used to access sites outside the class
  //-------------------------------------------------------------
  List<HistoricSite> get sites {
    return [..._sites];
  }

  //-------------------------------------------------------------
  // Returns the latest Ringfort data from Firestore and update
  // the local List and then notify comsumer it's changed
  //-------------------------------------------------------------
  Future<void> fetchAndSetRingforts() async {
    final List<HistoricSite> loadedSites = [];
    var snapshot = await firebaseDB.fetchSites();

    final documents = snapshot.docs.map((docs) => docs.data()).toList();
    documents.forEach((site) {
      HistoricSite ringfort = HistoricSite.fromJson(site);
      loadedSites.add(ringfort);
    });
    _sites = loadedSites;
    notifyListeners();
  }

  //-------------------------------------------------------------
  // Returns a single Ringfort Site by the uid.
  //-------------------------------------------------------------
  HistoricSite findSiteById(String uid) {
    return _sites.firstWhere((site) => site.uid == uid);
  }

  //-------------------------------------------------------------
  // Add a new site to the List
  //-------------------------------------------------------------
  void addSite(HistoricSite site, io.File image) async {
    // Get a key for the image file (update later to firebase uid)
    final keyDate = DateTime.now().toString();

    // get the address for the lat, lng coordinates picked.
    final addressMap = await LocationHelper.getLatLngPositionAddress(
        site.latitude, site.longitude);

    print('Just before call to addImage');
    final imageUrl = await FirebaseDB().addImage(image, keyDate);
    print('Just After call to addImage');

    final newSite = HistoricSite(
        uid: keyDate,
        siteName: site.siteName,
        siteDesc: site.siteDesc,
        siteAccess: site.siteAccess,
        latitude: site.latitude,
        longitude: site.longitude,
        siteSize: site.siteSize,
        address: addressMap['address'],
        county: addressMap['county'],
        province: addressMap['province'],
        image: imageUrl);

    print(newSite.province);
    print(newSite.county);
    _sites.add(newSite);

    firebaseDB.addSite(newSite);

    notifyListeners();
  }

  //-------------------------------------------------------------
  // This will find the site to be updated and update it.
  //-------------------------------------------------------------
  void updateSite(String uid, HistoricSite updatedSite, io.File image) async {
    // Get a key for the image file (update later to firebase uid)
    final keyDate = DateTime.now().toString();

    final siteIndex = _sites.indexWhere((site) => site.uid == uid);

    // Store the image in Firebase Storage
    final imageUrl = await FirebaseDB().addImage(image, keyDate);
    print('after call to add image : $imageUrl');
    updatedSite.image = imageUrl;

    // get the address for the lat, lng coordinates picked and update
    final addressMap = await LocationHelper.getLatLngPositionAddress(
        updatedSite.latitude, updatedSite.longitude);
    updatedSite.address = addressMap['address'];
    updatedSite.county = addressMap['county'];
    updatedSite.province = addressMap['province'];

    // Update the RInfort object in the List
    _sites[siteIndex] = updatedSite;
    notifyListeners();
  }

  //---------------------------------------------------------------------
  // This will delete the site which matches the uid
  //---------------------------------------------------------------------
  void deleteSite(String uid) {
    _sites.removeWhere((site) => site.uid == uid);
    notifyListeners();
  }
}
