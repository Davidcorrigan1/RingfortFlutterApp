import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../helpers/location_helper.dart';
import '../screens/maps_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectSiteLocationHander;

  // Constructor for the LocationInput class take a reference to a
  // function which will be called to save the location picked here
  const LocationInput(
    this.onSelectSiteLocationHander,
  );

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LocationData _currentLocation;
  double _userSelectedLatitude;
  double _userSelectedLongitude;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  String _mapImageUrl;

  void _showPreview(double latitude, double longitude) {
    final staticMapImageURL = LocationHelper.generateStaticMapPreview(
        longitude: longitude, latitude: latitude);

    setState(() {
      _mapImageUrl = staticMapImageURL;
    });
  }

  Future<void> _getCurrentLocation() async {
    _currentLocation = await Location().getLocation();

    _showPreview(_currentLocation.latitude, _currentLocation.longitude);

    _userSelectedLatitude = _currentLocation.latitude;
    _userSelectedLongitude = _currentLocation.longitude;

    // Call the passed in function to save the location
    widget.onSelectSiteLocationHander(
        _userSelectedLatitude, _userSelectedLongitude);
  }

  Future<Void> _selectPositionOnMap(double latitude, double longitude) async {
    final LatLng selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapsScreen(latitude, longitude, true),
      ),
    );
    if (selectedLocation == null) {
      return null;
    }
    // Now we can set the location the user picked and show a static
    // preview of the new location on the add screen.
    _userSelectedLatitude = selectedLocation.latitude;
    _userSelectedLongitude = selectedLocation.longitude;
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);

    // Call the passed in function to save the location
    widget.onSelectSiteLocationHander(
        selectedLocation.latitude, selectedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: Colors.grey),
          ),
          child: _mapImageUrl == null
              ? CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )
              : Image.network(
                  _mapImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              print(_currentLocation.latitude);
              _selectPositionOnMap(
                  _userSelectedLatitude, _userSelectedLongitude);
            },
            icon: Icon(Icons.map),
            label: Text('Select Different Location'),
          ),
        )
      ],
    );
  }
}
