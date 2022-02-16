import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/models/historic_site.dart';

import '../providers/historic_sites_provider.dart';
import '../helpers/map_helper.dart';

class MapOverviewScreen extends StatefulWidget {
  static const routeName = '/map-overview';

  @override
  _MapOverviewScreenState createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends State<MapOverviewScreen> {
  var initFirst = true;
  MapType _selectMapType = MapType.normal;
  Set<Marker> _markers = {};
  List<LatLng> _points = [];
  Marker _marker;
  List<HistoricSite> _filteredSites = [];
  List<HistoricSite> _sites = [];
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";
  GoogleMapController _myController;

  // Before the Widget builds do a refresh of the site list in the
  // provider from Firebase.
  @override
  void didChangeDependencies() {
    if (initFirst) {
      Provider.of<HistoricSitesProvider>(context, listen: false)
          .fetchAndSetRingforts();
    }
    initFirst = false;
    super.didChangeDependencies();
  }

  // This method is called by the FutureBuilder widget.
  // It calls the HistoricSitesProvider to refresh the site list from Firebase
  // and then retrieves the list into this class
  // If there is a filter seach term entered it will filter the results to show.
  Future<void> _retrieveSiteandMarkers(BuildContext context) async {
    _sites =
        await Provider.of<HistoricSitesProvider>(context, listen: false).sites;

    // Filter the sites based on the search criteria
    if (searchQuery.isEmpty || searchQuery == null) {
      _filteredSites = _sites;
    } else {
      _filteredSites = _sites.where((ringfort) {
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
    }

    // Get the markers and the bound points for the filtered sites
    _markers = {};
    _points = [];
    _filteredSites.forEach((site) {
      _marker = Marker(
        markerId: MarkerId('${site.uid}'),
        position: LatLng(site.latitude, site.longitude),
        infoWindow: InfoWindow(title: site.siteName),
      );
      _markers.add(_marker);
      _points.add(LatLng(site.latitude, site.longitude));
    });
  }

  // Based on https://stackoverflow.com/questions/58908968/how-to-implement-a-flutter-search-app-bar
  // This method returns a Widget of TextField which is used to enter
  // the search term. It will be displayed in the toolbar if the
  // search icon is pressed. It triggers the updateSearchQuery method once
  // typing happen in the field. This triggers the state variable searchQuery
  // to be updated and triggers a rebuild. The rebuild will trigger the
  // Future builder which retrives the data and performs the filtering.
  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Ringforts...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  // This method returns a Widget of an 'X' icon in the toolbar if isSearching
  // is true. If the search text input field is empty it will clear the text
  // on pressing it. It the search text input is already empty it will pop
  // the stack clearing the search input field.
  // If isSearching is not true it returns the search icon and the add Ringfort
  // Widget. (This is the default before the search icon is pressed.)
  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    // This is
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  // This method is triggered when the search icon is pressed. It adds the
  // local history entry, which when 'pop' which trigger the _stopSearching method.
  // THe isSearching state variable is also set and rebuild triggered.
  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  // This method is triggered when typing starts in the search field.
  // It sets the state variable searchQuery and triggers a rebuild of the
  // widget tree. This will trigger the FutureBuilder to trigger in the
  // Widget tree and retrieve the ringforts and filter with searchQuery.
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  // Triggered when the 'X' is pressed in search bar. Clears the filter
  // state variable searchQuery and triggers a rebuild.
  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  // Clears the search text field in toolbar and the searchQuery field.
  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  // Build a Text Widget for the Normal Screen title.
  Widget _buildTitle(BuildContext context) {
    return Text('Map Overview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
      ),
      body: FutureBuilder(
        future: _retrieveSiteandMarkers(context),
        builder: (context, snapShot) => snapShot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _filteredSites.length > 0
                ? Stack(children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(52.55444, -6.2376), zoom: 16),
                      onTap: null,
                      mapType: _selectMapType,
                      markers: _filteredSites.length <= 0 ? {} : _markers,
                      onMapCreated: (controller) {
                        _myController = controller;
                        // If there is only 1 ringfort then zoom differently
                        if (_filteredSites.length == 1) {
                          controller.animateCamera(CameraUpdate.newLatLngZoom(
                              LatLng(_filteredSites[0].latitude,
                                  _filteredSites[0].longitude),
                              15));
                        } else {
                          controller.animateCamera(
                            CameraUpdate.newLatLngBounds(
                                MapHelper.boundsFromLatLngList(_points), 45),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            // Trigger a switch in the Map type depending on the
                            // current status, and trigger re-build to show new map.
                            setState(() {
                              _selectMapType = _selectMapType == MapType.normal
                                  ? MapType.satellite
                                  : MapType.normal;
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          backgroundColor: Theme.of(context).backgroundColor,
                          child: const Icon(
                            Icons.map,
                          ),
                        ),
                      ),
                    )
                  ])
                : Center(
                    child: Text('No Matching Ringforts'),
                  ),
      ),
    );
  }
}
