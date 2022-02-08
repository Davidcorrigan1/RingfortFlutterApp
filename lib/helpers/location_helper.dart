import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

import '../auth/secret.dart';

class LocationHelper {
  // This API generates a url of a static map based on location and zoom provided with a marker of the location at lat,lng
  static String generateStaticMapPreview({double latitude, double longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${latitude},${longitude}&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  // This API will generate a Future which will return the address Map for the given location.
  // This Map will have 'address', 'county' and 'province'.
  static Future<Map<String, String>> getLatLngPositionAddress(
      double latitude, double lonitude) async {
    // define the counties in eacg province
    var leinster = ['WX','WW','KK','LH','LD','MH','OY','LS','CW','KE','D','WH'];
    var munster = ['KY', 'C', 'L', 'W', 'CE', 'T'];
    var connaght = ['MO', 'G', 'SO', 'LM', 'RN'];
    var ulster = ['DL', 'CN', 'Northern Ireland'];

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$lonitude&amp&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    final responseMap = json.decode(response.body)['results'][0];
    var addressMap = <String, String>{};
    addressMap['address'] = responseMap['formatted_address'].toString();

    // Determine the county and province from the address returned,
    for (int i = 0; i < 5; i++) {
      if (responseMap['address_components'][i]['types'][0] != null) {
        if (responseMap['address_components'][i]['types'][0] ==
            'administrative_area_level_1') {
          addressMap['county'] =
              responseMap['address_components'][i]['long_name'].toString();
          print(responseMap['address_components'][i]['short_name']);
          if (leinster
              .contains(responseMap['address_components'][i]['short_name'])) {
            addressMap['province'] = 'Leinster';
          } else if (munster
              .contains(responseMap['address_components'][i]['short_name'])) {
            addressMap['province'] = 'Munster';
          } else if (connaght
              .contains(responseMap['address_components'][i]['short_name'])) {
            addressMap['province'] = 'Connaght';
          } else if (ulster
              .contains(responseMap['address_components'][i]['short_name'])) {
            addressMap['province'] = 'Ulster';
          } else {
            addressMap['province'] = 'Ulster';
          }
        }
      }
    }
    print(addressMap);
    return addressMap;
  }
}
