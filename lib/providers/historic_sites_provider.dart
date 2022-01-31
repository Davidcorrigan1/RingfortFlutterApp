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

  


}
