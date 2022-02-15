import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  // with thanks to https://medium.com/theotherdev-s/getting-to-know-flutter-google-maps-integration-f0275d5aafa2
  // This calculated the bounds of a lat lng rectangle which encompasses all the points passed in.
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    var firstTime = true;

    for (LatLng latlng in list) {
      if (firstTime) {
        firstTime = false;
        x0 = x1 = latlng.latitude;
        y0 = y1 = latlng.longitude;
      } else {
        if (latlng.latitude > (x1 ?? 0)) x1 = latlng.latitude;
        if (latlng.latitude < x0) x0 = latlng.latitude;
        if (latlng.longitude > (y1 ?? 0)) y1 = latlng.longitude;
        if (latlng.longitude < (y0 ?? double.infinity)) y0 = latlng.longitude;
      }
    }
    return LatLngBounds(
        southwest: LatLng(x0 ?? 0, y0 ?? 0),
        northeast: LatLng(x1 ?? 0, y1 ?? 0));
  }
}
