import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../helpers/location_helper.dart';
import '../models/historic_site.dart';
import '../firebase/firebaseDB.dart';

class HistoricSitesProvider with ChangeNotifier {
  final FirebaseDB firebaseDB = FirebaseDB();

  //-------------------------------------------------------------
  // private list of ringfort sites
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
    // generate a document id for the new document on FB
    var docId = await firebaseDB.generateDocumentId();
    site.uid = docId;

    // get the address for the lat, lng coordinates picked.
    final addressMap = await LocationHelper.getLatLngPositionAddress(
        site.latitude, site.longitude);

    // adding the image to Firebase storage
    final imageUrl = await FirebaseDB().addImage(image, docId);

    // waiting for the firebase storage o return a Url to store with site
    final newSite = HistoricSite(
        uid: site.uid,
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

    // adding site to local list
    _sites.add(newSite);

    // adding to Firebase Firestore
    firebaseDB.addSite(newSite);
    // Notify consumers of changes
    notifyListeners();
  }

  //-------------------------------------------------------------
  // This will find the site to be updated and update it.
  //-------------------------------------------------------------
  void updateSite(String uid, HistoricSite updatedSite, io.File image) async {
    final siteIndex = _sites.indexWhere((site) => site.uid == uid);

    // Store the image in Firebase Storage
    final imageUrl = await FirebaseDB().addImage(image, uid);
    if (!imageUrl.isEmpty) {
      updatedSite.image = imageUrl;
    }

    // get the address for the lat, lng coordinates picked and update
    final addressMap = await LocationHelper.getLatLngPositionAddress(
        updatedSite.latitude, updatedSite.longitude);
    updatedSite.address = addressMap['address'];
    updatedSite.county = addressMap['county'];
    updatedSite.province = addressMap['province'];

    // Update the RInfort object in the List
    _sites[siteIndex] = updatedSite;

    // Update the document on Firestore
    firebaseDB.updateSite(updatedSite);

    // Notify comsumers of the data
    notifyListeners();
  }

  //---------------------------------------------------------------------
  // This will delete the site which matches the uid
  //---------------------------------------------------------------------
  void deleteSite(String uid) {
    _sites.removeWhere((site) => site.uid == uid);
    firebaseDB.deleteSite(uid);
    notifyListeners();
  }
}
