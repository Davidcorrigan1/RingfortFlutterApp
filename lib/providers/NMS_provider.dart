import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../firebase/firebaseDB.dart';
import '../models/NMS_data.dart';

class NMSProvider with ChangeNotifier {
  var firebaseDB = FirebaseDB();

  List<NMSData> _nmsData = [];
  List<NMSData> _filteredNmsData = [];

  List<NMSData> get nmsData {
    return [..._nmsData];
  }

  List<NMSData> get filteredNmsData {
    return [..._filteredNmsData];
  }

  //-------------------------------------------------------------
  // Returns the latest NMS data from Firestore and update
  // the local List and then notify comsumer it's changed
  //-------------------------------------------------------------
  Future<void> fetchAndSetNMSRingforts() async {
    final List<NMSData> loadedSites = [];
    var snapshot = await firebaseDB.fetchNMSSites();

    final documents = snapshot.docs.map((docs) => docs.data()).toList();
    documents.forEach((site) {
      NMSData ringfort = NMSData.fromJson(site);
      loadedSites.add(ringfort);
    });
    _nmsData = loadedSites;
    notifyListeners();
  }

//-------------------------------------------------------------
  // This method will return the list of filtered NMS sites
  // based on current location if _showLocal flag set.
  //-------------------------------------------------------------
  void setFilteredNMSSites(bool _showLocal, LatLng currentLocation) {
    List<NMSData> _localSites = [];
    // First it checks if locals sites are requested. If so then it
    // checks the distance between the passed in current location and
    // each of the saved sites and returns those < 50km.
    if (_showLocal) {
      _localSites = _nmsData.where((site) {
        return (Geolocator.distanceBetween(site.latitude, site.longitude,
                currentLocation.latitude, currentLocation.longitude) <
            50000);
      }).toList();
      _filteredNmsData = [..._localSites];
    } else {
      _filteredNmsData = [..._nmsData];
    }

    notifyListeners();
  }
}
