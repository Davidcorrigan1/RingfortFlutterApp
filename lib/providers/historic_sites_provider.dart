import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/historic_site.dart';

class HistoricSitesProvider with ChangeNotifier {
  // private list of sites
  List<HistoricSite> _sites = [];

  // This is a getter for the private sites list which
  // should be used to access sites outside the class
  List<HistoricSite> get sites {
    return [..._sites];
  }

  // Add a new site to the List
  void addSite(HistoricSite site) {
    final newSite = HistoricSite(
        uid: DateTime.now().toString(),
        siteName: site.siteName,
        siteDesc: site.siteDesc,
        siteAccess: site.siteAccess,
        latitude: site.latitude,
        longitude: site.longitude,
        siteSize: site.siteSize,
        image: site.image);

    _sites.add(newSite);
    notifyListeners();
  }
}
