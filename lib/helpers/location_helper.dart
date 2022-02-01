import 'dart:convert';
import 'package:http/http.dart' as http;

import '../auth/secret.dart';

class LocationHelper {
  // This API generates a url of a static map based on location and zoom provided with a marker of the location at lat,lng
  static String generateStaticMapPreview({double latitude, double longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${latitude},${longitude}&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  // This API will generate a Future which will return the address string at the given location.
  static Future<String> getPositionAddress(
      double latitude, double lonitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$lonitude&amp&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    print(json.decode(response.body)['results'][0]);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }
}