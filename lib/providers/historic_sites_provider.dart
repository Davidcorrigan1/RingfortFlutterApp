import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../helpers/location_helper.dart';
import '../models/historic_site.dart';

class HistoricSitesProvider with ChangeNotifier {
  // private list of sites
  List<HistoricSite> _sites = [];

  // This is a getter for the private sites list which
  // should be used to access sites outside the class
  List<HistoricSite> get sites {
    return [..._sites];
  }

  // Returns a single Ringfort Site by the uid.
  HistoricSite findSiteById(String uid) {
    return _sites.firstWhere((site) => site.uid == uid);
  }

  // Add a new site to the List
  void addSite(HistoricSite site) async {
    // get the address for the lat, lng coordinates picked.
    final addressMap = await LocationHelper.getLatLngPositionAddress(
        site.latitude, site.longitude);

    final newSite = HistoricSite(
        uid: DateTime.now().toString(),
        siteName: site.siteName,
        siteDesc: site.siteDesc,
        siteAccess: site.siteAccess,
        latitude: site.latitude,
        longitude: site.longitude,
        siteSize: site.siteSize,
        address: addressMap['address'],
        county: addressMap['county'],
        province: addressMap['province'],
        image: site.image);

    print(newSite.province);
    print(newSite.county);
    _sites.add(newSite);
    notifyListeners();
  }

  // This will find the site to be updated and update it.
  void updateSite(String uid, HistoricSite updatedSite) async {
    final siteIndex = _sites.indexWhere((site) => site.uid == uid);

    // get the address for the lat, lng coordinates picked 
    //if (_sites[siteIndex].latitude != updatedSite.latitude ||
    //    _sites[siteIndex].longitude != updatedSite.longitude) {
      final addressMap = await LocationHelper.getLatLngPositionAddress(
          updatedSite.latitude, updatedSite.longitude);
      updatedSite.address = addressMap['address'];
      updatedSite.county = addressMap['county'];
      updatedSite.province = addressMap['province'];
    //}

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
