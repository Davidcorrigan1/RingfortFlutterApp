import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/user_data.dart';
import '../widgets/app_drawer.dart';
import '../providers/NMS_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/nms_card.dart';
import '../helpers/map_helper.dart';

class NmsOverviewScreen extends StatefulWidget {
  static const routeName = '/nms-overview';

  @override
  _NmsOverviewScreenState createState() => _NmsOverviewScreenState();
}

class _NmsOverviewScreenState extends State<NmsOverviewScreen> {
  var _initFirst = true;
  var _isLoading = false;
  var _isMapVisible = false;
  var _showLocal = false;
  String onTapUID;
  User user;
  UserData userData;
  MapType _selectMapType = MapType.normal;
  Set<Marker> _markers = {};
  List<LatLng> _points = [];
  Marker _marker;
  bool _serviceEnabled;
  LocationPermission _locationPermission;
  GoogleMapController _myController;
  Position _currentLocation;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final ItemScrollController itemScrollController1 = ItemScrollController();

  // Before the Widget builds do a refresh of the NMS list in the
  // provider from Firebase.
  @override
  void didChangeDependencies() {
    print('NMSScreen: didChangeDependencies ');
    if (_initFirst) {
      _isLoading = true;
      user = Provider.of<User>(context, listen: false);
      Provider.of<NMSProvider>(context, listen: false)
          .fetchAndSetNMSRingforts()
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

  @override
  void dispose() {
    _myController = null;
    super.dispose();
  }

  // Gets the users current location
  Future<void> getCurrentLocation() async {
    _serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    _locationPermission = await _geolocatorPlatform.requestPermission();
    print('permission: $_locationPermission');

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
      _geolocatorPlatform.getCurrentPosition().then((value) {
        setState(() {
          _currentLocation = value;
        });
      });
    } catch (error) {
      print('Getting location: $error');
    }
  }

  // It calls the NMSProvider to refresh the NMS list from Firebase
  // and then retrieves the list into this class
  // If there is a show local flaf set it will filter the sites to within
  // 50km of the current location
  void _retrieveSiteandMarkers(BuildContext context) {
    print('NMS: Run _retrieveSiteandMarkers ');
    // Filter the sites based on the search criteria
    LatLng _currentLatLng;
    if (_currentLocation != null) {
      _currentLatLng =
          LatLng(_currentLocation.latitude, _currentLocation.longitude);
    }

    Provider.of<NMSProvider>(context, listen: false)
        .setFilteredNMSSites(_showLocal, _currentLatLng);

    var _nmsSites =
        Provider.of<NMSProvider>(context, listen: false).filteredNmsData;

    // Get the markers and the bound points for the filtered sites
    _markers = {};
    _points = [];
    _nmsSites.forEach((site) {
      if (site.latitude > 51.417 &&
          site.latitude < 55.389 &&
          site.longitude > -10.12 &&
          site.longitude < -5.6) {
        _marker = Marker(
          markerId: MarkerId('${site.uid}'),
          position: LatLng(site.latitude, site.longitude),
          infoWindow: InfoWindow(title: site.siteName, onTap: () {}),
          onTap: () {
            var index = _nmsSites.indexOf(site);
            // See https://pub.dev/packages/scrollable_positioned_list
            itemScrollController1.scrollTo(
              index: index,
              duration: Duration(
                seconds: 1,
              ),
            );
          },
        );
        _markers.add(_marker);
        _points.add(LatLng(site.latitude, site.longitude));
      }
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
          if (_nmsSites.length > 1) {
            _myController.animateCamera(
              CameraUpdate.newLatLngBounds(
                  MapHelper.boundsFromLatLngList(_points), 45),
            );
          } else {
            _myController.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(_nmsSites[0].latitude, _nmsSites[0].longitude), 15));
          }
        }
      }
    }
  }

  // Build a Text Widget for the Normal Screen title.
  Widget _buildTitle(BuildContext context) {
    return Text('National Monument Data Overview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildTitle(context), actions: <Widget>[]),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Provider.of<NMSProvider>(context, listen: false)
                      .filteredNmsData
                      .length >
                  0
              ? Stack(children: [
                  Consumer<NMSProvider>(
                    // Using AnimatedOpacity as a workaround for a Google Maps issue.
                    // Flutter: see https://github.com/flutter/flutter/issues/39797
                    // and suggested workaround by zubairehman.
                    builder: (context, nmsData, child) => AnimatedOpacity(
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
                        markers:
                            nmsData.filteredNmsData.length <= 0 ? {} : _markers,
                        onMapCreated: (controller) {
                          _myController = controller;
                          print('MapsScreen: onMapCreated executed');
                          Future.delayed(
                              const Duration(milliseconds: 550),
                              () => setState(() {
                                    // If there is only 1 ringfort then zoom differently
                                    if (nmsData.filteredNmsData.length == 1) {
                                      controller.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                              LatLng(
                                                  nmsData.filteredNmsData[0]
                                                      .latitude,
                                                  nmsData.filteredNmsData[0]
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
                        child: Consumer<NMSProvider>(
                          builder: (context, nmsSites, child) => nmsSites
                                      .filteredNmsData.length >
                                  0
                              ? ScrollablePositionedList.builder(
                                  // See https://pub.dev/packages/scrollable_positioned_list
                                  itemScrollController: itemScrollController1,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: nmsSites.filteredNmsData.length,
                                  itemBuilder: (ctx, index) => NMSCard(
                                      uid: nmsSites.filteredNmsData[index].uid,
                                      siteName: nmsSites
                                          .filteredNmsData[index].siteName,
                                      siteDesc: nmsSites
                                          .filteredNmsData[index].siteDesc))
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
