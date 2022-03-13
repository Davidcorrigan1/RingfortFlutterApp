import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_switch/flutter_switch.dart';
 
import '../models/user_data.dart';
import '../widgets/app_drawer.dart';
import '../widgets/map_card.dart';
import '../providers/historic_sites_provider.dart';
import '../providers/user_provider.dart';
import '../helpers/map_helper.dart';

class MapOverviewScreen extends StatefulWidget {
  static const routeName = '/map-overview';

  @override
  _MapOverviewScreenState createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends State<MapOverviewScreen> {
  var _initFirst = true;
  var _isLoading = false;
  var _isMapVisible = false;
  var _showFavourites = false;
  var _showLocal = false;
  User user;
  UserData userData;
  MapType _selectMapType = MapType.normal;
  Set<Marker> _markers = {};
  List<LatLng> _points = [];
  Marker _marker;
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  bool _serviceEnabled;
  LocationPermission _locationPermission;
  String searchQuery = "";
  GoogleMapController _myController;
  Position _currentLocation;
  final ItemScrollController itemScrollController = ItemScrollController();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  // Before the Widget builds do a refresh of the site list in the
  // provider from Firebase.
  @override
  void didChangeDependencies() {
    if (_initFirst) {
      _isLoading = true;
      user = Provider.of<User>(context, listen: false);
      Provider.of<HistoricSitesProvider>(context, listen: false)
          .fetchAndSetRingforts()
          .then((value) => _retrieveSiteandMarkers(context))
          .then((value) {
        if (user != null) {
          Provider.of<UserProvider>(context, listen: false)
              .getCurrentUserData(user.uid)
              .then((value) {
            setState(() {
              userData = value;
              _isLoading = false;
            });
          }).then((value) {
            // No need to wait on the current location before setting loading to
            // false and displaying the map. But it is needed for the local ringforts
            // button.
            getCurrentLocation();
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
    _initFirst = false;
    super.didChangeDependencies();
  }

  // Gets the users current location
  Future<void> getCurrentLocation() async {
    _serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    _locationPermission = await _geolocatorPlatform.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await _geolocatorPlatform.requestPermission();
      if (_locationPermission != LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (_locationPermission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    try {
      _currentLocation = await _geolocatorPlatform.getCurrentPosition();
    } catch (error) {
      print('Getting location: $error');
    }
  }

  // It calls the HistoricSitesProvider to refresh the site list from Firebase
  // and then retrieves the list into this class
  // If there is a filter search term entered it will filter the results to show.
  // It also takes a favourites flag and usedata which had the users favourites.
  // So if _showFavourites set to true will only show those ringforts which
  // match the users selected favs.
  void _retrieveSiteandMarkers(BuildContext context) {
    // Filter the sites based on the search criteria
    LatLng _currentLatLng;
    if (_currentLocation != null) {
      _currentLatLng =
          LatLng(_currentLocation.latitude, _currentLocation.longitude);
    }

    Provider.of<HistoricSitesProvider>(context, listen: false).setFilteredSites(
        searchQuery, _showFavourites, _showLocal, _currentLatLng, userData);

    var _filteredSites =
        Provider.of<HistoricSitesProvider>(context, listen: false)
            .filteredSites;

    // Get the markers and the bound points for the filtered sites
    _markers = {};
    _points = [];
    _filteredSites.forEach((site) {
      _marker = Marker(
        markerId: MarkerId('${site.uid}'),
        position: LatLng(site.latitude, site.longitude),
        infoWindow: InfoWindow(title: site.siteName),
        onTap: () {
          {
            var index = _filteredSites.indexOf(site);
            // See https://pub.dev/packages/scrollable_positioned_list
            itemScrollController.scrollTo(
              index: index,
              duration: Duration(
                seconds: 1,
              ),
            );
          }
          ;
        },
      );
      _markers.add(_marker);
      _points.add(LatLng(site.latitude, site.longitude));
    });
    // Pointing the Map camera at the markers which match the filter using
    // the map controller. Not doing this the first time as onMapCreated will
    // do it. But will do subsequently if there is a visible marker in the map.
    // If there is only 1 matching marker then the zoom needs to be handled
    // differently so as to not zoom too much.
    if (_markers.length > 0) {
      if (!_initFirst &&
          _myController != null &&
          _markers.first.markerId != null) {
        if (_myController.isMarkerInfoWindowShown(_markers.first.markerId) !=
            null) {
          if (_filteredSites.length > 1) {
            _myController.animateCamera(
              CameraUpdate.newLatLngBounds(
                  MapHelper.boundsFromLatLngList(_points), 45),
            );
          } else {
            _myController.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(_filteredSites[0].latitude, _filteredSites[0].longitude),
                15));
          }
        }
      }
    }
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
      // show the favourites ion if the user is logged on.
      user != null
          // The FlutterSwitch widget from an imported package Flutter_Switch
          // Wrapping in padding to move away from right side
          ? Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FlutterSwitch(
                value: _showFavourites,
                height: 22,
                width: 44,
                padding: 0,
                inactiveColor: Theme.of(context).backgroundColor,
                inactiveIcon: Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                ),
                activeColor: Theme.of(context).primaryColorDark,
                activeIcon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onToggle: (value) {
                  setState(() {
                    _showFavourites = value;
                    _retrieveSiteandMarkers(context);
                  });
                },
              ),
            )
          : Container(),
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
      _retrieveSiteandMarkers(context);
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
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Provider.of<HistoricSitesProvider>(context, listen: false)
                      .filteredSites
                      .length >
                  0
              ? Stack(children: [
                  Consumer<HistoricSitesProvider>(
                    // Using AnimatedOpacity as a workaround for a Google Maps issue.
                    // Flutter: see https://github.com/flutter/flutter/issues/39797
                    // and suggested workaround by zubairehman.
                    builder: (context, historicSites, child) => AnimatedOpacity(
                      curve: Curves.fastOutSlowIn,
                      opacity: _isMapVisible ? 1.0 : 0,
                      duration: Duration(microseconds: 600),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(52.55444, -6.2376), zoom: 16),
                        // positioning the Horizonal listview on marker selction.
                        // FInd index of marker which matches the LatLng selected.
                        onTap: null,
                        mapType: _selectMapType,
                        markers: historicSites.filteredSites.length <= 0
                            ? {}
                            : _markers,
                        onMapCreated: (controller) {
                          _myController = controller;
                          Future.delayed(
                              const Duration(milliseconds: 550),
                              () => setState(() {
                                    // If there is only 1 ringfort then zoom differently
                                    if (historicSites.filteredSites.length ==
                                        1) {
                                      controller.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                              LatLng(
                                                  historicSites.filteredSites[0]
                                                      .latitude,
                                                  historicSites.filteredSites[0]
                                                      .longitude),
                                              15));
                                    } else {
                                      controller.animateCamera(
                                        CameraUpdate.newLatLngBounds(
                                            MapHelper.boundsFromLatLngList(
                                                _points),
                                            45),
                                      );
                                    }
                                    _isMapVisible = true;
                                  }));
                        },
                      ),
                    ),
                  ),
                  //-----------------------------------------------------------
                  // Stacked Floating action button
                  //-----------------------------------------------------------
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
                  ),
                  //-----------------------------------------------------------
                  // Stacked Local Ringfort Selection Chip
                  //-----------------------------------------------------------
                  _currentLocation != null
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ChoiceChip(
                              label: Text('Local'),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              selectedColor: Theme.of(context).backgroundColor,
                              disabledColor: Theme.of(context).primaryColor,
                              elevation: 10,
                              selected: _showLocal,
                              onSelected: (val) {
                                // Trigger a switch in the Map type depending on the
                                // current status, and trigger re-build to show new map.
                                setState(() {
                                  _showLocal = val;
                                  _retrieveSiteandMarkers(context);
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                  //-----------------------------------------------------------
                  // Stacked Horizonal Scrolling list of sites
                  //-----------------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        child: Consumer<HistoricSitesProvider>(
                          builder: (context, historicSites, child) => historicSites
                                      .filteredSites.length >
                                  0
                              ? ScrollablePositionedList.builder(
                                  // See https://pub.dev/packages/scrollable_positioned_list
                                  itemScrollController: itemScrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: historicSites.filteredSites.length,
                                  itemBuilder: (ctx, index) => MapCard(
                                        uid: historicSites
                                            .filteredSites[index].uid,
                                        siteName: historicSites
                                            .filteredSites[index].siteName,
                                        siteDesc: historicSites
                                            .filteredSites[index].siteDesc,
                                        siteProvince: historicSites
                                            .filteredSites[index].province,
                                        siteCounty: historicSites
                                            .filteredSites[index].county,
                                        siteImage: historicSites
                                            .filteredSites[index].image,
                                        user: Provider.of<User>(context,
                                            listen: false),
                                      ))
                              : Center(
                                  child: Text('No matches'),
                                ),
                        ),
                      ),
                    ),
                  )
                ])
              : Center(
                  child: Text('No Matching Ringforts'),
                ),
    );
  }
}
