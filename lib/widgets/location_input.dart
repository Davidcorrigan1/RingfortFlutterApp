import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../helpers/location_helper.dart';

class LocationInput extends StatefulWidget {
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _mapImageUrl;

  Future<void> _getCurrentLocation() async {
    final currentLocation = await Location().getLocation();
    final currentLocStaticMapURL =
        await LocationHelper.generateStaticMapPreview(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude);
    // Using setState to update the map URL so that it triggers a rebuild of the Widget and displays the map
    setState(() {
      _mapImageUrl = currentLocStaticMapURL;
    });
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
              ? Text(
                  'No Location Chosen',
                  textAlign: TextAlign.center,
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
            onPressed: _getCurrentLocation,
            icon: Icon(Icons.map),
            label: Text('Update Location'),
          ),
        )
      ],
    );
  }
}
