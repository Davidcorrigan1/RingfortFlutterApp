import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/historic_sites_provider.dart';
import '../helpers/map_helper.dart';

class MapOverviewScreen extends StatefulWidget {
  static const routeName = '/map-overview';

  @override
  _MapOverviewScreenState createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends State<MapOverviewScreen> {
  MapType _selectMapType = MapType.normal;
  Set<Marker> _markers = {};
  List<LatLng> _points = [];
  Marker _marker;
  GoogleMapController _myController;

  @override
  void didChangeDependencies() {
    var ringforts =
        Provider.of<HistoricSitesProvider>(context, listen: false).sites;

    ringforts.forEach((site) {
      _marker = Marker(
        markerId: MarkerId('${site.uid}'),
        position: LatLng(site.latitude, site.longitude),
        infoWindow: InfoWindow(title: site.siteName),
      );
      _markers.add(_marker);
      _points.add(LatLng(site.latitude, site.longitude));
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ringfort Overview'),
        actions: [
          // Only add the Icon button if we are in selecting mode
        ],
      ),
      body: Consumer<HistoricSitesProvider>(
        builder: (context, historicSites, child) => Stack(children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(52.55444, -6.2376), zoom: 16),
            onTap: null,
            mapType: _selectMapType,
            markers: historicSites.sites.length <= 0 ? {} : _markers,
            onMapCreated: (controller) {
              _myController = controller;
              setState(() {
                controller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                      MapHelper.boundsFromLatLngList(_points), 45),
                );
              });
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
      ),
    );
  }
}
