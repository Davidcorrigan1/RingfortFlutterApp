import 'package:flutter/foundation.dart';

class UserData {
  String uid;
  String email;
  List<String> favourites;
  bool adminUser;

  // Class constructor
  UserData(
      {@required this.uid,
      @required this.email,
      this.favourites,
      this.adminUser = false});

  // A factory constructor to create Ringfort object from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    print('json: $json');

    List<String> favourites = [...json['favourites']];

    return UserData(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      favourites: favourites,
      adminUser: json['adminUser'],
    );
  }

  // Function to turn Ringfort object to a Map of key values pairs
  Map<String, dynamic> toJson() => _userToJson(this);
}

// Convert a historicSite object into a map of key/value pairs.
Map<String, dynamic> _userToJson(UserData instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'favourites': instance.favourites,
      'adminUser': instance.adminUser,
    };
