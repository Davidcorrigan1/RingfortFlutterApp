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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(widget.initialLatitude, widget.initialLongitude),
            zoom: 16),
        onTap: widget.isSelecting ? _selectLocation : null,
        markers: _userSelectedLocation == null
            ? {}
            : {
                Marker(
                    markerId: MarkerId('m1'), position: _userSelectedLocation)
              },
      ),
    );
  }
}
