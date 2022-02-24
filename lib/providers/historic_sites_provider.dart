import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/historic_site_staging.dart';
import '../models/user_data.dart';
import '../models/historic_site.dart';
import '../firebase/firebaseDB.dart';
import '../helpers/location_helper.dart';

class HistoricSitesProvider with ChangeNotifier {
  final FirebaseDB firebaseDB = FirebaseDB();

  //-------------------------------------------------------------
  // private list of ringfort sites and filtered Sites
  // Also a list of Staging changes awaiting approval
  //-------------------------------------------------------------
  List<HistoricSite> _sites = [];
  List<HistoricSite> _filteredSites = [];
  List<HistoricSiteStaging> _stagingSites = [];

  //-------------------------------------------------------------
  // This is a getter for the private sites list which
  // should be used to access sites outside the class
  //-------------------------------------------------------------
  List<HistoricSite> get sites {
    return [..._sites];
  }

  List<HistoricSite> get filteredSites {
    return [..._filteredSites];
  }

  List<HistoricSiteStaging> get stagingSites {
    return [..._stagingSites];
  }

  //-------------------------------------------------------------
  // This method will return the list of filtered sites
  // checking if the search text is present in any of the
  // ringforts fields, and if favourite selected, check if
  // the ringfort uid is one of the users favourites.
  //-------------------------------------------------------------
  void setFilteredSites(
      String searchQuery, bool _showFavourites, UserData userData) {
    if (searchQuery.isEmpty) {
      if (_showFavourites) {
        _filteredSites = _sites.where((ringfort) {
          bool _found = false;
          userData.favourites.forEach((fav) {
            if (fav == ringfort.uid) {
              _found = true;
            }
          });
          return _found;
        }).toList();
      } else {
        _filteredSites = [..._sites];
      }
    } else {
      var _searchedSites = _sites.where((ringfort) {
        return ((ringfort.siteName
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) ||
            (ringfort.siteDesc
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) ||
            (ringfort.province
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) ||
            (ringfort.county
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) ||
            (ringfort.address
                .toLowerCase()
                .contains(searchQuery.toLowerCase())));
      }).toList();
      if (_showFavourites) {
        _filteredSites = _searchedSites.where((ringfort) {
          bool _found = false;
          userData.favourites.forEach((fav) {
            if (fav == ringfort.uid) {
              _found = true;
            }
          });
          return _found;
        }).toList();
      } else {
        _filteredSites = [..._searchedSites];
      }
    }
    notifyListeners();
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
  // Returns the latest Staging Ringfort data from Firestore and update
  // the local List and then notify comsumer it's changed
  //-------------------------------------------------------------
  Future<void> fetchAndSetStagingRingforts() async {
    final List<HistoricSiteStaging> loadedSites = [];
    var snapshot = await firebaseDB.fetchStagingSites();

    final documents = snapshot.docs.map((docs) => docs.data()).toList();
    documents.forEach((site) {
      HistoricSiteStaging ringfort = HistoricSiteStaging.fromJson(site);
      loadedSites.add(ringfort);
    });
    _stagingSites = loadedSites;
    notifyListeners();
  }

  //-------------------------------------------------------------
  // Returns a single Ringfort Site by the uid.
  //-------------------------------------------------------------
  HistoricSite findSiteById(String uid) {
    return _sites.firstWhere((site) => site.uid == uid);
  }

  //-------------------------------------------------------------
  // Returns a single Staging Ringfort Site by the uid.
  //-------------------------------------------------------------
  HistoricSiteStaging findStagingSiteById(String uid) {
    return _stagingSites.firstWhere((site) => site.uid == uid);
  }

  //-------------------------------------------------------------
  // Add a new site to the List
  //-------------------------------------------------------------
  void addSite(UserData userData, HistoricSite site, io.File image) async {
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
      image: imageUrl,
      lastUpdatedBy: site.lastUpdatedBy,
      createdBy: site.createdBy,
    );

    // Set up the site data for staging
    final newStagingSite = HistoricSiteStaging(
        uid: site.uid,
        action: 'add',
        actionDate: DateTime.now(),
        actionStatus: 'awaiting',
        actionedBy: userData.uid,
        updatedSite: newSite);

    if (userData.adminUser) {
      // adding site to local site list, but only if admin user.
      _sites.add(newSite);
    } else {
      // else add it to the local staging list
      _stagingSites.add(newStagingSite);
    }

    _filteredSites = [..._sites];

    // adding to Firebase Firestore
    firebaseDB.addSite(userData.adminUser, newSite, newStagingSite);
    // Notify consumers of changes
    notifyListeners();
  }

  //-------------------------------------------------------------
  // This will find the site to be updated and update it.
  //-------------------------------------------------------------
  void updateSite(
      String siteUid, HistoricSite updatedSite, io.File image) async {
    final siteIndex = _sites.indexWhere((site) => site.uid == siteUid);

    // Store the image in Firebase Storage
    final imageUrl = await FirebaseDB().addImage(image, siteUid);
    if (!imageUrl.isEmpty) {
      updatedSite.image = imageUrl;
    }

    // get the address for the lat, lng coordinates picked and update
    final addressMap = await LocationHelper.getLatLngPositionAddress(
        updatedSite.latitude, updatedSite.longitude);
    updatedSite.address = addressMap['address'];
    updatedSite.county = addressMap['county'];
    updatedSite.province = addressMap['province'];

    // Update the Rinfort object in the List
    _sites[siteIndex] = updatedSite;
    _filteredSites = [..._sites];

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

  //----------------------------------------------------------------------
  //  This will approve the staging site. Adding it to the historicSites
  // collection and updating on the historicSitesStaging to approved
  //----------------------------------------------------------------------
  void approveStagingSite(String uid) {
    // Find the staging site object
    var historicSiteStaging =
        _stagingSites.firstWhere((site) => site.uid == uid);

    // Add to local sites
    _sites.add(historicSiteStaging.updatedSite);

    // Adding to Firebase Firestore
    firebaseDB.addSite(true, historicSiteStaging.updatedSite, null);

    // delete from the local staging site table
    _stagingSites.removeWhere((site) => site.uid == historicSiteStaging.uid);

    // delete from the historicSitesStaging firestore collection
    firebaseDB.deleteStagingSite(historicSiteStaging.uid);

    notifyListeners();
  }
}
