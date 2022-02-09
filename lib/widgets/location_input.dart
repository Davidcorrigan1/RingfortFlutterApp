import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../helpers/location_helper.dart';
import '../screens/maps_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectSiteLocationHander;
  final LatLng passedInLocation;

  // Constructor for the LocationInput class take a reference to a
  // function which will be called to save the location picked here
  const LocationInput(
    this.onSelectSiteLocationHander,
    this.passedInLocation,
  );

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LocationData _currentLocation;
  double _userSelectedLatitude;
  double _userSelectedLongitude;
  String _mapImageUrl;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  // This will call google API to get static map URL. It uses
  // setState to set the variable so to trigger a rebuild and show map.
  void _showPreview(double latitude, double longitude) {
    final staticMapImageURL = LocationHelper.generateStaticMapPreview(
        longitude: longitude, latitude: latitude);

    setState(() {
      _mapImageUrl = staticMapImageURL;
    });
  }

  // This method will use a google location API to retrieve the users
  // current location. And then use this to get a static map URL of that
  // location and trigger a re-build to display.
  // It will pass this location back to the AddRingfortScreen.
  Future<void> _getCurrentLocation() async {
    if (widget.passedInLocation == null) {
      _currentLocation = await Location().getLocation();
      _showPreview(_currentLocation.latitude, _currentLocation.longitude);
      _userSelectedLatitude = _currentLocation.latitude;
      _userSelectedLongitude = _currentLocation.longitude;
    } else {
      _showPreview(
          widget.passedInLocation.latitude, widget.passedInLocation.longitude);
      _userSelectedLatitude = widget.passedInLocation.latitude;
      _userSelectedLongitude = widget.passedInLocation.longitude;
    }

    // Call the passed in function to save the location
    widget.onSelectSiteLocationHander(
        _userSelectedLatitude, _userSelectedLongitude);
  }

  // This method Push the MapsScreen onto the stack. This will trigger that
  // screen centred at the location passed into method. It awaits the screen
  // to be Pop(ed) back with the selected location. It uses this selected
  // location to show a preview on the AddRingfortScreen. It also passes
  // this location back to the AddRingfortScreen.
  Future<void> _selectPositionOnMap(double latitude, double longitude) async {
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
    return null;
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
              ? Center(
                  child: CircularProgressIndicator(),
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
