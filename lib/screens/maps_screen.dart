import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final bool isSelecting;

  const MapsScreen(this.initialLatitude, this.initialLongitude,
      [this.isSelecting = false]);

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  LatLng _userSelectedLocation;
  MapType _selectMapType = MapType.normal;

  // Set the user selected position for the marker and
  // trigger a re-build to show it.
  void _selectLocation(LatLng position) {
    setState(() {
      _userSelectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          // Only add the Icon button if we are in selecting mode
          if (widget.isSelecting)
            IconButton(
              // Only allow it to be pressed if user has picked a location
              onPressed: _userSelectedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_userSelectedLocation);
                    },
              icon: Icon(Icons.save),
            )
        ],
      ),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialLatitude, widget.initialLongitude),
              zoom: 16),
          onTap: widget.isSelecting ? _selectLocation : null,
          mapType: _selectMapType,
          markers: _userSelectedLocation == null
              ? {}
              : {
                  Marker(
                      markerId: MarkerId('m1'), position: _userSelectedLocation)
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
      ]),
    );
  }
}
